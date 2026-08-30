/* LearnTube for Windows — shares the same Firebase family data as the
   iPhone/iPad/Mac apps, so minutes and progress are one pool. */

const DB = "https://learntube-family-default-rtdb.firebaseio.com";

// Stable per-install device id so this PC shows up once in Family Progress.
function deviceId() {
  let id = localStorage.getItem("lt_device_id");
  if (!id) {
    id = "WIN-" + (crypto.randomUUID ? crypto.randomUUID() : Date.now() + "-" + Math.random());
    localStorage.setItem("lt_device_id", id);
  }
  return id;
}
const DEVICE = deviceId();
const DEVICE_NAME = "Gabriel's PC";

// Read-only mode: set true while testing so play-throughs don't touch his record.
const DRY_RUN = new URLSearchParams(location.search).has("dry");

const dayKey = () => new Date().toISOString().slice(0, 10);

/* ------------------------------------------------------------ firebase --- */
async function getJSON(path) {
  try {
    const r = await fetch(`${DB}/${path}.json`, { cache: "no-store" });
    return r.ok ? await r.json() : null;
  } catch { return null; }
}
async function putJSON(path, body) {
  if (DRY_RUN) { console.log("[dry] PUT", path, body); return; }
  try {
    await fetch(`${DB}/${path}.json`,
      { method: "PUT", body: JSON.stringify(body), headers: { "Content-Type": "application/json" } });
  } catch (e) { console.warn("put failed", e); }
}
async function patchJSON(path, body) {
  if (DRY_RUN) { console.log("[dry] PATCH", path, body); return; }
  try {
    await fetch(`${DB}/${path}.json`,
      { method: "PATCH", body: JSON.stringify(body), headers: { "Content-Type": "application/json" } });
  } catch (e) { console.warn("patch failed", e); }
}

/* --------------------------------------------------------------- state --- */
const S = {
  curriculum: null,
  settings: { minutesPerConcept: 15, maxPlaysPerDay: 3, masteryThreshold: 3 },
  minutes: 0,
  completions: {},   // skillId -> all-time count (this device)
  todayCounts: {},   // skillId -> today count
  current: null,
};

async function pullSettings() {
  const s = await getJSON("family/settings");
  if (s) S.settings = { ...S.settings, ...s };
}
async function pullTime() {
  const t = await getJSON("family");
  S.minutes = (t && typeof t.availableMinutes === "number") ? t.availableMinutes : 0;
  paintMinutes();
}
/** Add/spend minutes on the SHARED family pool (read first so we never clobber). */
async function addMinutes(delta, watched) {
  const t = (await getJSON("family")) || {};
  const cur = typeof t.availableMinutes === "number" ? t.availableMinutes : 0;
  const next = Math.max(0, cur + delta);
  const body = { availableMinutes: next };
  if (watched) {
    const w = t.watchedByDay || {};
    w[dayKey()] = (w[dayKey()] || 0) + watched;
    body.watchedByDay = w;
  }
  await patchJSON("family", body);
  S.minutes = next;
  paintMinutes();
}
/** Push this PC's progress so it merges into Progress/Insights like any device. */
async function pushSnapshot() {
  await putJSON(`family/progress/${DEVICE}`, {
    deviceID: DEVICE,
    name: DEVICE_NAME,
    dayKey: dayKey(),
    todayCounts: S.todayCounts,
    buddyCount: 0,
    updatedAt: new Date().toISOString(),
    allCounts: S.completions,
    masteredCount: Object.values(S.completions).filter(c => c >= S.settings.masteryThreshold).length,
  });
}

/* ---------------------------------------------------------------- view --- */
const $ = id => document.getElementById(id);
const show = id => {
  ["home", "teachScreen", "gameScreen", "winScreen"].forEach(s => $(s).classList.add("hidden"));
  $(id).classList.remove("hidden");
};
function paintMinutes() {
  $("minutes").textContent = `${S.minutes} min`;
  const has = S.minutes > 0;
  $("watchCard").classList.toggle("hidden", !has);
  $("earnCard").classList.toggle("hidden", has);
  $("watchMins").textContent = S.minutes;
}

const SUBJECT_COLORS = {
  reading: ["#36bcd0", "#7fdce6"], math: ["#4f8fe8", "#a9c9f5"],
  science: ["#4fbf6a", "#a9e3b6"], writing: ["#e0a23a", "#f3d79a"],
  life: ["#e08a4a", "#f3c39a"], social: ["#b06fd6", "#d9b6ef"],
};
/** A colourful topic thumbnail: first emoji we can find for this skill. */
function thumbFor(sk) {
  const st = sk.lesson.type === "story" ? S.curriculum.stories[sk.lesson.storyId] : null;
  let emo = [];
  if (st && st.questions.length) {
    emo = (st.questions[0].visuals || []).slice(0, 3);
    if (!emo.length) emo = st.questions[0].choices.map(c => c.emoji).filter(Boolean).slice(0, 3);
  }
  if (!emo.length && sk.lesson.type === "trace") emo = ["✏️"];
  if (!emo.length) emo = [{ math: "🔢", reading: "📖", science: "🔬", writing: "✏️", life: "🌟" }[sk.subject] || "⭐"];
  return emo.join(" ");
}

function renderHome() {
  const live = S.curriculum.skills.filter(s => s.live);
  // Finished-today games sink to the bottom, same as the iPhone app.
  live.sort((a, b) => (!!S.todayCounts[a.id] - !!S.todayCounts[b.id]));
  $("grid").innerHTML = "";
  for (const sk of live) {
    const done = !!S.todayCounts[sk.id];
    const [c1, c2] = SUBJECT_COLORS[sk.subject] || ["#5b6b7a", "#93a3b2"];
    const el = document.createElement("button");
    el.className = "card" + (done ? " done" : "");
    el.innerHTML =
      `<div class="thumb" style="background:linear-gradient(150deg,${c1},${c2})">${thumbFor(sk)}</div>
       <div class="card-body">
         <div class="card-title">${sk.title}</div>
         <div class="card-sub">${sk.standard}</div>
         ${done ? '<div class="badge-done">✓ done today</div>' : ""}
       </div>`;
    el.onclick = () => openSkill(sk);
    $("grid").appendChild(el);
  }
}

/* ------------------------------------------------------- teaching card --- */
function openSkill(sk) {
  S.current = sk;
  $("teachTitle").textContent = sk.title;
  $("teachText").textContent = sk.teach || sk.activity;
  show("teachScreen");
}
$("teachGo").onclick = () => startGame(S.current);
$("quitBtn").onclick = () => { show("home"); renderHome(); };
$("winGo").onclick = () => { show("home"); renderHome(); };

/* -------------------------------------------------------------- engines --- */
function startGame(sk) {
  show("gameScreen");
  const body = $("gameBody");
  body.innerHTML = "";
  const t = sk.lesson.type;
  if (t === "story") {
    const st = S.curriculum.stories[sk.lesson.storyId];
    if (!st || !st.questions.length) return finish(sk);
    engineChoices(body, st.questions.map(q => ({
      teach: q.teach,
      prompt: q.prompts[Math.floor(Math.random() * q.prompts.length)],
      visual: (q.visuals || []).join(" "),
      choices: q.choices.map(c => ({ emoji: c.emoji, label: c.label, correct: c.correct })),
    })), sk);
  } else if (t === "quiz") {
    engineChoices(body, sk.lesson.questions.map(q => ({
      teach: "", prompt: q.prompt, visual: "",
      choices: [{ label: q.correct, correct: true }, ...q.wrong.map(w => ({ label: w, correct: false }))],
    })), sk);
  } else if (t === "trace") {
    engineTrace(body, sk.lesson.items, sk);
  } else {
    // Engines not built yet (match/order/numberPad/count/faceMatch)
    body.innerHTML = `<div class="stage"><div class="visual">🚧</div>
      <div class="prompt">This game is coming to the PC soon!</div></div>`;
  }
}

/** Shared engine for story-quiz and plain quiz: prompt + tappable choices. */
function engineChoices(root, questions, sk) {
  let i = 0, locked = false;
  const stage = document.createElement("div");
  stage.className = "stage";
  root.appendChild(stage);

  const draw = () => {
    const q = questions[i];
    const shuffled = [...q.choices].sort(() => Math.random() - 0.5);
    stage.innerHTML =
      `<div class="dots">${questions.map((_, n) => `<span class="dot ${n < i ? "on" : ""}"></span>`).join("")}</div>
       ${q.visual ? `<div class="visual">${q.visual}</div>` : ""}
       ${q.teach ? `<div class="teachline">${q.teach}</div>` : ""}
       <div class="prompt">${q.prompt}</div>
       <div class="choices"></div>`;
    const box = stage.querySelector(".choices");
    shuffled.forEach(c => {
      const b = document.createElement("button");
      b.className = "choice";
      b.innerHTML = (c.emoji ? `<span class="emo">${c.emoji}</span>` : "") + `<span>${c.label}</span>`;
      b.onclick = () => {
        if (locked) return;
        if (c.correct) {
          locked = true; b.classList.add("right");
          setTimeout(() => {
            locked = false; i++;
            if (i >= questions.length) finish(sk); else draw();
          }, 700);
        } else {
          b.classList.add("wrong");
          setTimeout(() => b.classList.remove("wrong"), 400);
        }
      };
      box.appendChild(b);
    });
  };
  draw();
}

/** Finger/mouse tracing: follow the letter outline, dots light up as you go. */
function engineTrace(root, items, sk) {
  let idx = 0;
  const stage = document.createElement("div");
  stage.className = "stage";
  stage.innerHTML =
    `<div class="dots" id="tdots"></div>
     <div class="prompt" id="tprompt"></div>
     <div class="trace-card"><canvas id="traceCanvas"></canvas></div>
     <button class="redo" id="tredo">↺ Start over</button>`;
  root.appendChild(stage);

  const cv = stage.querySelector("#traceCanvas");
  const ctx = cv.getContext("2d");
  let targets = [], hit = new Set(), ink = [], drawing = false, doneFlag = false;

  function layout() {
    const r = cv.getBoundingClientRect();
    cv.width = r.width * devicePixelRatio; cv.height = r.height * devicePixelRatio;
    ctx.setTransform(devicePixelRatio, 0, 0, devicePixelRatio, 0, 0);
    buildTargets(r.width, r.height);
    paint();
  }
  // Sample points along the glyph by rasterising the letter and walking its pixels.
  function buildTargets(w, h) {
    targets = []; hit = new Set(); ink = [];
    const letter = items[idx];
    const size = Math.min(w, h) * 0.8;
    ctx.save();
    ctx.clearRect(0, 0, w, h);
    ctx.font = `900 ${size}px "Segoe UI",system-ui,sans-serif`;
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillStyle = "#000";
    ctx.fillText(letter, w / 2, h / 2);
    const img = ctx.getImageData(0, 0, w * devicePixelRatio, h * devicePixelRatio).data;
    const step = Math.max(6, Math.floor(size / 12));
    for (let y = 0; y < h; y += step) {
      for (let x = 0; x < w; x += step) {
        const px = Math.floor(x * devicePixelRatio), py = Math.floor(y * devicePixelRatio);
        const a = img[(py * Math.floor(w * devicePixelRatio) + px) * 4 + 3];
        if (a > 128) targets.push({ x, y });
      }
    }
    ctx.restore();
    ctx.clearRect(0, 0, w, h);
  }
  function paint() {
    const r = cv.getBoundingClientRect();
    ctx.clearRect(0, 0, r.width, r.height);
    const size = Math.min(r.width, r.height) * 0.8;
    // faint guide letter
    ctx.font = `900 ${size}px "Segoe UI",system-ui,sans-serif`;
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillStyle = "#dcdcdc";
    ctx.fillText(items[idx], r.width / 2, r.height / 2);
    // dots
    targets.forEach((t, n) => {
      ctx.beginPath(); ctx.arc(t.x, t.y, 4, 0, 7);
      ctx.fillStyle = hit.has(n) ? "#34c759" : "#b4b4b4"; ctx.fill();
    });
    // ink
    if (ink.length > 1) {
      ctx.beginPath(); ctx.moveTo(ink[0].x, ink[0].y);
      ink.forEach(p => ctx.lineTo(p.x, p.y));
      ctx.strokeStyle = "#3a86d6"; ctx.lineWidth = 13;
      ctx.lineCap = "round"; ctx.lineJoin = "round"; ctx.stroke();
    }
    $("tdots").innerHTML = items.map((_, n) => `<span class="dot ${n < idx ? "on" : ""}"></span>`).join("");
    $("tprompt").textContent = `Trace the ${items[idx]}  ✏️`;
  }
  function at(e) {
    const r = cv.getBoundingClientRect();
    const p = e.touches ? e.touches[0] : e;
    return { x: p.clientX - r.left, y: p.clientY - r.top };
  }
  function move(e) {
    if (!drawing || doneFlag) return;
    e.preventDefault();
    const p = at(e); ink.push(p);
    targets.forEach((t, n) => {
      if (!hit.has(n) && Math.hypot(p.x - t.x, p.y - t.y) < 26) hit.add(n);
    });
    paint();
    if (targets.length && hit.size / targets.length >= 0.75) {
      doneFlag = true;
      setTimeout(() => {
        idx++;
        if (idx >= items.length) finish(sk);
        else { doneFlag = false; drawing = false; layout(); }
      }, 650);
    }
  }
  cv.addEventListener("pointerdown", e => { drawing = true; ink = []; move(e); });
  cv.addEventListener("pointermove", move);
  window.addEventListener("pointerup", () => { drawing = false; });
  stage.querySelector("#tredo").onclick = () => layout();
  requestAnimationFrame(layout);
}

/* ------------------------------------------------------------- finish ---- */
async function finish(sk) {
  const playsToday = S.todayCounts[sk.id] || 0;
  S.completions[sk.id] = (S.completions[sk.id] || 0) + 1;
  S.todayCounts[sk.id] = playsToday + 1;

  let earned = 0;
  if (playsToday < (S.settings.maxPlaysPerDay || 3)) {
    earned = S.settings.minutesPerConcept || 15;
    await addMinutes(earned);
  }
  await pushSnapshot();

  $("winText").textContent = earned
    ? `You finished ${sk.title} and earned more YouTube time!`
    : `You finished ${sk.title} again — nice practice!`;
  show("winScreen");
}

/* -------------------------------------------------------------- watch ---- */
$("watchBtn").onclick = async () => {
  if (S.minutes <= 0) return;
  // In the packaged Windows app this opens the built-in gated player window.
  if (window.__TAURI__) {
    window.__TAURI__.event.emit("open-youtube");
  } else {
    alert("In the installed Windows app this opens YouTube inside LearnTube,\nspending a minute at a time from his shared balance.");
  }
};

/* --------------------------------------------------------------- boot ---- */
(async function boot() {
  const res = await fetch("curriculum.json");
  S.curriculum = await res.json();
  await Promise.all([pullSettings(), pullTime()]);
  // Adopt today's counts already recorded for this device.
  const mine = await getJSON(`family/progress/${DEVICE}`);
  if (mine) {
    S.completions = mine.allCounts || {};
    if (mine.dayKey === dayKey()) S.todayCounts = mine.todayCounts || {};
  }
  renderHome();
  show("home");
  setInterval(pullTime, 15000);   // stay in sync with his other devices
})();
