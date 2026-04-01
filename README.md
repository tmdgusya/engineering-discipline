# Engineering Discipline

Engineering discipline skills for AI coding agents. Works with Claude Code, Gemini CLI, OpenCode, Codex, and Cursor.

## How It Works

Skills chain together to handle tasks from vague request to verified implementation:

```
User request
    |
clarification ─── resolve ambiguity, explore codebase
    |
    |── Complexity Assessment (auto-routing)
    |       |
    |       |── Simple (score 5-8)
    |       |       |
    |       |       plan-crafting ─── create executable plan
    |       |           |
    |       |       run-plan ─── worker-validator execution loop
    |       |           |
    |       |       review-work ─── information-isolated verification
    |       |
    |       |── Complex (score 9-15)
    |               |
    |           milestone-planning ─── 5 parallel reviewers + synthesis
    |               |
    |           long-run ─── multi-day orchestrator
    |               |── M1: plan-crafting → run-plan → review-work → checkpoint
    |               |── M2: plan-crafting → run-plan → review-work → checkpoint
    |               |── ...
    |
    |── simplify ─── post-implementation code quality pass
    |── systematic-debugging ─── reproduce-first bug fixing
    |── rob-pike ─── measurement-driven optimization
```

You don't need to memorize this. Each skill activates automatically based on trigger phrases and context.

## Skills

### Workflow Skills (chain together)

#### Clarification

Resolves vague requests into well-defined work scopes through iterative Q&A + parallel codebase exploration. Outputs a Context Brief with automatic complexity routing.

**Triggers on:** "I want to...", "I need...", "let's build...", or any request where scope isn't immediately clear.

#### Plan Crafting

Creates executable multi-step implementation plans from a clear scope. Every step contains actual code — no placeholders allowed.

**Triggers on:** "plan this", "create a plan", or after clarification completes with a Simple verdict.

#### Run Plan

Executes plans using worker-validator pairs. Workers implement, validators verify independently with zero knowledge of the worker's approach.

**Triggers on:** "run the plan", "execute the plan", or after plan-crafting completes.

#### Review Work

Information-isolated post-execution verification. Reads only the plan document and the codebase — receives no execution logs or worker output.

**Triggers on:** "review the work", "verify the implementation", or after run-plan completes.

#### Simplify

Reviews changed code through three parallel agents (reuse, quality, efficiency), then fixes any issues found.

**Triggers on:** "simplify", "clean up the code", "review the changes".

### Long Running Execution

For complex tasks that span multiple days.

#### Milestone Planning (Ultraplan)

Spawns 5 independent reviewer agents in parallel — feasibility, architecture, risk, dependency, user value — then synthesizes their findings into an optimized milestone dependency DAG.

**Triggers on:** "plan milestones", "break this into milestones", "ultraplan", or after clarification with a Complex verdict (score 9-15).

**Key features:**
- 5 parallel reviewers with information isolation (no cross-pollination)
- Synthesis agent with conflict resolution log
- Independent DAG validation after synthesis
- Milestone count guard (warn >7, require approval >10)

#### Long Run Harness

Orchestrates multi-day execution. Each milestone passes through plan-crafting, run-plan, review-work with checkpoint/recovery.

**Triggers on:** "long run", "start long run", "execute milestones".

**Key features:**
- State persisted to disk after every phase transition (survives crashes)
- Retry escalation: re-execute → re-plan → stop (with persistent counter)
- Parallel milestones via worktree isolation
- Recovery protocol for interrupted sessions
- Rate limit handling aligned with Claude Code's built-in retry
- Context window management for long conversations
- Mid-execution correction and milestone addition procedures

### Standalone Skills

#### Rob Pike's 5 Rules

A decision framework that prevents premature optimization and enforces measurement-driven development.

**Triggers on:** "optimize", "slow", "performance", "bottleneck", "speed up", "make faster", "too slow"

#### Systematic Debugging

Strict debugging workflow: reproduce-first, root-cause-first, failing-test-first.

**Triggers on:** Any bug, test failure, or unexpected behavior.

**Reference guides:**
- [Condition-based waiting](skills/systematic-debugging/condition-based-waiting.md) — Replace flaky timeouts with reliable condition polling
- [Defense-in-depth validation](skills/systematic-debugging/defense-in-depth.md) — Validate at every layer data passes through
- [Root cause tracing](skills/systematic-debugging/root-cause-tracing.md) — Trace backward through call chains to find the original trigger
- [Find polluter script](skills/systematic-debugging/find-polluter.sh) — Bisection script to find which test creates unwanted files/state

## Quick Start

After installation, just describe what you want to do:

- **"I want to add authentication to the API"** — triggers clarification, routes to plan-crafting or milestone-planning based on complexity
- **"run the plan"** — executes the plan with worker-validator verification
- **"this test is flaky"** — triggers systematic-debugging
- **"the API is slow"** — triggers rob-pike measurement-first workflow
- **"simplify"** — reviews recent changes for reuse, quality, and efficiency
- **"long run"** — starts multi-day milestone execution with checkpoints

## Installation

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

Install from the plugin marketplace, or:

```text
/add-plugin engineering-discipline
```

### Codex

```bash
npx skills add tmdgusya/engineering-discipline
```

Or install globally (available across all projects):

```bash
npx skills add tmdgusya/engineering-discipline -g
```

See [Codex install guide](.codex/INSTALL.md) for details.

### OpenCode

Add to your `opencode.json`:

```json
{
  "plugin": ["engineering-discipline@git+https://github.com/tmdgusya/engineering-discipline.git"]
}
```

See [OpenCode install guide](.opencode/INSTALL.md) for details.

## Verify Installation

Start a new session and mention a performance concern or a bug. The relevant skill should activate automatically.

## Marketplace

This plugin is listed in the Claude Code plugin marketplace.

- **Category:** engineering
- **Tags:** optimization, debugging, engineering, discipline, rob-pike, systematic, planning, long-running

### Install from marketplace

```
/plugin marketplace add tmdgusya/engineering-discipline
/plugin install engineering-discipline
```

### Publish updates

Update `.claude-plugin/marketplace.json` with a new version and push to the repository. The marketplace entry pulls metadata from that file.

## License

MIT
