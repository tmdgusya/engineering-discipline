---
name: milestone-planning
description: Decomposes complex, multi-day tasks into optimized milestones (ultraplan). Broad parallel exploration grounds a draft milestone DAG, then independent adversarial critics attack the draft in rounds until no blocking findings remain. Triggers when the user says "plan milestones", "break this into milestones", "ultraplan", or when long-run harness needs milestone generation.
---

# Milestone Planning (Ultraplan)

Decomposes a complex task into milestones in three moves: explore the codebase broadly in parallel, draft a milestone DAG grounded in what exploration found, then submit the draft to a panel of adversarial critics who attack it in rounds until it survives.

## Core Principle

Milestones are the unit of long-running execution. A bad milestone decomposition cascades into days of wasted work. Two things prevent that:

- **Grounding.** The draft is built from actual codebase evidence gathered by parallel exploration — not from assumptions about what the code probably looks like.
- **Adversarial pressure.** Independent critics whose only job is to break the draft, before execution does it the expensive way.

A critic needs a concrete artifact to attack. This is why drafting comes before critique: "review the problem" produces suggestions; "break this draft" produces findings.

## Hard Gates

1. **Explore before drafting.** Dispatch parallel exploration agents before composing the draft. Every milestone boundary must cite exploration evidence — a boundary not grounded in the actual codebase is an assumption, not a decision.
2. **All critics in a round run in parallel.** Dispatch every critic concurrently in a single message via the Agent tool. Sequential critique is prohibited.
3. **Every critic receives the full Problem Brief and the full draft.** Do not filter or slice per critic.
4. **Critics must not see each other's critiques.** Independence within a round is what makes agreement between critics meaningful.
5. **Every critique must be resolved explicitly.** Each finding is logged verbatim in the Critique Resolution Log and marked accepted (draft revised — say how) or rejected (with evidence-backed reason). Silently dropping a finding is a planning failure.
6. **Critique until dry.** After revising, dispatch a fresh critic round against the revised draft. The draft is locked only when a full round produces zero new Structural or Blocking findings. Maximum 3 rounds — Blocking findings still disputed after round 3 are escalated to the user with both sides stated.
7. **Every milestone must have binary-decidable success criteria.** "Working correctly" is not a criterion. Each criterion must be answerable met/not-met by running a command or reading code — the same standard as plan-crafting's Acceptance Criteria Rules.
8. **Milestone dependencies must form a DAG.** Circular dependencies are a plan failure. Every milestone must have a clear topological ordering.
9. **Do not generate milestones for trivial tasks.** If the problem can be solved in a single plan-crafting cycle (fewer than ~8 tasks), tell the user to use plan-crafting directly.

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

### Phase 1: Problem Framing + Broad Exploration

1. Read the input (Context Brief or user request)
2. Identify: goal, scope boundaries, technical constraints, success criteria
3. **Dispatch parallel exploration agents** — several read-only Explore subagents concurrently, each with a distinct lens:
   - **Architecture & interfaces:** modules, boundaries, and contracts the work will touch; existing patterns to follow
   - **Dependencies & data flow:** what depends on what; shared state (DB schemas, config, globals); external systems and their setup requirements
   - **Verification landscape:** e2e tests, integration tests, test suites, CI checks — this feeds the Verification Strategy
   - **Conventions & history:** naming and structural conventions, recent related changes, prior attempts at similar work
   Add task-specific lenses when the problem calls for them (a schema/migration lens for data work, an auth/permissions lens for security-touching work, a client-compat lens for API changes).
4. Compose the **Problem Brief** — self-contained; both the draft and every critic will receive it:

```markdown
## Problem Brief

**Goal:** [What must be achieved]

**Scope:**
- In: [What is included]
- Out: [What is explicitly excluded]

**Technical Context:**
[Relevant architecture, existing code, constraints]

**Exploration Digest:**
[Key findings per lens, with file references — this is the evidence base
 the draft cites and the critics check against]

**Constraints:**
[Time, compatibility, dependencies, performance requirements]

**Success Criteria:**
[Binary-decidable outcomes]

**Verification Strategy:**
- **Level:** [e2e | integration | skill/agent | test-suite | build-only]
- **Command:** [exact command to run the verification]
- **What it validates:** [what passing this verification proves]
```

**Verification Discovery:** Use the same discovery order as plan-crafting (e2e → integration → verification skills/agents → test suite → build+lint) and record the result in the Verification Strategy section. If no verification infrastructure exists, the Integration Verification Milestone's plan-crafting phase (during long-run execution) will create it as Task 0.

### Phase 2: Draft Decomposition (two skeletons, then one draft)

Iterating on a single draft anchors every later round to its initial shape — critics attack details, and the until-dry loop can only polish the skeleton it was given. Counter this with diverse initialization: draft twice before critiquing once.

1. **Dispatch two drafting agents in parallel**, each receiving the full Problem Brief + Exploration Digest with a different organizing principle:
   - **Skeleton A — interface-first:** order milestones so contracts and interfaces are defined before their consumers; boundaries follow the architecture map
   - **Skeleton B — risk-first:** order milestones so the riskiest integrations and most ambiguous requirements are exercised earliest; boundaries follow the failure modes
2. **Compare and compose `DRAFT v1`:** the main agent picks the stronger skeleton and grafts superior elements from the other. Record the choice and rationale at the top of the resolution log ("Skeleton: B, because …; grafted A's M2/M3 split").

The draft uses the full milestone format (see Phase 6) and is explicitly marked `DRAFT v1`.

For each milestone, the draft must state:

- **Name, Goal** (one sentence)
- **Success Criteria** (binary-decidable — Hard Gate 7)
- **Dependencies** (which milestones must complete first)
- **Files affected** (from the dependency exploration)
- **Risk / Effort / User Value / Abort Point**
- **Evidence:** which Exploration Digest findings justify this boundary

A milestone whose Evidence field is empty is a guess — explore more or merge it into a neighbor.

### Phase 3: Adversarial Critic Panel

Dispatch the critic panel against the draft — all critics concurrently, in a single message, `run_in_background: true`, no worktree isolation (critics are read-only).

**Panel composition — 4 core critics, always:**

1. **Hidden Complexity Critic** — attacks effort estimates: integration points, edge cases, data migration, backward compatibility that make a "Small" milestone Large; components that need a spike before they can be estimated at all.
2. **Dependency & Ordering Critic** — attacks the DAG: missing dependency edges, file conflicts inside parallel groups, shared state modified by unordered milestones, interfaces consumed before the milestone that defines them, external dependencies without setup steps.
3. **Verifiability Critic** — attacks the success criteria: any criterion not binary-decidable (requires interpretation to judge), milestones that cannot be independently verified when their turn comes, cross-milestone interfaces no criterion exercises.
4. **Integration & Risk Critic** — attacks the sequencing: riskiest integration deferred to the end, most ambiguous requirements tackled last (when corrections are most expensive), milestones that leave the system in a broken state, expensive-to-redo milestones that are too large.

**Plus up to 2 task-specific critics** chosen by the problem's nature: Value & Sequencing (early user-visible value, minimum viable first milestone, abort points), Migration & Compatibility, Security & Access, Performance. Justify the choice in one line in the resolution log.

**Critic prompt template** (fill `{LENS}`, `{LENS_FOCUS}` from the panel definitions; copy Problem Brief and draft in full):

```
You are the {LENS} critic reviewing a draft milestone decomposition.
Your job is to find the ways this draft fails during execution.
You are not here to be agreeable — an easy approval from you is
a defect in the process.

## Problem Brief
{PROBLEM_BRIEF}

## Draft Milestone DAG (v{N})
{DRAFT}

## Your Task

Attack the draft strictly from your lens: {LENS_FOCUS}

Rules:
- Every finding must be concrete: name the milestone, quote the draft
  text you are attacking, and state the failure scenario during
  execution. Check claims against the Exploration Digest — a draft
  assertion that contradicts the digest is automatically a finding.
- Assign each finding a severity:
  - **Structural:** the decomposition's fundamental shape is wrong —
    wrong unit of decomposition, wrong ordering philosophy, or a
    missing phase that no milestone-level edit can add. Use only when
    revision cannot fix it; a Structural finding must include a 3-5
    line sketch of the alternative shape.
  - **Blocking:** execution will fail, produce the wrong thing, or
    require redoing a completed milestone
  - **Concern:** elevated risk that needs a stated mitigation
  - **Nit:** improvement, safe to ignore
- Do not propose a full alternative decomposition — attack this one.
  The only exceptions: the "smallest fix" per finding, and the 3-5
  line shape sketch required for a Structural finding.
- If you find nothing Blocking, earn it: list the attacks you attempted
  and why the draft survived each one.

## Output Format

For each finding:
- **[Severity] Finding:** [one sentence]
- **Where:** [milestone ID(s) + quoted draft text]
- **Failure scenario:** [what concretely goes wrong during execution]
- **Smallest fix:** [minimal change to the draft that removes the failure]

If nothing Blocking: list attempted attacks and why each failed.
```

**Critic failure handling:**

1. **Timeout or error:** re-dispatch the failed critic once with the same prompt. If it fails again, proceed without it and log the missing lens in the resolution log.
2. **Empty or lazy output:** a critic returning no findings AND no attempted-attacks list did not do its job — re-dispatch once.
3. **Minimum viable panel:** at least 3 critics must succeed per round. Fewer → stop and report to the user.

### Phase 4: Revision Loop (Critique Until Dry)

1. **Log every finding verbatim** in the Critique Resolution Log — do not summarize or soften:

```markdown
| # | Critic | Severity | Finding (verbatim) | Resolution | Rationale / Draft change |
|---|--------|----------|--------------------|-----------|--------------------------|
| 1 | Dependency | Blocking | "M3 consumes the API defined in M4..." | Accepted | Reordered: M4 now precedes M3 |
| 2 | Complexity | Concern | "M2's migration effort is Small but..." | Accepted | M2 split into M2a (spike) + M2b |
| 3 | Verifiability | Blocking | "M5 criterion 'UX feels responsive'..." | Accepted | Rewritten: "p95 interaction latency < 100ms in the perf test" |
| 4 | Integration | Nit | "..." | Rejected | Digest shows the interface is already exercised by e2e suite |
```

2. **Structural findings trigger a redraft, not a revision.** If a Structural finding is accepted, return to Phase 2 and recompose the draft — the finding's shape sketch and the unused skeleton are inputs. Maximum one redraft per planning session; a second accepted Structural finding means the problem framing itself is wrong → escalate to the user and revisit Phase 1.
3. **Revise the draft** (v2, v3, …) applying every accepted fix.
4. **Re-dispatch a fresh critic round** against the revised draft if this round produced any Structural or Blocking finding. Fresh instances with no memory of prior rounds — a critic that remembers its old critique anchors on it instead of attacking the new draft.
5. **Dry condition:** a full round with zero new Structural or Blocking findings locks the draft. Open Concerns must have their mitigation noted in the affected milestone's Notes; Nits are optional.
6. **Round cap:** maximum 3 rounds (a redraft resets the count once). Blocking findings still disputed after round 3 → present to the user with the critic's finding and the draft's rebuttal, both verbatim.

### Phase 4.5: Integration Verification Milestone

After the draft is locked, the main agent **automatically appends** an Integration Verification Milestone as the final milestone in the DAG. This milestone is a structural guarantee — critics do not get a vote on its existence.

```markdown
### M_final: Integration Verification

- **Goal:** Validate that all milestones work together as a complete system
- **Success Criteria:**
  - [ ] Highest-level project verification passes (command from Verification Strategy)
  - [ ] All milestone success criteria remain met after full integration
  - [ ] Full test suite passes — no regressions in pre-existing functionality
  - [ ] Cross-milestone interfaces are exercised end-to-end
- **Dependencies:** ALL other milestones
- **Files:** None (read-only verification — no new code)
- **Risk:** Medium (integration issues between independently-verified milestones)
- **Effort:** Small (verification only, no implementation)
- **User Value:** Confidence that the system works as a whole, not just per-milestone
- **Abort Point:** No (this is the final gate)
```

### Phase 4.6: Independent DAG Validation

After appending the Integration Verification Milestone, the **main agent** independently validates the full DAG structure before presenting it to the user. Do not rely on the critics having caught everything.

1. **Circular dependency check:** trace each milestone's dependency chain; any milestone that is both ancestor and descendant of another invalidates the DAG. Fix the draft and re-run the Dependency & Ordering critic on the fix.
2. **File conflict check for parallel milestones:** milestones with no dependency relationship must have disjoint "Files affected" lists. Overlap → add a dependency edge or flag for user decision.
3. **Orphan check:** every milestone except the first must have at least one dependency OR be explicitly marked independently parallelizable with rationale.
4. **Criteria check:** every milestone has at least 2 binary-decidable success criteria. A criterion requiring interpretation → rewrite before presenting.

### Phase 5: User Review and Lock

This is the **single approval gate** of the entire long-run flow — after the user locks the plan here, `long-run` executes all milestones without further approval pauses.

**Milestone count guard:** The recommended count is 3-7. More than 7 → warn: "This plan has N milestones. Consider whether the problem should be split into separate projects." More than 10 → require explicit user approval to proceed.

1. Present the locked milestone plan
2. Show the Critique Resolution Log — the user must see what the critics attacked and how each finding was resolved
3. Show the execution order with parallelization
4. Show the milestone count with the count guard warning if applicable
5. Ask the user to approve, modify, or reject
6. If approved: save all artifacts to the harness state directory
7. If modifications requested: apply, re-run the affected critics on the change, re-present
8. If rejected: return to Phase 1 with updated constraints

### Phase 6: Save Milestone Artifacts

```
docs/engineering-discipline/harness/<session-slug>/
├── state.md                      # Master state file
├── milestones/
│   ├── M1-<name>.md              # Individual milestone definition
│   ├── M2-<name>.md
│   └── ...
└── planning/
    ├── problem-brief.md          # includes Exploration Digest
    ├── draft-v1.md ... draft-vN.md
    ├── critiques/
    │   ├── round-1-complexity.md
    │   ├── round-1-dependency.md
    │   └── ...
    └── resolution-log.md         # Critique Resolution Log, all rounds
```

**state.md format:**

```markdown
# Long Run State: [Session Name]

**Created:** YYYY-MM-DD HH:MM
**Last Updated:** YYYY-MM-DD HH:MM
**Status:** milestone-planning-complete | executing | paused | completing | completed | failed

**Verification Strategy:**
- **Level:** [e2e | integration | skill/agent | test-suite | build-only]
- **Command:** [exact verification command]
- **What it validates:** [what passing proves]

## Milestones

| ID | Name | Status | Attempts | Dependencies | Plan File | Review File |
|----|------|--------|----------|-------------|-----------|-------------|
| M1 | [name] | pending | 0 | — | — | — |
| M2 | [name] | pending | 0 | M1 | — | — |
| M3 | [name] | pending | 0 | M1, M2 | — | — |

Status values: pending | planning | executing | validating | completed | failed | skipped
Attempts: number of plan-execute-review cycles attempted (incremented at each Step 2-3 start)

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

- [ ] [Binary-decidable criterion — answerable met/not-met by command or code inspection]
- [ ] [Binary-decidable criterion]
- [ ] [Binary-decidable criterion]

## Files Affected

- Create: [files to create]
- Modify: [files to modify]

## User Value

[What the user sees/can test after this milestone]

## Abort Point

[Yes/No — can user stop here and have something useful?]

## Notes

[Mitigations for open Concerns from the critique rounds; special considerations]
```

## Anti-Patterns

| Anti-Pattern | Why It Fails |
|---|---|
| Critiquing the problem statement instead of a concrete draft | Produces suggestions, not findings; conflicts never surface until execution |
| Drafting once and only revising | Revision rounds polish the initial skeleton but cannot escape it; two skeletons + the Structural escape hatch exist for exactly this |
| Drafting without exploration | Milestone boundaries become assumptions; critics can't check claims against evidence |
| Running critics sequentially | Wastes time; critics are independent by design |
| Summarizing or softening critiques before resolving them | Filters findings through the drafter's bias; log verbatim |
| Marking a finding "addressed" without changing the draft or rebutting it | The finding resurfaces during execution, where it costs days instead of minutes |
| Reusing the same critic instance across rounds | Anchors on its previous critique instead of attacking the revised draft |
| Accepting criteria that need interpretation | Cannot validate completion; "done" becomes subjective |
| Creating milestones too large (>12 tasks each) | Exceeds single plan-crafting cycle; risk of context loss |
| Creating milestones too small (1-2 tasks each) | Overhead of plan-crafting + run-plan + review-work exceeds the work itself |
| Creating more than 10 milestones without user approval | Compounding risk across milestones; likely needs project split |
| Letting user skip the lock approval | This is the only approval gate — skipping it means days of unattended execution on an unreviewed plan |

## Minimal Checklist

- [ ] Parallel exploration agents dispatched before drafting
- [ ] Problem Brief composed with Exploration Digest and Verification Strategy
- [ ] Two independent skeletons drafted (interface-first, risk-first); DRAFT v1 composed with rationale logged
- [ ] Draft DAG cites exploration evidence per milestone
- [ ] All critics in each round dispatched in parallel (single message)
- [ ] Every critique logged verbatim and resolved (accepted with draft change, or rejected with reason)
- [ ] Final round produced zero new Blocking findings (or disputes escalated to user)
- [ ] Every milestone has binary-decidable success criteria
- [ ] Milestone DAG has no circular dependencies
- [ ] Integration Verification Milestone appended as final milestone
- [ ] User approved the milestone plan at the lock
- [ ] All artifacts saved to harness state directory

## Transition

After milestone planning is complete:

- To begin execution → `long-run` skill
- If ambiguity discovered → return to `clarification` skill
- If task is too small for milestones → use `plan-crafting` directly

This skill itself **does not invoke the next skill.** It ends by presenting the milestone plan and letting the user choose the next step.
