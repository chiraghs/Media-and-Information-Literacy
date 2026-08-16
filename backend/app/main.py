import json
import random
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List

from .database import engine, get_db, Base
from . import models, schemas

# Initialize database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="MIL Nexus API",
    description="Backend API services for the UNESCO Youth Initiative 2026 MIL Nexus platform.",
    version="1.0.0"
)

# Enable CORS for frontend requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {
        "title": "MIL Nexus API Hub",
        "description": "UNESCO Youth Initiative 2026 Services",
        "status": "online"
    }

@app.get("/api/stats", response_model=schemas.SystemStats)
def get_system_stats(db: Session = Depends(get_db)):
    teams_count = db.query(models.Team).count()
    members_count = db.query(models.Member).count()
    scans_count = db.query(models.Claim).count()
    evals_count = db.query(models.JuryEvaluation).count()
    
    # Calculate a baseline MIL score
    avg_mil_score = 75
    if evals_count > 0:
        avg_score = db.query(models.JuryEvaluation.consensus_score).all()
        if avg_score:
            avg_mil_score = int(sum(s[0] for s in avg_score) / len(avg_score) * 10)

    return {
        "total_teams": teams_count,
        "total_members": members_count,
        "total_scans": scans_count,
        "total_evaluations": evals_count,
        "avg_mil_score": avg_mil_score
    }

@app.post("/api/register", response_model=schemas.TeamOut, status_code=status.HTTP_201_CREATED)
def register_team(team_data: schemas.TeamCreate, db: Session = Depends(get_db)):
    # Support edit/overwrite to avoid unique constraint errors during iterative UI tests
    existing_team = db.query(models.Team).filter(models.Team.name == team_data.name).first()
    if existing_team:
        # Delete old members and update focus track
        db.query(models.Member).filter(models.Member.team_id == existing_team.id).delete()
        existing_team.track = team_data.track
        existing_team.modality = team_data.modality
        db.commit()
        db.refresh(existing_team)
        
        # Add new members
        for m_data in team_data.members:
            db_member = models.Member(
                team_id=existing_team.id,
                name=m_data.name,
                age=m_data.age
            )
            db.add(db_member)
        db.commit()
        db.refresh(existing_team)
        return existing_team

    # Create new team
    new_team = models.Team(
        name=team_data.name,
        track=team_data.track,
        modality=team_data.modality
    )
    db.add(new_team)
    db.commit()
    db.refresh(new_team)

    # Add members
    for m_data in team_data.members:
        db_member = models.Member(
            team_id=new_team.id,
            name=m_data.name,
            age=m_data.age
        )
        db.add(db_member)
    db.commit()
    db.refresh(new_team)
    
    return new_team

@app.post("/api/scan", response_model=schemas.ClaimOut)
def scan_claim(claim_data: schemas.ClaimCreate, db: Session = Depends(get_db)):
    text = claim_data.claim_text.strip()
    if not text:
        raise HTTPException(status_code=400, detail="Statement text cannot be empty.")

    clickbait = 10.0
    bias = 15.0
    source_val = 80.0
    flags = []

    # Lexical heuristics
    clickbait_words = ["shocking", "coverup", "revealed", "unbelievable", "leaked", "steal", "stealing", "overnight", "!!!", "expose"]
    for word in clickbait_words:
      if word in text.lower():
        clickbait += 15.0
        bias += 10.0

    # Upper case analysis
    upper_case_chars = len([c for c in text if c.isupper()])
    total_alpha_chars = len([c for c in text if c.isalpha()])
    if total_alpha_chars > 10 and (upper_case_chars / total_alpha_chars) > 0.25:
      clickbait += 20.0
      bias += 15.0
      flags.append({
        "type": "warning",
        "text": "High Capitalization detected: Typically used to force attention."
      })

    # Citations numbers
    has_numbers = any(c.isdigit() for c in text)
    if not has_numbers:
      source_val -= 30.0
      flags.append({
        "type": "danger",
        "text": "No numeric references or statistics: Indicates general rumor claiming."
      })
    else:
      source_val += 10.0

    # Academic citations match
    official_words = ["report", "institute", "research", "stable", "official", "data", "published"]
    has_official = any(word in text.lower() for word in official_words)
    if has_official:
      bias -= 20.0
      clickbait -= 25.0
      source_val += 15.0
      flags.append({
        "type": "success",
        "text": "Academic/Factual vocabulary match: Objective reporting framing."
      })
    else:
      flags.append({
        "type": "warning",
        "text": "Sensational framing: Adjectives outnumber concrete source citations."
      })

    # Constraints
    clickbait = max(0.0, min(100.0, clickbait))
    bias = max(0.0, min(100.0, bias))
    source_val = max(0.0, min(100.0, source_val))

    # Persist claim
    db_claim = models.Claim(
        claim_text=text,
        bias_risk=bias,
        clickbait_index=clickbait,
        source_validity=source_val,
        flags_json=json.dumps(flags)
    )
    db.add(db_claim)
    db.commit()
    db.refresh(db_claim)

    return db_claim

@app.post("/api/jury-simulate", response_model=schemas.JuryEvaluationOut)
def simulate_jury_evaluation(eval_data: schemas.JuryEvaluationCreate, db: Session = Depends(get_db)):
    title = eval_data.project_title.strip()
    desc = eval_data.project_desc.strip()

    if not title or not desc:
        raise HTTPException(status_code=400, detail="Title and description cannot be empty.")

    # Base ratings
    consistency = 7.0
    clarity = 7.0
    innovation = 7.0
    feasibility = 6.5
    impact = 7.0

    # Check length
    if len(desc) > 100:
      clarity += 1.0
      feasibility += 1.0
    
    # Check keywords
    keywords = ["sandbox", "game", "prototype", "expose", "decentralized", "pwa", "toolkit", "verify"]
    for word in keywords:
      if word in desc.lower():
        innovation += 0.4
        impact += 0.3

    if any(k in title.lower() for k in ["nexus", "truthcraft", "spotcheck"]):
      consistency += 1.5
      innovation += 0.8

    # Limits
    consistency = min(10.0, consistency)
    clarity = min(10.0, clarity)
    innovation = min(10.0, innovation)
    feasibility = min(10.0, feasibility)
    impact = min(10.0, impact)

    consensus = round((consistency + clarity + innovation + feasibility + impact) / 5.0, 1)

    scores_dict = {
        "theme": round(consistency, 1),
        "clarity": round(clarity, 1),
        "innovation": round(innovation, 1),
        "feasibility": round(feasibility, 1),
        "impact": round(impact, 1)
    }

    # Juror feedbacks matching keywords
    comments = {
      "juror1": [
        f"Strong presentation for '{title}'. The concept targets critical thinking skills, matching the core objectives of UNESCO's 2026 track.",
        "Highly consistent with the AI & MIL track. The prototype framework seems very practical and ready for testing."
      ],
      "juror2": [
        "The project demonstrates solid localized impact. Community-based interventions that target chat network rumors are highly needed.",
        "Interesting proposal. The integration of lateral reading prompts in the verification workflow has high educational value."
      ],
      "juror3": [
        "Feasibility is solid, especially since the team outline covers 2-6 roles. Ensure the final 3-minute video pitch focuses strongly on youth change agents.",
        "The scalability potential looks good. Suggest detailing how regional radio networks can replicate these guidelines."
      ]
    }

    r_idx = random.randint(0, 1)
    reviews_list = [
        {"name": "Juror 1 (Europe Office)", "review": comments["juror1"][r_idx]},
        {"name": "Juror 2 (Latin America Office)", "review": comments["juror2"][r_idx]},
        {"name": "Juror 3 (Asia-Pacific Office)", "review": comments["juror3"][r_idx]}
    ]

    # Save to db
    db_eval = models.JuryEvaluation(
        project_title=title,
        project_desc=desc,
        consensus_score=consensus,
        criteria_scores_json=json.dumps(scores_dict),
        juror_reviews_json=json.dumps(reviews_list)
    )
    db.add(db_eval)
    db.commit()
    db.refresh(db_eval)

    return db_eval
