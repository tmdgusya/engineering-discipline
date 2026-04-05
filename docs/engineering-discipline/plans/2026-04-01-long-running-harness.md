# Long Running Harness Implementation Plan

> **Worker note:** Execute this plan task-by-task using the run-plan skill or subagents. Each step uses checkbox (`- [ ]`) syntax for progress tracking.

**Goal:** Build a long-running, multi-day execution harness that decomposes complex tasks into milestones via parallel agent review (ultraplan), then executes each milestone through the existing worker-validator pipeline with checkpoint/recovery.

**Architecture:** Two new skills compose the harness. `milestone-planning` handles the critical milestone generation phase — it spawns 5 parallel reviewer agents (feasibility, architecture, risk, dependency, user-value) that independently analyze the problem, then a synthesis agent consolidates their findings into an optimized milestone DAG. `long-run` orchestrates multi-day execution — it invokes milestone-planning, then iterates through each milestone by chaining plan-crafting → run-plan → review-work, persisting state to disk after each milestone so execution can survive interruptions. Additionally, the existing `clarification` skill is enhanced with a **Complexity Gate** — after producing a Context Brief, it assesses task complexity and automatically routes to either `plan-crafting` (simple) or `milestone-planning` (complex).

**Tech Stack:** Markdown skill files with YAML frontmatter (Claude Code skill system), shell commands for state management

**Work Scope:**
- **In scope:** milestone-planning skill, long-run orchestrator skill, state file format, checkpoint/recovery protocol, milestone dependency DAG, clarification skill complexity gate addition
- **Out of scope:** Claude Code source modifications, UI/frontend changes, changes to run-plan/review-work/plan-crafting skills

---

## File Structure

```
skills/
├── clarification/
│   └── SKILL.md              # Modified: add Complexity Gate to Context Brief + Transition
├── milestone-planning/
│   └── SKILL.md              # Ultraplan: parallel reviewer agents → milestone DAG
└── long-run/
    └── SKILL.md              # Orchestrator: milestone lifecycle with checkpoint/recovery
```

**State files produced at runtime (not created by this plan):**

```
docs/engineering-discipline/harness/<session-slug>/
├── state.md                  # Master state: milestone list, status, dependencies
├── milestones/
│   ├── M1-<name>.md          # Individual milestone definition
│   ├── M2-<name>.md
│   └── ...
├── reviews/                  # Reviewer agent outputs (milestone-planning phase)
│   ├── feasibility.md
│   ├── architecture.md
│   ├── risk.md
│   ├── dependency.md
│   ├── user-value.md
│   └── synthesis.md
└── checkpoints/
    ├── M1-checkpoint.md      # Post-milestone completion record
    └── ...
```

---

## Task 0: Add Complexity Gate to clarification skill

**Dependencies:** None (can run in parallel with Task 1 and Task 2)
**Files:**
- Modify: `skills/clarification/SKILL.md:133-178` (Context Brief format + save section)
- Modify: `skills/clarification/SKILL.md:212-231` (Transition section)

- [ ] **Step 1: Add Complexity Assessment to Context Brief format**

In `skills/clarification/SKILL.md`, find the Context Brief format block (around line 139) and add the `Complexity Assessment` section between `Open Questions` and `Suggested Next Step`:

Replace:
```markdown
### Open Questions (if any)
[Questions still open — unresolved but not blocking]

### Suggested Next Step
[Which skill or action to proceed with, given this context]
```

With:
```markdown
### Open Questions (if any)
[Questions still open — unresolved but not blocking]

### Complexity Assessment

Assess task complexity using these 5 signals. Score each signal, then determine the routing.

| Signal | Simple (1) | Complex (2-3) |
|--------|-----------|---------------|
| **Scope breadth** | Single feature or component | Multiple components, cross-cutting concerns |
| **File impact** | ≤5 files created/modified | >5 files, or files across multiple directories |
| **Interface boundaries** | Works within existing interfaces | Defines new interfaces or modifies existing contracts |
| **Dependency depth** | No ordering constraints between steps | Steps have dependency chains requiring sequencing |
| **Risk surface** | Low integration risk, no data migration | Integration with external systems, schema changes, backward compatibility |

**Score:** [sum of signals, range 5-15]
**Verdict:** [Simple (5-8) | Complex (9-15)]
**Rationale:** [1-2 sentences explaining the dominant complexity factor]

### Suggested Next Step
[Auto-determined by Complexity Assessment verdict — see Routing Rules below]
```

- [ ] **Step 2: Add Routing Rules section before Transition**

In `skills/clarification/SKILL.md`, add a new section before the existing `## Transition` section (around line 212):

Insert before `## Transition`:

```markdown
## Routing Rules

After the Context Brief is approved, the **Complexity Assessment verdict** determines the next skill:

| Verdict | Route | Rationale |
|---------|-------|-----------|
| **Simple** (score 5-8) | `plan-crafting` | Task fits in a single plan cycle. Direct planning is sufficient. |
| **Complex** (score 9-15) | `milestone-planning` | Task requires multiple plan cycles. Milestone decomposition needed before planning. |

**Override:** The user can always override the routing. If the user says "just plan it" for a complex task, route to `plan-crafting`. If the user says "break it into milestones" for a simple task, route to `milestone-planning`.

**Edge case (score 8-9):** Present both options to the user with a recommendation. Example: "This scores 9 — borderline complex. I recommend milestone-planning because [dominant factor], but plan-crafting could work if [condition]. Which do you prefer?"

The "Suggested Next Step" field in the Context Brief must reflect this routing:

- Simple: "Proceed to `plan-crafting` — task fits in a single plan cycle."
- Complex: "Proceed to `milestone-planning` — task requires milestone decomposition for multi-phase execution."
- Borderline: "Recommend `milestone-planning` (score 9), but `plan-crafting` is viable if [condition]. User choice needed."
```

- [ ] **Step 3: Update Transition section**

Replace the existing Transition section:

```markdown
## Transition

Once the Context Brief is approved by the user:

- If detailed implementation planning is needed → `plan-crafting` skill
- If further exploration is needed → `clarification` 스킬 자체의 Q&A 루프 계속
- If the plan is already clear → `run-plan` skill

This skill itself **does not invoke the next skill.** It ends by presenting the Context Brief, saving it to a file, and suggesting the next step.
```

With:

```markdown
## Transition

Once the Context Brief is approved by the user, route based on the Complexity Assessment:

- **Simple** (score 5-8) → `plan-crafting` skill — single-cycle implementation planning
- **Complex** (score 9-15) → `milestone-planning` skill — multi-phase milestone decomposition, then `long-run` for execution
- **Borderline** (score 8-9) → present both options with recommendation, user decides
- If further exploration is needed → `clarification` 스킬 자체의 Q&A 루프 계속
- If the scope is already trivial and planning is unnecessary → direct implementation

This skill itself **does not invoke the next skill.** It ends by presenting the Context Brief, saving it to a file, and suggesting the routed next step.
```

- [ ] **Step 4: Verify the changes are consistent**

```bash
grep -n "Complexity\|complexity\|Simple\|Complex\|milestone-planning\|plan-crafting\|Routing" skills/clarification/SKILL.md
```

Expected: References to Complexity Assessment, Routing Rules, and both target skills appear in the file.

- [ ] **Step 5: Commit**

```bash
git add skills/clarification/SKILL.md
git commit -m "feat: add complexity gate to clarification skill for automatic routing"
```

---

## Task 1: Create milestone-planning skill

**Dependencies:** None (can run in parallel with Task 2)
**Files:**
- Create: `skills/milestone-planning/SKILL.md`

- [ ] **Step 1: Create the skill directory**

```bash
mkdir -p skills/milestone-planning
```

- [ ] **Step 2: Write the milestone-planning SKILL.md**

Create `skills/milestone-planning/SKILL.md` with the following complete content:

````markdown
---
name: milestone-planning
description: Decomposes complex, multi-day tasks into optimized milestones using parallel reviewer agents (ultraplan). Spawns 5 independent reviewers that analyze the problem from different angles, then synthesizes their findings into a milestone dependency DAG. Triggers when the user says "plan milestones", "break this into milestones", "ultraplan", or when long-run harness needs milestone generation.
---

# Milestone Planning (Ultraplan)

Decomposes a complex task into milestones by spawning 5 parallel reviewer agents, synthesizing their independent analyses, and producing a milestone dependency DAG.

## Core Principle

Milestones are the unit of long-running execution. A bad milestone decomposition cascades into days of wasted work. Therefore milestone generation must be adversarial — multiple independent perspectives must challenge each other before milestones are locked.

## Hard Gates

1. **All 5 reviewer agents must run in parallel.** Sequential execution is prohibited. Dispatch all 5 concurrently in a single message via the Agent tool.
2. **Each reviewer receives the full problem statement.** Do not split or filter the problem per reviewer. Every reviewer sees everything.
3. **Reviewers must not see each other's findings.** Each reviewer operates independently. No cross-pollination during the review phase.
4. **Synthesis must address every reviewer's concern.** The synthesis agent must explicitly respond to each finding — accepted, rejected with reason, or deferred to a specific milestone.
5. **Every milestone must have measurable success criteria.** "Working correctly" is not a criterion. Specific test commands, file existence checks, or behavioral assertions are required.
6. **Milestone dependencies must form a DAG.** Circular dependencies are a plan failure. Every milestone must have a clear topological ordering.
7. **Do not generate milestones for trivial tasks.** If the problem can be solved in a single plan-crafting cycle (fewer than ~8 tasks), tell the user to use plan-crafting directly.

## When To Use

- When the user presents a complex, multi-day task
- When the long-run harness needs milestone decomposition
- When the user says "plan milestones", "break this into milestones", or "ultraplan"
- When a task clearly requires multiple independent implementation phases

## When NOT To Use

- Single-day tasks (use plan-crafting directly)
- Tasks with fewer than ~8 implementation steps
- When milestones are already defined and the user wants execution (use long-run)
- When work scope is still ambiguous (use clarification first)

## Input

The skill requires a **clear problem statement** as input. This can come from:

1. A Context Brief file produced by the `clarification` skill (preferred)
2. A direct, detailed request from the user (must include goal, scope, constraints)

If the input is ambiguous, return to the `clarification` skill before proceeding.

## Process

### Phase 1: Problem Framing

Before dispatching reviewers, frame the problem:

1. Read the input (Context Brief or user request)
2. Identify: goal, scope boundaries, technical constraints, success criteria
3. If a codebase is involved, dispatch an Explore agent to map relevant architecture
4. Compose the **Problem Brief** — a self-contained document that each reviewer will receive:

```markdown
## Problem Brief

**Goal:** [What must be achieved]

**Scope:**
- In: [What is included]
- Out: [What is explicitly excluded]

**Technical Context:**
[Relevant architecture, existing code, constraints]

**Constraints:**
[Time, compatibility, dependencies, performance requirements]

**Success Criteria:**
[Specific, measurable outcomes]
```

### Phase 2: Parallel Reviewer Dispatch

Dispatch all 5 reviewer agents concurrently in a single message via the Agent tool. Each receives the full Problem Brief and its reviewer-specific prompt.

#### Reviewer 1: Feasibility Analyst

```
You are a feasibility analyst reviewing a problem decomposition.

## Problem Brief
{PROBLEM_BRIEF}

## Your Task

Analyze the feasibility of solving this problem. For each major component:

1. **Technical feasibility:** Can this be built with the stated tech stack?
   Identify any components that require research, prototyping, or may not
   be possible as described.

2. **Effort estimation:** Classify each component as:
   - Small (1-3 tasks, < 1 plan cycle)
   - Medium (4-8 tasks, 1 plan cycle)
   - Large (9+ tasks, multiple plan cycles → candidate for milestone)
   - Uncertain (requires spike/prototype before estimation)

3. **Risk of underestimation:** Flag components that appear simple but
   have hidden complexity (integration points, edge cases, data migration,
   backward compatibility).

4. **Suggested milestone boundaries:** Based on effort and risk, suggest
   where natural milestone boundaries should fall. A milestone should be
   independently deliverable and testable.

## Output Format

For each suggested milestone:
- **Name:** [milestone name]
- **Effort:** [Small/Medium/Large/Uncertain]
- **Feasibility risk:** [Low/Medium/High] — [reason]
- **Key deliverable:** [what this milestone produces]

Also list:
- **Spike candidates:** Components needing prototype before planning
- **Underestimation risks:** Components likely harder than they appear
```

#### Reviewer 2: Architecture Analyst

```
You are an architecture analyst reviewing a problem decomposition.

## Problem Brief
{PROBLEM_BRIEF}

## Your Task

Analyze the architectural implications and suggest milestone boundaries
that respect architectural constraints.

1. **Interface boundaries:** Identify the key interfaces, contracts, and
   APIs that must be defined. Milestones should align with interface
   boundaries — one milestone should not half-define an interface.

2. **Data flow:** Map how data flows through the system. Milestones that
   cut across data flows create integration risk.

3. **Dependency direction:** Identify which components depend on which.
   Milestones should be ordered so dependencies are built before dependents.

4. **Incremental deliverability:** Each milestone should leave the system
   in a working state. No milestone should produce a half-built component
   that only works after the next milestone.

5. **Existing pattern alignment:** Where possible, milestones should follow
   existing patterns in the codebase rather than introducing new patterns.

## Output Format

For each suggested milestone:
- **Name:** [milestone name]
- **Architectural rationale:** [why this is a natural boundary]
- **Interfaces defined:** [what contracts this milestone establishes]
- **Depends on:** [which milestones must complete first]
- **Leaves system in working state:** [Yes/No — explain]

Also list:
- **Interface risks:** Interfaces that may need revision after initial implementation
- **Pattern conflicts:** Where the proposed work conflicts with existing patterns
```

#### Reviewer 3: Risk Analyst

```
You are a risk analyst reviewing a problem decomposition.

## Problem Brief
{PROBLEM_BRIEF}

## Your Task

Identify risks that could derail multi-day execution and suggest milestone
ordering that minimizes cumulative risk.

1. **Integration risk:** Which components have the highest risk of not
   working together? These should be integrated early, not in the last
   milestone.

2. **Ambiguity risk:** Which requirements are most likely to change or
   be misunderstood? These should be tackled early so course corrections
   are cheap.

3. **Dependency risk:** Which external dependencies (APIs, libraries,
   services) are least reliable? Milestones depending on them should
   include fallback plans.

4. **Regression risk:** Which changes are most likely to break existing
   functionality? These milestones need heavier test coverage.

5. **Recovery cost:** If a milestone fails validation, how expensive is
   it to redo? High-cost milestones should be smaller and more frequent.

## Output Format

For each identified risk:
- **Risk:** [description]
- **Severity:** [Low/Medium/High/Critical]
- **Affected milestone(s):** [which milestones]
- **Mitigation:** [how to structure milestones to reduce this risk]

Overall risk-ordered milestone sequence:
1. [milestone] — [why first: highest ambiguity / integration risk / ...]
2. [milestone] — [why second]
...
```

#### Reviewer 4: Dependency Analyst

```
You are a dependency analyst reviewing a problem decomposition.

## Problem Brief
{PROBLEM_BRIEF}

## Your Task

Map all dependencies — between milestones, between files, between external
systems — and verify that the proposed decomposition respects them.

1. **File conflict analysis:** List all files that will be created or
   modified. Identify files touched by multiple milestones — these create
   ordering constraints.

2. **Interface dependency graph:** Map which milestones produce interfaces
   that other milestones consume. Draw the dependency DAG.

3. **External dependency mapping:** List external systems, APIs, libraries,
   or services each milestone depends on. Flag any that require setup,
   credentials, or may be unavailable.

4. **Shared state identification:** Identify shared state (databases,
   config files, global settings) that multiple milestones modify.
   These require strict ordering.

5. **Parallelization opportunities:** Identify milestones with zero
   dependencies between them — these can run concurrently.

## Output Format

**Dependency DAG:**
```
M1 (no deps) ─┬─→ M3 (depends on M1, M2)
M2 (no deps) ─┘         │
                         └─→ M4 (depends on M3)
```

**File conflict matrix:**
| File | Milestones | Ordering constraint |
|------|-----------|-------------------|
| path/to/file | M1, M3 | M1 before M3 |

**Parallelizable groups:**
- Group A: [M1, M2] — no shared files, no interface deps
- Group B: [M4, M5] — after Group A completes

**External dependencies:**
- [dependency]: required by [milestones], setup needed: [yes/no]
```

#### Reviewer 5: User Value Analyst

```
You are a user value analyst reviewing a problem decomposition.

## Problem Brief
{PROBLEM_BRIEF}

## Your Task

Ensure milestone ordering maximizes early value delivery and maintains
user motivation throughout multi-day execution.

1. **Value ordering:** Which milestones deliver the most visible,
   user-facing value? These should come early to provide feedback
   and maintain confidence.

2. **Demo-ability:** After each milestone, can the user see/test
   something meaningful? Milestones that produce only internal
   infrastructure with no visible output erode confidence.

3. **Feedback loops:** Which milestones benefit most from early user
   feedback? These should be prioritized so corrections are cheap.

4. **Minimum viable milestone:** What is the smallest first milestone
   that proves the approach works? This validates the overall direction
   before investing in the full plan.

5. **Abort points:** After which milestones could the user reasonably
   decide to stop and still have something useful? Mark these as
   natural checkpoints.

## Output Format

**Value-ordered milestone sequence:**
1. [milestone] — **Value:** [what user sees] — **Demo:** [how to verify]
2. [milestone] — **Value:** [what user sees] — **Demo:** [how to verify]
...

**Minimum viable milestone:** [which milestone and why]

**Natural abort points:** [milestones after which stopping is reasonable]

**Low-value milestones:** [milestones that could be cut if time is short]
```

### Phase 3: Synthesis

After all 5 reviewers complete, dispatch a **Synthesis Agent** that receives all 5 reviewer outputs and produces the final milestone plan.

The synthesis agent prompt:

```
You are a milestone synthesis agent. You have received analyses from 5
independent reviewers who each examined the same problem from a different
angle. Your job is to produce the final milestone decomposition.

## Reviewer Outputs

### Feasibility Analysis
{FEASIBILITY_OUTPUT}

### Architecture Analysis
{ARCHITECTURE_OUTPUT}

### Risk Analysis
{RISK_OUTPUT}

### Dependency Analysis
{DEPENDENCY_OUTPUT}

### User Value Analysis
{USER_VALUE_OUTPUT}

## Your Task

1. **Cross-reference findings.** Identify where reviewers agree and
   where they conflict. Agreements are high-confidence decisions.
   Conflicts require resolution.

2. **Resolve conflicts explicitly.** For each conflict:
   - State the conflict
   - State your resolution
   - State why (which reviewer's reasoning is stronger in this case)

3. **Produce the milestone DAG.** Each milestone must have:
   - Name
   - Goal (1 sentence)
   - Success criteria (measurable, specific)
   - Dependencies (which milestones must complete first)
   - Files affected (from dependency analysis)
   - Risk level (from risk analysis)
   - Estimated effort (from feasibility analysis)
   - User value (from value analysis)

4. **Validate the DAG.** Verify:
   - No circular dependencies
   - Valid topological ordering exists
   - No file conflicts between parallel milestones
   - Each milestone leaves system in working state
   - First milestone is the minimum viable milestone

5. **Produce execution order.** List milestones in execution order,
   marking which can run in parallel.

## Output Format

## Conflict Resolution Log

| Conflict | Resolution | Rationale |
|----------|-----------|-----------|
| [description] | [decision] | [why] |

## Milestone DAG

### M1: [Name]
- **Goal:** [one sentence]
- **Success Criteria:**
  - [ ] [specific, measurable criterion]
  - [ ] [specific, measurable criterion]
- **Dependencies:** None
- **Files:** [list]
- **Risk:** [Low/Medium/High]
- **Effort:** [Small/Medium/Large]
- **User Value:** [what user sees after completion]
- **Abort Point:** [Yes/No]

### M2: [Name]
...

## Execution Order

```
Phase 1 (parallel): M1, M2
Phase 2 (after Phase 1): M3
Phase 3 (parallel): M4, M5
```

## Rejected Proposals

| Proposal | Source | Reason for rejection |
|----------|--------|---------------------|
| [what was proposed] | [which reviewer] | [why rejected] |
```

### Phase 4: User Review and Lock

1. Present the synthesized milestone plan to the user
2. Show the conflict resolution log — the user must see where reviewers disagreed
3. Show the execution order with parallelization
4. Ask the user to approve, modify, or reject the milestone plan
5. If approved: save the milestone plan to the harness state directory
6. If modifications requested: apply changes and re-present
7. If rejected: return to Phase 1 with updated constraints

### Phase 5: Save Milestone Artifacts

Save all artifacts to the harness state directory:

```
docs/engineering-discipline/harness/<session-slug>/
├── state.md                  # Master state file
├── milestones/
│   ├── M1-<name>.md          # Individual milestone definition
│   ├── M2-<name>.md
│   └── ...
└── reviews/
    ├── feasibility.md
    ├── architecture.md
    ├── risk.md
    ├── dependency.md
    ├── user-value.md
    └── synthesis.md
```

**state.md format:**

```markdown
# Long Run State: [Session Name]

**Created:** YYYY-MM-DD HH:MM
**Last Updated:** YYYY-MM-DD HH:MM
**Status:** milestone-planning-complete | executing | paused | completed | failed

## Milestones

| ID | Name | Status | Dependencies | Plan File | Review File |
|----|------|--------|-------------|-----------|-------------|
| M1 | [name] | pending | — | — | — |
| M2 | [name] | pending | M1 | — | — |
| M3 | [name] | pending | M1, M2 | — | — |

Status values: pending | planning | executing | validating | completed | failed | skipped

## Execution Log

| Timestamp | Event | Details |
|-----------|-------|---------|
| YYYY-MM-DD HH:MM | milestones-locked | N milestones approved by user |
```

**Individual milestone file (M1-<name>.md) format:**

```markdown
# Milestone: [Name]

**ID:** M1
**Status:** pending
**Dependencies:** [None | M1, M2, ...]
**Risk:** [Low/Medium/High]
**Effort:** [Small/Medium/Large]

## Goal

[One sentence goal]

## Success Criteria

- [ ] [Specific, measurable criterion]
- [ ] [Specific, measurable criterion]
- [ ] [Specific, measurable criterion]

## Files Affected

- Create: [files to create]
- Modify: [files to modify]

## User Value

[What the user sees/can test after this milestone]

## Abort Point

[Yes/No — can user stop here and have something useful?]

## Notes

[Any special considerations from reviewer analysis]
```

## Anti-Patterns

| Anti-Pattern | Why It Fails |
|---|---|
| Running reviewers sequentially | Wastes time; reviewers are independent |
| Skipping synthesis and just merging reviewer outputs | Conflicts go unresolved; milestone boundaries are incoherent |
| Accepting milestones without measurable success criteria | Cannot validate completion; "done" becomes subjective |
| Creating milestones too large (>12 tasks each) | Exceeds single plan-crafting cycle; risk of context loss |
| Creating milestones too small (1-2 tasks each) | Overhead of plan-crafting + run-plan + review-work exceeds the work itself |
| Ignoring reviewer conflicts | Unresolved conflicts surface during execution when they're expensive to fix |
| Not saving reviewer outputs | Loses the reasoning behind milestone decisions; cannot audit later |
| Letting user skip approval | User discovers misalignment mid-execution after days of work |

## Minimal Checklist

- [ ] Problem Brief composed with goal, scope, constraints, success criteria
- [ ] All 5 reviewers dispatched in parallel (single message)
- [ ] Each reviewer received the full Problem Brief
- [ ] Synthesis agent received all 5 reviewer outputs
- [ ] All reviewer conflicts explicitly resolved
- [ ] Every milestone has measurable success criteria
- [ ] Milestone DAG has no circular dependencies
- [ ] First milestone is the minimum viable milestone
- [ ] User approved the milestone plan
- [ ] All artifacts saved to harness state directory

## Transition

After milestone planning is complete:

- To begin execution → `long-run` skill
- If ambiguity discovered → return to `clarification` skill
- If task is too small for milestones → use `plan-crafting` directly

This skill itself **does not invoke the next skill.** It ends by presenting the milestone plan and letting the user choose the next step.
````

- [ ] **Step 3: Verify file was created correctly**

```bash
test -f skills/milestone-planning/SKILL.md && echo "OK" || echo "MISSING"
wc -l skills/milestone-planning/SKILL.md
```

Expected: File exists, approximately 280-320 lines.

- [ ] **Step 4: Commit**

```bash
git add skills/milestone-planning/SKILL.md
git commit -m "feat: add milestone-planning skill (ultraplan with parallel reviewers)"
```

---

## Task 2: Create long-run harness skill

**Dependencies:** None (can run in parallel with Task 1)
**Files:**
- Create: `skills/long-run/SKILL.md`

- [ ] **Step 1: Create the skill directory**

```bash
mkdir -p skills/long-run
```

- [ ] **Step 2: Write the long-run SKILL.md**

Create `skills/long-run/SKILL.md` with the following complete content:

````markdown
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
````

- [ ] **Step 3: Verify file was created correctly**

```bash
test -f skills/long-run/SKILL.md && echo "OK" || echo "MISSING"
wc -l skills/long-run/SKILL.md
```

Expected: File exists, approximately 280-320 lines.

- [ ] **Step 4: Commit**

```bash
git add skills/long-run/SKILL.md
git commit -m "feat: add long-run harness skill (multi-day milestone orchestrator)"
```

---

## Task 3: Verify integration and cross-references

**Dependencies:** Runs after Task 0, Task 1, and Task 2 complete
**Files:**
- Modify: `skills/clarification/SKILL.md` (if needed)
- Modify: `skills/milestone-planning/SKILL.md` (if needed)
- Modify: `skills/long-run/SKILL.md` (if needed)

- [ ] **Step 1: Verify skill frontmatter is valid**

```bash
head -5 skills/milestone-planning/SKILL.md
head -5 skills/long-run/SKILL.md
```

Expected: Both files start with `---` followed by `name:` and `description:` fields.

- [ ] **Step 2: Verify cross-references between skills**

Check that:
- milestone-planning references `long-run` in its Transition section
- long-run references `milestone-planning` in its When To Use section
- Both reference existing skills correctly (clarification, plan-crafting, run-plan, review-work, simplify)

```bash
grep -n "long-run\|milestone-planning\|plan-crafting\|run-plan\|review-work\|clarification\|simplify" skills/milestone-planning/SKILL.md
grep -n "long-run\|milestone-planning\|plan-crafting\|run-plan\|review-work\|clarification\|simplify" skills/long-run/SKILL.md
```

Expected: Both files reference each other and the existing skills they depend on.

- [ ] **Step 3: Verify state file format consistency**

Check that the state.md format described in milestone-planning matches what long-run expects to read:
- milestone-planning saves `state.md` with milestone table (ID, Name, Status, Dependencies, Plan File, Review File)
- long-run reads `state.md` and expects that exact format

Manual review — both are defined in this plan. The formats are consistent.

- [ ] **Step 4: Run any existing tests**

```bash
cd /home/roach/engineering-discipline && ls tests/ 2>/dev/null || echo "No tests directory"
```

If tests exist, run them. If not, this step passes (plugin is config-driven markdown, no test suite).

- [ ] **Step 5: Final commit if any fixes were needed**

```bash
# Only if files were modified in steps 1-3
git add -A
git commit -m "fix: correct cross-references between milestone-planning and long-run skills"
```

If no changes were needed, skip this step.

---

## Self-Review

### 1. Spec Coverage

| Requirement | Task |
|------------|------|
| Automatic routing (simple vs complex) | Task 0 (Complexity Gate in clarification) |
| Parallel reviewer agents for milestone generation | Task 1 (5 reviewers in Phase 2) |
| Synthesis/debate of reviewer findings | Task 1 (Phase 3 synthesis agent) |
| Milestone dependency DAG | Task 1 (Phase 3 output + Phase 5 state format) |
| Per-milestone plan-crafting → run-plan → review-work | Task 2 (Phase 2, Steps 2-2 through 2-4) |
| Checkpoint/recovery for multi-day execution | Task 2 (Phase 2 Step 2-5, Recovery Protocol) |
| State persistence to disk | Task 2 (Hard Gate #2, state.md format) |
| Rate limit handling | Task 2 (Rate Limit Handling section) |
| User gates between phases | Task 2 (Hard Gate #5) |
| Parallel milestone execution | Task 2 (Phase 3 with worktree isolation) |
| Failed milestone blocks dependents | Task 2 (Hard Gate #4) |

### 2. Placeholder Scan

No TBD, TODO, or placeholder patterns found.

### 3. Type Consistency

- State file format: consistent between milestone-planning (writer) and long-run (reader)
- Milestone file format: consistent between milestone-planning (writer) and long-run (reader)
- Checkpoint file format: defined only in long-run (writer and reader)
- Milestone status values: `pending | planning | executing | validating | completed | failed | skipped` — consistent across both skills

### 4. Dependency Verification

- Task 0, Task 1, Task 2 have no file conflicts (different files/directories)
- Task 3 depends on Task 0, Task 1, and Task 2 (correctly stated)
- Task 0, Task 1, Task 2 can all run in parallel (correctly stated)
