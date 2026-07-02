---
name: review-work
description: Use after run-plan completes to independently verify the implementation. Reads only the plan document and inspects the codebase from scratch — information-isolated from the execution context. Produces a structured review document with PASS/FAIL verdict. Triggers when the user says "review the work", "verify the implementation", "check if the plan was executed correctly".
---

# Review Work

Independently verifies implementation results using only the plan document and the codebase. Receives no information from the execution process.

## Core Principle

The reviewer shares no memory with the executor. The plan's stated goals and the current state of the codebase — these two alone are the basis for judgment.

## Hard Gates

1. **Do not receive execution context.** No logs from run-plan, no worker output, no diffs, no task completion summaries, no conversation history. The only input is the plan file path.
2. **Read the plan document directly.** Read the plan file from disk — not a summary or a passed-along description.
3. **Run all tests yourself.** Do not trust previous execution results. Run the full test suite and every verification command specified in the plan.
4. **Verdict is PASS or FAIL — binary at every level.** Each success criterion and each task's acceptance criteria are judged met/not-met individually; the verdict is the AND of all of them. No conditional passes, no "almost done", no partial credit.
5. **The verdict judges only the goal contract.** Verdict inputs are: planned files exist, acceptance criteria met, tests pass, no regressions, plan success criteria met. Everything else — placeholder/debug code, commit message mismatches, style — is reported as advisory findings and never flips the verdict. A binary signal is only useful if it is not polluted by cosmetics.
6. **Save the review document to a file.** Review results must be saved as a structured document. Never end with a verbal report alone.
7. **Do not modify code.** This skill is read-only. If issues are found, report them — do not fix them.

## When To Use

- After run-plan execution is complete
- When the user says "review the work", "verify the implementation", "check if the plan was executed correctly"
- When implementation is done but independent verification is needed

## When NOT To Use

- While run-plan is still in progress
- When no plan document exists (use `plan-crafting` first)
- When the goal is a general code review (this skill verifies "implementation against plan")

## Input

The only input to this skill is the **plan file path**.

```
docs/engineering-discipline/plans/YYYY-MM-DD-<feature-name>.md
```

The following must never be provided as input:

- Execution logs or task completion summaries from run-plan
- Output or diffs from worker subagents
- Validation results from validator subagents
- Conversation history from the execution session

## Process

### Phase 1: Load and Analyze Plan Document

1. Receive the plan file path as input
2. Read the plan document directly from disk
3. Extract the following:
   - **Goal:** What this plan implements
   - **Work Scope:** In scope / Out of scope
   - **Task List:** Each task's name, acceptance criteria, and target files
   - **File Structure Mapping:** Complete list of files to be created or modified
   - **Commit Structure:** Commit messages and scope specified in the plan
   - **Test Commands:** All test execution commands specified in the plan

If the plan contains a `## Plan Amendment Log` (appended by run-plan when plan defects were found mid-execution), the review judges against the **amended** plan — the log is part of the plan, not execution context. Amendments that weakened a criterion relative to the plan's Goal are themselves a FAIL finding.

Use the extracted results as the foundation for the review document.

### Phase 2: Codebase Inspection

Inspect the codebase against the files specified in the plan.

1. **File existence check:** Verify that all files specified in the plan actually exist
2. **Content alignment check:** Inspect whether each file's content matches the plan's requirements (function signatures, type definitions, logic, etc.)
3. **Residual artifact check (advisory — not a verdict input):**
   - Placeholder code (TODO, FIXME, "implement later", stub functions)
   - Debug code (console.log, print debugging, commented-out code blocks)
   - Unexpected changes outside the plan's scope
   These are recorded as advisory findings. Exception: if a placeholder sits where an acceptance criterion requires working code, the criterion itself fails — that is what flips the verdict, not the artifact.
4. **Verify acceptance criteria per task.** Check each criterion stated in the plan one by one and record met/not-met — binary per criterion, no partial credit.

### Phase 3: Test Execution

1. Run all **individual test commands** specified in the plan
2. Run the **full test suite** to check for regressions
3. Record each test's result (PASS/FAIL)
4. If any test fails, record the error message

### Phase 4: Git History Check (Informational)

1. Compare the commit structure specified in the plan against the actual `git log`
2. Note mismatches in commit messages or scope (unrelated changes mixed into a single commit)

Findings here are **informational only** — plans rarely predict commit messages exactly, and workers may have legitimately adapted. Record mismatches in the review document; they never affect the verdict.

### Phase 5: Verdict and Review Document

The verdict is computed from the goal contract only — Phases 2 (criteria) and 3 (tests).

**PASS conditions (all must be met — verdict is the AND):**

- All files specified in the plan exist
- Each task's acceptance criteria are met (binary per criterion)
- All tests specified in the plan pass
- Full test suite shows no regressions
- The plan's success criteria are met

**FAIL if any single condition above is not met.** No conditional passes.

**Never verdict inputs (advisory findings only):**

- Placeholder or debug code (unless it makes a criterion fail)
- Commit message or commit structure mismatches
- Style, naming, or code quality observations

After reaching a verdict, write and save the review document.

## Review Document

### Save Location

```
docs/engineering-discipline/reviews/YYYY-MM-DD-<feature-name>-review.md
```

(User preferences for review location override this default.)

### Document Structure

```markdown
# [Feature Name] Review

**Date:** YYYY-MM-DD HH:MM
**Plan Document:** `docs/engineering-discipline/plans/YYYY-MM-DD-<feature-name>.md`
**Verdict:** PASS / FAIL

---

## 1. File Inspection Against Plan

| Planned File | Status | Notes |
|---|---|---|
| `path/to/file` | OK / Missing / Mismatch | Details |

## 2. Test Results

| Test Command | Result | Notes |
|---|---|---|
| `pytest tests/...` | PASS / FAIL | Error details if failed |

**Full Test Suite:** PASS / FAIL (N passed, M failed)

## 3. Acceptance Criteria

| Task | Criterion | Met |
|---|---|---|
| Task 1 | [criterion verbatim from plan] | PASS / FAIL |

## 4. Advisory Findings (not verdict inputs)

- [ ] No placeholders
- [ ] No debug code
- [ ] No commented-out code blocks
- [ ] No changes outside plan scope

**Findings:**
- (Describe with file path and line number)

**Git history (informational):**

| Planned Commit | Actual Commit | Match |
|---|---|---|
| `feat: add X` | `abc1234 feat: add X` | OK / Mismatch |

## 5. Overall Assessment

(Summary of the overall judgment. If FAIL, describe specifically which items failed and why.)

## 6. Follow-up Actions

- (If FAIL: list of items that need to be fixed)
- (If PASS: record improvement suggestions if any)
```

## When To Stop

Stop immediately and notify the user in the following situations:

- The plan file does not exist or cannot be read
- The test execution environment is not ready (e.g., dependencies not installed)
- The plan document format cannot be parsed

**When in doubt, do not guess — ask the user.**

## Anti-Patterns

| Anti-Pattern | Why It Fails |
|---|---|
| Reading run-plan execution logs to verify | Information isolation violation. Anchors on the executor's framing |
| Trusting previous test results instead of running tests | Environment may have changed after execution. Not independent verification |
| Finding issues and fixing them directly | Violates separation of reviewer and implementer roles |
| Giving a "close enough, PASS" verdict | No conditional passes. If criteria are not met, it is FAIL |
| Failing the verdict over cosmetics (commit messages, TODOs, style) | Pollutes the binary signal; triggers retry loops over trivia. Cosmetics are advisory findings |
| Delivering review results verbally without saving a document | No verification record remains. Untraceable |
| Judging by criteria not in the plan | The reviewer judges only by the plan's criteria. Adding arbitrary standards is prohibited |
| Receiving a plan summary and verifying from that | Information is lost during summarization. The original must be read directly |

## Minimal Checklist

Self-check when review is complete:

- [ ] Read the plan document directly from disk
- [ ] Did not receive run-plan execution results as input
- [ ] Ran all tests myself
- [ ] Inspected all tasks in the plan
- [ ] Verdict is either PASS or FAIL
- [ ] Saved the review document to a file

## Transition

After review is complete:

- **PASS** → Report results to the user and suggest next steps (PR creation, deployment, etc.)
- **FAIL** → Report failure items to the user. If fixes are needed, suggest transitioning to the `run-plan` or `systematic-debugging` skill
- If the plan itself has issues → suggest returning to the `plan-crafting` skill to revise the plan

This skill itself **does not invoke the next skill.** It saves the review document, reports results, and lets the user decide the next step.
