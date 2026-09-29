---
name: sdd-spec-done
description: >-
  Finalize an SDD feature: verify implementation quality, move spec to done, and commit.
  Runs lint/test/build checks, validates requirements and design alignment, completes the feature,
  then checks project steering against what the feature changed.
argument-hint: "<feature-name>"
---

# Feature Completion

<background_information>

- **Mission**: Verify implementation quality comprehensively, then finalize the feature by moving the spec to done and creating a git commit
- **Success Criteria**:
  - All tasks marked as completed in tasks.md
  - Every acceptance criterion checked clause by clause by an independent auditor against the code, with every ID covered in `criteria-audit.md` (`verify`: 2j instead)
  - Every non-HOLDS audit item routed (A / B / C / D / E, or rejected as a false positive); stale criterion wording reconciled in requirements.md
  - Design alignment verified
  - Lint, tests, and build pass without issues (`verify`: 2j instead)
  - Behavior scenarios (if formulated) verified with concrete evidence — no concept drift
  - Code is clean and does not require refactoring
  - Spec moved from `docs/tasks/todo/` to `docs/tasks/done/`
  - Changes committed with project-consistent commit message
  - Steering checked against what the feature changed (`docs/settings/rules/steering-principles.md`)
  - When a canon layer exists: `Used by` updated for the registry IDs this feature implemented, orphan identifiers reported, `check_canon.sh check` run (non-blocking), canon changes committed separately

</background_information>

<instructions>

## Input

This skill expects:
1. **Feature name** (required): The feature directory name in `docs/tasks/`

If inputs were provided with this skill invocation, use them directly.
Otherwise, ask the user for the feature name.

## Core Task

Run comprehensive quality verification on the completed feature. If all checks pass, finalize by moving the spec to done and committing. If any check fails, report issues and suggest corrective actions.

## Execution Steps

### Step 0: Resolve Spec Path

Look for the feature directory in `docs/tasks/todo/<feature-name>/` **only**. Features already in `docs/tasks/done/` are already completed and cannot be finalized again. If not found in `todo/`, report an error.

### Step 1: Load Context

**Read all necessary context**:

- `{spec_path}/spec.json` for metadata, language, and `kind`
- `{spec_path}/requirements.md` for requirements
- `{spec_path}/behaviors.md` for behavior scenarios (if exists)
- `{spec_path}/verdict.md` for the judgments (kind `verify`)
- `{spec_path}/design.md` for design structure
- `{spec_path}/tasks.md` for task list
- **Entire `docs/steering/` directory** for complete project memory
- `docs/settings/rules/change-propagation.md` for the documents each change must carry through

### Step 2: Verification

Execute all verification checks sequentially. Collect all issues before making a decision.

**By kind**: `verify` skips 2b, 2c, 2d–2g and 2i and runs 2j instead. `fix` also runs 2b-fix after 2b. Every other check applies to every kind.

#### 2a. Task Completion Check

- Parse tasks.md for all checkboxes
- ALL tasks must be `[x]` (completed)
- If any `[ ]` remain, flag as **Critical**: "Incomplete tasks found"

#### 2b. Acceptance Criteria Audit

The criteria are checked clause by clause by an auditor that has not read the upstream documents, then the lead routes each discrepancy. The context loaded in Step 1 is used for routing (④), never handed to the auditor. One audit run finds some discrepancies, not all — treat it as a way to find drift, not a guarantee of none.

**① Extract the criteria**

```bash
bash docs/settings/scripts/list_criteria.sh {spec_path}/requirements.md
```

Prints one line per numbered acceptance criterion: `N.M<TAB>text`.

**② Independent auditor**

Dispatch **one new sub-agent**, via whatever delegation tool the host harness provides. Pass it the extracted criteria list (the output of ①) and the instruction below, verbatim — and nothing else: no upstream history, no summary of the spec, no impressions of your own. It reads the repository's code and tests. The prohibition on other documents is in the instruction; no tool restriction is applied (in the acceptance run the auditor did read probe scripts under docs/, but no document). For a `chore` whose deliverable is a document, name that document in the instruction as an auditable artifact.

Auditor instruction:

```
You are auditing whether the code in this repository does what a list of acceptance criteria says. Your only inputs are the criteria below (one criterion per line: ID<TAB>text) and the repository's code and tests. Do not read any document under docs/ — requirements, design, research, tasks, behaviors, steering, canon, validate-* reports — and do not look for design notes or history. Code, tests and probe scripts are inputs wherever they live, including under docs/. Do not modify any file.

For every criterion:
1. Take its `shall` predicate — the thing asserted to happen.
2. Find the seat in the code that produces it (file:line), or establish that none exists.
3. Write what the code actually does, from the code itself, quoting file:line.
4. Only then compare it with the predicate. Verdict: HOLDS / MISMATCH / NO-SEAT / RUNTIME-ONLY. Do not decide whether the code or the criterion is wrong — only state the difference.

A clean result is a normal outcome. Do not guess: every claim needs a file:line quote.

Output (in <language from spec.json>):
A. Coverage: every ID, one per line: `ID | seat file:line | HOLDS / MISMATCH / NO-SEAT / RUNTIME-ONLY`.
B. For each verdict other than HOLDS: `ID` / quoted predicate / what the code does (file:line quotes) / the difference.
C. For criteria that assert an absence ("shall not", "does not have", "does not …"): whether any test or guard would fail if the absence broke (name it, or "none").

Criteria:
<output of list_criteria.sh>
```

Save the auditor's report as `{spec_path}/criteria-audit.md`.

**③ Coverage check**

```bash
bash docs/settings/scripts/list_criteria.sh --check {spec_path}/requirements.md {spec_path}/criteria-audit.md
```

Exit 0 prints `OK: <n> criteria covered`. Exit 1 prints `MISSING: <ID>` (stderr) for every ID absent from the report — send those IDs back to the same auditor, have it add their rows (A, and B / C where they apply), append them to `criteria-audit.md`, and re-run the check until it exits 0. `UNKNOWN: <ID>` (an ID in the report but not in requirements.md) is a warning only.

**④ Routing by the lead**

With every document and the canon loaded, route each non-HOLDS item of `criteria-audit.md` one at a time. **Gather the evidence first (file:line quotes of the decision and of the code); choose the class last.**

| Class | Condition | Action |
| --- | --- | --- |
| **A** — criterion wording is stale | A decision recorded after the requirements — in research.md, design.md or tasks.md — can be quoted by file:line, and the code implements it | Into the one batched confirmation (Step 3), proposing previous → new criterion text |
| **B** — implementation diverged | No decision recorded after the requirements can be quoted that supports the code's behavior | Into the one batched confirmation. Default is a code fix: the criterion stands, a fix task is added to tasks.md, NO-GO. The user may override with "fix the criterion". An override is recorded in `## Requirements changes` (class: "B → fix the criterion") and as a `Reconciled: 3.5 ← spec-done confirmation` line in the commit body. Git holds the history |
| **C** — decided but not implemented | A decision recorded after the requirements asks for the behavior, and the code does not do it (no such decision, only the criterion → B) | The user decides — implement, or withdraw the decision. Into the one batched confirmation |
| **D** — upstream document is stale | Canon or steering states something the code contradicts, and the criterion inherited it | Route to canon change control (`docs/settings/rules/canon-layer.md §Change Control`) and into the one batched confirmation. The criterion fix follows that answer |
| **E** — checked against an artifact | A criterion the auditor marked NO-SEAT or RUNTIME-ONLY — the code alone cannot settle it (e.g. a probe shows it; the registry holds it; only a run can confirm it) | The lead checks the artifact (probe results file, the evidence on a behaviors.md `Verification:` line, registry, document). If it shows the predicate, close the item. If not, put it into the one batched confirmation as a ruling: proceed as is / fix the criterion / defer to a later spec |
| False positive | The auditor misread the code | Reject it by quoting the refuting file:line. Leave its row in `criteria-audit.md` |

The B/C boundary is whether a decision recorded after the requirements exists.

Three rules:

1. **Never choose A on the strength of the code alone.** If you cannot quote the decision, it is not A.
2. **Compare the authority of the decision.** Decisions in research.md, design.md or tasks.md rank below requirements and canon — that is why A is always confirmed, never applied silently. If the decision contradicts canon or steering, route to D.
3. **Confirm once, before GO.** Every A, B, C, D and unclosed E goes into one batched question in Step 3 — requirements and canon changes become visible before any commit.

For each criterion that asserts an absence and has no test or guard in the audit's section C, flag as **Warning**: "Absence unverified". Report it only; adding a guard is not required.

#### 2b-fix. Regression Guard Check (kind `fix`)

- (i) Every Regression Guard named in design.md exists (grep the test name); (ii) `probe/` holds the guard's failing run from before the fix and the post-fix re-run of every Defect Ledger row
- Missing → **Critical**: "Regression guard missing" / "Reproduction not re-run"

#### 2c. Design Alignment

- Check if design.md structure is reflected in implementation
- Verify key interfaces, components, and modules exist
- Confirm file structure matches design
- If misalignment found, flag as **Warning**: "Design deviation"

#### 2d. Lint Check

- Detect lint command from project configuration:
  1. `package.json` scripts (`lint`, `lint:check`)
  2. `Makefile` targets (`lint`)
  3. `pyproject.toml` / `Cargo.toml` equivalents
  4. Steering context (`docs/steering/tech.md`)
- Run detected lint command
- If lint fails, flag as **Critical**: "Lint errors detected"
- If no lint command detected, flag as **Info**: "No lint configuration found — skipping"

#### 2e. Test Check

- Detect test command from project configuration:
  1. `package.json` scripts (`test`, `test:unit`)
  2. `Makefile` targets (`test`)
  3. `pyproject.toml` / `Cargo.toml` equivalents
  4. Steering context (`docs/steering/tech.md`)
- Run detected test command
- If tests fail, flag as **Critical**: "Test failures detected"
- If no test command detected, flag as **Warning**: "No test configuration found — manual verification required"

#### 2f. Build Check

- Detect build command from project configuration:
  1. `package.json` scripts (`build`, `compile`)
  2. `Makefile` targets (`build`)
  3. `pyproject.toml` / `Cargo.toml` equivalents
  4. Steering context (`docs/steering/tech.md`)
- Run detected build command
- If build fails, flag as **Critical**: "Build errors detected"
- If no build command detected, flag as **Info**: "No build configuration found — skipping"

#### 2g. Behavior Verification Check (if behaviors.md exists)

- For every scenario, confirm the `Verification:` line carries concrete, passing evidence (existing test / probe results file / manual observation record)
- If a scenario lacks evidence or its evidence fails, flag as **Critical**: "Behavior not verified"
- If the implemented behavior contradicts a scenario or a `docs/steering/behaviors.md` invariant, flag as **Critical**: "Concept drift detected"
- If no behaviors.md exists, flag as **Info**: "No behavior scenarios — skipping" (legacy specs); when the kind does not produce behaviors: "Behavior scenarios not applicable (`<kind>`)"

#### 2h. Assumption Signpost Check (if design.md declares assumptions)

- For each assumption declared in `design.md`, check whether its signpost actually fired during implementation — the implementation is the first place an unverified premise meets reality
- If one fired, flag as **Warning** with what it invalidates. Non-blocking: report it so the knowledge survives the spec

#### 2i. Code Quality Review

- Review implemented code for the feature's tasks
- Check for:
  - Code duplication that should be extracted
  - Overly complex methods that need simplification
  - Missing error handling at system boundaries
  - Inconsistent patterns compared to existing codebase
- If refactoring is needed, flag as **Warning**: "Refactoring recommended" with specific suggestions

#### 2j. Verdict Check (kind `verify`)

- `verdict.md` exists, and every question (`### N` in requirements.md) has a verdict from `holds | partial | fails | unmeasured` with a `probe/` pointer. If not, flag as **Critical**: "Verdict incomplete"
- The files this spec's tasks changed — the working-tree changes the tasks made and any commits made during impl for this spec — are all under the spec directory. A product file among them is **Critical**: "verify spec changed product code". Unrelated working-tree changes are handled as in 4f (warn and exclude), not flagged here.

### Step 3: GO/NO-GO Decision

**Batched confirmation (before GO)**: If 2b routed any item to A, B, C, D, or left an E item unclosed, ask the user **once**, in a single message, covering all of them — each with its ID, class, evidence, and the proposed action (A: previous → new criterion text; B: code fix by default, or "fix the criterion"; C: implement / withdraw the decision; D: the proposed canon change, presented per `canon-layer.md §Change Control`; E: proceed as is / fix the criterion / defer to a later spec). The canon confirmation for D items is taken here, not after GO in Step 6.

After the answer, every B still resolved as a code fix, and every C the user chose to implement, is **Critical**: "Implementation diverged from criterion" — add a fix task for it to tasks.md. A C the user chose to withdraw is handled like a B override: fix the criterion to match the code's behavior in Step 4a and record it the same way (Requirements changes and a `Reconciled:` line).

**GO Criteria**: Zero Critical issues.

**If NO-GO**:

- Present all issues categorized by severity (Critical / Warning / Info)
- For each issue, provide:
  - Description of the problem
  - Specific file(s) or location(s) affected
  - Suggested corrective action
- Suggest next steps: fix issues, then re-run `/sdd-spec-done <feature-name>`
- **Stop execution here** — do not proceed to Step 4

**If GO**:

- Present verification summary showing all checks passed
- Proceed to Step 4

### Step 4: Completion

#### 4a. Reconcile Requirements

Apply, in `{spec_path}/requirements.md`: every A item, and every criterion the Step 3 answer resolved as "fix the criterion" (B overridden, C withdrawn, E, D). For a B override or a C withdrawal, record it in Requirements changes and as a `Reconciled: <ID> ← spec-done confirmation` line (4f). For D, fix the criterion only after the canon answer, following it.

- Never renumber a criterion.
- Record the answer to each E ruling in the spec before finalizing.
- Do not add a revision-history section to any document — git holds the history (`docs/settings/rules/document-hygiene.md`, one fact, one seat).
- Put `## Requirements changes` at the top of the reply: per criterion ID, the full previous → new text, then one line with the grounds (file:line) and the class. When there are canon changes, the `## Canon changes` section follows it.

#### 4b. Update Metadata

- Update `spec.json`:
  - Set `phase: "done"`
  - Update `updated_at` timestamp

#### 4c. Move Spec to Done

- Move `docs/tasks/todo/<feature-name>/` to `docs/tasks/done/<feature-name>/`

#### 4d. Inception Sync (when the spec belongs to a plan)

If `spec.json` carries a `plan` block, update `docs/inception/<parent>/` to reflect completion:

- In `units.md`, repoint the unit's Summary-row Spec link from `todo/` to `done/` and, when the file keeps per-unit detail blocks, delete the completed unit's block — the Summary row and the done spec are the record.
- Update the unit's `status` in `inception.json` when that field exists.

These files are staged with the feature commit (4f); they are part of completing the unit.

#### 4e. Detect Commit Message Style

- Analyze recent git history:
  ```bash
  git log --oneline -20
  ```
- Detect dominant pattern:
  - Conventional Commits (`feat:`, `fix:`, `chore:`, etc.) → use matching format
  - Scope usage (`feat(scope):`) → include feature name as scope
  - No clear pattern → default to Conventional Commits
- Commit type: the kind's column in `docs/settings/rules/spec-kinds.md` §4

#### 4f. Stage and Commit

- Check `git status` for current working tree state
- Stage changes relevant to this feature:
  - The moved spec directory (`docs/tasks/done/<feature-name>/`)
  - Implementation code changes related to the feature's tasks
  - Inception plan updates from 4d, when present
- If unrelated unstaged changes exist, warn the user and exclude them
- Commit with detected style, e.g.:
  ```
  <type>(<short-name>): <summary>
  ```
- Kind `verify`: the commit holds only the spec directory and the 4d inception updates, with the message `docs(spec): verdict <feature-name>`
- The requirements.md and design.md edits from 4a are part of this commit. Add one body line per reconciled criterion, pointing at the decision by section heading, not line number (line numbers go stale with edits). A B override or C withdrawal points at the Step 3 confirmation:
  ```
  Reconciled: 1.10 ← design.md §<section heading>
  Reconciled: 3.5 ← spec-done confirmation
  ```
- **Do NOT push** — leave that to the user

### Step 5: Steering Sync Check (non-blocking)

Runs only on GO, after the feature is committed (Step 4), and never blocks completion. Apply `docs/settings/rules/steering-principles.md §Admission` and `§Updating` to what this feature changed, against the steering loaded in Step 1; promotion candidates for `behaviors.md` come from the spec's `behaviors.md` §Promotion Candidates.

- **Nothing to change**: report "Steering current — no update needed" and finish without touching steering.
- **Changes**: propose, confirm, and commit per `§Updating` as `docs(steering): sync after <feature-name>`, in the commit style detected in Step 4e. Declined: leave steering untouched; it can be synced anytime with `/sdd-steering`.

For a review beyond what this feature touched, point the user to `/sdd-steering`.

### Step 6: Canon Sync (non-blocking, when a canon layer exists)

If `docs/steering/product.md §Canon References` declares a canon root, run the "Canon changes" protocol from `docs/settings/rules/canon-layer.md §Change Control` for this feature — like Step 5, only on GO, after Step 4, never blocking:

1. **`Used by`**: for every registry ID this feature adopted (rows carrying `spec: <this-feature>` plus IDs its code references), append `code: <path Symbol>` in `<canon-root>/registry.md`. The `spec:` entry stays — the spec now lives in `done/`, so the script classifies it as implemented.
2. **Orphans (the direction that historically goes unwatched)**: grep the enums / const catalogs this feature touched; an identifier with no registry row is reported. Norm → propose the row in the Canon changes section and take one confirmation; implementation detail → ignore; unsure → an Open Question in the canon README. Never silently adopt or delete a norm.
3. Run `bash docs/settings/scripts/check_canon.sh check` and report its findings.
4. Present `## Canon changes` (full text of changed sections), then commit only the files edited here: `docs(canon): sync after <feature-name>` — its own commit, never bundled with the feature or steering commits. Nothing changed → report "Canon current".

Canon changes for 2b's D items were already confirmed in the Step 3 batched confirmation; do not ask for them again here.

## Critical Constraints

- **todo/ only**: Only finalize features in `docs/tasks/todo/` — never re-process `done/`
- **All checks must pass**: Zero Critical issues for GO decision
- **Independent criteria audit**: The auditor receives only the criteria list and reads only code and tests; routing is the lead's job, evidence first and class last. No quota or cap on the number of findings — a quota's harm has been measured; a cap's has not, but nothing supports one either
- **No A from code alone**: A requires a decision recorded after the requirements, quoted by file:line
- **One confirmation, before GO**: A, B, C, D and unclosed E are asked in one batched question before GO; a B still resolved as a code fix, or a C the user chose to implement, means NO-GO
- **Requirements changes are visible**: Every criterion changed is shown previous → new under `## Requirements changes` at the top of the reply and listed as `Reconciled:` in the feature commit body; no revision-history sections
- **No auto-push**: Commit locally only; pushing is the user's responsibility
- **Scoped commits**: Only stage changes related to this feature
- **Non-destructive**: If anything fails, the spec stays in `todo/`; the only writes are `criteria-audit.md` and the fix tasks added to tasks.md for B (and for C chosen to implement)
- **Steering sync never blocks**: Step 5 runs only after the feature is committed and is never a GO/NO-GO gate
- **Canon sync never blocks**: Step 6 runs after the feature is committed (the canon confirmation for 2b's D items is taken in Step 3 instead), presents every changed section in full, pauses only for a new norm or an overturned one (`canon-layer.md` R2), and lands in its own `docs(canon):` commit

</instructions>

## Tool Guidance

- **Read first**: Load all context (spec, steering, implementation) before verification
- **Bash for checks**: Execute lint, test, and build commands via Bash
- **Grep/Read for traceability**: Search codebase for requirement and design evidence
- **Bash for git**: Use git commands for commit style detection, staging, and committing
- **Edit for steering**: Apply the changes confirmed in Step 5 to `docs/steering/*.md` with Edit

## Output Description

Provide output in the language specified in spec.json:

### If NO-GO

1. **Verification Summary**: Table of all checks with pass/fail status
2. **Issues**: List of issues by severity with descriptions and suggestions (including the number of B items left as code fixes and the fix task added to tasks.md for each)
3. **Next Steps**: Specific commands to fix issues and re-run

**Format**: Markdown with severity indicators, under 500 words

### If GO

1. **Requirements changes** (when any criterion changed): at the top — per criterion ID, previous → new, grounds (file:line), class; `## Canon changes` follows when present
2. **Verification Summary**: Table of all checks — all passed, including one line `Criteria reconciled: n (confirmed m · artifact-checked e)` (on GO, B is zero by definition)
3. **Completion Actions**: Confirm spec moved and commit created
4. **Commit Details**: Show commit hash and message
5. **Steering Sync**: One of — "Steering current — no update needed", "Steering updated (separate commit `<hash>`)", or "Steering update declined"
6. **Canon Sync** (when a canon layer exists): "Canon current", or the Canon changes landed (commit hash), orphans routed, and `check_canon.sh` findings

**Format**: Concise Markdown, under 300 words

## Safety & Fallback

### Error Scenarios

**Feature Not Found in todo/**:

- **Stop Execution**: Cannot finalize a feature that doesn't exist in todo/
- **Check done/**: If found in `docs/tasks/done/`, report "Feature already completed"
- **Neither**: Report "Feature not found. Check available specs with `/sdd-spec-status`"

**Incomplete Tasks**:

- **NO-GO**: List remaining tasks with their descriptions
- **Suggested Action**: "Complete remaining tasks with `/sdd-spec-impl <feature-name> <task-numbers>`, then re-run `/sdd-spec-done <feature-name>`"

**Lint/Test/Build Failures**:

- **NO-GO**: Show command output with error details
- **Suggested Action**: "Fix the reported errors, then re-run `/sdd-spec-done <feature-name>`"

**Unrelated Changes in Working Tree**:

- **Warning**: "Unrelated changes detected in working tree. These will not be included in the commit."
- **Proceed**: Continue with only feature-related changes

**No Unstaged Implementation Changes**:

- **Info**: If all implementation code is already committed, only the spec move will be committed
- **Proceed**: This is a valid scenario (user committed implementation incrementally)

**Git Not Clean for Spec Move**:

- **Warning**: If `docs/tasks/todo/<feature-name>/` has uncommitted modifications, include them in the commit

### Workflow Integration

**Before Running spec-done**:

- Complete all implementation tasks: `/sdd-spec-impl <feature-name>`
- Optional mid-implementation validation: `/sdd-validate-impl <feature-name>`

**After Successful Completion**:

- Feature is finalized and committed
- Spec is archived in `docs/tasks/done/<feature-name>/`
- Steering is updated in its own commit if the feature changed what it holds; otherwise left as-is
- Ready to start next feature with `/sdd-spec-init "description"`
