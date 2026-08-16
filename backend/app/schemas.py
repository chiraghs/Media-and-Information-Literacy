from pydantic import BaseModel, Field
from typing import List, Dict, Any
from datetime import datetime

# Member schemas
class MemberBase(BaseModel):
    name: str
    age: int = Field(..., ge=18, le=30)

class MemberCreate(MemberBase):
    pass

class MemberOut(MemberBase):
    id: int
    team_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Team schemas
class TeamBase(BaseModel):
    name: str
    track: str
    modality: str = "Applications / Websites"

class TeamCreate(TeamBase):
    members: List[MemberCreate]

class TeamOut(TeamBase):
    id: int
    created_at: datetime
    members: List[MemberOut]

    class Config:
        from_attributes = True

# Claim schemas
class ClaimCreate(BaseModel):
    claim_text: str

class ClaimOut(BaseModel):
    id: int
    claim_text: str
    bias_risk: float
    clickbait_index: float
    source_validity: float
    flags_json: str
    created_at: datetime

    class Config:
        from_attributes = True

# Jury schemas
class JuryEvaluationCreate(BaseModel):
    project_title: str
    project_desc: str

class JuryEvaluationOut(BaseModel):
    id: int
    project_title: str
    project_desc: str
    consensus_score: float
    criteria_scores_json: str
    juror_reviews_json: str
    created_at: datetime

    class Config:
        from_attributes = True

# System Statistics schema
class SystemStats(BaseModel):
    total_teams: int
    total_members: int
    total_scans: int
    total_evaluations: int
    avg_mil_score: int
