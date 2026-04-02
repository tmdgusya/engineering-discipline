# Engineering Discipline

[English](README.md) | [中文](README.cn.md)

AI 코딩 에이전트를 위한 엔지니어링 규율 스킬. Claude Code, Gemini CLI, OpenCode, Codex, Cursor에서 사용 가능합니다.

## 작동 방식

스킬이 체인으로 연결되어 모호한 요청부터 검증된 구현까지 처리합니다:

```
사용자 요청
    |
clarification ─── 모호성 해소, 코드베이스 탐색
    |
    |── 복잡도 평가 (자동 라우팅)
    |       |
    |       |── 단순 (점수 5-8)
    |       |       |
    |       |       plan-crafting ─── 실행 가능한 계획 생성
    |       |           |
    |       |       run-plan ─── worker-validator 실행 루프
    |       |           |
    |       |       review-work ─── 정보 격리된 검증
    |       |
    |       |── 복잡 (점수 9-15)
    |               |
    |           milestone-planning ─── 5개 병렬 리뷰어 + 합성
    |               |
    |           long-run ─── 다일 오케스트레이터
    |               |── M1: plan-crafting → run-plan → review-work → 체크포인트
    |               |── M2: plan-crafting → run-plan → review-work → 체크포인트
    |               |── ...
    |
    |── simplify ─── 구현 후 코드 품질 검토
    |── systematic-debugging ─── 재현 우선 버그 수정
    |── rob-pike ─── 측정 기반 최적화
```

이걸 외울 필요 없습니다. 각 스킬은 트리거 문구와 컨텍스트에 따라 자동으로 활성화됩니다.

## 스킬

### 워크플로 스킬 (체인으로 연결)

#### Clarification (명확화)

반복적인 Q&A + 병렬 코드베이스 탐색을 통해 모호한 요청을 명확한 작업 범위로 좁힙니다. 자동 복잡도 라우팅이 포함된 Context Brief를 출력합니다.

**트리거:** "~하고 싶어", "~이 필요해", "~을 만들자", 또는 범위가 즉시 명확하지 않은 모든 요청.

#### Plan Crafting (계획 작성)

명확한 범위로부터 실행 가능한 다단계 구현 계획을 생성합니다. 모든 단계에 실제 코드가 포함되어야 합니다 — 플레이스홀더는 허용되지 않습니다.

**트리거:** "계획 세워줘", "플랜 만들어줘", 또는 clarification이 단순(Simple) 판정으로 완료된 후.

#### Run Plan (계획 실행)

worker-validator 쌍을 사용하여 계획을 실행합니다. Worker가 구현하고, Validator가 worker의 접근 방식에 대한 지식 없이 독립적으로 검증합니다.

**트리거:** "계획 실행해", "플랜 돌려줘", 또는 plan-crafting 완료 후.

#### Review Work (작업 검토)

정보가 격리된 실행 후 검증. 계획 문서와 코드베이스만 읽습니다 — 실행 로그나 worker 출력은 받지 않습니다.

**트리거:** "작업 검토해줘", "구현 확인해줘", 또는 run-plan 완료 후.

#### Simplify (단순화)

3개의 병렬 에이전트(재사용, 품질, 효율성)를 통해 변경된 코드를 검토한 후 발견된 문제를 수정합니다.

**트리거:** "simplify", "코드 정리해줘", "변경사항 검토해줘".

### 장기 실행

며칠에 걸친 복잡한 작업을 위한 스킬입니다.

#### Milestone Planning (마일스톤 계획, Ultraplan)

5개의 독립적인 리뷰어 에이전트를 병렬로 생성합니다 — 실현가능성, 아키텍처, 리스크, 의존성, 사용자 가치 — 그리고 그 결과를 합성하여 최적화된 마일스톤 의존성 DAG를 만듭니다.

**트리거:** "마일스톤 계획해줘", "마일스톤으로 나눠줘", "ultraplan", 또는 clarification에서 복잡(Complex) 판정 (점수 9-15) 후.

**주요 기능:**
- 정보 격리된 5개 병렬 리뷰어 (교차 오염 없음)
- 충돌 해결 로그가 포함된 합성 에이전트
- 합성 후 독립적 DAG 검증
- 마일스톤 수 가드 (7개 초과 경고, 10개 초과 시 승인 필요)

#### Long Run Harness (장기 실행 하네스)

며칠에 걸친 실행을 오케스트레이션합니다. 각 마일스톤은 plan-crafting, run-plan, review-work를 거치며 체크포인트/복구를 지원합니다.

**트리거:** "long run", "장기 실행 시작", "마일스톤 실행해줘".

**주요 기능:**
- 모든 단계 전환 시 디스크에 상태 저장 (크래시에서 생존)
- 재시도 에스컬레이션: 재실행 → 재계획 → 중단 (영구 카운터 포함)
- worktree 격리를 통한 병렬 마일스톤 실행
- 중단된 세션을 위한 복구 프로토콜
- Claude Code 내장 재시도와 정렬된 rate limit 처리
- 장기 대화를 위한 컨텍스트 윈도우 관리
- 실행 중 수정 및 마일스톤 추가 절차

### 독립 스킬

#### Rob Pike's 5 Rules (Rob Pike의 5가지 규칙)

조기 최적화를 방지하고 측정 기반 개발을 강제하는 의사결정 프레임워크입니다.

**트리거:** "최적화", "느려", "성능", "병목", "빠르게", "속도 올려"

#### Systematic Debugging (체계적 디버깅)

엄격한 디버깅 워크플로: 재현 우선, 근본 원인 우선, 실패 테스트 우선.

**트리거:** 모든 버그, 테스트 실패, 또는 예상치 못한 동작.

**참고 가이드:**
- [조건 기반 대기](skills/systematic-debugging/condition-based-waiting.md) — 불안정한 타임아웃을 안정적인 조건 폴링으로 교체
- [심층 방어 검증](skills/systematic-debugging/defense-in-depth.md) — 데이터가 통과하는 모든 레이어에서 검증
- [근본 원인 추적](skills/systematic-debugging/root-cause-tracing.md) — 호출 체인을 역추적하여 원래 트리거 찾기
- [오염자 찾기 스크립트](skills/systematic-debugging/find-polluter.sh) — 원치 않는 파일/상태를 생성하는 테스트를 찾는 이분법 스크립트

## 빠른 시작

설치 후, 하고 싶은 것을 그냥 설명하면 됩니다:

- **"API에 인증을 추가하고 싶어"** — clarification이 트리거되고, 복잡도에 따라 plan-crafting 또는 milestone-planning으로 라우팅
- **"계획 실행해"** — worker-validator 검증으로 계획을 실행
- **"이 테스트가 불안정해"** — systematic-debugging 트리거
- **"API가 느려"** — rob-pike 측정 우선 워크플로 트리거
- **"simplify"** — 최근 변경사항의 재사용, 품질, 효율성 검토
- **"long run"** — 체크포인트가 포함된 다일 마일스톤 실행 시작

## 설치

### Claude Code

```
/plugin marketplace add tmdgusya/engineering-discipline
/plugin install engineering-discipline
```

### Gemini CLI

```bash
gemini extensions install https://github.com/tmdgusya/engineering-discipline
```

### Cursor

플러그인 마켓플레이스에서 설치하거나:

```text
/add-plugin engineering-discipline
```

### Codex

```bash
npx skills add tmdgusya/engineering-discipline
```

또는 글로벌 설치 (모든 프로젝트에서 사용 가능):

```bash
npx skills add tmdgusya/engineering-discipline -g
```

자세한 내용은 [Codex 설치 가이드](.codex/INSTALL.md)를 참고하세요.

### OpenCode

`opencode.json`에 추가:

```json
{
  "plugin": ["engineering-discipline@git+https://github.com/tmdgusya/engineering-discipline.git"]
}
```

자세한 내용은 [OpenCode 설치 가이드](.opencode/INSTALL.md)를 참고하세요.

## 설치 확인

새 세션을 시작하고 성능 문제나 버그를 언급하세요. 관련 스킬이 자동으로 활성화됩니다.

## 마켓플레이스

이 플러그인은 Claude Code 플러그인 마켓플레이스에 등록되어 있습니다.

- **카테고리:** engineering
- **태그:** optimization, debugging, engineering, discipline, rob-pike, systematic, planning, long-running

### 마켓플레이스에서 설치

```
/plugin marketplace add tmdgusya/engineering-discipline
/plugin install engineering-discipline
```

### 업데이트 게시

`.claude-plugin/marketplace.json`에서 버전을 업데이트하고 리포지토리에 push하세요. 마켓플레이스 항목은 해당 파일에서 메타데이터를 가져옵니다.

## 라이선스

MIT
