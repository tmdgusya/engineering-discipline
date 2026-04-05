# Skills GitHub Pages Implementation Plan

> **Worker note:** Execute this plan task-by-task. Each step uses checkbox syntax for progress tracking.

**Goal:** engineering-discipline 리포지토리의 11개 핵심 스킬을 Neo-Brutalist 디자인으로 소개하는 정적 GitHub Pages 사이트 구축

**Architecture:** 순수 HTML + CSS 기반 정적 사이트. 메인 페이지에서 워크플로우 시각화 + 스킬 맵 제공. 각 스킬은 개별 HTML 페이지로 구성. CSS custom properties로 Neo-Brutalist 디자인 시스템 일관성 유지.

**Tech Stack:** HTML5, CSS3 (custom properties), Vanilla JS (minimal, 네비게이션 토글)

**Work Scope:**
- **In scope:**
  - 메인 페이지: 워크플로우 다이어그램, 스킬 맵, 탐색 메뉴
  - 스킬 상세 페이지 11개: 사용 상황 + 동작 메커니즘
  - Neo-Brutalist 디자인 시스템 (CSS 파일 분리)
  - GitHub Actions 자동 배포
  - 한국어 콘텐츠, MiSans + Noto Sans KR 폴백
- **Out of scope:**
  - 외부 스킬 25개 소개
  - 백엔드/API
  - 모바일 반응형 (Neo-Brutalist 데스크톱 중심, 기본 반응형만)

**Constraints:**
- MiSans 웹폰트 CDN 미제공 → 시스템 폰트 우선, Noto Sans KR (Google Fonts) fallback
- GitHub Pages path: `https://tmdgusya.github.io/engineering-discipline/`
- 모든 HTML 파일에 `<base href="/engineering-discipline/">` 적용 (하위 경로 대응)
- 최대 12페이지 (메인 1 + 상세 11)

**Verification Strategy:**
- **Level:** build-only
- **Command:** `python3 -m http.server 8080` 로 로컬 서버 기동 후 `curl -s http://localhost:8080/engineering-discipline/ | grep -c "<html"`
- **What it validates:** 모든 HTML 파일이 유효하게 렌더링되고 링크가 깨지지 않음

---

## File Structure Mapping

```
/home/roach/engineering-discipline/
├── index.html                          # 메인 페이지
├── css/
│   └── style.css                       # 전체 사이트 스타일 (Neo-Brutalist)
├── skills/
│   ├── clarification.html
│   ├── clean-ai-slop.html
│   ├── karpathy.html
│   ├── long-run.html
│   ├── milestone-planning.html
│   ├── plan-crafting.html
│   ├── review-work.html
│   ├── rob-pike.html
│   ├── run-plan.html
│   ├── simplify.html
│   └── systematic-debugging.html
├── assets/
│   └── favicon.svg                     # 단순 SVG favicon
└── .github/
    └── workflows/
        └── deploy.yml                  # GitHub Pages 배포
```

모든 스킬 상세 페이지는 서로 독립적인 파일이므로 병렬 생성 가능. `index.html`과 `css/style.css`는 선행 필요 (다른 페이지들이 공통 CSS 및 네비게이션 구조 참조).

---

## Task 1: CSS 디자인 시스템 + 기본 HTML 템플릿

**Dependencies:** None (can run in parallel with nothing, but is prerequisite for all other pages)
**Files:**
- Create: `css/style.css`
- Create: `assets/favicon.svg`

- [ ] **Step 1: Create Neo-Brutalist CSS design system**

```css
/* css/style.css — Neo-Brutalist Design System */

/* === Custom Properties === */
:root {
  --bg: #FFFFFF;
  --black: #000000;
  --blue: #0000FF;
  --border-width: 4px;
  --border-width-thick: 8px;
  --shadow-offset: 6px;
  --shadow-offset-lg: 10px;
  --font-ko: 'MiSans', 'Noto Sans KR', 'Apple SD Gothic Neo', 'Malgun Gothic', sans-serif;
  --font-en: 'Arial', 'Helvetica', sans-serif;
  --mono: 'SF Mono', 'Fira Code', 'Consolas', monospace;
}

/* === Reset === */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

/* === Base === */
html {
  font-size: 16px;
  scroll-behavior: smooth;
}

body {
  font-family: var(--font-ko);
  background: var(--bg);
  color: var(--black);
  line-height: 1.7;
  min-height: 100vh;
}

.en {
  font-family: var(--font-en);
}

code {
  font-family: var(--mono);
  font-size: 0.9em;
}

pre {
  font-family: var(--mono);
  background: var(--bg);
  border: var(--border-width) solid var(--black);
  box-shadow: var(--shadow-offset) var(--shadow-offset) 0 var(--black);
  padding: 1rem;
  overflow-x: auto;
  margin: 1rem 0;
  line-height: 1.4;
}

pre code {
  background: none;
  padding: 0;
  border: none;
  box-shadow: none;
}

/* === Layout === */
.container {
  max-width: 960px;
  margin: 0 auto;
  padding: 2rem 1.5rem;
}

/* === Navigation Bar === */
.nav {
  border-bottom: var(--border-width-thick) solid var(--black);
  padding: 1rem 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--bg);
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav-brand {
  font-size: 1.25rem;
  font-weight: 900;
  color: var(--black);
  text-decoration: none;
  letter-spacing: -0.02em;
}

.nav-brand:hover {
  color: var(--blue);
}

.nav-links {
  display: flex;
  gap: 1.5rem;
  list-style: none;
  flex-wrap: wrap;
}

.nav-links a {
  color: var(--black);
  text-decoration: none;
  font-weight: 700;
  font-size: 0.9rem;
  padding: 0.25rem 0.5rem;
  border: 2px solid transparent;
  transition: all 0.1s;
}

.nav-links a:hover {
  border-color: var(--black);
  box-shadow: 2px 2px 0 var(--black);
}

.nav-links a.active {
  background: var(--black);
  color: var(--bg);
}

/* === Typography === */
h1 {
  font-size: 2.5rem;
  font-weight: 900;
  letter-spacing: -0.03em;
  line-height: 1.2;
  margin-bottom: 1.5rem;
}

h2 {
  font-size: 1.75rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  margin-top: 2rem;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: var(--border-width) solid var(--black);
}

h3 {
  font-size: 1.25rem;
  font-weight: 700;
  margin-top: 1.5rem;
  margin-bottom: 0.5rem;
}

/* === Sections === */
section {
  margin: 2rem 0;
}

/* === Cards === */
.card {
  border: var(--border-width) solid var(--black);
  box-shadow: var(--shadow-offset) var(--shadow-offset) 0 var(--black);
  padding: 1.5rem;
  margin: 1rem 0;
  transition: transform 0.1s, box-shadow 0.1s;
}

.card:hover {
  transform: translate(2px, 2px);
  box-shadow: calc(var(--shadow-offset) - 2px) calc(var(--shadow-offset) - 2px) 0 var(--black);
}

.card-link {
  text-decoration: none;
  color: inherit;
  display: block;
}

.card-link:hover .card-title {
  color: var(--blue);
}

.card-title {
  font-size: 1.25rem;
  font-weight: 800;
  margin-bottom: 0.5rem;
}

.card-tag {
  display: inline-block;
  background: var(--black);
  color: var(--bg);
  font-size: 0.75rem;
  font-weight: 700;
  padding: 0.15rem 0.5rem;
  margin-right: 0.35rem;
  margin-bottom: 0.35rem;
}

.card-tag.blue {
  background: var(--blue);
}

/* === Buttons === */
.btn {
  display: inline-block;
  padding: 0.6rem 1.25rem;
  border: var(--border-width) solid var(--black);
  box-shadow: 4px 4px 0 var(--black);
  background: var(--bg);
  color: var(--black);
  font-weight: 700;
  font-size: 0.95rem;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.1s;
  font-family: var(--font-ko);
}

.btn:hover {
  transform: translate(2px, 2px);
  box-shadow: 2px 2px 0 var(--black);
}

.btn:active {
  transform: translate(4px, 4px);
  box-shadow: none;
}

.btn-primary {
  background: var(--black);
  color: var(--bg);
}

.btn-blue {
  background: var(--blue);
  color: var(--bg);
  border-color: var(--blue);
  box-shadow: 4px 4px 0 var(--black);
}

/* === Workflow Diagram === */
.workflow {
  background: var(--bg);
  border: var(--border-width-thick) solid var(--black);
  box-shadow: var(--shadow-offset-lg) var(--shadow-offset-lg) 0 var(--black);
  padding: 2rem;
  margin: 2rem 0;
  font-family: var(--mono);
  font-size: 0.85rem;
  line-height: 1.6;
  white-space: pre;
  overflow-x: auto;
  color: var(--black);
}

/* === Lists === */
ul, ol {
  padding-left: 1.5rem;
  margin: 0.75rem 0;
}

li {
  margin: 0.35rem 0;
}

/* === Table === */
table {
  width: 100%;
  border-collapse: collapse;
  margin: 1rem 0;
}

th, td {
  border: var(--border-width) solid var(--black);
  padding: 0.75rem;
  text-align: left;
}

th {
  background: var(--black);
  color: var(--bg);
  font-weight: 700;
}

/* === Callout / Badge === */
.callout {
  border: var(--border-width) solid var(--black);
  box-shadow: var(--shadow-offset) var(--shadow-offset) 0 var(--black);
  padding: 1rem 1.25rem;
  margin: 1.5rem 0;
}

.callout::before {
  content: '▸ ';
  font-weight: 900;
  color: var(--blue);
}

.callout.blue {
  border-color: var(--blue);
  box-shadow: var(--shadow-offset) var(--shadow-offset) 0 var(--blue);
}

.callout.blue::before {
  color: var(--black);
}

/* === Trigger badge (inline code-like) === */
.trigger {
  display: inline-block;
  background: var(--black);
  color: var(--bg);
  font-family: var(--mono);
  font-size: 0.8rem;
  padding: 0.2rem 0.6rem;
  margin: 0.25rem 0;
}

/* === ASCII Arrow / diagram helpers === */
.ascii-arrow {
  color: var(--blue);
  font-weight: 900;
}

/* === Footer === */
.footer {
  border-top: var(--border-width) solid var(--black);
  padding: 1.5rem;
  margin-top: 3rem;
  text-align: center;
  font-size: 0.85rem;
}

.footer a {
  color: var(--blue);
  font-weight: 700;
}

/* === Skill detail page header === */
.skill-header {
  padding: 2rem 1.5rem;
  border-bottom: var(--border-width-thick) solid var(--black);
}

.skill-header h1 {
  margin-bottom: 0.5rem;
}

.skill-badge {
  display: inline-block;
  background: var(--black);
  color: var(--bg);
  font-size: 0.8rem;
  font-weight: 700;
  padding: 0.25rem 0.75rem;
  margin-right: 0.5rem;
}

.skill-badge.blue {
  background: var(--blue);
}

/* === Flow diagram for skill pages === */
.flow-steps {
  display: flex;
  flex-direction: column;
  gap: 0;
  margin: 1.5rem 0;
}

.flow-step {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1rem;
  border: var(--border-width) solid var(--black);
  margin-bottom: -4px;
}

.flow-step:last-child {
  margin-bottom: 0;
}

.flow-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  background: var(--black);
  color: var(--bg);
  font-weight: 900;
  font-size: 0.9rem;
  flex-shrink: 0;
}

.flow-step:first-child .flow-number {
  background: var(--blue);
}

/* === Responsive (minimal) === */
@media (max-width: 768px) {
  .container { padding: 1rem; }
  h1 { font-size: 1.75rem; }
  h2 { font-size: 1.35rem; }
  .nav { flex-direction: column; gap: 0.75rem; }
  .nav-links { gap: 0.75rem; }
  .workflow { font-size: 0.7rem; padding: 1rem; }
  .card:hover { transform: none; box-shadow: var(--shadow-offset) var(--shadow-offset) 0 var(--black); }
}
```

- [ ] **Step 2: Create SVG favicon**

```svg
<!-- assets/favicon.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect x="0" y="0" width="64" height="64" fill="#FFFFFF" stroke="#000000" stroke-width="4"/>
  <rect x="8" y="8" width="48" height="48" fill="none" stroke="#000000" stroke-width="4"/>
  <text x="32" y="42" text-anchor="middle" font-family="Arial, sans-serif" font-size="28" font-weight="900" fill="#000000">ED</text>
</svg>
```

---

## Task 2: 메인 페이지 (index.html)

**Dependencies:** Task 1 (CSS 필요)
**Files:**
- Create: `index.html`

- [ ] **Step 1: Create main page with workflow visualization**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Engineering Discipline — AI 코딩을 위한 엔지니어링 규율</title>
  <link rel="stylesheet" href="css/style.css">
  <link rel="icon" type="image/svg+xml" href="assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="index.html" class="active">홈</a></li>
    <li><a href="#skills">스킬</a></li>
    <li><a href="#workflow">워크플로우</a></li>
    <li><a href="#install">설치</a></li>
  </ul>
</nav>

<div class="container">

  <!-- Hero -->
  <section>
    <h1>AI 코딩 에이전트를 위한<br>엔지니어링 규율</h1>
    <p style="font-size:1.15rem;margin-bottom:1.5rem;">
      모호한 요청 → 명확한 계획 → 검증된 구현까지.<br>
      Claude Code, Gemini CLI, Cursor, Codex에서 바로 작동합니다.
    </p>
    <a href="#workflow" class="btn btn-primary">워크플로우 보기 ↓</a>
    <a href="https://github.com/tmdgusya/engineering-discipline" class="btn" target="_blank">GitHub ↗</a>
  </section>

  <!-- Workflow Diagram -->
  <section id="workflow">
    <h2>01 ▸ 워크플로우</h2>

    <div class="callout">
      <strong>어떻게 동작하나요?</strong> 스킬이 체인으로 연결되어 작업을 자동으로 라우팅합니다.
      당신이 해야 할 일은 <em>무엇을 원하는지</em> 말하는 것뿐입니다.
    </div>

    <div class="workflow">사용자 요청 (모호)
    │
    ▼
┌─────────────────────────────┐
│  clarification              │
│  모호성 해소 + 코드베이스 탐색 │
│  ─────────────────────────  │
│  복잡도 평가 (자동 라우팅)    │
└──────────────┬──────────────┘
               │
      ┌────────┴────────┐
      │                 │
      ▼                 ▼
  단순 (5-8)       복잡 (9-15)
      │                 │
      ▼                 ▼
┌─────────────┐   ┌──────────────────┐
│plan-crafting│   │milestone-planning│
│  계획 작성   │   │  5개 병렬 리뷰어   │
└──────┬──────┘   └────────┬─────────┘
       │                   │
       ▼                   ▼
┌─────────────┐   ┌──────────────────┐
│  run-plan   │   │    long-run       │
│  worker-   │   │  다일 오케스트레이  │
│  validator  │   │                  │
└──────┬──────┘   └────────┬─────────┘
       │                   │
       ▼                   │
┌─────────────┐            │
│ review-work │◄───────────┘
│  독립 검증   │  각 마일스톤:
└─────────────┘  plan → run → review
      │
      ▼
  [완료]

  ─── 독립 스킬 (언제든 호출) ───

  karpathy          → 코딩 전/중 가드레일
  clean-ai-slop     → AI 생성 코드 정리
  simplify          → 변경사항 품질 검토
  systematic-debug  → 버그/테스트 실패
  rob-pike          → 성능 최적화
</div>

    <div class="callout blue">
      <strong>핵심 원리:</strong> 모든 전환점에서 <em>정보 격리</em>가 적용됩니다.
      검증자는 구현자의 의도를 모릅니다 — 오직 계획과 결과만 봅니다.
    </div>
  </section>

  <!-- Skills Map -->
  <section id="skills">
    <h2>02 ▸ 스킬 맵</h2>

    <h3>워크플로 스킬</h3>

    <div class="card">
      <a href="skills/clarification.html" class="card-link">
        <div class="card-title">Clarification</div>
      </a>
      <div>
        <span class="card-tag">출발점</span>
        <span class="card-tag blue">자동 라우팅</span>
      </div>
      <p style="margin-top:0.5rem;">모호한 요청을 반복 질문 + 코드 탐색으로 명확한 범위로 좁힙니다. 단순/복잡을 자동 판별해 다음 스킬로 라우팅합니다.</p>
    </div>

    <div class="card">
      <a href="skills/plan-crafting.html" class="card-link">
        <div class="card-title">Plan Crafting</div>
      </a>
      <div>
        <span class="card-tag">계획</span>
        <span class="card-tag">실행 가능</span>
      </div>
      <p style="margin-top:0.5rem;">명확한 범위로 실행 가능한 다단계 구현 계획을 생성합니다. 모든 단계에 실제 코드가 포함됩니다 — 플레이스홀더 금지.</p>
    </div>

    <div class="card">
      <a href="skills/run-plan.html" class="card-link">
        <div class="card-title">Run Plan</div>
      </a>
      <div>
        <span class="card-tag">실행</span>
        <span class="card-tag blue">Worker-Validator</span>
      </div>
      <p style="margin-top:0.5rem;">Worker가 구현하고 Validator가 독립 검증합니다. 실패 시 자동 재시도, 3회 실패 시 사용자에게 에스컬레이션.</p>
    </div>

    <div class="card">
      <a href="skills/review-work.html" class="card-link">
        <div class="card-title">Review Work</div>
      </a>
      <div>
        <span class="card-tag">검증</span>
        <span class="card-tag blue">정보 격리</span>
      </div>
      <p style="margin-top:0.5rem;">정보가 격리된 상태에서 계획 vs 구현을 대조 검증합니다. PASS/FAIL 이진 판정을 내립니다.</p>
    </div>

    <h3>장기 실행</h3>

    <div class="card">
      <a href="skills/milestone-planning.html" class="card-link">
        <div class="card-title">Milestone Planning</div>
      </a>
      <div>
        <span class="card-tag">분해</span>
        <span class="card-tag blue">5개 병렬 리뷰어</span>
      </div>
      <p style="margin-top:0.5rem;">실현가능성, 아키텍처, 리스크, 의존성, 사용자 가치 — 5개 관점에서 동시 리뷰 후 최적화된 마일스톤 DAG를 합성합니다.</p>
    </div>

    <div class="card">
      <a href="skills/long-run.html" class="card-link">
        <div class="card-title">Long Run</div>
      </a>
      <div>
        <span class="card-tag">오케스트레이션</span>
        <span class="card-tag blue">체크포인트</span>
      </div>
      <p style="margin-top:0.5rem;">며칠에 걸친 실행을 오케스트레이션합니다. 디스크 체크포인트로 크래시에서 생존하고, 병렬 마일스톤을 worktree 격리로 실행합니다.</p>
    </div>

    <h3>독립 스킬</h3>

    <div class="card">
      <a href="skills/karpathy.html" class="card-link">
        <div class="card-title">Karpathy Guidelines</div>
      </a>
      <div>
        <span class="card-tag">예방</span>
        <span class="card-tag">가드레일</span>
      </div>
      <p style="margin-top:0.5rem;">수술적 변경, 가정 검증, 범위 규율 — 코딩 전과 중에 LLM의 흔한 실수를 방지합니다.</p>
    </div>

    <div class="card">
      <a href="skills/clean-ai-slop.html" class="card-link">
        <div class="card-title">Clean AI Slop</div>
      </a>
      <div>
        <span class="card-tag">정리</span>
        <span class="card-tag blue">6단계 패스</span>
      </div>
      <p style="margin-top:0.5rem;">AI 코드의 과잉 주석, 불필요 추상화, 방어적 편집증 등을 동작 보존하면서 제거합니다. 테스트 우선, 단일 스멜 패스.</p>
    </div>

    <div class="card">
      <a href="skills/simplify.html" class="card-link">
        <div class="card-title">Simplify</div>
      </a>
      <div>
        <span class="card-tag">검토</span>
        <span class="card-tag blue">3개 병렬 에이전트</span>
      </div>
      <p style="margin-top:0.5rem;">재사용, 품질, 효율성 — 3개 병렬 리뷰어가 변경된 코드를 검토하고 발견된 문제를 자동 수정합니다.</p>
    </div>

    <div class="card">
      <a href="skills/systematic-debugging.html" class="card-link">
        <div class="card-title">Systematic Debugging</div>
      </a>
      <div>
        <span class="card-tag">디버깅</span>
        <span class="card-tag">7단계</span>
      </div>
      <p style="margin-top:0.5rem;">재현 우선 → 근본 원인 추적 → 실패 테스트 작성 → 단일 수정 → 검증. "하면서 다른 것도 고치는" 행위를 차단합니다.</p>
    </div>

    <div class="card">
      <a href="skills/rob-pike.html" class="card-link">
        <div class="card-title">Rob Pike's 5 Rules</div>
      </a>
      <div>
        <span class="card-tag">성능</span>
        <span class="card-tag blue">측정 우선</span>
      </div>
      <p style="margin-top:0.5rem;">"느려 보여도 측정 전에는 만지지 않는다." 조기 최적화를 방지하고 데이터 기반 최적화를 강제합니다.</p>
    </div>
  </section>

  <!-- Install -->
  <section id="install">
    <h2>03 ▸ 설치</h2>

    <div class="card">
      <div class="card-title">Claude Code</div>
      <pre>/plugin marketplace add tmdgusya/engineering-discipline
/plugin install engineering-discipline</pre>
    </div>

    <div class="card">
      <div class="card-title">Gemini CLI</div>
      <pre>gemini extensions install https://github.com/tmdgusya/engineering-discipline</pre>
    </div>

    <div class="card">
      <div class="card-title">Cursor</div>
      <pre>/add-plugin engineering-discipline</pre>
    </div>

    <div class="card">
      <div class="card-title">Codex</div>
      <pre>npx skills add tmdgusya/engineering-discipline</pre>
    </div>
  </section>

  <footer class="footer">
    <p>
      <a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a>
      · MIT License
    </p>
  </footer>

</div>

</body>
</html>
```

---

## Task 3: 스킬 상세 페이지 — 워{k}플로 코어 3종

**Dependencies:** Task 1 (CSS), Task 2 (페이지 구조 패턴 참조)
**Files:**
- Create: `skills/clarification.html`
- Create: `skills/plan-crafting.html`
- Create: `skills/run-plan.html`

이 3개 페이지는 같은 디렉토리에 있지만 서로 다른 파일을 수정하므로 병렬 실행 가능합니다.

- [ ] **Step 1: Create clarification.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Clarification — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="clarification.html" class="active">Clarification</a></li>
    <li><a href="plan-crafting.html">Plan Crafting</a></li>
    <li><a href="run-plan.html">Run Plan</a></li>
    <li><a href="review-work.html">Review Work</a></li>
    <li><a href="milestone-planning.html">Milestones</a></li>
    <li><a href="long-run.html">Long Run</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">워크플로</span>
      <span class="skill-badge blue">출발점</span>
    </div>
    <h1>Clarification</h1>
    <p style="font-size:1.1rem;">반복적인 Q&A + 병렬 코드베이스 탐색을 통해 모호한 요청을 명확한 작업 범위로 좁힙니다.</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      "<em>~하고 싶어</em>", "<em>~이 필요해</em>", "~을 만들자" — 범위가 즉시 명확하지 않은 <strong>모든 요청의 출발점</strong>입니다.
    </div>
    <ul>
      <li>요청이 모호해서 구현 방향이 여러 갈래일 때</li>
      <li>기존 코드베이스와 충돌할 가능성이 있을 때</li>
      <li>사용자 자신이 정확히 무엇을 원하는지 아직 정리하지 못했을 때</li>
    </ul>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> 사용자 질문 트랙 1, 코드 탐색 트랙 2 — 두 트랙이 동시에 진행되며 서로를 보완합니다.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>모호성 파악</strong>
          <p>요청에서 무엇이 불명확한지 식별합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>사용자에게 질문 1개 + 코드 탐색 병렬 dispatched</strong>
          <p>메시지당 오직 하나의 질문만 합니다. 동시에 서브에이전트가 코드베이스를 탐색합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>답변 + 탐색 결과 합성</strong>
          <p>사용자의 답변과 코드 탐색 결과를 교차 검증합니다. 여전히 모호한 부분이 있으면 다음 질문으로 진행.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">4</div>
        <div>
          <strong>Context Brief 생성</strong>
          <p>목표, 범위, 기술 컨텍스트, 제약사항, 성공 기준, 복잡도 평가를 문서화합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">5</div>
        <div>
          <strong>복잡도 기반 자동 라우팅</strong>
          <p>점수 5-8 → <a href="plan-crafting.html">Plan Crafting</a> / 점수 9-15 → <a href="milestone-planning.html">Milestone Planning</a></p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>복잡도 평가</h2>
    <table>
      <tr><th>신호</th><th>단순 (1)</th><th>중간 (2)</th><th>복잡 (3)</th></tr>
      <tr><td>범위</td><td>단일 기능</td><td>2-3 컴포넌트</td><td>4+ 컴포넌트</td></tr>
      <tr><td>파일 영향</td><td>≤3개</td><td>4-8개</td><td>9+개</td></tr>
      <tr><td>인터페이스</td><td>기존 내부 작업</td><td>인터페이스 확장</td><td>새 인터페이스 정의</td></tr>
      <tr><td>의존성</td><td>순서 없음</td><td>선형 체인</td><td>분기 DAG</td></tr>
      <tr><td>위험 표면</td><td>통합 위험 없음</td><td>내부 통합</td><td>외부 시스템</td></tr>
    </table>
    <p><strong>점수 5-8:</strong> 단순 → Plan Crafting / <strong>점수 9-15:</strong> 복잡 → Milestone Planning</p>
  </section>

  <section>
    <h2>하드 게이트</h2>
    <ul>
      <li>메시지당 질문 <strong>단 1개</strong> — 복합 질문 금지</li>
      <li>항상 서브에이전트로 코드베이스 탐색 — 독단에 의존하지 않음</li>
      <li>명확해질 때까지 구현 시작 금지 — "이제 충분하다"는 자체 판단 금지</li>
      <li>질문은 항상 범위를 좁혀야 함 — 같은 수준의 추상화 반복 금지</li>
    </ul>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="plan-crafting.html" class="btn">Plan Crafting →</a>
      <a href="milestone-planning.html" class="btn">Milestone Planning →</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

- [ ] **Step 2: Create plan-crafting.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Plan Crafting — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="clarification.html">Clarification</a></li>
    <li><a href="plan-crafting.html" class="active">Plan Crafting</a></li>
    <li><a href="run-plan.html">Run Plan</a></li>
    <li><a href="review-work.html">Review Work</a></li>
    <li><a href="milestone-planning.html">Milestones</a></li>
    <li><a href="long-run.html">Long Run</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">워크플로</span>
      <span class="skill-badge blue">계획</span>
    </div>
    <h1>Plan Crafting</h1>
    <p style="font-size:1.1rem;">명확한 범위로부터 실행 가능한 다단계 구현 계획을 생성합니다. 모든 단계에 실제 코드가 포함됩니다 — 플레이스홀더는 허용되지 않습니다.</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      Clarification이 <strong>단순(Simple)</strong> 판정으로 완료된 직후. 또는 이미 범위가 명료할 때 직접 호출합니다.
    </div>
    <ul>
      <li>Context Brief 파일이 준비되었을 때</li>
      <li>명확한 목표 + 범위가 있고 단계별 계획이 필요할 때</li>
      <li>"계획 세워줘", "플랜 만들어줘"</li>
    </ul>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> 계획은 <em>실행 문서</em>입니다. 코드가 없는 단계, "나중에 구현" 같은 플레이스홀더는 계획 결함으로 간주됩니다.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>검증 인프라 탐색</strong>
          <p>프로젝트에서 가장 높은 수준의 검증(e2e, 통합, 테스트 스위트, 빌드)을 찾아 Final Verification Task를 결정합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>파일 구조 매핑</strong>
          <p>어떤 파일을 생성/수정할지 미리 매핑합니다. 함께 변경되는 파일은 같은 작업에 묶고, 다른 책임은 분리합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>작업 분해 — Worker-Validator 구조</strong>
          <p>각 작업은 실행자와 검증자가 쌍으로 작동하도록 설계됩니다. 같은 파일을 수정하는 작업은 직렬로, 독립적인 작업은 병렬로 배치합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">4</div>
        <div>
          <strong>모든 단계에 실제 코드 포함</strong>
          <p>TBD, TODO, "적절한 에러 처리 추가" 금지. 모든 코드 변경 사항이 계획에 명시됩니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">5</div>
        <div>
          <strong>Self-Review</strong>
          <p>사양 커버리지, 플레이스홀더 스캔, 타입 일관성, 의존성 검증, 검증 커버리지를 자체 점검합니다.</p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>플레이스홀더 금지 목록</h2>
    <div class="callout">
      다음 패턴은 계획 <strong>결함</strong>입니다:
    </div>
    <ul>
      <li><code>"TBD"</code>, <code>"TODO"</code>, <code>"implement later"</code></li>
      <li><code>"적절한 에러 처리 추가"</code></li>
      <li><code>"테스트 작성"</code> (실제 테스트 코드 없이)</li>
      <li><code>"Task N과 유사"</code> (실제 코드 반복 필요 — 워커는 순서대로 읽지 않을 수 있음)</li>
    </ul>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="clarification.html" class="btn">← Clarification</a>
      <a href="run-plan.html" class="btn">Run Plan →</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

- [ ] **Step 3: Create run-plan.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Run Plan — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="clarification.html">Clarification</a></li>
    <li><a href="plan-crafting.html">Plan Crafting</a></li>
    <li><a href="run-plan.html" class="active">Run Plan</a></li>
    <li><a href="review-work.html">Review Work</a></li>
    <li><a href="milestone-planning.html">Milestones</a></li>
    <li><a href="long-run.html">Long Run</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">워크플로</span>
      <span class="skill-badge blue">Worker-Validator</span>
    </div>
    <h1>Run Plan</h1>
    <p style="font-size:1.1rem;">Worker가 구현하고 Validator가 독립적으로 검증합니다. 실패 시 자동 재시도, 3회 실패 시 사용자에게 에스컬레이션.</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      Plan Crafting이 완료된 직후. 또는 이미 작성된 계획 문서를 실행해야 할 때.
    </div>
    <ul>
      <li><code>"계획 실행해"</code>, <code>"플랜 돌려줘"</code></li>
      <li>plan-crafting 완료 후 자동 전환</li>
    </ul>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> Validator는 Worker의 코드를 절대 보지 않습니다. 오직 <em>계획의 목표</em>와 <em>수락 기준</em>만으로 독립 검증합니다.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">0</div>
        <div>
          <strong>검증 인프라 발견 + 에이전트 탐색</strong>
          <p>프로젝트의 테스트 러너, 사용 가능한 에이전트/스킬을 파악합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>계획 사전 검토</strong>
          <p>실행 전 계획 자체의 이슈(파일 충돌, 순서 오류)를 검사합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>Worker-Validator 루프</strong>
          <p>각 작업이 3단계 서브에이전트를 거칩니다: 적합성 검사 → Worker 구현 → Validator 검토. 정보 격리가 핵심입니다 — Validator는 Worker의 결과를 보지 않습니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>E2E 검증 게이트</strong>
          <p>모든 작업 완료 후 최종 통합 검증을 실행합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">?</div>
        <div>
          <strong>재시도 → 에스컬레이션</strong>
          <p>Validator 실패 시 Worker에게 피드백과 함께 재시도. 3회 연속 실패 시 사용자에게 에스컬레이션.</p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>병렬 실행 규칙</h2>
    <table>
      <tr><th>조건</th><th>실행 방식</th></tr>
      <tr><td>파일 겹침 없음 + 의존성 없음</td><td><strong>병렬</strong></td></tr>
      <tr><td>동일 파일 수정</td><td><strong>직렬</strong> — 선행 작업 완료 후</td></tr>
      <tr><td>A의 출력이 B의 입력</td><td><strong>직렬</strong> — A 완료 후 B</td></tr>
    </table>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="plan-crafting.html" class="btn">← Plan Crafting</a>
      <a href="review-work.html" class="btn">Review Work →</a>
      <a href="systematic-debugging.html" class="btn">버그 발생 시 →</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

---

## Task 4: 스킬 상세 페이지 — 장기 실행 2종 + Review Work

**Dependencies:** Task 1 (CSS)
**Files:**
- Create: `skills/milestone-planning.html`
- Create: `skills/long-run.html`
- Create: `skills/review-work.html`

서로 독립 파일이므로 병렬 실행 가능합니다.

- [ ] **Step 1: Create milestone-planning.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Milestone Planning — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="clarification.html">Clarification</a></li>
    <li><a href="long-run.html">Long Run</a></li>
    <li><a href="milestone-planning.html" class="active">Milestones</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">장기 실행</span>
      <span class="skill-badge blue">5개 병렬 리뷰어</span>
    </div>
    <h1>Milestone Planning</h1>
    <p style="font-size:1.1rem;">5개의 독립적인 리뷰어 에이전트가 병렬로 리뷰하고, 결과를 합성해 최적화된 마일스톤 의존성 DAG를 만듭니다.</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      Clarification이 <strong>복잡(Complex)</strong> 판정(점수 9-15)을 내린 직후. 며칠에 걸친 작업이 필요할 때.
    </div>
    <ul>
      <li><code>"마일스톤 계획해줘"</code>, <code>"마일스톤으로 나눠줘"</code>, <code>"ultraplan"</code></li>
      <li>작업이 2-3개 이상의 독립적 하위 태스크로 분해될 때</li>
    </ul>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> 5개 리뷰어는 서로 <em>정보 격리</em>되어 있습니다. 교차 오염 없이 각자의 관점에서 계획을 비판합니다.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>Problem Brief</strong>
          <p>문제를 프레임화합니다 — 목표, 범위, 제약사항.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>5개 병렬 리뷰어 동시 생성</strong>
          <p><strong>Feasibility</strong> — 실현 가능한가? / <strong>Architecture</strong> — 구조가 올바른가? / <strong>Risk</strong> — 위험 요소는? / <strong>Dependency</strong> — 의존성 순서가 맞는가? / <strong>User Value</strong> — 사용자에게 필요한가?</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>합성 — 마일스톤 DAG</strong>
          <p>5개 리뷰어 결과를 Conflict Resolution Log와 함께 종합. 자동 통합 검증 마일스톤이 마지막으로 추가됩니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">4</div>
        <div>
          <strong>독립 DAG 검증</strong>
          <p>메인 에이전트가 순환 의존, 파일 충돌, 성공 기준 품질을 독립적으로 검증합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">5</div>
        <div>
          <strong>사용자 승인 → Harness 잠금</strong>
          <p>승인된 마일스톤이 harness 상태 디렉토리에 잠깁니다. <a href="long-run.html">Long Run</a>으로 실행 진입.</p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>마일스톤 수 가드</h2>
    <div class="callout">
      7개 초과: 경고 / 10개 초과: 사용자 추가 승인 필요. 과도한 분할은 관리 오버헤드를 만듭니다.
    </div>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="clarification.html" class="btn">← Clarification</a>
      <a href="long-run.html" class="btn">Long Run →</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

- [ ] **Step 2: Create long-run.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Long Run — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="milestone-planning.html">Milestones</a></li>
    <li><a href="long-run.html" class="active">Long Run</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">장기 실행</span>
      <span class="skill-badge blue">체크포인트</span>
    </div>
    <h1>Long Run</h1>
    <p style="font-size:1.1rem;">며칠에 걸친 실행을 오케스트레이션합니다. 디스크 체크포인트로 크래시에서 생존하고, 병렬 마일스톤을 worktree 격리로 실행합니다.</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      Milestone Planning이 완료된 직후. 또는 며칠에 걸친 대규모 리팩토링/기능 개발이 필요할 때.
    </div>
    <ul>
      <li><code>"long run"</code>, <code>"장기 실행 시작"</code>, <code>"마일스톤 실행해줘"</code></li>
    </ul>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> 모든 마일스틴이 독립적인 plan-crafting → run-plan → review-work 사이클을 거칩니다. 실패한 마일스틴은 후속 마일스틴을 차단합니다.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>마일스틴 순차 실행</strong>
          <p>각 마일스틴: plan-crafting → run-plan → review-work → 체크포인트 저장.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>재시도 에스컬레이션</strong>
          <p>재실행 → 재계획 → 중단 (3회 시도, 영구 카운터 유지).</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>병렬 마일스틴 (worktree 격리)</strong>
          <p>의존성이 없는 마일스틴은 별도 git worktree에서 동시에 실행됩니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">4</div>
        <div>
          <strong>크로스-마일스틴 통합 검사</strong>
          <p>각 마일스틴 완료 후 통합 검사를 실행합니다. 마일스틴 간 간섭을 탐지.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">5</div>
        <div>
          <strong>Final E2E 게이트</strong>
          <p>전체 완료 후 최종 End-to-End 검증. Simplify로 코드 품질 정리, Systematic Debugging으로 이슈 해결.</p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>내구성 설계</h2>
    <table>
      <tr><th>기능</th><th>설명</th></tr>
      <tr><td>디스크 체크포인트</td><td><code>state.md</code>에 모든 상태 전환 기록 — 크래시 생존</td></tr>
      <tr><td>복구 프로토콜</td><td>중단된 세션에서 마지막 체크포인트부터 재개</td></tr>
      <tr><td>Rate limit 처리</td><td>Claude Code 내장 재시도와 정렬됨</td></tr>
      <tr><td>컨텍스트 윈도우 관리</td><td>장기 대화를 위해 자동 압축 및 상태 분리</td></tr>
    </table>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="milestone-planning.html" class="btn">← Milestone Planning</a>
      <a href="simplify.html" class="btn">Simplify →</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

- [ ] **Step 3: Create review-work.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Review Work — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="run-plan.html">Run Plan</a></li>
    <li><a href="review-work.html" class="active">Review Work</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">워크플로</span>
      <span class="skill-badge blue">정보 격리 검증</span>
    </div>
    <h1>Review Work</h1>
    <p style="font-size:1.1rem;">정보가 격리된 실행 후 검증. 계획 문서와 코드베이스만 읽습니다 — 실행 로그나 worker 출력은 받지 않습니다.</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      Run Plan 또는 Long Run 완료 직후. "<em>구현이 계획을 제대로 따랐는가?</em>"를 독립적으로 검증해야 할 때.
    </div>
    <ul>
      <li><code>"작업 검토해줘"</code>, <code>"구현 확인해줘"</code></li>
      <li>run-plan 완료 후 자동 전환</li>
    </ul>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> Reviewer는 <strong>정보 격리</strong>됩니다. 계획 문서만 받고, 실행 로그나 worker 출력은 받지 않습니다. 구현자의 의도가 아니라 오직 결과만 평가합니다.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>계획 로드 및 파싱</strong>
          <p>계획 파일만 읽습니다. 목표, 범위, 수락 기준을 추출.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>코드베이스 검사</strong>
          <p>계획된 파일 vs 실제 파일을 대조. 잔여 아티팩트(TODO, 비어있는 함수 등) 탐지.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>테스트 독립 실행</strong>
          <p>계획에 명시된 테스트를 직접 실행합니다 — worker의 테스트 결과를 신뢰하지 않음.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">4</div>
        <div>
          <strong>Git 히스토리 검증</strong>
          <p>계획된 커밋이 실제로 있는지 히스토리와 대조합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">5</div>
        <div>
          <strong>이진 판정 (PASS/FAIL)</strong>
          <p>구조화된 검토 문서를 <code>docs/engineering-discipline/reviews/</code>에 저장합니다. 코드를 수정하지 않습니다 — 보고만 합니다.</p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>왜 정보를 격리하나요?</h2>
    <div class="callout">
      Worker의 출력을 본 Reviewer는 "의도는 좋았으니 통과"하는 편향을 가집니다. 정보 격리는 <strong>결과만</strong>으로Plans are executable documents with real code in every step — no placeholders.

All tasks have exact file paths, dependencies, and verification steps.

Self-review passed: no placeholders, full code coverage, consistent types, correct dependencies.

How would you like to proceed?

1. Subagent execution (recommended) — dispatch a fresh subagent per task
2. Inline execution — execute tasks in this session using the run-plan skill 검증의 공정성을 보장합니다.
    </div>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="run-plan.html" class="btn">← Run Plan</a>
      <a href="systematic-debugging.html" class="btn">버그 발견 시 →</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

---

## Task 5: 스킬 상세 페이지 — 독립 스킬 5종

**Dependencies:** Task 1 (CSS)
**Files:**
- Create: `skills/karpathy.html`
- Create: `skills/clean-ai-slop.html`
- Create: `skills/simplify.html`
- Create: `skills/systematic-debugging.html`
- Create: `skills/rob-pike.html`

서로 독립 파일이므로 병렬 실행 가능합니다.

- [ ] **Step 1: Create karpathy.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Karpathy Guidelines — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="karpathy.html" class="active">Karpathy</a></li>
    <li><a href="clean-ai-slop.html">Clean AI Slop</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">독립</span>
      <span class="skill-badge blue">예방 가드레일</span>
    </div>
    <h1>Karpathy Guidelines</h1>
    <p style="font-size:1.1rem;">코드 구현을 위한 예방적 가드레일 — 수술적 변경, 가정 검증, 범위 규율을 코딩 전과 코딩 중에 강제합니다.</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      기능 구현 <strong>전</strong>과 코딩 <strong>중</strong>에 작동합니다. LLM의 흔한 실수를 사전에 차단합니다.
    </div>
    <ul>
      <li>기능 구현을 시작하기 전</li>
      <li>기존 컨텍스트를 읽지 않고 코드를 생성하려 할 때</li>
      <li>코드 수정 시</li>
    </ul>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> 예외 없는 5가지 하드 규칙. 각 규칙 위반 시 변경을 멈추고 규칙을 따르도록 수정합니다.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>수술적 변경 — Minimum Edit Needed</strong>
          <p>목표를 충족하는 최소 변경만 합니다. 리팩토링은 별도 작업입니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>기존 코드 읽기 전까지 수정 금지</strong>
          <p>수정할 파일의 현재 컨벤션을 먼저 파악합니다. 읽지 않고 추측하지 않습니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>모든 가정 검증</strong>
          <p>API, 함수 시그니처, 동작 — 읽거나 grep으로 확인합니다. 추측으로 코딩하지 않습니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">4</div>
        <div>
          <strong>구체적 성공 기준 정의</strong>
          <p>코딩 전 "이렇게 되면 완료"를 명확히 합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">5</div>
        <div>
          <strong>가상의 미래 문제 해결 금지</strong>
          <p>"나중에 필요할 것 같아서" 추가하는 추상화, 설정, 검증은 하지 않습니다.</p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="clean-ai-slop.html" class="btn">Clean AI Slop →</a>
      <a href="systematic-debugging.html" class="btn">버그 발생 시 →</a>
      <a href="rob-pike.html" class="btn">성능 우려 시 →</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

- [ ] **Step 2: Create clean-ai-slop.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Clean AI Slop — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="karpathy.html">Karpathy</a></li>
    <li><a href="clean-ai-slop.html" class="active">Clean AI Slop</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">독립</span>
      <span class="skill-badge blue">6단계 정리</span>
    </div>
    <h1>Clean AI Slop</h1>
    <p style="font-size:1.1rem;">AI 생성 코드의 교정적 정리. 동작을 보존하면서 LLM 특유의 패턴을 제거합니다. 회귀 테스트 우선, 단일 스멜 패스 규율.</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      대규모 AI 코드 생성 세션 이후. 또는 <code>"정리해줘"</code>, <code>"deslop"</code>, <code>"AI 코드 정리"</code>라고 말했을 때.
    </div>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> 테스트로 동작을 먼저 잠근 다음, 6개 스멜 카테고리를 <strong>순차적 패스</strong>로 정리합니다. 각 패스 전후로 테스트를 실행하고 실패 시 되돌립니다.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">0</div>
        <div>
          <strong>테스트로 동작 잠금</strong>
          <p>정리 전 테스트를 실행해 통과 상태를 확인합니다. 회귀 기준점.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>死 code 제거</strong>
          <p>사용하지 않는 함수, 변수, import, 리턴값.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>과잉 주석 제거</strong>
          <p>명백한 코드를 설명하는 주석, "이 함수는 ~한다" 타입의 LLM 필러.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>불필요 추상화 제거</strong>
          <p>한 번만 쓰는 헬퍼, 과도한 인터페이스, wrapper.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">4</div>
        <div>
          <strong>방어적 편집증 제거</strong>
          <p>불가능한 케이스 핸들링, 과잉 검증, null 체크 폭포.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">5</div>
        <div>
          <strong>장황한 네이밍 정리</strong>
          <p>AnalyzeAndProcessTheData → processData</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">6</div>
        <div>
          <strong>LLM 필러 아티팩트 제거</strong>
          <p>"이 코드는 ~합니다" 타입의 자체 설명 주석, 과도한 docstring.</p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>하드 게이트</h2>
    <div class="callout">
      동작을 테스트로 잠그기 전 <strong>어떤 정리도 시작하지 않습니다</strong>. AI가 touch한 파일만 대상으로 합니다.
    </div>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="karpathy.html" class="btn">← Karpathy</a>
      <a href="simplify.html" class="btn">Simplify →</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

- [ ] **Step 3: Create simplify.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Simplify — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="simplify.html" class="active">Simplify</a></li>
    <li><a href="systematic-debugging.html">Debugging</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">독립</span>
      <span class="skill-badge blue">3개 병렬 리뷰어</span>
    </div>
    <h1>Simplify</h1>
    <p style="font-size:1.1rem;">재사용, 품질, 효율성 — 3개 병렬 리뷰어가 변경된 코드를 검토하고 발견된 문제를 수정합니다.</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      구현 완료 후 코드 품질을 높이고 싶을 때. Long Run의 마지막 정제 단계로도 사용됩니다.
    </div>
    <ul>
      <li><code>"simplify"</code>, <code>"코드 정리해줘"</code>, <code>"변경사항 검토해줘"</code></li>
    </ul>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> 세 리뷰어는 같은 diff를 보지만 <strong>서로 다른 렌즈</strong>로 분석합니다. 중복 findings는 통합되고, 최소 수정만 적용됩니다.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>변경사항 식별</strong>
          <p><code>git diff</code>로 최근 변경된 파일을 파악합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>3개 병렬 리뷰어 동시 생성</strong>
          <p><strong>Agent 1 — 재사용:</strong> 중복 코드, 기존 유틸리티로 인라인 가능한 로직.<br><strong>Agent 2 — 품질:</strong> 중복 상태, 파라미터 과다, 사본-붙여넣기 변형, 추상화 누수, 문자열 타입 코드, 불필요 주석.<br><strong>Agent 3 — 효율성:</strong> 불필요 작업, 누락된 동시성, 핫패스 비대, TOCTOU, 메모리 누수.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>통합 + 최소 수정</strong>
          <p>results를 집계하고 중복을 제거한 뒤, 최소 수정을 적용하고 테스트를 실행합니다.</p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="long-run.html" class="btn">← Long Run</a>
      <a href="review-work.html" class="btn">Review Work →</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

- [ ] **Step 4: Create systematic-debugging.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Systematic Debugging — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="simplify.html">Simplify</a></li>
    <li><a href="systematic-debugging.html" class="active">Debugging</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">독립</span>
      <span class="skill-badge blue">7단계</span>
    </div>
    <h1>Systematic Debugging</h1>
    <p style="font-size:1.1rem;">재현 우선, 근본 원인 우선, 실패 테스트 우선. "하면서 다른 것도 고치는" 행위를 차단하는 엄격한 디버깅 워크플로입니다.</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      버그, 테스트 실패, 예상치 못한 동작 — <strong>무엇이든</strong> 고쳐야 할 때.
    </div>
    <ul>
      <li>런타임 에러, 테스트 실패, 예기치 않은 동작</li>
      <li>Run Plan 또는 Long Run 실패 시 자동 전환</li>
      <li>"이 테스트가 불안정해", "버그 있어"</li>
    </ul>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> 재현 없으면 수정 없습니다. 가설 없으면 수정 없습니다. 한 번에 하나의 가설만.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>문제 정의 (한 문장)</strong>
          <p>"무엇이 기대와 다른가"를 한 문장으로 명확히 합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>재현 또는 계측</strong>
          <p>최소 재현 경로를 확보합니다. 재현 불가면 계측부터.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>컴포넌트 경계에서 증거 수집</strong>
          <p>입력/출력을 추적하여 실패 지점을 좁힙니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">4</div>
        <div>
          <strong>단일 근본 원인 가설 분리</strong>
          <p>"A가 B 때문에 실패한다" — 하나의 구체적 가설.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">5</div>
        <div>
          <strong>실패 테스트로 고정</strong>
          <p>가설을 증명하는 실패 테스트를 작성합니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">6</div>
        <div>
          <strong>가설당 하나의 수정</strong>
          <p>한 가설, 한 수정. 리팩토링 금지.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">7</div>
        <div>
          <strong>검증 및 종료</strong>
          <p>테스트 통과 → 종료. 3회 실패 시 구조적 문제 분석.</p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>하드 게이트</h2>
    <table>
      <tr><th>규칙</th><th>설명</th></tr>
      <tr><td>재현 금지</td><td>재현 없이는 수정하지 않음</td></tr>
      <tr><td>가설 금지</td><td>가설 없이는 수정하지 않음</td></tr>
      <tr><td>한 번에 하나</td><td>동시 다중 가설/수정 금지</td></tr>
      <tr><td>"하면서" 금지</td><td>"while I'm here" 리팩토링 금지</td></tr>
    </table>
  </section>

  <section>
    <h2>참고 가이드</h2>
    <ul>
      <li><strong>조건 기반 대기</strong> — 불안정한 타임아웃을 안정적인 조건 폴링으로 교체</li>
      <li><strong>심층 방어 검증</strong> — 데이터가 통과하는 모든 레이어에서 검증</li>
      <li><strong>근본 원인 추적</strong> — 호출 체인을 역추적하여 원래 트리거 찾기</li>
      <li><strong>오염자 찾기 스크립트</strong> — 원치 않는 파일/상태를 생성하는 테스트를 찾는 이분법 스크립트</li>
    </ul>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="run-plan.html" class="btn">← Run Plan</a>
      <a href="rob-pike.html" class="btn">Rob Pike →</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

- [ ] **Step 5: Create rob-pike.html**

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/engineering-discipline/">
  <title>Rob Pike's 5 Rules — Engineering Discipline</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="icon" type="image/svg+xml" href="../assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700;900&display=swap" rel="stylesheet">
</head>
<body>

<nav class="nav">
  <a href="../index.html" class="nav-brand">▣ Engineering Discipline</a>
  <ul class="nav-links">
    <li><a href="../index.html">홈</a></li>
    <li><a href="systematic-debugging.html">Debugging</a></li>
    <li><a href="rob-pike.html" class="active">Rob Pike</a></li>
  </ul>
</nav>

<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">독립</span>
      <span class="skill-badge blue">측정 우선</span>
    </div>
    <h1>Rob Pike's 5 Rules</h1>
    <p style="font-size:1.1rem;">조기 최적화를 방지하고 측정 기반 개발을 강제합니다. "느려 보여도 측정 전에는 만지지 않는다."</p>
  </div>
</div>

<div class="container">

  <section>
    <h2>언제 사용하나요?</h2>
    <div class="callout">
      성능 개선이 필요할 때 — 최적화를 <strong>시작하기 직전</strong>에 작동합니다.
    </div>
    <ul>
      <li><code>"최적화"</code>, <code>"느려"</code>, <code>"성능"</code>, <code>"병목"</code>, <code>"빠르게"</code></li>
      <li>이 루프가 느려 보인다는 느낌이 들 때</li>
    </ul>
  </section>

  <section>
    <h2>어떻게 동작하나요?</h2>

    <div class="callout blue">
      <strong>핵심 원리:</strong> "이 루프가 느려 보인다" → <em>"프로파일링 해보셨나요?"</em>. 측정이 병목을 확인하고, 가장 단순한 변경이 최적화가 됩니다.
    </div>

    <div class="flow-steps">
      <div class="flow-step">
        <div class="flow-number">1</div>
        <div>
          <strong>Rule 1: 병목을 예측할 수 없다</strong>
          <p>누가 어디가 느린지 맞추지 않습니다. 프로파일러가 알려줍니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">2</div>
        <div>
          <strong>Rule 2: 튜닝 전 측정</strong>
          <p>기존 계측(loge, profiling, timing, APM)을 스캔하고, 없으면 계측부터.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">3</div>
        <div>
          <strong>Rule 3: n이 작으면 복잡한 알고리즘도 느리다</strong>
          <p>그리고 n은 보통 작습니다. 단순한 코드가 이깁니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">4</div>
        <div>
          <strong>Rule 4: 복잡한 알고리즘은 버그도 많다</strong>
          <p>단순한 알고리즘이 유지보수도 쉽고 디버깅도 쉽습니다.</p>
        </div>
      </div>
      <div class="flow-step">
        <div class="flow-number">5</div>
        <div>
          <strong>Rule 5: 데이터 구조가 핵심이다</strong>
          <p>올바른 데이터 구조를 선택하면 알고리즘은 자명해집니다.</p>
        </div>
      </div>
    </div>
  </section>

  <section>
    <h2>적용 순서</h2>
    <div class="callout">
      1. 기존 계측 확인 → 2. 측정 질문 → 3. 병목 확인 시 가장 단순한 수정 제안 → 4. 변경 후 재측정으로 검증
    </div>
  </section>

  <section>
    <h2>연결된 스킬</h2>
    <p>
      <a href="systematic-debugging.html" class="btn">← Systematic Debugging</a>
      <a href="../index.html" class="btn btn-primary">← 홈</a>
    </p>
  </section>

</div>

<footer class="footer">
  <p><a href="https://github.com/tmdgusya/engineering-discipline">tmdgusya/engineering-discipline</a> · MIT License</p>
</footer>

</body>
</html>
```

---

## Task 6: GitHub Actions 배포 설정

**Dependencies:** Task 1 (파일 구조 완성 후)
**Files:**
- Create: `.github/workflows/deploy.yml`

- [ ] **Step 1: Create GitHub Pages workflow**

먼저 `.github/workflows/` 디렉토리를 생성합니다.

- [ ] **Step 2: Create deploy.yml**

```yaml
# .github/workflows/deploy.yml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Pages
        uses: actions/configure-pages@v4
        with:
          enablement: true

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: .

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

---

## Task 7 (Final): 최종 검증

**Dependencies:** All preceding tasks
**Files:** None (read-only verification)

- [ ] **Step 1: Verify all files exist**

```bash
cd /home/roach/engineering-discipline
ls -la index.html css/style.css assets/favicon.svg
ls -la skills/*.html
ls -la .github/workflows/deploy.yml
```

Expected: All files present.

- [ ] **Step 2: Verify cross-page links**

```bash
cd /home/roach/engineering-discipline
# Check that all href targets exist
grep -roh 'href="[^"]*\.html"' index.html | sed 's/href="//;s/"//' | sort -u
grep -roh 'href="[^"]*\.html"' skills/*.html | sed 's/href="//;s/"//' | sort -u
```

Expected: All referenced HTML files exist in the repository. Missing links indicate a broken navigation path.

- [ ] **Step 3: Verify CSS loads correctly**

```bash
cd /home/roach/engineering-discipline
# Confirm all pages reference the same CSS file
grep -l 'style.css' index.html skills/*.html | wc -l
```

Expected: 12 (index + 11 skill pages).

- [ ] **Step 4: Verify deploy workflow syntax**

```bash
cd /home/roach/engineering-discipline
# Verify YAML is valid
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/deploy.yml'))"
```

Expected: No errors.

- [ ] **Step 5: Success criteria checklist**

Manually check each criterion:
- [ ] index.html에 워크플로우 다이어그램과 스킬 맵이 포함됨
- [ ] 11개 스킬 상세 페이지 각각 "언제", "어떻게", "연결된 스킬" 포함
- [ ] Neo-Brutalist 디자인 일관성 (#FFFFFF/#000000/#0000FF, 4-8px border, hard shadow)
- [ ] 한국어 콘텐츠, Noto Sans KR 웹폰트
- [ ] GitHub Actions 배포 워크플로 설정됨
- [ ] 모든 페이지 간 링크 정상 작동
