# Qwen + gl-switcher - Threads 게시글

## 본문 (1/)

Qwen 좋다는 소문이 너무 많아서 직접 써봤습니다.
상당히 괜찮습니다.

Qwen Cloud 구독 고려 중이고,
Minimax 3 안 나오면 잠시 갈아탈까 싶습니다.

## 답글 1 — 어떻게 쓰고 있는가 (2/)

OpenRouter에 무료 Qwen 모델이 있어서
Claude Code에 물려서 돌려봤습니다.

기대 안 하고 써봤는데 생각보다 잘 따라옵니다.
가벼운 작업은 이쪽으로 충분해요.

## 답글 2 — 모델 전환 (3/)

모델을 자주 갈아끼우다 보니
환경변수 전환이 귀찮아서 gt라는 셸 유틸을 만들었었는데,
이번에 OpenRouter도 지원하도록 추가했습니다.

`gt o` 한 줄이면 OpenRouter,
`gt m`이면 Minimax, `gt c`면 Anthropic.

tmux teammate pane 환경변수 동기화도 자동으로 처리합니다.

github.com/tmdgusya/gl-switcher

## 답글 3 — 현재 셋업 (4/)

지금 제 셋업:
- 본격 작업: Anthropic / Minimax
- 실험 + 가벼운 작업: Qwen (OpenRouter)

모델은 상황에 따라 바꿉니다.
고정할 필요 없어요.
