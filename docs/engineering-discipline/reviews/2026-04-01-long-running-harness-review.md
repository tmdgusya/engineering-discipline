# Long Running Harness Review

**Date:** 2026-04-01
**Plan Document:** `docs/engineering-discipline/plans/2026-04-01-long-running-harness.md`
**Verdict:** FAIL

---

## 1. File Inspection Against Plan

| Planned File | Status | Notes |
|---|---|---|
| `skills/clarification/SKILL.md` (modify) | OK | Complexity Assessment, Routing Rules, updated Transition all present |
| `skills/milestone-planning/SKILL.md` (create) | OK | 541 lines, all 5 reviewers + synthesis + state formats present |
| `skills/long-run/SKILL.md` (create) | OK | 298 lines, all 4 phases + recovery + rate limit present |

## 2. Test Results

| Test Command | Result | Notes |
|---|---|---|
| No automated tests | N/A | Plugin is config-driven markdown; no test suite exists |

**Full Test Suite:** N/A (no tests directory)

## 3. Code Quality

- [x] No placeholders (TBD, TODO, FIXME) — confirmed via grep
- [x] No debug code
- [x] No commented-out code blocks
- [x] No changes outside plan scope

**Findings:** No residual artifacts.

## 4. Git History

| Planned Commit | Actual Commit | Match |
|---|---|---|
| `feat: add complexity gate to clarification skill for automatic routing` | `1abd2df feat: add complexity gate to clarification skill for automatic routing` | OK |
| `feat: add milestone-planning skill (ultraplan with parallel reviewers)` | `4acd652 feat: add milestone-planning skill (ultraplan with parallel reviewers)` | OK |
| `feat: add long-run harness skill (multi-day milestone orchestrator)` | `cd8899b feat: add long-run harness skill (multi-day milestone orchestrator)` | OK |

## 5. Overall Assessment

Files exist, cross-references are correct, no placeholders, git history matches plan. However, **hardening review reveals 12 governance gaps** that would cause failures during multi-day execution. These are not cosmetic — they represent scenarios where the harness would lose state, behave ambiguously, or silently corrupt execution.

**Verdict: FAIL** — the structure is solid, but the following hardening gaps must be addressed before this harness is production-ready for multi-day runs.

## 6. Hardening Findings

### CRITICAL (would cause state loss or silent corruption)

**F1. Retry counter not persisted in state.md**
- **File:** `skills/long-run/SKILL.md:148-151`
- **Problem:** Step 2-4 references "1st failure", "2nd failure", "3rd failure" for retry escalation (re-execute → re-plan → stop). But `state.md` format has no field to track retry count per milestone. If the session crashes mid-retry, the retry counter resets to 0 on resume — the harness may retry indefinitely instead of escalating.
- **Required fix:** Add `Retry Count` column to the milestones table in `state.md`, or add an `Attempts` field to individual milestone files. Update Recovery Protocol to read this on resume.

**F2. `skipped` status defined but no transition path**
- **File:** `skills/milestone-planning/SKILL.md:458` and `skills/long-run/SKILL.md:249`
- **Problem:** `state.md` format defines status value `skipped`, and Recovery Protocol says for `failed` milestones: "ask whether to retry or skip." But there is no rule defining what happens to dependents of a skipped milestone. Hard Gate #4 says "Failed milestones block dependents" — does `skipped` also block? If not, dependents execute without their prerequisite, corrupting the DAG.
- **Required fix:** Add explicit rule: either (a) `skipped` blocks dependents same as `failed`, or (b) `skipped` allows dependents but requires user to acknowledge the missing prerequisite. Add to Hard Gates or Anti-Patterns.

**F3. No information isolation rule for synthesis handoff**
- **File:** `skills/milestone-planning/SKILL.md:312-409`
- **Problem:** The run-plan skill has a fixed template and explicit "do not paraphrase" rule for validator prompts. The milestone-planning skill has no equivalent safeguard for the synthesis handoff. The main agent could paraphrase, filter, or reframe reviewer outputs before passing them to the synthesis agent, defeating the adversarial review.
- **Required fix:** Add a hard gate: "Reviewer outputs must be passed verbatim to the synthesis agent. Do not summarize, filter, or reframe. The main agent copies each reviewer's full output into the designated placeholder."

### HIGH (would cause ambiguous behavior under real conditions)

**F4. No reviewer failure handling**
- **File:** `skills/milestone-planning/SKILL.md` (Phase 2, no failure section)
- **Problem:** What if one of the 5 reviewer agents fails (timeout, rate limit, error)? What if a reviewer returns empty or unusably low-quality output? Currently no guidance — the synthesis agent would receive 4 of 5 outputs, or garbage from one reviewer, without knowing.
- **Required fix:** Add failure handling: "If any reviewer fails or returns empty output, re-dispatch that reviewer once. If it fails again, proceed with available outputs but log the missing perspective in the Conflict Resolution Log and notify the user."

**F5. Parallel milestone user gates are ambiguous**
- **File:** `skills/long-run/SKILL.md:182-200`
- **Problem:** Hard Gate #5 requires user confirmation at gate points. Phase 3 dispatches parallel milestones each through plan-crafting → run-plan → review-work. But does the user approve 2 plans simultaneously? Do they approve plan A, then plan B, then both execute in parallel? Or does the harness present both plans together? The interaction model for parallel user gates is undefined.
- **Required fix:** Add explicit parallel gate protocol: "For parallel milestones, present all plans together for batch approval. User approves or rejects each individually. Only approved milestones proceed. Rejected milestones return to planning while approved ones execute."

**F6. Complexity Assessment scoring is ambiguous**
- **File:** `skills/clarification/SKILL.md:171-181`
- **Problem:** The table header says "Simple (1) | Complex (2-3)" but never defines what score 2 vs 3 means. Is each signal binary (1 or 3)? A 3-point scale (1, 2, 3)? The range "5-15" implies 3-point per signal, but the column headers only show "1" and "2-3", not "1", "2", "3". An LLM will interpret this inconsistently.
- **Required fix:** Either (a) make it binary (1 or 3) and adjust range to 5-15, or (b) define three tiers per signal with clear labels: Low (1), Medium (2), High (3). The table must unambiguously map each signal to a score.

**F7. No guard against milestone scope creep or count**
- **File:** `skills/milestone-planning/SKILL.md`
- **Problem:** Nothing prevents milestone-planning from generating 20+ milestones. The anti-patterns mention "too large" (>12 tasks) and "too small" (1-2 tasks) per milestone, but no upper bound on milestone count. 20 milestones at ~1 day each = month-long execution with compounding risk.
- **Required fix:** Add guidance: "Recommended milestone count: 3-7 for most projects. If more than 10 milestones are needed, consider whether the problem should be split into separate projects. If more than 7, present the count to the user for explicit approval."

### MEDIUM (governance gaps that reduce auditability)

**F8. No rule for what completed milestone context gets forwarded**
- **File:** `skills/long-run/SKILL.md:110-114`
- **Problem:** Step 2-2 says "Constraints → inherited from the parent problem + completed milestone outputs." This is vague. What exactly from completed milestones is passed to the next milestone's plan-crafting? The full checkpoint? Just file paths? The review verdict? Without specificity, each invocation will pass different amounts of context, making debugging across milestones difficult.
- **Required fix:** Define explicitly: "Completed milestone context passed to subsequent plan-crafting consists of: (1) the list of files created/modified (from checkpoint), (2) the milestone's success criteria marked as met, (3) any interface contracts established. Do NOT pass: execution logs, review documents, or worker/validator output."

**F9. No procedure for mid-execution milestone addition**
- **File:** `skills/long-run/SKILL.md:21`
- **Problem:** Hard Gate #6 says "Never modify completed milestones. If a later milestone needs changes to earlier work, that is a new milestone." But the skill never describes HOW to add a new milestone mid-execution. Does the user go back to milestone-planning? Does the harness pause? Does the new milestone get inserted into the DAG? Without a procedure, the harness has no defined way to handle the most common multi-day scenario: discovering that the plan was wrong.
- **Required fix:** Add a "Mid-Execution Correction" section: "If execution reveals that a completed milestone's output is incorrect or a new milestone is needed: (1) pause execution, (2) update state.md with new milestone, (3) run milestone-planning for just the new milestone (skip full 5-reviewer if user approves), (4) insert into DAG respecting dependencies, (5) resume from the new milestone."

**F10. Context Brief from long-run has no Complexity Assessment**
- **File:** `skills/long-run/SKILL.md:110-114`
- **Problem:** Step 2-2 says "Compose a Context Brief from the milestone definition" and invoke plan-crafting. But the Context Brief format from clarification now includes a Complexity Assessment section with routing. A milestone-derived Context Brief shouldn't have routing (it's already routed). This creates format ambiguity — plan-crafting may expect the Complexity Assessment field.
- **Required fix:** Add note: "Context Briefs composed from milestone definitions omit the Complexity Assessment section, since routing has already been determined by the milestone-planning phase."

**F11. No milestone-level timeout or duration guard**
- **File:** `skills/long-run/SKILL.md`
- **Problem:** Individual milestones have no timeout. A single milestone could run for days if plan-crafting generates a massive plan or run-plan enters an infinite retry loop on a flaky test. The 3-retry limit on tasks doesn't bound total milestone duration.
- **Required fix:** Add guidance: "If a single milestone's total execution time (planning + execution + review) exceeds a reasonable threshold (e.g., 8 hours of active agent time), pause and report to user. This prevents a single runaway milestone from consuming the entire execution budget."

**F12. Synthesis agent has no DAG validation instruction enforcement**
- **File:** `skills/milestone-planning/SKILL.md:361-366`
- **Problem:** The synthesis prompt says "Validate the DAG" with a checklist (no cycles, valid topological ordering, etc.), but this is a request, not a hard gate. The synthesis agent could skip validation or validate incorrectly. There's no independent verification of the DAG structure after synthesis — unlike run-plan's validator pattern, milestone-planning trusts the synthesis agent's self-reported validation.
- **Required fix:** Add a post-synthesis verification step: "After receiving the synthesis output, the main agent independently verifies the DAG: (1) check for circular dependencies by attempting topological sort, (2) verify no file conflicts between parallel milestones. If validation fails, re-dispatch synthesis with the specific error."

## 7. Follow-up Actions

**Must fix before production use (CRITICAL + HIGH: F1-F7):**
1. Add retry counter to state.md format and milestone files
2. Define `skipped` status transition rules and dependent behavior
3. Add verbatim handoff rule for reviewer → synthesis (fixed template or hard gate)
4. Add reviewer failure handling (re-dispatch once, then degrade gracefully)
5. Define parallel milestone user gate interaction model
6. Fix Complexity Assessment to unambiguous 3-tier scoring
7. Add milestone count guidance/guard

**Should fix for robustness (MEDIUM: F8-F12):**
8. Define completed milestone context forwarding contract
9. Add mid-execution milestone addition procedure
10. Clarify Context Brief format for milestone-derived briefs
11. Add milestone-level duration guard
12. Add independent DAG validation after synthesis
