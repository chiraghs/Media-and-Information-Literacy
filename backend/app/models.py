from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from .database import Base

class Team(Base):
    __tablename__ = "teams"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    track = Column(String, nullable=False)
    modality = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    members = relationship("Member", back_populates="team", cascade="all, delete-orphan")

class Member(Base):
    __tablename__ = "members"

    id = Column(Integer, primary_key=True, index=True)
    team_id = Column(Integer, ForeignKey("teams.id", ondelete="CASCADE"), nullable=False)
    name = Column(String, nullable=False)
    age = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    team = relationship("Team", back_populates="members")

class Claim(Base):
    __tablename__ = "claims"

    id = Column(Integer, primary_key=True, index=True)
    claim_text = Column(String, nullable=False)
    bias_risk = Column(Float, default=0.0)
    clickbait_index = Column(Float, default=0.0)
    source_validity = Column(Float, default=0.0)
    flags_json = Column(String, default="[]") # JSON list of flags e.g. [{"type": "warning", "text": "..."}]
    created_at = Column(DateTime, default=datetime.utcnow)

class JuryEvaluation(Base):
    __tablename__ = "jury_evaluations"

    id = Column(Integer, primary_key=True, index=True)
    project_title = Column(String, nullable=False)
    project_desc = Column(String, nullable=False)
    consensus_score = Column(Float, default=0.0)
    criteria_scores_json = Column(String, default="{}") # JSON dict of scores
    juror_reviews_json = Column(String, default="[]") # JSON list of reviews
    created_at = Column(DateTime, default=datetime.utcnow)
