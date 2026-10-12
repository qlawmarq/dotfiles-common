---
name: sdd-spec-done
description: >-
  Finalize an SDD feature: verify the completion record, run lint/test/build, have one independent
  reviewer check the diff, route every finding, then move the spec to done and commit.
  Afterwards checks project steering and the decision records against what the feature changed.
---

# Feature Completion

<background_information>

- **Mission**: Verify the completed feature against its record and its diff, then finalize it by moving the spec to done and creating a git commit
- **Success Criteria**:
  - All tasks marked as completed in tasks.md
  - `check_completion.sh` exits 0 — the kind's completion checks (`docs/settings/rules/spec-kinds.md` §4, `Completion checks`): the `_Evidence:` lines, the product-check record, the completion review report, the verdict
  - Lint, tests, and build pass without issues (`verify`: 2f instead)
  - Every review finding routed and closed per `docs/settings/rules/concept-alignment.md §Findings`, one line each in `reviews/routing-<n>.md`; stale criterion wording reconciled in requirements.md
  - Spec moved from `docs/specs/todo/` to `docs/specs/done/`
  - Changes committed with project-consistent commit message
  - Steering checked against what the feature changed (`docs/settings/rules/steering-principles.md`)
  - When decision records exist: `Used by` updated for the registry IDs this feature implemented, orphan identifiers reported, `check_decisions.sh check` run (non-blocking), decision changes committed separately

</background_information>

<instructions>

## Input

**Feature name** (required): the feature directory name in `docs/specs/`. Use it when given with the invocation; otherwise ask the user for it.

## Core Task

Verify the completed feature: its completion record, lint/test/build, and one independent review of its diff. If all checks pass, finalize by moving the spec to done and committing. If any check fails, report issues and suggest corrective actions.

## Execution Steps

### Step 0: Resolve Spec Path

Look for the feature directory in `docs/specs/todo/<feature-name>/` **only**. If it is in `docs/specs/done/` instead, stop with "Feature already completed"; if it is in neither, stop with "Feature not found. Check available specs with `/sdd-spec-status`".

### Step 1: Load Context

- From `{spec_path}/`: `spec.json` (metadata, language, `kind`), `requirements.md`, `behaviors.md` (if exists), `verdict.md` (kind `verify`), `design.md` (the Regression Guard, the assumptions, where a finding goes), `tasks.md`
- The entire `docs/steering/` directory
- `docs/settings/rules/concept-alignment.md`: §Findings to route and close every finding of this run, §User Check for Step 3, §Independent Runs and §Waiting on a Run for 2d
- `docs/settings/rules/document-hygiene.md` for every document this run writes or changes (§After a Change)
- `{spec_path}/research.md` only when routing a finding needs the decision it records

### Step 2: Verification

Execute all verification checks sequentially. Collect all issues before making a decision.

**By kind**: 2d runs when the kind's `Completion checks` column in `docs/settings/rules/spec-kinds.md` §4 lists `review`, 2f when it lists `verdict`. `verify` also skips 2c. `fix` also runs 2e. Every other check applies to every kind.

**Run number**: `<n>` is one more than the largest number among `{spec_path}/reviews/review-*.md`, `routing-*.md` and `probe/user-run-*.md` (1 when there are none). `review-<n>.md`, `routing-<n>.md` and `probe/user-run-<n>.md` of this run use the same n.

**Commands** (2c): lint, test and build commands come from the project's build configuration (its scripts or targets), else `docs/steering/tech.md` (§Common Commands).

#### 2a. Task Completion Check

Every checkbox in tasks.md must be `[x]`; any `[ ]` left is **Critical**: "Incomplete tasks found".

#### 2b. Completion Record

```bash
bash docs/settings/scripts/check_completion.sh --skip review {spec_path}
```

The `review` check belongs to Step 3, after 2d. A non-zero exit is **Critical**: "Completion record incomplete", with its output. The usual causes: an `[x]` task without `_Evidence:` → the lead runs the task's test and writes the line in the task's block (form: `docs/settings/rules/tasks-generation.md` §Checkbox Format); a criterion no `[x]` task cites → Step 3 (fix the criterion, or add a task); the product-check record missing, or its task reopened → NO-GO: "Run the product-check task" (`concept-alignment.md §Product Check`). `user` scenarios `NOT RUN` go to Step 3.

#### 2c. Lint, Test and Build

- Lint: failure → **Critical**: "Lint errors detected"; no command → **Info**: "No lint configuration found — skipping"
- Test: failure → **Critical**: "Test failures detected"; no command → **Warning**: "No test configuration found — manual verification required"
- Build: failure → **Critical**: "Build errors detected"; no command → **Info**: "No build configuration found — skipping"

#### 2d. Completion Review

Runs only when 2a–2c raised no Critical in this run; otherwise it is not run, and the NO-GO report says so.

- **Dispatch**: one new sub-agent that does not inherit this conversation (`concept-alignment.md §Independent Runs`). Hand it `docs/settings/templates/specs/completion-review.md` and only what that file's comment lists. Where to get them: the diff is `git diff <base> -- . ':!docs'` plus the working tree, `<base>` being the commit that approved tasks.md (`git log -S'"approved": true' -- {spec_path}/spec.json`); the criteria are the output of `bash docs/settings/scripts/list_criteria.sh {spec_path}/requirements.md`; the time limit is the one the user set for this spec's check, else that of `concept-alignment.md §Waiting on a Run`. Before dispatching, tell the user in one line that the review is starting and the time limit it runs under (`§Waiting on a Run`).
- **Re-run** (n > 1): also hand over every `F<k>` of an earlier `routing-<m>.md` still `open`, or `changed` without a later `not reproduced`, as `R<m>-F<k>` with its `Conflict:` line copied from that report, and the fix's diff — never your answer to it. The review's scope is the fix. From the third run on with findings still open, raise it with the user as an upstream problem (requirements, plan or design) before dispatching again.
- **Incomplete report**: a report that does not have exactly one of the two — `#### F<k>` headings, or the `Findings: none` line — goes back to the same reviewer.
- **Re-checks**: for each line of its C. Re-checks, `not reproduced` closes the `changed` line in `routing-<m>.md` (append `; re-checked in review-<n>.md`); `reproduced` sets it back to `open` there, and it is routed again as below, on that line.
- **Warnings**: the report's D. Warnings go into this run's report as **Warning**; they get no routing line.

**Routing**: each `F<k>` of the report gets a line in `{spec_path}/reviews/routing-<n>.md`: `F<k> — <closure> — <rest>`, the closure from `concept-alignment.md §Findings` 4, `open` until closed. The lead closes at once only:

- `rejected` — with the refuting quote (`§Findings` 5).
- `changed — fix task <N>` — a fix task added to tasks.md for a finding in the 'Code, inside the open spec' row: NO-GO, re-checked by the next review's C.
- `changed — product-check task reopened` — for a finding against the product-check record itself (its claims did not reproduce): NO-GO, a new record follows the fix.

Every other finding goes to Step 3 and is closed by the user's answer. A finding raised again with no new fact is closed by pointing at the user's earlier closure (`§Findings` 6), written `F<k> — <closure> — probe/user-run-<x>.md (R<p>-F<q>)`, with the other spec's directory name in front when the answer lies there (`<spec-dir-name>/probe/user-run-<x>.md`).

Three rules:

1. **Never reword a criterion on the strength of the code alone.** Quote the decision that changed it (research.md, design.md or tasks.md, by file:line), or ask the user.
2. **A decision ranked below requirements and decision records is confirmed, never applied silently.** One that contradicts a decision record or steering is a finding in that row.
3. **Confirm once, before GO.** A stale criterion goes into the Step 3 message as previous → new text.

#### 2e. Regression Guard Check (kind `fix`)

(i) Every Regression Guard named in design.md exists (grep the test name); (ii) `probe/` holds the guard's failing run from before the fix and the post-fix re-run of every Defect Ledger row. Missing → **Critical**: "Regression guard missing" / "Reproduction not re-run".

#### 2f. Verdict Check (kind `verify`)

- Every verdict points at the `probe/` records it rests on, and those records meet the question's rule in requirements.md (vocabulary: `docs/settings/rules/spec-kinds.md` §6). If not, flag as **Critical**: "Verdict incomplete". That `verdict.md` has a verdict for every question is checked by `check_completion.sh` (2b)
- The files this spec's tasks changed — the working-tree changes the tasks made and any commits made during impl for this spec — are all under the spec directory. A product file among them is **Critical**: "verify spec changed product code". Unrelated working-tree changes are handled as in 4f (warn and exclude), not flagged here.
- A verdict other than `holds` is a finding (`spec-kinds.md` §6): it goes into item 1 of the Step 3 message with the row of `concept-alignment.md §Findings` it falls under, and the user's answer closes it in the seat that row names (the plan, the decision records). The spec still completes with its verdict.

#### 2g. Assumption Signpost Check (if design.md declares assumptions)

For each assumption declared in `design.md`, check whether its signpost actually fired during implementation — the implementation is the first place an unverified premise meets reality. If one fired, flag as **Warning** with what it invalidates. Non-blocking: report it so the knowledge survives the spec.

### Step 3: GO/NO-GO Decision

**The message to the user (one, before GO)**: the details stay in the report files; each item takes 1–3 lines.

1. **What needs the user's decision**
   - Every review finding routed to the user (2d): its `Conflict:` line word for word, then one line with your proposed answer (for a stale criterion: previous → new text; with the refutation, when you hold one). A finding in the 'Decision records or steering' row is presented per `decision-records.md §Change Control`; the change is committed on that answer (`§Change Control` 5).
   - The latest product-check record's findings with `Route: open — the user`: its `In use:` line — its `Conflict:` line where there is none — word for word, then your proposed answer; and its E. Questions for the user.
   - Every criterion no `[x]` task cites (2b): fix the criterion, or add a task.
   - In a run where 2a–2c passed: every `user` scenario of behaviors.md without its `probe/user-S<N>.md` — what to do and what should happen (`concept-alignment.md §User Check`), and whether the spec may complete with S<N> `not run`.
   - A verdict other than `holds` (2f).
2. **For information only (no answer asked)**: what was closed without the user, one line each — the `rejected` / `changed` lines of `routing-<n>.md` and the record's `Route:` lines.

When 1 is empty, ask nothing; 2 goes into this run's report. Otherwise wait for the answer.

**Recording the answer**: the user's words, verbatim, with the build (commit):

- Findings: `{spec_path}/probe/user-run-<n>.md` — the build on its first line; one heading per finding the answer decides (`## F<k>` for this run's, `## R<m>-F<k>` for an earlier run's, `## P<k>` for the product-check record's); a reply that decides none of them — "go ahead" — is saved above the headings and gets none.
- A `user` scenario: `{spec_path}/probe/user-S<N>.md`. One the answer reports no run of gets no record and stays `not run`: the spec completes with it only on the user's yes to completing without it, listed in the completion report; otherwise it is **Critical**: "User check not run".
- Routing: set each line the answer closes — this run's in `routing-<n>.md`, an earlier run's in its `routing-<m>.md` — as `F<k> — <closure> — <rest>`, `<rest>` naming the fix task when there is one and `probe/user-run-<n>.md`. Criterion changes are recorded as in 4a and 4f.

After the answer, a finding left to be fixed is **Critical**: "Finding open" — add its fix task to tasks.md (its routing line `changed — fix task <N>`), or edit the document and have it re-approved (`concept-alignment.md §Findings`). When a fix task touches this spec's code, reopen the product-check task; it runs after the fix (`concept-alignment.md §Product Check`).

**Completion record**: re-run `bash docs/settings/scripts/check_completion.sh {spec_path}` after the answer. A non-zero exit is **Critical**: "Completion record incomplete", with its output. A finding the user has closed does not block completion.

**GO Criteria**: Zero Critical issues, and `check_completion.sh` exits 0.

**If NO-GO**: **stop here** — do not proceed to Step 4. The spec stays in `todo/`; this run's only writes are under `reviews/`, the user's answers under `probe/`, and in tasks.md the fix tasks, the reopened product-check task and the `_Evidence:` lines of 2b.

**If GO**: present the verification summary and proceed to Step 4.

### Step 4: Completion

#### 4a. Reconcile Requirements

Apply, in `{spec_path}/requirements.md`, every criterion the Step 3 answer resolved as "fix the criterion"; record each in Requirements changes and as a `Reconciled: <ID>` line (4f). For a finding in the 'Decision records or steering' row, fix the criterion only after the decision answer, following it. Never renumber a criterion. Carry each change to the documents that cite it (`document-hygiene.md §After a Change`). Do not add a revision-history section to any document — git holds the history (`docs/settings/rules/document-hygiene.md`, one fact, one seat).

Put `## Requirements changes` at the top of the reply: per criterion ID, the full previous → new text, then one line with the grounds (file:line) and the finding ID. When there are decision changes, the `## Decision changes` section follows it.

#### 4b. Update Metadata

Set `spec.json` `phase: "done"`.

#### 4c. Move Spec to Done

Move `docs/specs/todo/<feature-name>/` to `docs/specs/done/<feature-name>/` — the whole directory, untracked files under `reviews/` and `probe/` included.

#### 4d. Plan Sync (when the spec belongs to a plan)

If `spec.json` carries a `plan` block and `docs/plans/<parent>/units.md` keeps per-unit detail blocks, delete the completed unit's block — the Summary row and the done spec are the record. The edit is staged with the feature commit (4f); it is part of completing the unit.

#### 4e. Detect Commit Message Style

From `git log --oneline -20`: Conventional Commits (`feat:`, `fix:`, `chore:`, etc.) → use matching format; scope usage (`feat(scope):`) → include feature name as scope; no clear pattern → default to Conventional Commits. Commit type: the kind's column in `docs/settings/rules/spec-kinds.md` §4.

#### 4f. Stage and Commit

- Check `git status`. Stage the moved spec directory (`docs/specs/done/<feature-name>/`), the implementation code changes of the feature's tasks, and the 4d plan updates, when present. Unrelated unstaged changes: warn the user and exclude them.
- Commit with the detected style, e.g. `<type>(<short-name>): <summary>`. Kind `verify`: the commit holds only the spec directory and the 4d plan updates, with the message `docs(spec): verdict <feature-name>`.
- The requirements.md and design.md edits from 4a are part of this commit. Add one body line per reconciled criterion, pointing at the decision by section heading, not line number (line numbers go stale with edits), or at the Step 3 confirmation when no decision is quoted:
  ```
  Reconciled: 1.10 ← design.md §<section heading>
  Reconciled: 3.5 ← spec-done confirmation
  ```
- Do not push; pushing is the user's.

### Step 5: Steering Sync Check (non-blocking)

Runs only on GO, after the feature is committed (Step 4), and never blocks completion. Apply `docs/settings/rules/steering-principles.md §Admission` and `§Updating` to what this feature changed, against the steering loaded in Step 1; promotion candidates for `behaviors.md` come from the spec's `behaviors.md` §Promotion Candidates.

**Nothing to change**: report "Steering current — no update needed" and finish without touching steering. **Changes**: propose, confirm, and commit per `§Updating` as `docs(steering): sync after <feature-name>`, in the commit style detected in Step 4e. Declined: leave steering untouched; it can be synced anytime with `/sdd-steering`. For a review beyond what this feature touched, point the user to `/sdd-steering`.

### Step 6: Decision Sync (non-blocking, when decision records exist)

If `docs/steering/product.md §Decision Records` declares a decisions root, follow `docs/settings/rules/decision-records.md §Change Control` for this feature — like Step 5, only on GO, after Step 4, never blocking. What this step puts in the decision records:

1. **`Used by`**: for every registry ID this feature adopted (rows carrying `spec: <this-feature>` plus IDs its code references), append `code: <path Symbol>` in `<decisions-root>/registry.md`. The `spec:` entry stays — the spec now lives in `done/`, so the script classifies it as implemented.
2. **Orphans**: grep the enums / const catalogs this feature touched; an identifier with no registry row is reported. Norm → propose the row in the Decision changes section; implementation detail → ignore; unsure → an Open Question in the decisions README. Never silently adopt or delete a norm.
3. Run `bash docs/settings/scripts/check_decisions.sh check` and report its findings.
4. When this step changed the decision records, present the Decision changes section and ask once — commit? On yes, commit as `docs(decisions): sync after <feature-name>`; on no, revert (`decision-records.md §Change Control` 5) and report what was not landed. Nothing changed → report "Decisions current".

</instructions>

## Output Description

Provide output in the language specified in spec.json.

**If NO-GO** (Markdown with severity indicators, under 500 words; the Step 3 message is not counted):

1. **Verification Summary**: Table of all checks with pass/fail status, and 2d's state (run, or not run and why)
2. **Issues**: by severity (Critical / Warning / Info), each with the problem, the location affected, and the corrective action (including the fix tasks added to tasks.md)
3. **Next Steps**: Specific commands to fix issues and re-run

**If GO** (concise Markdown, under 300 words; the Step 3 message is not counted):

1. **Requirements changes** (when any criterion changed): at the top, as in 4a; `## Decision changes` follows when present
2. **Verification Summary**: Table of all checks — all passed, including one line `Review: n findings (closed by the user m · rejected r · fixed f)`, the review report path, the product-check record path, item 2 of the Step 3 message, every `user` scenario left `not run`, and for `verify` the tasks a `fails` removed (`spec-kinds.md` §6)
3. **Completion Actions**: Confirm spec moved and commit created, with the commit hash and message
4. **Steering Sync**: One of — "Steering current — no update needed", "Steering updated (separate commit `<hash>`)", or "Steering update declined"
5. **Decision Sync**: "No decision records declared — skipped", "Decisions current", or the Decision changes landed (commit hash) or declined and reverted, orphans routed, and `check_decisions.sh` findings

## Safety & Fallback

- **Incomplete Tasks** → NO-GO: list the remaining tasks; suggest "Complete remaining tasks with `/sdd-spec-impl <feature-name> <task-numbers>`, then re-run `/sdd-spec-done <feature-name>`"
- **Lint/Test/Build Failures** → NO-GO: show the command output; suggest "Fix the reported errors, then re-run `/sdd-spec-done <feature-name>`"
- **Unrelated Changes in Working Tree** → Warning: "Unrelated changes detected in working tree. These will not be included in the commit." Proceed with only feature-related changes
- **No Unstaged Implementation Changes** → Info: the implementation was committed incrementally; only the spec move is committed. Proceed
- **Git Not Clean for Spec Move** → Warning: uncommitted modifications in `docs/specs/todo/<feature-name>/` are included in the commit

**Workflow**: before — complete all implementation tasks, the product-check task last (`/sdd-spec-impl <feature-name>`; optional mid-implementation validation: `/sdd-validate-impl <feature-name>`). After — the feature is committed, the spec archived in `docs/specs/done/<feature-name>/`, steering updated in its own commit when the feature changed what it holds; next: `/sdd-spec-init "description"`.
