import json
from datetime import datetime
from app.database import engine, SessionLocal, Base
from app import models

def seed_database():
    # Make sure tables exist
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    
    try:
        # Check if database is already seeded
        if db.query(models.Team).count() > 0:
            print("Database already contains data. Skipping seeding.")
            return

        print("Seeding SQLite database with mock MIL data...")

        # 1. Seed Teams & Members
        teams_data = [
            {
                "name": "Thessaloniki Pulse",
                "track": "Youth Engagement",
                "members": [
                    {"name": "Eleni Georgiou", "age": 22},
                    {"name": "Nikos Papadopoulos", "age": 24},
                    {"name": "Sofia Dimitriou", "age": 21}
                ]
            },
            {
                "name": "Cyber Shield",
                "track": "AI and MIL",
                "members": [
                    {"name": "Liam Andersson", "age": 23},
                    {"name": "Emma Nilsson", "age": 25}
                ]
            }
        ]

        for t in teams_data:
            team = models.Team(
                name=t["name"], 
                track=t["track"], 
                modality=t.get("modality", "Applications / Websites")
            )
            db.add(team)
            db.commit()
            db.refresh(team)

            for m in t["members"]:
                member = models.Member(team_id=team.id, name=m["name"], age=m["age"])
                db.add(member)
        
        # 2. Seed Mock Claims
        claims_data = [
            {
                "claim_text": "SHOCKING COVERUP! Elite billionaire robots steal all local high-paying tech jobs overnight. Unbelievable details leaked!!!",
                "bias_risk": 75.0,
                "clickbait_index": 90.0,
                "source_validity": 20.0,
                "flags": [
                    {"type": "warning", "text": "High Capitalization detected: Typically used to force attention."},
                    {"type": "danger", "text": "No numeric references or statistics: Indicates general rumor claiming."},
                    {"type": "warning", "text": "Sensational framing: Adjectives outnumber concrete source citations."}
                ]
            },
            {
                "claim_text": "A research report by the Global Tech Institute indicates that local employment figures in technology sectors remained stable, growing 4% year-over-year.",
                "bias_risk": 5.0,
                "clickbait_index": 0.0,
                "source_validity": 95.0,
                "flags": [
                    {"type": "success", "text": "Academic/Factual vocabulary match: Objective reporting framing."}
                ]
            }
        ]

        for c in claims_data:
            claim = models.Claim(
                claim_text=c["claim_text"],
                bias_risk=c["bias_risk"],
                clickbait_index=c["clickbait_index"],
                source_validity=c["source_validity"],
                flags_json=json.dumps(c["flags"])
            )
            db.add(claim)

        # 3. Seed Jury Evaluations
        evals_data = [
            {
                "project_title": "TruthCraft Sandbox",
                "project_desc": "TruthCraft is a browser-based interactive branching narrative comic that teaches deepfake spotting and metadata verification.",
                "consensus_score": 8.6,
                "criteria": {
                    "theme": 9.0,
                    "clarity": 8.0,
                    "innovation": 9.0,
                    "feasibility": 8.5,
                    "impact": 8.5
                },
                "reviews": [
                    {"name": "Juror 1 (Europe Office)", "review": "Highly consistent with the AI & MIL track. The prototype framework seems very practical and ready for testing."},
                    {"name": "Juror 2 (Latin America Office)", "review": "Interesting proposal. The integration of lateral reading prompts in the verification workflow has high educational value."},
                    {"name": "Juror 3 (Asia-Pacific Office)", "review": "Feasibility is solid, especially since the team outline covers 2-6 roles. Ensure the final 3-minute video pitch focuses strongly on youth change agents."}
                ]
            }
        ]

        for e in evals_data:
            evaluation = models.JuryEvaluation(
                project_title=e["project_title"],
                project_desc=e["project_desc"],
                consensus_score=e["consensus_score"],
                criteria_scores_json=json.dumps(e["criteria"]),
                juror_reviews_json=json.dumps(e["reviews"])
            )
            db.add(evaluation)

        db.commit()
        print("Database seeded successfully.")
        
    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
