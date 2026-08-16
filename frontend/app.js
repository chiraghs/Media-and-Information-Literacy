/* MIL Nexus - Application Engine & State Coordinator */

// --- API Helpers ---
const API_URL = "http://localhost:8000";

async function callApi(endpoint, method = "GET", body = null) {
  const headers = { "Content-Type": "application/json" };
  const options = { method, headers };
  if (body) options.body = JSON.stringify(body);
  const response = await fetch(`${API_URL}${endpoint}`, options);
  if (!response.ok) {
    throw new Error(`API Error: ${response.statusText}`);
  }
  return await response.json();
}

async function loadStats() {
  try {
    const stats = await callApi("/api/stats");
    console.log("System stats from backend:", stats);
    const subtitle = document.getElementById("top-subtitle");
    if (subtitle && appState.currentTab === 'dashboard') {
      subtitle.textContent = `Explore media literacy prototypes. Joined by ${stats.total_teams} teams globally.`;
    }
  } catch (e) {
    console.warn("Backend offline. Running in local simulation mode.", e);
  }
}

// --- Global State ---
let appState = {
  currentTab: 'dashboard',
  userScore: 0,
  streak: 1,
  theme: 'light',
  team: null,
  game: {
    currentScene: 'intro',
    score: 0,
    milestones: {
      story: false,
      df: false,
      exif: false,
      bias: false
    }
  }
};

// --- Initialization ---
document.addEventListener("DOMContentLoaded", () => {
  // Restore State from localStorage
  loadPersistedState();
  
  // Load Stats from backend (or fallback)
  loadStats();
  
  // Initialize UI Bindings
  initTheme();
  initTabNavigation();
  initRegistrationForm();
  initSpotCheckScanner();
  initTruthCraftGame();
  initJurySimulator();
  
  // Track default streak
  updateStreakDisplay();
});

// --- LocalStorage Persistence ---
function loadPersistedState() {
  const savedState = localStorage.getItem("mil-nexus-state");
  if (savedState) {
    try {
      const parsed = JSON.parse(savedState);
      appState.userScore = parsed.userScore || 0;
      appState.streak = parsed.streak || 1;
      appState.theme = parsed.theme || 'light';
      appState.team = parsed.team || null;
      appState.game.milestones = parsed.milestones || { story: false, df: false, exif: false, bias: false };
    } catch (e) {
      console.error("Failed to parse state", e);
    }
  }
  
  // Update Score UI
  document.getElementById("mil-score-val").textContent = appState.userScore;
}

function saveState() {
  const stateToSave = {
    userScore: appState.userScore,
    streak: appState.streak,
    theme: appState.theme,
    team: appState.team,
    milestones: appState.game.milestones
  };
  localStorage.setItem("mil-nexus-state", JSON.stringify(stateToSave));
}

// --- Theme Management ---
function initTheme() {
  const toggleBtn = document.getElementById("theme-toggle-btn");
  const toggleText = document.getElementById("theme-toggle-text");
  
  const applyTheme = (theme) => {
    document.documentElement.setAttribute("data-theme", theme);
    document.documentElement.style.colorScheme = theme;
    appState.theme = theme;
    localStorage.setItem("color-scheme", theme);
    toggleText.textContent = theme === 'dark' ? 'Light Mode' : 'Dark Mode';
    saveState();
  };

  toggleBtn.addEventListener("click", () => {
    const nextTheme = appState.theme === 'dark' ? 'light' : 'dark';
    applyTheme(nextTheme);
  });

  // Apply restored theme
  applyTheme(appState.theme);
}

// --- Tab Navigation ---
function initTabNavigation() {
  const navButtons = document.querySelectorAll(".nav-item");
  const tabViews = document.querySelectorAll(".tab-view");

  window.switchTab = (tabId) => {
    // Deactivate previous
    navButtons.forEach(btn => btn.classList.remove("active"));
    tabViews.forEach(view => view.classList.remove("active"));

    // Activate selected
    const activeBtn = document.querySelector(`[data-tab="${tabId}"]`);
    const activeView = document.getElementById(`view-${tabId}`);
    if (activeBtn) activeBtn.classList.add("active");
    if (activeView) activeView.classList.add("active");

    // Update Header Text dynamically
    updateHeaderText(tabId);
    appState.currentTab = tabId;
    
    // Refresh stats if on dashboard
    if (tabId === 'dashboard') {
      loadStats();
    }
  };

  navButtons.forEach(button => {
    button.addEventListener("click", () => {
      const tabId = button.getAttribute("data-tab");
      window.switchTab(tabId);
    });
  });
}

function updateHeaderText(tabId) {
  const title = document.getElementById("top-title");
  const subtitle = document.getElementById("top-subtitle");

  switch(tabId) {
    case 'dashboard':
      title.textContent = "Dashboard Hub";
      subtitle.textContent = "Explore media literacy prototypes and register your project team.";
      break;
    case 'truthcraft':
      title.textContent = "TruthCraft Game";
      subtitle.textContent = "Test your verification strategies in an interactive media investigation.";
      break;
    case 'spotcheck':
      title.textContent = "SpotCheck Kit";
      subtitle.textContent = "Audit statement structures and generate shareable debunk graphics.";
      break;
    case 'resources':
      title.textContent = "Resource Kits";
      subtitle.textContent = "Download blueprints and facilitation guides for local advocacy campaigns.";
      break;
    case 'about':
      title.textContent = "Diagnostic Check";
      subtitle.textContent = "Draft fact-checks or campaign statements and receive immediate expert feedback.";
      break;
  }
}

// --- Streak Handler ---
function updateStreakDisplay() {
  document.getElementById("streak-num").textContent = appState.streak;
}

// --- Step 1: Team Registration Management ---
function initRegistrationForm() {
  const form = document.getElementById("team-register-form");
  const membersContainer = document.getElementById("members-inputs");
  const addMemberBtn = document.getElementById("add-member-btn");
  const passContainer = document.getElementById("registration-pass-container");
  const printPassBtn = document.getElementById("btn-print-pass");
  const editTeamBtn = document.getElementById("btn-edit-team");

  let memberCount = 0;

  // Helper to add member input row
  const addMemberInput = (name = "", age = "") => {
    if (memberCount >= 6) return;
    
    memberCount++;
    const row = document.createElement("div");
    row.className = "member-input-row";
    row.id = `member-row-${memberCount}`;
    
    row.innerHTML = `
      <input type="text" placeholder="Member Name" value="${name}" required class="member-name-field">
      <input type="number" placeholder="Age" min="18" max="30" value="${age}" required class="member-age-field">
      <button type="button" class="btn-remove-member" title="Remove Member">&times;</button>
    `;
    
    // Wire delete button
    row.querySelector(".btn-remove-member").addEventListener("click", () => {
      if (memberCount <= 2) {
        alert("A team must contain at least 2 members.");
        return;
      }
      row.remove();
      memberCount--;
      updateMemberAddButtonState();
    });

    membersContainer.appendChild(row);
    updateMemberAddButtonState();
  };

  const updateMemberAddButtonState = () => {
    addMemberBtn.disabled = memberCount >= 6;
  };

  addMemberBtn.addEventListener("click", () => addMemberInput());

  // Form submission
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    
    const teamNameVal = document.getElementById("team-name").value;
    const focusTrackVal = document.getElementById("focus-track").value;
    const modalityVal = document.getElementById("project-modality").value;
    
    // Extract members
    const memberRows = document.querySelectorAll(".member-input-row");
    const members = [];
    let ageError = false;

    memberRows.forEach(row => {
      const name = row.querySelector(".member-name-field").value;
      const age = parseInt(row.querySelector(".member-age-field").value);
      
      if (age < 18 || age > 30) {
        ageError = true;
      }
      members.push({ name, age });
    });

    if (ageError) {
      alert("Eligibility rule: All team members must be aged 18–30.");
      return;
    }

    if (members.length < 2 || members.length > 6) {
      alert("A team must consist of 2 to 6 members.");
      return;
    }

    const payload = {
      name: teamNameVal,
      track: focusTrackVal,
      modality: modalityVal,
      members: members
    };

    try {
      const res = await callApi("/api/register", "POST", payload);
      console.log("Team registered on backend:", res);
      appState.team = res;
    } catch (err) {
      console.warn("Backend registration failed. Falling back to local state.", err);
      appState.team = payload;
    }
    
    saveState();
    renderPass();
    
    const roadmapStatus = document.getElementById("roadmap-reg-status");
    roadmapStatus.textContent = `Status: Registered (${teamNameVal})`;
    document.querySelector(".timeline-item.completed").classList.add("active");
  });

  // Render pass details to front layout
  const renderPass = () => {
    if (!appState.team) return;
    
    document.getElementById("pass-team-title").textContent = appState.team.name;
    document.getElementById("pass-track-title").textContent = `${appState.team.track} Track`;
    document.getElementById("pass-modality-title").textContent = `Format: ${appState.team.modality || "Applications / Websites"}`;
    document.getElementById("pass-members-count").textContent = appState.team.members.length;
    document.getElementById("pass-team-letter").textContent = appState.team.name.charAt(0).toUpperCase();
    
    // Update sidebar display name
    document.getElementById("user-name-display").textContent = appState.team.name;
    document.getElementById("user-role-display").textContent = `Team Leader (${appState.team.members.length} Members)`;
    document.getElementById("avatar-display").textContent = appState.team.name.charAt(0).toUpperCase();

    // Toggle layouts
    form.classList.add("hidden");
    passContainer.classList.remove("hidden");
  };

  // Toggle back to edit
  editTeamBtn.addEventListener("click", () => {
    passContainer.classList.add("hidden");
    form.classList.remove("hidden");
  });

  // Print Pass Action
  printPassBtn.addEventListener("click", () => {
    window.print();
  });

  // Seed default 2 members
  if (appState.team) {
    document.getElementById("team-name").value = appState.team.name;
    document.getElementById("focus-track").value = appState.team.track;
    appState.team.members.forEach(m => addMemberInput(m.name, m.age));
    renderPass();
    const roadmapStatus = document.getElementById("roadmap-reg-status");
    roadmapStatus.textContent = `Status: Registered (${appState.team.name})`;
  } else {
    addMemberInput("", "");
    addMemberInput("", "");
  }
}

function scrollToRegisterForm() {
  const elem = document.getElementById("register-section");
  if (elem) {
    elem.scrollIntoView({ behavior: 'smooth' });
  }
}

// --- SpotCheck: Algorithmic Claim Scanner & Infographic Maker ---
function initSpotCheckScanner() {
  const scanInput = document.getElementById("claim-input-box");
  const runScanBtn = document.getElementById("btn-run-scan");
  const scanResults = document.getElementById("scan-results-box");
  
  // Real-time card builder triggers
  const infoClaimInput = document.getElementById("info-claim");
  const infoVerdictSelect = document.getElementById("info-verdict");
  const infoBulletsText = document.getElementById("info-bullets");
  
  const renderClaim = document.getElementById("info-render-claim");
  const renderVerdict = document.getElementById("info-render-verdict");
  const renderBullets = document.getElementById("info-render-bullets");
  const renderCard = document.getElementById("debunk-card-render");
  
  const exportBtn = document.getElementById("btn-export-infographic");

  window.insertSampleClaim = (type) => {
    if (type === 1) {
      scanInput.value = "SHOCKING COVERUP! Elite billionaire robots steal all local high-paying tech jobs overnight. Unbelievable details leaked!!!";
    } else {
      scanInput.value = "A research report by the Global Tech Institute indicates that local employment figures in technology sectors remained stable, growing 4% year-over-year.";
    }
  };

  runScanBtn.addEventListener("click", async () => {
    const text = scanInput.value.trim();
    if (!text) {
      alert("Please paste a statement to analyze.");
      return;
    }

    let clickbait, bias, sourceVal, flags;

    try {
      const res = await callApi("/api/scan", "POST", { claim_text: text });
      console.log("Claim audited on backend:", res);
      clickbait = res.clickbait_index;
      bias = res.bias_risk;
      sourceVal = res.source_validity;
      flags = JSON.parse(res.flags_json);
    } catch (err) {
      console.warn("Backend scan failed. Running local heuristics.", err);
      // Fallback
      clickbait = 10;
      bias = 15;
      sourceVal = 80;
      flags = [];

      const clickbaitKeywords = ["shocking", "coverup", "revealed", "unbelievable", "leaked", "steal", "stealing", "overnight", "!!!", "expose"];
      clickbaitKeywords.forEach(word => {
        if (text.toLowerCase().includes(word)) {
          clickbait += 15;
          bias += 10;
        }
      });

      const upperCaseChars = text.replace(/[^A-Z]/g, "").length;
      const totalAlphaChars = text.replace(/[^a-zA-Z]/g, "").length;
      if (totalAlphaChars > 10 && (upperCaseChars / totalAlphaChars) > 0.25) {
        clickbait += 20;
        bias += 15;
        flags.push({
          type: 'warning',
          text: 'High Capitalization detected: Typically used to force attention.'
        });
      }

      const hasNumbers = /\d+/.test(text);
      if (!hasNumbers) {
        sourceVal -= 30;
        flags.push({
          type: 'danger',
          text: 'No numeric references or statistics: Indicates general rumor claiming.'
        });
      } else {
        sourceVal += 10;
      }

      const officialKeywords = ["report", "institute", "research", "stable", "official", "data", "published"];
      let officialMatch = false;
      officialKeywords.forEach(word => {
        if (text.toLowerCase().includes(word)) {
          officialMatch = true;
        }
      });

      if (officialMatch) {
        bias -= 20;
        clickbait -= 25;
        sourceVal += 15;
        flags.push({
          type: 'success',
          text: 'Academic/Factual vocabulary match: Objective reporting framing.'
        });
      } else {
        flags.push({
          type: 'warning',
          text: 'Sensational framing: Adjectives outnumber concrete source citations.'
        });
      }

      clickbait = Math.max(0, Math.min(100, clickbait));
      bias = Math.max(0, Math.min(100, bias));
      sourceVal = Math.max(0, Math.min(100, sourceVal));
    }

    // Update UI (Gauges)
    document.getElementById("gauge-bias").style.setProperty('--value', `${bias}%`);
    document.getElementById("gauge-bias-val").textContent = `${bias}%`;

    document.getElementById("gauge-clickbait").style.setProperty('--value', `${clickbait}%`);
    document.getElementById("gauge-clickbait-val").textContent = `${clickbait}%`;

    document.getElementById("gauge-source").style.setProperty('--value', `${sourceVal}%`);
    document.getElementById("gauge-source-val").textContent = `${sourceVal}%`;

    // Render Flags
    const flagListContainer = document.getElementById("scan-flags-list");
    flagListContainer.innerHTML = "";

    if (flags.length === 0) {
      flagListContainer.innerHTML = '<li class="flag-item flag-success"><span class="flag-item-icon">✓</span> No warning indicators detected.</li>';
    } else {
      flags.forEach(flag => {
        const itemClass = flag.type === 'danger' ? 'flag-item' : (flag.type === 'warning' ? 'flag-item flag-warning' : 'flag-item flag-success');
        const icon = flag.type === 'success' ? '✓' : '⚠';
        flagListContainer.innerHTML += `
          <li class="${itemClass}">
            <span class="flag-item-icon">${icon}</span>
            <span>${flag.text}</span>
          </li>
        `;
      });
    }

    scanResults.classList.remove("hidden");
    awardPoints(5);
  });

  // Real-time Infographic syncing
  const syncInfographic = () => {
    renderClaim.textContent = infoClaimInput.value.trim() || "Claim summary here";
    
    const verdict = infoVerdictSelect.value;
    renderVerdict.textContent = verdict;
    
    renderCard.className = `debunk-card theme-${verdict.toLowerCase()}`;

    const bullets = infoBulletsText.value.split("\n").filter(line => line.trim() !== "");
    renderBullets.innerHTML = "";
    if (bullets.length === 0) {
      renderBullets.innerHTML = "<li>No facts entered yet.</li>";
    } else {
      bullets.forEach(bullet => {
        renderBullets.innerHTML += `<li>${bullet}</li>`;
      });
    }
  };

  infoClaimInput.addEventListener("input", syncInfographic);
  infoVerdictSelect.addEventListener("change", syncInfographic);
  infoBulletsText.addEventListener("input", syncInfographic);

  syncInfographic();

  exportBtn.addEventListener("click", () => {
    window.print();
  });
}

function awardPoints(pts) {
  appState.userScore += pts;
  document.getElementById("mil-score-val").textContent = appState.userScore;
  saveState();
}

// --- TruthCraft Game: Narrative Sandbox & Completion Cert ---
function initTruthCraftGame() {
  const startBtn = document.getElementById("btn-start-game");
  const introScreen = document.getElementById("game-screen-intro");
  const storyScreen = document.getElementById("game-screen-story");
  const printCertBtn = document.getElementById("btn-print-cert");

  // Story definition
  const storyScenes = {
    intro: {
      text: "Maya, a young reporter at the Thessaloniki Student Pulse, receives an anonymous DM. It contains a video showing the university rector apparently stating that all local technology scholarships will be terminated to buy high-cost AI management packages.",
      character: "Narrator",
      role: "Logistics",
      avatar: "N",
      choices: [
        { text: "Share the video immediately: The public has a right to know!", target: "share_rash" },
        { text: "Stop and verify: Inspect the video source, audio matching, and EXIF metadata.", target: "investigate_exif" }
      ]
    },
    share_rash: {
      text: "You shared the video instantly. Within hours, it goes viral. However, a local technician comments showing that the speech coordinates and lip synchronization are artificial. You spread a deepfake, ruining your journal credibility.",
      character: "Narrator",
      role: "Failure",
      avatar: "✗",
      choices: [
        { text: "Restart and try a safer verification path.", target: "intro" }
      ]
    },
    investigate_exif: {
      text: "You decide to investigate the video's details. You capture frame segments and analyze the files. First, let's analyze the profile photo of the anonymous source who sent you the DM. Spot which of the two images contains synthetic AI distortions.",
      character: "Maya",
      role: "Investigator",
      avatar: "M",
      choices: [
        { text: "Launch Profile Analysis", target: "trigger_df_puzzle" }
      ]
    },
    exif_forensics: {
      text: "Great! You isolated the profile details. Now, let's inspect the digital file data of the protest images attached to the rumor file. Verify the EXIF tags for inconsistencies.",
      character: "Maya",
      role: "Investigator",
      avatar: "M",
      choices: [
        { text: "Open EXIF Metadata Tool", target: "trigger_exif_puzzle" }
      ]
    },
    bias_balancing: {
      text: "Awesome forensics. You verified that the file is an old edit and the profile was AI-generated. Before publishing your debunk article, you must ensure your headline is objective, avoiding sensational clickbait framing.",
      character: "Maya",
      role: "Investigator",
      avatar: "M",
      choices: [
        { text: "Open Headline Balancer Tool", target: "trigger_bias_puzzle" }
      ]
    },
    conclusion: {
      text: "Outstanding work! You successfully verified the data, isolated the deepfake profile, and published a neutral headline. The true story receives high praise for integrity, protecting student scholarships.",
      character: "Narrator",
      role: "Success",
      avatar: "✓",
      choices: [
        { text: "Generate Achievement Certificate", target: "trigger_cert" }
      ]
    }
  };

  startBtn.addEventListener("click", () => {
    introScreen.classList.add("hidden");
    storyScreen.classList.remove("hidden");
    appState.game.currentScene = 'investigate_exif';
    appState.game.score = 10;
    appState.game.milestones.story = true;
    updateGameUI();
    renderScene('investigate_exif');
  });

  const renderScene = (sceneKey) => {
    const scene = storyScenes[sceneKey];
    if (!scene) return;

    appState.game.currentScene = sceneKey;
    
    document.getElementById("char-name").textContent = scene.character;
    document.getElementById("char-role").textContent = scene.role;
    document.getElementById("char-avatar").textContent = scene.avatar;
    document.getElementById("story-text").textContent = scene.text;

    const choicesBox = document.getElementById("story-choices-box");
    choicesBox.innerHTML = "";
    
    scene.choices.forEach(choice => {
      const btn = document.createElement("button");
      btn.className = "btn btn-secondary-outline btn-block text-left";
      btn.textContent = choice.text;
      
      btn.addEventListener("click", () => {
        handleChoice(choice.target);
      });
      choicesBox.appendChild(btn);
    });

    updateGameUI();
  };

  const handleChoice = (target) => {
    if (target === 'trigger_df_puzzle') {
      storyScreen.classList.add("hidden");
      document.getElementById("game-screen-puzzle-df").classList.remove("hidden");
      appState.game.currentScene = 'puzzle_df';
      updateGameUI();
    } else if (target === 'trigger_exif_puzzle') {
      storyScreen.classList.add("hidden");
      document.getElementById("game-screen-puzzle-exif").classList.remove("hidden");
      appState.game.currentScene = 'puzzle_exif';
      updateGameUI();
    } else if (target === 'trigger_bias_puzzle') {
      storyScreen.classList.add("hidden");
      document.getElementById("game-screen-puzzle-bias").classList.remove("hidden");
      appState.game.currentScene = 'puzzle_bias';
      setupBiasBalancerPuzzle();
      updateGameUI();
    } else if (target === 'trigger_cert') {
      storyScreen.classList.add("hidden");
      document.getElementById("game-screen-cert").classList.remove("hidden");
      appState.game.currentScene = 'cert';
      
      const certName = document.getElementById("cert-user-name");
      if (appState.team) {
        certName.textContent = appState.team.name;
      } else {
        certName.textContent = "Media Literacy Changemaker";
      }

      awardPoints(appState.game.score);
      document.getElementById("game-final-score").textContent = appState.game.score;
      
      updateGameUI();
    } else {
      renderScene(target);
    }
  };

  const updateGameUI = () => {
    document.getElementById("game-status-scenario").textContent = appState.game.currentScene;
    document.getElementById("game-status-score").textContent = appState.game.score;

    const progressFill = document.getElementById("story-progress-fill");
    let progress = 10;
    if (appState.game.currentScene === 'puzzle_df') progress = 35;
    if (appState.game.currentScene === 'puzzle_exif') progress = 60;
    if (appState.game.currentScene === 'puzzle_bias') progress = 85;
    if (appState.game.currentScene === 'cert') progress = 100;
    progressFill.style.width = `${progress}%`;

    updateMilestoneElement("milestone-story", appState.game.milestones.story);
    updateMilestoneElement("milestone-df", appState.game.milestones.df);
    updateMilestoneElement("milestone-exif", appState.game.milestones.exif);
    updateMilestoneElement("milestone-bias", appState.game.milestones.bias);
  };

  const updateMilestoneElement = (id, active) => {
    const elem = document.getElementById(id);
    if (active) {
      elem.className = "completed";
    } else {
      elem.className = "pending";
    }
  };

  window.selectDeepfake = (choice) => {
    const feedbackBox = document.getElementById("df-feedback-box");
    const feedbackText = document.getElementById("df-feedback-text");
    
    if (choice === 'B') {
      feedbackText.innerHTML = "<strong>Correct!</strong> Profile B contains multiple AI deepfake artifacts (floating hair strands, asymmetric earring placement, and distorted edge background loops). Score +25.";
      appState.game.score += 25;
      appState.game.milestones.df = true;
    } else {
      feedbackText.innerHTML = "<strong>Incorrect.</strong> Profile B is the AI-generated headshot due to structural warping artifacts. You still gather clues to proceed.";
      appState.game.milestones.df = true;
    }
    
    feedbackBox.classList.remove("hidden");
    document.getElementById("df-card-a").style.opacity = 0.5;
    document.getElementById("df-card-b").style.opacity = 0.5;
  };

  document.getElementById("btn-next-from-df").addEventListener("click", () => {
    document.getElementById("game-screen-puzzle-df").classList.add("hidden");
    document.getElementById("df-card-a").style.opacity = 1;
    document.getElementById("df-card-b").style.opacity = 1;
    document.getElementById("df-feedback-box").classList.add("hidden");

    storyScreen.classList.remove("hidden");
    renderScene('exif_forensics');
  });

  window.assessMetadata = (choice) => {
    const feedbackBox = document.getElementById("exif-feedback-box");
    const feedbackText = document.getElementById("exif-feedback-text");

    if (choice === 2) {
      feedbackText.innerHTML = "<strong>Correct!</strong> The EXIF metadata timestamp shows the photo was captured in 2024 (2 years before the current 2026 protest) and has software edit signatures from Photoshop.";
      appState.game.score += 25;
      appState.game.milestones.exif = true;
    } else {
      feedbackText.innerHTML = "<strong>Incorrect.</strong> The EXIF data clearly displays a 2024 capture stamp and Photoshop signature, showing it is not a live image from yesterday's protest.";
      appState.game.milestones.exif = true;
    }

    feedbackBox.classList.remove("hidden");
  };

  document.getElementById("btn-next-from-exif").addEventListener("click", () => {
    document.getElementById("game-screen-puzzle-exif").classList.add("hidden");
    document.getElementById("exif-feedback-box").classList.add("hidden");
    
    storyScreen.classList.remove("hidden");
    renderScene('bias_balancing');
  });

  const setupBiasBalancerPuzzle = () => {
    const wordList = ["AI", "Hiring", "Grows", "Steadily", "Despite", "Fears"];
    const container = document.getElementById("draggable-words");
    const dropzone = document.getElementById("headline-dropzone");
    
    container.innerHTML = "";
    dropzone.innerHTML = '<p class="drop-placeholder">Click words in correct order to construct balanced headline...</p>';

    const shuffled = [...wordList].sort(() => Math.random() - 0.5);

    shuffled.forEach(word => {
      const span = document.createElement("span");
      span.className = "word-tag";
      span.textContent = word;
      
      span.addEventListener("click", () => {
        const placeholder = dropzone.querySelector(".drop-placeholder");
        if (placeholder) placeholder.remove();
        dropzone.appendChild(span);
      });

      container.appendChild(span);
    });

    document.getElementById("btn-reset-bias").onclick = () => {
      setupBiasBalancerPuzzle();
    };

    document.getElementById("btn-submit-bias").onclick = () => {
      const tags = dropzone.querySelectorAll(".word-tag");
      const currentSentence = Array.from(tags).map(t => t.textContent).join(" ");
      const correctSentence = "AI Hiring Grows Steadily Despite Fears";

      const feedbackBox = document.getElementById("bias-feedback-box");
      const feedbackText = document.getElementById("bias-feedback-text");

      if (currentSentence === correctSentence) {
        feedbackText.innerHTML = "<strong>Correct!</strong> Headline balanced. 'AI Hiring Grows Steadily Despite Fears' uses objective facts without fear-mongering triggers. Score +25.";
        appState.game.score += 25;
        appState.game.milestones.bias = true;
      } else {
        feedbackText.innerHTML = `<strong>Incomplete/Incorrect.</strong> The balanced sequence is: 'AI Hiring Grows Steadily Despite Fears'. Your current sequence: '${currentSentence || "None"}'`;
        appState.game.milestones.bias = true;
      }

      feedbackBox.classList.remove("hidden");
    };
  };

  document.getElementById("btn-next-from-bias").addEventListener("click", () => {
    document.getElementById("game-screen-puzzle-bias").classList.add("hidden");
    document.getElementById("bias-feedback-box").classList.add("hidden");
    
    storyScreen.classList.remove("hidden");
    renderScene('conclusion');
  });

  printCertBtn.addEventListener("click", () => {
    window.print();
  });

  window.resetGame = () => {
    document.getElementById("game-screen-cert").classList.add("hidden");
    introScreen.classList.remove("hidden");
    appState.game.currentScene = 'intro';
    appState.game.score = 0;
    appState.game.milestones = { story: false, df: false, exif: false, bias: false };
    updateGameUI();
  };
}

// --- About Tab: 3-Expert Jury Evaluation Simulator ---
function initJurySimulator() {
  const submitBtn = document.getElementById("btn-submit-jury");
  const resultsBox = document.getElementById("jury-results-box");

  submitBtn.addEventListener("click", async () => {
    const title = document.getElementById("jury-project-title").value.trim();
    const desc = document.getElementById("jury-project-desc").value.trim();

    if (!title || !desc) {
      alert("Please enter both a project title and description to evaluate.");
      return;
    }

    let consensus, scores, reviews;

    try {
      const res = await callApi("/api/jury-simulate", "POST", { project_title: title, project_desc: desc });
      console.log("Jury evaluation simulated on backend:", res);
      consensus = res.consensus_score;
      scores = JSON.parse(res.criteria_scores_json);
      reviews = JSON.parse(res.juror_reviews_json);
    } catch (err) {
      console.warn("Backend jury simulator failed. Falling back to local mock.", err);
      // Fallback
      let consistency = 7.0;
      let clarity = 7.0;
      let innovation = 7.0;
      let feasibility = 6.5;
      let impact = 7.0;

      if (desc.length > 100) {
        clarity += 1.0;
        feasibility += 1.0;
      }
      
      const keywords = ["sandbox", "game", "prototype", "expose", "decentralized", "PWA", "toolkit", "verify"];
      keywords.forEach(word => {
        if (desc.toLowerCase().includes(word)) {
          innovation += 0.4;
          impact += 0.3;
        }
      });

      if (title.toLowerCase().includes("nexus") || title.toLowerCase().includes("truthcraft") || title.toLowerCase().includes("spotcheck")) {
        consistency += 1.5;
        innovation += 0.8;
      }

      consistency = Math.min(10, consistency).toFixed(1);
      clarity = Math.min(10, clarity).toFixed(1);
      innovation = Math.min(10, innovation).toFixed(1);
      feasibility = Math.min(10, feasibility).toFixed(1);
      impact = Math.min(10, impact).toFixed(1);

      consensus = ((parseFloat(consistency) + parseFloat(clarity) + parseFloat(innovation) + parseFloat(feasibility) + parseFloat(impact)) / 5).toFixed(1);

      scores = {
        theme: consistency,
        clarity: clarity,
        innovation: innovation,
        feasibility: feasibility,
        impact: impact
      };

      const comments = {
        juror1: [
          `"Strong presentation for '${title}'. The concept targets critical thinking skills, matching the core objectives of UNESCO's 2026 track."`,
          `"Highly consistent with the AI & MIL track. The prototype framework seems very practical and ready for testing."`
        ],
        juror2: [
          `"The project demonstrates solid localized impact. Community-based interventions that target chat network rumors are highly needed."`,
          `"Interesting proposal. The integration of lateral reading prompts in the verification workflow has high educational value."`
        ],
        juror3: [
          `"Feasibility is solid, especially since the team outline covers 2-6 roles. Ensure the final 3-minute video pitch focuses strongly on youth change agents."`,
          `"The scalability potential looks good. Suggest detailing how regional radio networks can replicate these guidelines."`
        ]
      };

      const rIdx = Math.floor(Math.random() * 2);
      reviews = [
        { name: "Juror 1 (Europe Office)", review: comments.juror1[rIdx] },
        { name: "Juror 2 (Latin America Office)", review: comments.juror2[rIdx] },
        { name: "Juror 3 (Asia-Pacific Office)", review: comments.juror3[rIdx] }
      ];
    }

    // Update UI
    document.getElementById("jury-consensus-score").textContent = consensus;
    document.getElementById("score-theme").textContent = `${scores.theme}/10`;
    document.getElementById("score-clarity").textContent = `${scores.clarity}/10`;
    document.getElementById("score-innovation").textContent = `${scores.innovation}/10`;
    document.getElementById("score-feasibility").textContent = `${scores.feasibility}/10`;
    document.getElementById("score-impact").textContent = `${scores.impact}/10`;

    document.getElementById("juror-1-text").textContent = reviews[0].review;
    document.getElementById("juror-2-text").textContent = reviews[1].review;
    document.getElementById("juror-3-text").textContent = reviews[2].review;

    resultsBox.classList.remove("hidden");
    awardPoints(15);
  });
}
