
# 📱 NewsBrief — AI-Powered News Summarizer for Ethiopia

> **Mobile-first, bilingual (Amharic/English), AI-powered news summaries & audio briefs for Ethiopia.**
> Built in **3 weeks** with Flutter + thin GenAI backend wrapper.

## 🌍 Problem

* Ethiopia has **slow, unreliable internet**, especially in rural areas.
* News is **scattered** (Addis Standard, Ethiopian Herald, Fana, ENA, VOA Amharic, etc.).
* Articles are long and **hard to digest on mobile**.
* Citizens miss important updates in **economy, agriculture, health, governance**.

**Need:** A lightweight, offline-capable app that delivers short, neutral, bilingual news briefs — with optional audio.

## 🚀 Solution

**NewsBrief** ingests multiple news feeds, deduplicates stories, summarizes them in plain **Amharic/English**, and provides **short TTS audio**.

* **Daily Briefs (AM/PM):** 4–6 top stories stitched into 45–90 sec audio.
* **Offline Cache:** Last 3–7 days of summaries + audio available without internet.
* **Search & Topics:** Query “agriculture”, “Addis”, “economy”, etc.
* **Lightweight:** Text-first, images optional, optimized for low-data devices.
* **Privacy-first:** No accounts; anonymous telemetry only.

## 🎯 Goals & Metrics (V1)

* **Adoption:** 2,000+ unique sessions in first month.
* **Engagement:** ≥30% play Daily Brief 3x/week.
* **Speed:**

  * Open-to-content: <1.5s (cached).
  * Audio start: <2s (pre-generated).
* **Offline Reliability:** 3–7 days cached briefs, 0 errors.
* **Quality:** Avg. ≥4.2/5 on clarity & usefulness.

## 🔑 Core Features

* ✅ **Topic & Keyword Search** (e.g., “agriculture in Amhara”).
* ✅ **Plain Summaries:** 3–5 bullets (≤120 words), neutral tone.
* ✅ **Audio Mode:** 30–60 sec per story, stitched AM/PM briefs.
* ✅ **Daily Brief Screen:** Morning & evening digest with notifications.
* ✅ **Offline Cache:** Text + audio stored locally.
* ✅ **Data Saver Mode:** Text-only, compressed payloads.
* ✅ **Shareable Summaries:** With source + time.

## 👥 Target Users

* Urban + rural Ethiopians with low data budgets.
* Students, farmers, small businesses, community groups.
* Low-literacy users benefiting from **audio mode**.

## 📱 Example Use Cases

* **Morning Catch-Up:** Tap *Daily Brief (Amharic)* → 60-sec summary of top news.
* **Topic Pull:** Search *“Agriculture this week”* → summaries + audio.
* **Offline Ride:** No data? Cached last 3 days still available.

## 🛠️ Tech Stack

**Mobile (primary):** Flutter

* `sqflite` (cache)
* `just_audio` (TTS playback)
* `intl` (Amharic/English i18n)

**Backend:** (team picks one: FastAPI / Express.js / Go Fiber)

* **Jobs:** Ingestor, Summarizer, TTS worker
* **Storage:** Postgres/SQLite (stories), Redis (cache), Object storage (audio)

**Web (optional demo):** Next.js (TypeScript)

**AI Usage:**

* **LLM Summarization** → JSON { title, bullets\[], source, published\_at, lang }
* **TTS** → Amharic & English voices, pre-generated for AM/PM briefs

## 🎨 Design Principles

* **Simplicity First:** 3–5 bullets, then optional audio.
* **Neutral & Transparent:** Always show source + time.
* **Data Saver:** Text primary, images optional.
* **Bilingual:** Amharic + English, fully supported.
* **Privacy:** No accounts, minimal telemetry.

## 📅 Execution Plan (3 Weeks)

* **Week 1:** Foundations → RSS ingest, first summaries, Flutter mock screens.
* **Week 2:** Core Features → API integration, TTS, offline cache.
* **Week 3:** Hardening → Performance, error states, accessibility, demo.

Demo Date: **Sep 10**

## ⚠️ Risks & Mitigation

* **RSS downtime:** Multi-source ingest + cache.
* **LLM costs:** Token limits, batching, caching.
* **TTS latency:** Pre-generate briefs, lazy per-story.
* **Amharic quality:** Prompt tuning, native review.
* **Offline bugs:** Strict cache fallbacks, airplane-mode tests.

## 🧪 Test Plan (for Juniors)

* Feed shows items with **source + time**.
* Search works in **both Amharic & English**.
* Audio plays for **stories + daily briefs**.
* Offline mode: app shows last 3–7 days cached.
* Notifications fire at AM/PM.

## 🤝 Contributing

We welcome contributions!

* Fork repo → create feature branch → submit PR.
* Please follow code style (Flutter/Backend/Web).
* Add tests for new features where possible.

## 📜 License

MIT License © 2025 NewsBrief Team