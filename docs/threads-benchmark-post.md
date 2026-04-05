# Engineering Discipline - Threads 벤치마크 게시글

## 본문 (1/)

engineering-discipline으로 RealWorld 벤치마크를 돌려봤습니다.
원샷, 재시도 없음.

13/13 테스트 파일, 149 requests, 100% pass.
7분 32초.

## 답글 1 — RealWorld가 뭔데 (2/)

RealWorld는 Medium.com 클론 API 스펙입니다.
todo 앱 같은 장난감이 아니에요.

회원가입, 로그인, 기사 CRUD, 댓글, 좋아요, 팔로우, 피드, 태그.
19개 엔드포인트, 6개 도메인, 149개 테스트 케이스.

100개 넘는 구현체가 있는 업계 표준 벤치마크입니다.

## 답글 2 — 규칙 (3/)

규칙은 간단합니다.

OpenAPI 스펙이랑 Hurl 테스트 파일을 줌.
스택 지정해줌 (TypeScript, Express, Prisma, SQLite).
"만들어" 하고 끝.

사람이 중간에 개입 안 함.
재시도 안 함.
한 번에 통과해야 함.

## 답글 3 — 에이전트가 한 일 (4/)

에이전트가 먼저 한 건 코드 쓰기가 아닙니다.

Hurl 테스트 14개를 전부 읽고,
빈 문자열 → null 변환, tagList: null 거부, 중복 제목 slug 처리 같은
엣지 케이스를 먼저 전부 뽑아냈어요.

그 다음에 의존성 순서로 계획 세우고, 그제서야 코드를 씁니다.

## 답글 4 — 결과물 (5/)

코드 약 700줄. 파일 8개.
Prisma 모델 7개.

과잉 추상화 없음.
불필요한 헬퍼 없음.
주석은 "왜"가 필요한 곳에만.

AI가 쓴 티가 안 나는 코드입니다.

## 답글 5 — 숫자 (6/)

```
Executed files:    13
Executed requests: 149 (122.8/s)
Succeeded files:   13 (100.0%)
Failed files:      0 (0.0%)
Duration:          1213 ms
```

벽시계 기준 7분 32초.
이 중 상당 부분이 hurl 설치 삽질입니다.
실제 구현은 그보다 짧아요.

## 답글 6 — 소스와 transcript (7/)

전체 소스코드와 Claude Code 세션 transcript를
그대로 공개합니다.

숨길 게 없으니까.

github.com/tmdgusya/realworld-benchmark

transcript가 한국어라 번역기 돌려야 할 수 있는데,
흐름은 보일 겁니다: 스펙 분석 → 계획 → 실행 → 테스트 통과.
