# Why AI coding agents spiral — and how I fixed it with engineering discipline

AI coding agents fail for a simple reason: they start writing code before they know what to build.

You say "build this for me" and the agent immediately starts coding. When requirements are vague, it fills in gaps with guesses. Wrong guess → revert → guess again → wrong again. This loop eats through the context window until the whole thing collapses. Especially brutal on long-running tasks.

I built an open-source skill set called **engineering-discipline** that enforces a structured workflow to prevent this.

## How it works

**Clarification first** — Before a single line of code is written, the agent runs iterative Q&A to eliminate ambiguity. In parallel, it explores the codebase to understand existing structure. Only after "what to build" is crystal clear does it move on.

**Automatic complexity routing** — Once requirements are locked, complexity is scored automatically. Simple tasks get plan → execute → review. Complex tasks get decomposed into a milestone DAG for long-running execution.

**Worker-Validator separation** — The agent that writes code and the agent that reviews it are completely separate. The reviewer has zero knowledge of the execution process — it only reads the plan document and inspects the codebase from scratch. Same information isolation as human code review.

**Checkpoint-based recovery** — Every milestone has a checkpoint. If something fails, it resumes from that point instead of restarting from zero. Hours of work don't get thrown away.

**Implementation guardrails (Karpathy skill)** — Forces the agent to read existing code before writing anything, and blocks it from touching code outside the requested scope. "While I'm here, I should also fix this..." is the #1 killer of long-running agent tasks.

**AI slop removal** — AI-generated code works, but it smells. Over-commenting, unnecessary abstractions, defensive error handling for impossible cases, verbose naming. The clean-ai-slop skill removes these category by category, running tests after each pass to ensure behavior stays identical. The output isn't "AI-written code" — it's just good code.

## The surprising part

I originally built this as a harness optimized for Minimax. But when I paired it with Codex or Opus, it actually performed *better*. Turns out when the discipline is solid, you can swap models and success rates go up. What matters isn't the model — it's the harness.

## Benchmark: RealWorld one-shot

To put numbers on this, I ran it against the [RealWorld](https://github.com/realworld-apps/realworld) spec — a Medium.com clone with 19 API endpoints across 6 domains. The rules: one shot, no retries, no human intervention during execution.

**13/13 Hurl test files, 149 requests, 100% pass. 7 minutes 32 seconds.**

Full source and session transcript: [github.com/tmdgusya/realworld-benchmark](https://github.com/tmdgusya/realworld-benchmark)

## Details

- Works with **Claude Code, Gemini CLI, Cursor, Codex, and OpenCode**
- MIT license
- GitHub: [github.com/tmdgusya/engineering-discipline](https://github.com/tmdgusya/engineering-discipline)

Happy to answer questions about the architecture or design decisions.
