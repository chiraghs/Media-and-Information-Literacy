import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.database import Base, get_db
from app.main import app

# Setup testing in-memory SQLite database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_mil.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Override the database session dependency
def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(scope="module", autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "online"

def test_register_team_success():
    payload = {
        "name": "Beta Factcheckers",
        "track": "AI and MIL",
        "members": [
            {"name": "Alice Smith", "age": 22},
            {"name": "Bob Jones", "age": 24}
        ]
    }
    response = client.post("/api/register", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Beta Factcheckers"
    assert len(data["members"]) == 2

def test_register_team_invalid_age():
    payload = {
        "name": "Gamma Hackers",
        "track": "MIL Education",
        "members": [
            {"name": "Charlie Brown", "age": 17}, # under 18
            {"name": "Delta Force", "age": 24}
        ]
    }
    response = client.post("/api/register", json=payload)
    # Pydantic validation should fail
    assert response.status_code == 422

def test_scan_claim():
    payload = {
        "claim_text": "SHOCKING Mandate: Billionaire robots steal tech jobs overnight leaked details!!!"
    }
    response = client.post("/api/scan", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "bias_risk" in data
    assert "clickbait_index" in data
    assert "source_validity" in data

def test_simulate_jury_evaluation():
    payload = {
        "project_title": "SpotCheck PWA Tracker",
        "project_desc": "SpotCheck is a mobile-responsive toolkit and infograph scanner resolving clickbaits."
    }
    response = client.post("/api/jury-simulate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "consensus_score" in data
    assert "criteria_scores_json" in data
    assert "juror_reviews_json" in data

def test_get_system_stats():
    response = client.get("/api/stats")
    assert response.status_code == 200
    data = response.json()
    assert "total_teams" in data
    assert "total_members" in data
    assert "total_scans" in data
    assert "total_evaluations" in data
