# MIL Nexus: UNESCO Youth Initiative 2026 Project Incubator

**Theme:** *Play Your Part: Youth Designing the Future of Media and Information Literacy (MIL)*  
**Target Demographic:** Global Youth (18–30)  
**Primary Architecture:** Full-Stack Single-Page Application (FastAPI + SQLite + ES6 Vanilla Client)  
**Design Palette:** *Institutional Trust* (UNESCO Blue, Teal, and Amber Gold)

---

## 🌟 Project Overview

**MIL Nexus** is an interactive, full-stack media and information literacy incubator built for the UNESCO Youth Initiative 2026. Rather than a static slide deck, **MIL Nexus** hosts a live suite of digital prototypes that address multiple challenge tracks (AI & MIL, MIL Education, Community Impact, and Youth Engagement).

It equips young advocates with the practical tools and simulated scenarios needed to navigate today's rapidly changing information environment, combat AI-generated misinformation, audit sources, and lead regional media campaigns.

---

## 📂 Directory Layout

```text
/Volumes/DiskD/HACKATHONS/Media-and-Information-Literacy/
├── .github/
│   └── workflows/
│       └── ci.yml             # CI/CD GitHub Actions Pipeline
├── backend/
│   ├── app/
│   │   ├── database.py        # SQLAlchemy connector & engine
│   │   ├── main.py            # FastAPI App & Endpoints
│   │   ├── models.py          # SQLAlchemy Models (sqlite schema)
│   │   └── schemas.py         # Pydantic validation rules (ages 18-30)
│   ├── tests/
│   │   └── test_main.py       # Pytest integration tests
│   ├── requirements.txt       # Python dependencies
│   └── seed.py                # Database seeder
├── frontend/
│   ├── index.html             # Client view layout
│   ├── index.css              # Design tokens & layouts (UNESCO palette)
│   └── app.js                 # API handler (fetch queries with fallbacks)
├── run_dev.sh                 # Launcher daemon (Venv compiler & server runner)
├── .gitignore                 # Exclusion mappings (venv, db, logs)
├── analytical_reasoning.pdf   # Research study brief
├── research_foundations.pdf   # MIL Scientific foundations brief
└── prebunking.pdf             # Inoculation & prebunking brief
```

---

## 🚀 Interactive Prototypes

### 🎮 1. TruthCraft: The Disinformation Defense
An immersive, interactive branching narrative game where players take on the role of Maya, a student journalist in Thessaloniki investigating a viral disinformation campaign.
* **Deepfake Spotter Challenge:** Compares synthetic profiles side-by-side to detect AI-generated imagery by auditing physical and background pixel artifacts.
* **EXIF Metadata Inspector:** Forensic data tool that allows players to inspect timestamps and software signatures to verify if protest images are authentic or manipulated.
* **Headline Bias Balancer:** An interactive drag-and-drop game that teaches how to translate sensationalist clickbait headers into neutral, objective reporting.
* **UNESCO Completion Certificate:** Dynamically generates and prints a personalized participation certificate matching the Initiative guidelines.

### 📱 2. SpotCheck: Grassroots Fact-Checking Kit
A lightweight, mobile-responsive utility dashboard designed for student networks and community organizers.
* **Heuristic Text Scanner:** Analyzes claims for clickbait, emotional bias, caps locks, and citation ratios, updating visual circular progress gauges.
* **Infographic Card Generator:** A template builder that generates customizable debunking infographics (Verdict: FALSE / MISLEADING / VERIFIED).
* **One-Click Share/Export:** Utilizes custom printing stylesheets (`@media print`) to let users print or save debunk cards as PDF/images to share instantly inside WhatsApp, Telegram, or messaging groups.

### 📚 3. Digital Resource & Research Library
* **Scientific Foundations Library:** The app integrates an empirical library mapping MIL Nexus modules to verified academic frameworks (Wineburg & McGrew, Kahne & Bowyer, Roozenbeek & van der Linden, Mihailidis & Thevenin).
* **Interactive PDF Downloads:** Direct links to download detailed technical briefs and prebunking studies generated directly by the platform.

---

## 🎨 Visual Aesthetics & Theming

* **Institutional Trust Theme:** Visuals are styled with curated HSL tokens referencing the official **UNESCO Blue**, **Teal**, and **Amber Gold** warning accents.
* **Premium Glassmorphism:** Translucent frosted panels styled with `backdrop-filter: blur(20px)` and animated borders to appeal to youth delegates.
* **Print Optimization:** Formatted with a separate `@media print` stylesheet that strips navigation interfaces and prints the registration pass, certificate, and debunk cards cleanly.

---

## 🛠️ How to Run Locally

We have provided a unified shell script launcher that manages the full-stack setup environment automatically.

### 1. Launch Dev Servers (Backend + Frontend)
Execute the launcher script in your terminal:
```bash
chmod +x run_dev.sh
./run_dev.sh
```

**What the script does:**
1. Creates a Python virtual environment (`venv`) inside the root folder.
2. Installs backend dependencies from `backend/requirements.txt`.
3. Runs the seeder script (`backend/seed.py`) to initialize `mil.db` with mock claims and expert reviews.
4. Starts the **FastAPI Uvicorn Backend** on port `8000` in the background.
5. Starts the **Python Static Frontend** on port `3000` in the background.

* **Frontend UI:** Open [http://localhost:3000](http://localhost:3000)
* **Swagger API Documentation:** Open [http://localhost:8000/docs](http://localhost:8000/docs)

---

## 🧪 Testing

To run the Pytest integration suite locally:
```bash
# Activate the venv
source venv/bin/activate

# Run pytest with PYTHONPATH pointing to backend
PYTHONPATH=backend pytest backend/tests/
```
The suite runs 6 core tests asserting team registration rules, scanner heuristics, stats counts, and simulated juror response structures.
