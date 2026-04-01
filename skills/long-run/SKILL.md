---
name: long-run
description: Orchestrates multi-day execution of complex tasks through milestones. Each milestone goes through plan-crafting, run-plan (worker-validator), and review-work phases with checkpoint/recovery. Triggers when the user says "long run", "start long run", "execute milestones", or "run all milestones".
---

# Long Run Harness

Orchestrates multi-day execution of complex tasks through a milestone pipeline. Each milestone passes through plan-crafting → run-plan → review-work with checkpoints between milestones for recovery from interruptions.

## Core Principle

Long-running execution must be **resumable, auditable, and fail-safe.** Every state transition is persisted to disk before the next action begins. If execution stops for any reason — rate limit, crash, user pause, context loss — it can resume from the last checkpoint without repeating completed work.

## Hard Gates

1. **Milestones must exist before execution.** Either from `milestone-planning` skill or user-provided. Never generate milestones inline during execution.
2. **State file must be updated before and after every milestone.** No in-memory-only state. If it's not on disk, it didn't happen.
3. **Each milestone must complete the full pipeline.** plan-crafting → run-plan → review-work. No shortcuts. No skipping review-work "because it looked fine."
4. **Failed milestones block dependents.** If M2 depends on M1 and M1 fails review, M2 does not start. Period.
5. **User confirmation required at gate points.** Before starting a new milestone phase (planning, execution, review), check if the user wants to continue, pause, or abort.
6. **Never modify completed milestones.** Once a milestone passes review-work, its files are locked. If a later milestone needs changes to earlier work, that is a new milestone.
7. **Checkpoint after every milestone completion.** Write a checkpoint file recording what was done, test results, and review verdict before proceeding.

## When To Use

- After `milestone-planning` has produced a milestone DAG
- When the user says "long run", "start long run", "execute milestones", or "run all milestones"
- When resuming a previously paused long run session

## When NOT To Use

- When milestones don't exist yet (use `milestone-planning` first)
- When there's only one milestone (use plan-crafting + run-plan directly)
- For quick tasks that don't warrant multi-phase execution

## Input

1. **Harness state directory path** — e.g., `docs/engineering-discipline/harness/<session-slug>/`
2. The directory must contain `state.md` and `milestones/*.md` files

If no state directory exists, ask the user if they want to run `milestone-planning` first.

## Process

### Phase 1: Load and Validate State

1. Read `state.md` from the harness directory
2. Read all milestone files from `milestones/`
3. Validate:
   - All milestones referenced in state.md have corresponding files
   - Dependency DAG is valid (no cycles, topological sort possible)
   - No milestone is in an invalid state (e.g., "executing" without a plan file)
4. Determine current position:
   - Which milestones are completed?
   - Which milestones are ready to start (all dependencies met)?
   - Is this a fresh start or a resume?
5. Present status to the user:

```
## Long Run Status: [Session Name]

**Progress:** N/M milestones completed
**Current phase:** [planning M3 | executing M3 | reviewing M3 | ready to start M3]
**Next up:** [M3, M4 (parallel)]

Completed: M1 ✓, M2 ✓
In progress: M3 (executing)
Pending: M4, M5
```

6. Ask user to confirm: continue, pause, or abort.

### Phase 2: Milestone Execution Loop

For each milestone in topological order:

```
┌─────────────────────────────────────┐
│         Milestone Pipeline          │
│                                     │
│  ┌──────────┐    ┌─────────┐        │
│  │  Plan    │───→│  Run    │        │
│  │ Crafting │    │  Plan   │        │
│  └──────────┘    └────┬────┘        │
│                       │             │
│                  ┌────▼────┐        │
│                  │ Review  │        │
│                  │  Work   │        │
│                  └────┬────┘        │
│                       │             │
│              ┌────────▼────────┐    │
│              │   PASS?         │    │
│              │  Yes → checkpoint│    │
│              │  No  → retry    │    │
│              └─────────────────┘    │
└─────────────────────────────────────┘
```

#### Step 2-1: Gate Check

Before starting a milestone:

1. Verify all dependency milestones have status `completed`
2. Verify no file conflicts with in-progress parallel milestones
3. Update state.md: set milestone status to `planning`
4. Update execution log with timestamp

#### Step 2-2: Plan Crafting Phase

1. Compose a Context Brief from the milestone definition:
   - Goal → from milestone file
   - Scope → files affected from milestone file
   - Success Criteria → from milestone file
   - Constraints → inherited from the parent problem + completed milestone outputs
2. Invoke the `plan-crafting` skill pattern:
   - Create a plan document at `docs/engineering-discipline/plans/YYYY-MM-DD-<milestone-name>.md`
   - The plan must satisfy all milestone success criteria
   - The plan must not modify files outside the milestone's scope
3. Update state.md: record plan file path for this milestone
4. **User gate:** Present the plan and ask for approval before execution

#### Step 2-3: Run Plan Phase

1. Update state.md: set milestone status to `executing`
2. Execute the plan using the `run-plan` skill pattern:
   - Worker-validator loop for each task
   - Parallel execution for independent tasks
   - Information-isolated validators
3. If run-plan reports failure after 3 retries on any task:
   - Update state.md: set milestone status to `failed`
   - Record failure details in execution log
   - **Stop and report to user.** Do not proceed to dependent milestones.
4. If all tasks complete: proceed to review phase

#### Step 2-4: Review Work Phase

1. Update state.md: set milestone status to `validating`
2. Invoke the `review-work` skill pattern:
   - Information-isolated review against the plan document
   - Binary PASS/FAIL verdict
3. **If PASS:**
   - Update state.md: set milestone status to `completed`
   - Write checkpoint file (see Checkpoint Format below)
   - Update execution log
   - Proceed to next milestone
4. **If FAIL:**
   - Record review findings in execution log
   - **Retry decision:**
     - If this is the 1st failure: return to Step 2-3 with review feedback
     - If this is the 2nd failure: return to Step 2-2 (re-plan with review feedback)
     - If this is the 3rd failure: set status to `failed`, stop, report to user

#### Step 2-5: Checkpoint

After a milestone passes review:

Write `checkpoints/M<N>-checkpoint.md`:

```markdown
# Checkpoint: M<N> — [Milestone Name]

**Completed:** YYYY-MM-DD HH:MM
**Duration:** [time from planning start to review pass]
**Attempts:** [number of plan-execute-review cycles]

## Plan File
`docs/engineering-discipline/plans/YYYY-MM-DD-<name>.md`

## Review File
`docs/engineering-discipline/reviews/YYYY-MM-DD-<name>-review.md`

## Test Results
[Full test suite status at checkpoint time]

## Files Changed
[List of files created/modified in this milestone]

## State After Milestone
[Brief description of system state — what works now that didn't before]
```

### Phase 3: Parallel Milestone Execution

When multiple milestones have all dependencies satisfied and no file conflicts:

1. Identify parallelizable milestone group
2. Present to user: "Milestones M3 and M4 can run in parallel. Proceed?"
3. If approved, dispatch each milestone's pipeline concurrently:
   - Each milestone gets its own plan-crafting → run-plan → review-work cycle
   - Each runs in a worktree (`isolation: "worktree"`) to prevent file conflicts
   - After both complete and pass review, merge worktrees back
4. If either fails: handle independently (the other can continue if no dependency)

**Worktree merge protocol:**
1. Both milestones pass review in their respective worktrees
2. Check for file conflicts between worktree changes
3. If no conflicts: merge sequentially (M_lower first, then M_higher)
4. If conflicts detected: stop, report to user, request manual resolution
5. After merge: run full test suite on merged result
6. If tests fail: stop, report to user

### Phase 4: Completion

After all milestones are completed:

1. Update state.md: set overall status to `completed`
2. Run full test suite one final time
3. Generate completion summary:

```markdown
# Long Run Complete: [Session Name]

**Started:** YYYY-MM-DD
**Completed:** YYYY-MM-DD
**Total milestones:** N
**Total attempts:** [sum of all milestone attempts]

## Milestone Summary

| Milestone | Status | Attempts | Duration |
|-----------|--------|----------|----------|
| M1: [name] | ✓ completed | 1 | 2h |
| M2: [name] | ✓ completed | 2 | 4h |
| ...

## Final Test Suite
[PASS/FAIL — N passed, M failed]

## Files Changed (Total)
[Aggregated list across all milestones]
```

4. Present to user and suggest `simplify` for a final code quality pass

## Recovery Protocol

When resuming a paused or interrupted session:

1. Read state.md to determine last known state
2. For each milestone, determine recovery action:

| Last Status | Recovery Action |
|-------------|----------------|
| `pending` | Start normally |
| `planning` | Restart plan-crafting (plan file may be incomplete) |
| `executing` | Check run-plan progress; resume or restart |
| `validating` | Restart review-work (review may be incomplete) |
| `completed` | Skip (already checkpointed) |
| `failed` | Present failure to user; ask whether to retry or skip |

3. For `executing` milestones: check if tasks in the plan have checkboxes marked. Resume from the first unchecked task.
4. Present recovery plan to user before proceeding.

## Rate Limit Handling

Long-running sessions will encounter rate limits. When a rate limit is hit:

1. Record current state to disk immediately
2. Log the rate limit event in execution log
3. Report to user: "Rate limit hit. State saved. Resume with `long-run` when ready."
4. Do NOT retry automatically — the user may want to wait or adjust

## Anti-Patterns

| Anti-Pattern | Why It Fails |
|---|---|
| Generating milestones inline instead of using milestone-planning | Milestones lack adversarial review; poor decomposition |
| Skipping review-work for "simple" milestones | Undetected defects compound across milestones |
| Continuing after a milestone fails | Dependent milestones build on broken foundation |
| Not updating state.md between phases | Crash loses progress; cannot resume |
| Modifying completed milestone files | Breaks checkpoint invariant; invalidates reviews |
| Running parallel milestones without worktree isolation | File conflicts corrupt both milestones |
| Auto-retrying on rate limit | Wastes quota; user may prefer to wait |
| Skipping user gates between milestones | User loses control of multi-day execution |
| Merging worktrees without conflict check | Silent data loss if files overlap |

## Minimal Checklist

- [ ] State directory exists with valid state.md and milestone files
- [ ] Dependency DAG validated (no cycles)
- [ ] Current position determined (fresh start or resume)
- [ ] User confirmed continuation at session start
- [ ] Each milestone goes through plan-crafting → run-plan → review-work
- [ ] State.md updated before and after every phase transition
- [ ] Checkpoint written after every successful milestone
- [ ] Failed milestones block dependents
- [ ] Parallel milestones use worktree isolation
- [ ] Full test suite passes at completion

## Transition

After long run completion:

- For final code quality pass → `simplify` skill
- If issues found in completion testing → `systematic-debugging` skill
- If user wants to extend with more milestones → `milestone-planning` skill

This skill itself **does not invoke the next skill.** It reports completion and lets the user decide the next step.
