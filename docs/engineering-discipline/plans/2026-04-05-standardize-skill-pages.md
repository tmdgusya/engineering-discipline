# Standardize Skill Detail Pages Implementation Plan

> **Worker note:** Execute this plan task-by-task. Each step uses checkbox (`- [ ]`) syntax for progress tracking.

**Goal:** 모든 11개 스킬 상세 페이지를 `index.html`의 디자인 컴포넌트(번호가 매겨진 H2, card, callout)를 사용하여 통일된 디자인으로 리팩토링합니다.

**Architecture:**
- `index.html`에서 사용된 핵심 디자인 패턴을 모든 상세 페이지에 적용합니다.
- 복잡한 전용 컴포넌트(`meta-card`, `stat-grid`, `rule-list` 등)를 `index.html`의 범용 컴포넌트(`card`, `callout`)로 대체합니다.
- 모든 섹션에 `01 ▸` 형식의 번호가 매겨진 제목을 적용합니다.
- 워크플로우 시각화는 `workflow` 클래스(ASCII box)를 사용하여 메인 페이지와 일관성을 유지합니다.

**Tech Stack:** HTML5, CSS3

**Work Scope:**
- **In scope:**
  - `skills/` 디렉토리 내 11개 HTML 파일 리팩토링
  - CSS 스타일 시트와의 정렬 (필요시 `style.css` 미세 조정)
  - 네비게이션 및 푸터 일관성 유지
- **Out of scope:**
  - 새로운 스킬 추가
  - 기능적 로직 변경 (내용은 유지)

**Verification Strategy:**
- **Level:** build-only
- **Command:** `grep -r "h2.*[0-9]\{2\} ▸" skills/`
- **What it validates:** 모든 상세 페이지의 섹션 제목이 표준화된 형식을 따름

---

## File Structure Mapping

```
/home/roach/engineering-discipline/
├── index.html                          # 디자인 참조점
├── css/
│   └── style.css                       # 공통 스타일
└── skills/
    ├── clarification.html              # 리팩토링 대상 1
    ├── plan-crafting.html              # 리팩토링 대상 2
    ├── run-plan.html                   # 리팩토링 대상 3
    ├── review-work.html                # 리팩토링 대상 4
    ├── milestone-planning.html         # 리팩토링 대상 5
    ├── long-run.html                   # 리팩토링 대상 6
    ├── karpathy.html                   # 리팩토링 대상 7
    ├── clean-ai-slop.html              # 리팩토링 대상 8
    ├── simplify.html                   # 리팩토링 대상 9
    ├── systematic-debugging.html       # 리팩토링 대상 10
    └── rob-pike.html                   # 리팩토링 대상 11
```

---

## Task 1: 디자인 표준 정의 및 CSS 업데이트

**Dependencies:** None (can run in parallel)
**Files:**
- Modify: `css/style.css`

- [ ] **Step 1: CSS에 상세 페이지용 레이아웃 보완**
`skill-header`를 메인 페이지의 Hero와 유사하게 조정하고, `workflow` 박스의 텍스트 가독성을 높입니다.

```css
/* css/style.css 수정 (기존 skill-header 부분 업데이트) */
.skill-header {
  padding: 4rem 1.5rem; /* 더 넓은 여백 */
  border-bottom: var(--border-width-thick) solid var(--black);
  background: var(--bg);
}

.skill-header h1 {
  font-size: 3.5rem; /* 더 큰 제목 */
  margin-bottom: 1rem;
}

.skill-header p {
  font-size: 1.25rem;
  max-width: 800px;
}
```

---

## Task 2: 워크플로 스킬 리팩토링 (Clarification, Plan Crafting, Run Plan)

**Dependencies:** Task 1
**Files:**
- Modify: `skills/clarification.html`
- Modify: `skills/plan-crafting.html`
- Modify: `skills/run-plan.html`

- [ ] **Step 1: Refactor clarification.html**
`meta-card`, `stat-grid`, `rule-list`를 `card`와 `callout`으로 교체합니다.

```html
<!-- skills/clarification.html 리팩토링 예시 구조 -->
<div class="skill-header">
  <div class="container">
    <div>
      <span class="skill-badge">01</span>
      <span class="skill-badge blue">출발점</span>
    </div>
    <h1>Clarification</h1>
    <p>반복적인 Q&A + 병렬 코드베이스 탐색으로 모호한 요청을 명확한 작업 범위로 좁힙니다.</p>
  </div>
</div>

<div class="container">
  <section>
    <h2>01 ▸ 워크플로우 위치</h2>
    <div class="workflow">
사용자 요청 (모호)
    │
    ▼
┌─────────────────────────────┐
│  clarification (ACTIVE)     │
│  모호성 해소 + 코드베이스 탐색 │
└──────────────┬──────────────┘
               │
      ┌────────┴────────┐
      ▼                 ▼
  단순 (5-8)       복잡 (9-15)
    </div>
  </section>

  <section>
    <h2>02 ▸ 언제 사용하나요?</h2>
    <div class="callout">...</div>
    <div class="card">
       <div class="card-title">주요 트리거</div>
       <ul>...</ul>
    </div>
  </section>
  ...
</div>
```

- [ ] **Step 2: Refactor plan-crafting.html**
동일한 패턴 적용.

- [ ] **Step 3: Refactor run-plan.html**
동일한 패턴 적용.

---

## Task 3: 검증 및 장기 실행 스킬 리팩토링 (Review Work, Milestone Planning, Long Run)

**Dependencies:** Task 1
**Files:**
- Modify: `skills/review-work.html`
- Modify: `skills/milestone-planning.html`
- Modify: `skills/long-run.html`

- [ ] **Step 1: Refactor review-work.html**
- [ ] **Step 2: Refactor milestone-planning.html**
- [ ] **Step 3: Refactor long-run.html**

---

## Task 4: 독립 스킬 리팩토링 (Karpathy, Clean AI Slop, Simplify, Systematic Debugging, Rob Pike)

**Dependencies:** Task 1
**Files:**
- Modify: `skills/karpathy.html`
- Modify: `skills/clean-ai-slop.html`
- Modify: `skills/simplify.html`
- Modify: `skills/systematic-debugging.html`
- Modify: `skills/rob-pike.html`

- [ ] **Step 1: Refactor karpathy.html**
- [ ] **Step 2: Refactor clean-ai-slop.html**
- [ ] **Step 3: Refactor simplify.html**
- [ ] **Step 4: Refactor systematic-debugging.html**
- [ ] **Step 5: Refactor rob-pike.html**

---

## Task 5 (Final): 일관성 검증 및 마무리

**Dependencies:** All preceding tasks
**Files:** None

- [ ] **Step 1: 모든 파일에서 H2 제목 형식 확인**
Run: `grep -r "h2.*[0-9]\{2\} ▸" skills/`
Expected: 모든 파일이 최소 3개 이상의 번호가 매겨진 섹션을 가짐.

- [ ] **Step 2: 네비게이션 링크 검증**
모든 페이지에서 '홈' 및 다른 스킬로의 이동이 정상적으로 작동하는지 확인.

- [ ] **Step 3: 푸터 일관성 확인**
모든 페이지의 푸터가 동일한 형식을 유지하는지 확인.
