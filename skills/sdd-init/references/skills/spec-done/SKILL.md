---
name: sdd-spec-done
description: >-
  Finalize an SDD feature: verify implementation quality, move spec to done, and commit.
  Runs lint/test/build checks, an independent criteria audit and product check, routes every finding,
  completes the feature, then checks project steering against what the feature changed.
---

# Feature Completion

<background_information>

- **Mission**: Verify implementation quality comprehensively, then finalize the feature by moving the spec to done and creating a git commit
- **Success Criteria**:
  - All tasks marked as completed in tasks.md
  - The kind's completion checks (`docs/settings/rules/spec-kinds.md` §4, `Completion checks`) recorded under `{spec_path}/reviews/`, and `check_completion.sh` exits 0 — of them:
    - `criteria-audit`: every acceptance criterion checked clause by clause by an independent auditor against the code, with every ID covered in `reviews/criteria-audit-<n>.md`
    - `product-check`: the running product checked from its entry by a reviewer that did not build it
    - `verdict`: every question judged in `verdict.md` (2j)
  - Every finding routed and closed per `docs/settings/rules/concept-alignment.md §Findings`, one line each in `reviews/routing-<n>.md`; stale criterion wording reconciled in requirements.md
  - Design alignment verified
  - Lint, tests, and build pass without issues (`verify`: 2j instead)
  - Implemented behavior contradicts no scenario or invariant — no concept drift
  - Code-quality findings reported (2i)
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

Look for the feature directory in `docs/tasks/todo/<feature-name>/` **only**. If it is in `docs/tasks/done/` instead, stop with "Feature already completed"; if it is in neither, stop with "Feature not found. Check available specs with `/sdd-spec-status`".

### Step 1: Load Context

**Read all necessary context**:

- `{spec_path}/spec.json` for metadata, language, and `kind`
- `{spec_path}/requirements.md` for requirements
- `{spec_path}/behaviors.md` for behavior scenarios (if exists)
- `{spec_path}/verdict.md` for the judgments (kind `verify`)
- `{spec_path}/design.md` for design structure
- `{spec_path}/tasks.md` for task list
- The entire `docs/steering/` directory
- `docs/settings/rules/concept-alignment.md`, applied whole: §Findings to route and close every finding of this run, §Product Check for 2k, §User Check for Step 3
- `docs/settings/rules/document-hygiene.md` for every document this run writes or changes (§After a Change)

### Step 2: Verification

Execute all verification checks sequentially. Collect all issues before making a decision.

**By kind**: 2b (`criteria-audit`), 2k (`product-check`) and 2j (`verdict`) run when the kind's `Completion checks` column in `docs/settings/rules/spec-kinds.md` §4 lists them. `verify` also skips 2c, 2d–2g and 2i. `fix` also runs 2b-fix after 2b. Every other check applies to every kind.

**Run number**: `<n>` is one more than the largest number among the files in `{spec_path}/reviews/` (1 when there are none). Every file this run writes under `reviews/`, and `probe/user-run-<n>.md`, uses the same n.

**Routing record**: when this run has findings, the lead writes `{spec_path}/reviews/routing-<n>.md`, one line per non-HOLDS audit ID and per product-check finding: `<ID> — <open, or its closure (`concept-alignment.md §Findings` 4)> — <where, the quoted refutation, or the file holding the user's answer>`. An audit ID is the criterion's (`3.5`), a product-check ID is `F<k>`; outside its own run's files, a product-check finding of run m is `R<m>-F<k>`. A line stays `open` until it is closed, in its own run's `routing-<m>.md`.

**Commands** (2d–2f): lint, test and build commands come from the project's build configuration (its scripts or targets), else `docs/steering/tech.md` (§Common Commands).

#### 2a. Task Completion Check

- Parse tasks.md for all checkboxes
- Every task must be `[x]`
- If any `[ ]` remain, flag as **Critical**: "Incomplete tasks found"

#### 2b. Acceptance Criteria Audit

The criteria are checked clause by clause by an auditor that has not read the upstream documents, then the lead routes each discrepancy. The context loaded in Step 1 is used for routing (④), never handed to the auditor. One audit run finds some discrepancies, not all — treat it as a way to find drift, not a guarantee of none; there is no quota or cap on the number of findings.

**① Extract the criteria**

```bash
bash docs/settings/scripts/list_criteria.sh {spec_path}/requirements.md
```

Prints one line per numbered acceptance criterion: `N.M<TAB>text`.

**② Independent auditor**

Dispatch **one new sub-agent**, via whatever delegation tool the host harness provides (with no sub-agents: `concept-alignment.md §Product Check`). Pass it the extracted criteria list (the output of ①) and the instruction below, verbatim — and nothing else: no upstream history, no summary of the spec, no impressions of your own. It reads the repository's code and tests. The prohibition on other documents is in the instruction; no tool restriction is applied. For a `chore` whose deliverable is a document, name that document in the instruction as an auditable artifact.

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

Save the auditor's report as `{spec_path}/reviews/criteria-audit-<n>.md`.

**③ Coverage check**

```bash
bash docs/settings/scripts/list_criteria.sh --check {spec_path}/requirements.md {spec_path}/reviews/criteria-audit-<n>.md
```

Exit 0 prints `OK: <count> criteria covered`. Exit 1 prints `MISSING: <ID>` (stderr) for every ID absent from the report — send those IDs back to the same auditor, have it add their rows (A, and B / C where they apply), append them to `criteria-audit-<n>.md`, and re-run the check until it exits 0. `UNKNOWN: <ID>` (an ID in the report but not in requirements.md) is a warning only.

**④ Routing by the lead**

With every document loaded, classify each non-HOLDS item of `criteria-audit-<n>.md` one at a time. **Gather the evidence first (file:line quotes of the decision and of the code); choose the class last.**

| Class | Condition |
| --- | --- |
| **A** — criterion wording is stale | A decision recorded after the requirements — in research.md, design.md or tasks.md — can be quoted by file:line, and the code implements it |
| **B** — implementation diverged | No decision recorded after the requirements can be quoted that supports the code's behavior |
| **C** — decided but not implemented | A decision recorded after the requirements asks for the behavior, and the code does not do it (no such decision, only the criterion → B) |
| **D** — upstream document is stale | Canon or steering states something the code contradicts, and the criterion inherited it |
| **E** — checked against a run | A criterion the auditor marked NO-SEAT or RUNTIME-ONLY — the code alone cannot settle it (e.g. a probe shows it; only a run can confirm it) |
| False positive | The auditor misread the code |

The B/C boundary is whether a decision recorded after the requirements exists.

Where each class goes and how it is closed is `docs/settings/rules/concept-alignment.md §Findings`:

- **A** → the Requirements row: into the Step 3 message, proposing previous → new criterion text.
- **B** → the Code-inside row. Default is a code fix: the criterion stands, a fix task is added to tasks.md, NO-GO. The user may choose "fix the criterion" instead (the Requirements row), so B goes into the Step 3 message. An override is recorded in `## Requirements changes` (class: "B → fix the criterion") and as a `Reconciled: 3.5 ← spec-done confirmation` line in the commit body (`document-hygiene.md`, one fact, one seat).
- **C** → the user decides which it is: implement (a fix task, as B) or withdraw the decision (the criterion is fixed to the code, as A). Into the Step 3 message.
- **D** → the Canon-or-steering row: canon change control (`docs/settings/rules/canon-layer.md §Change Control`), into the Step 3 message. The criterion fix follows that answer.
- **E** → the lead checks this spec's run records: probe results, the evidence on a behaviors.md `Verification:` line, tests, and the product-check report (2k) — so E is settled after 2k. If one shows the predicate, the item is rejected, quoting it. A document's statement is not a run record. If none does, the Cannot-tell row: into the Step 3 message as a ruling — proceed as is / fix the criterion.
- **False positive** → rejected, quoting the refuting file:line. Its row stays in `criteria-audit-<n>.md`.

Each item gets its line in `routing-<n>.md`: rejected items when rejected, the rest `open` until the Step 3 answer closes them. An audit line an earlier `routing-<m>.md` still leaves `open` becomes `changed — re-audited in criteria-audit-<n>.md` once this run's audit is saved; this run's audit carries that criterion.

Three rules:

1. **Never choose A on the strength of the code alone.** If you cannot quote the decision, it is not A.
2. **Compare the authority of the decision.** Decisions in research.md, design.md or tasks.md rank below requirements and canon — that is why A is always confirmed, never applied silently. If the decision contradicts canon or steering, route to D.
3. **Confirm once, before GO.** Every A, B, C, D and unclosed E goes into the one Step 3 message — requirements and canon changes become visible before any commit.

For each criterion that asserts an absence and has no test or guard in the audit's section C, flag as **Warning**: "Absence unverified". Report it only; adding a guard is not required.

#### 2b-fix. Regression Guard Check (kind `fix`)

- (i) Every Regression Guard named in design.md exists (grep the test name); (ii) `probe/` holds the guard's failing run from before the fix and the post-fix re-run of every Defect Ledger row
- Missing → **Critical**: "Regression guard missing" / "Reproduction not re-run"

#### 2c. Design Alignment

- Check if design.md structure is reflected in implementation
- Verify key interfaces, components, and modules exist
- If misalignment found, flag as **Warning**: "Design deviation"

#### 2d. Lint Check

- Run the lint command
- If lint fails, flag as **Critical**: "Lint errors detected"
- If no lint command detected, flag as **Info**: "No lint configuration found — skipping"

#### 2e. Test Check

- Run the test command
- If tests fail, flag as **Critical**: "Test failures detected"
- If no test command detected, flag as **Warning**: "No test configuration found — manual verification required"

#### 2f. Build Check

- Run the build command
- If build fails, flag as **Critical**: "Build errors detected"
- If no build command detected, flag as **Info**: "No build configuration found — skipping"

#### 2g. Behavior Verification Check (if behaviors.md exists)

- For every scenario, read the evidence its `Verification:` line points to (tiers: `docs/settings/rules/behavior-formulation.md §Verification Mapping`). That the evidence exists is checked by `check_completion.sh` (Step 3), not here
- If the implemented behavior, or the evidence, contradicts a scenario or a `docs/steering/behaviors.md` invariant, flag as **Critical**: "Concept drift detected"
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

- Every verdict points at the `probe/` records it rests on, and those records meet the question's rule in requirements.md (vocabulary: `docs/settings/rules/spec-kinds.md` §6). If not, flag as **Critical**: "Verdict incomplete". That `verdict.md` has a verdict for every question is checked by `check_completion.sh` (Step 3)
- The files this spec's tasks changed — the working-tree changes the tasks made and any commits made during impl for this spec — are all under the spec directory. A product file among them is **Critical**: "verify spec changed product code". Unrelated working-tree changes are handled as in 4f (warn and exclude), not flagged here.
- A verdict other than `holds` is a finding (`spec-kinds.md` §6): it goes into item 1 of the Step 3 message with the row of `concept-alignment.md §Findings` it falls under, and the user's answer closes it in the seat that row names (the plan, the canon). The spec still completes with its verdict.

#### 2k. Product Check

Runs only when 2a and 2d–2f passed in this run; otherwise it is not run, and the NO-GO report says so. Who checks, what they are given, and where they record are `docs/settings/rules/concept-alignment.md §Product Check`. When two product-check reports already exist, ask the user before dispatching another; on a no, every earlier finding still `open` goes to the user in Step 3.

- **Dispatch**: one new sub-agent that does not inherit this conversation. Hand it `docs/settings/templates/specs/product-check.md` and only what that file's comment lists. Their sources here: the criteria are the output of 2b ①, the language is spec.json's, the report path is `{spec_path}/reviews/product-check-<n>.md` with this run's n, the time limit is the one the user set for this spec's check, if any. Before dispatching, tell the user in one line that the check is starting and the time limit it runs under (`concept-alignment.md §Waiting on a Run`).
- **Claims to re-check**: every product-check finding of an earlier run still `open` that a change has since answered — its `In use:` line (its `Conflict:` line where there is none), copied from that report, under the ID `R<m>-F<k>`. Never your answer to it.
- **Incomplete report**: a report that does not have exactly one of the two — `#### F<k>` headings, or the `Findings: none` line — goes back to the same reviewer.
- **Routing**: each `F<k>` of the report gets an `open` line in `routing-<n>.md`. For each line of its F. Re-checks: `not reproduced` → set that finding's line in `routing-<m>.md` to `changed — <the change>; re-checked in product-check-<n>.md`; `reproduced` → it stays `open`. The lead writes no other closing for a product-check finding (`concept-alignment.md §Findings` 5), except pointing a finding raised again with no new fact at the user's earlier closure (`concept-alignment.md §Findings` 6), written `F<k> — <closing> — probe/user-run-<x>.md (R<p>-F<q>)`: the answer file that holds that closure — with the other spec's directory name in front when it lies there (`<spec-dir-name>/probe/user-run-<x>.md`) — and the original finding's ID in parentheses.

### Step 3: GO/NO-GO Decision

**The message to the user (one, before GO)**: the details stay in the report files; each item takes 1–3 lines.

1. **What needs the user's decision**
   - Every A, B, C, D and unclosed E of 2b — each with its ID, class, evidence, and the proposed action (A: previous → new criterion text; B: code fix by default, or "fix the criterion"; C: implement / withdraw the decision; D: the proposed canon change, presented per `canon-layer.md §Change Control`; E: proceed as is / fix the criterion). The canon confirmation for D items is taken here, and the change is committed on that answer (`canon-layer.md §Change Control` 5).
   - Every product-check finding still `open`: the reviewer's `In use:` line — its `Conflict:` line where there is none — word for word, then one line with your proposed answer (with the refutation, when you hold one). For a main use not reached inside the time limit: how long a run that reaches it would take, and the ways to shorten it (`concept-alignment.md §Waiting on a Run`) — no longer run starts before the user's answer.
   - In a run where 2a and 2d–2f passed: every `user` scenario of behaviors.md without its `probe/user-S<N>.md` — what to do and what should happen (`concept-alignment.md §User Check`), and whether the spec may complete with S<N> `not run`.
   - A verdict other than `holds` (2j).
2. **For information only (no answer asked)**
   - What was closed without the user, one line each: ID, closing, where its grounds are.
   - The count of the product-check report's D. Not reached, with the report path, and its E. Questions for the user.

When 1 is empty, ask nothing; 2 goes into this run's report. Otherwise wait for the answer.

**Recording the answer**: the user's words, verbatim, with the build (commit) — for product-check findings in `{spec_path}/probe/user-run-<n>.md` (the build on its first line; one heading per finding the answer decides: `## F<k>` for this run's, `## R<m>-F<k>` for an earlier run's; a reply that decides none of them — "go ahead" — is saved above the headings and gets none), for a `user` scenario in `{spec_path}/probe/user-S<N>.md`. Set each routing line the answer closes — this run's in `routing-<n>.md`, an earlier run's in its `routing-<m>.md` — as `F<k> — <closing> — probe/user-run-<n>.md`; a finding the answer leaves to be fixed stays `open`. A `user` scenario the answer reports no run of gets no record and stays `not run`: the spec completes with it only on the user's yes to completing without it, listed in the completion report; otherwise it is **Critical**: "User check not run". Answers to 2b items are recorded as in 4a and 4f; their routing lines point there.

After the answer, every B still resolved as a code fix, and every C the user chose to implement, is **Critical**: "Implementation diverged from criterion" — add a fix task for it to tasks.md; its routing line is `changed — fix task <N> in tasks.md`. A C the user chose to withdraw is handled like a B override: fix the criterion to match the code's behavior in Step 4a and record it the same way (Requirements changes and a `Reconciled:` line). A product-check finding left to be fixed is **Critical**: "Product check finding open" — add its fix task, or edit the document and have it re-approved (`concept-alignment.md §Findings`); a later run re-checks it.

**Completion record**: run `bash docs/settings/scripts/check_completion.sh {spec_path}`. A non-zero exit is **Critical**: "Completion record incomplete", with its output. A finding the user has closed does not block completion.

**GO Criteria**: Zero Critical issues, and `check_completion.sh` exits 0.

**If NO-GO**:

- **Stop execution here** — do not proceed to Step 4. The spec stays in `todo/`; this run's only writes are under `reviews/`, the user's answers under `probe/`, and what a finding's route calls for in Step 3.

**If GO**:

- Present verification summary showing all checks passed
- Proceed to Step 4

### Step 4: Completion

#### 4a. Reconcile Requirements

Apply, in `{spec_path}/requirements.md`: every A item, and every criterion the Step 3 answer resolved as "fix the criterion" (B overridden, C withdrawn, E, D). For a B override or a C withdrawal, record it in Requirements changes and as a `Reconciled: <ID> ← spec-done confirmation` line (4f). For D, fix the criterion only after the canon answer, following it.

- Never renumber a criterion.
- Carry each change to the documents that cite it (`document-hygiene.md §After a Change`).
- Do not add a revision-history section to any document — git holds the history (`docs/settings/rules/document-hygiene.md`, one fact, one seat).
- Put `## Requirements changes` at the top of the reply: per criterion ID, the full previous → new text, then one line with the grounds (file:line) and the class. When there are canon changes, the `## Canon changes` section follows it.

#### 4b. Update Metadata

- Set `spec.json` `phase: "done"`

#### 4c. Move Spec to Done

- Move `docs/tasks/todo/<feature-name>/` to `docs/tasks/done/<feature-name>/`

#### 4d. Inception Sync (when the spec belongs to a plan)

If `spec.json` carries a `plan` block and `docs/inception/<parent>/units.md` keeps per-unit detail blocks, delete the completed unit's block — the Summary row and the done spec are the record. The edit is staged with the feature commit (4f); it is part of completing the unit.

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
- Do not push; pushing is the user's.

### Step 5: Steering Sync Check (non-blocking)

Runs only on GO, after the feature is committed (Step 4), and never blocks completion. Apply `docs/settings/rules/steering-principles.md §Admission` and `§Updating` to what this feature changed, against the steering loaded in Step 1; promotion candidates for `behaviors.md` come from the spec's `behaviors.md` §Promotion Candidates.

- **Nothing to change**: report "Steering current — no update needed" and finish without touching steering.
- **Changes**: propose, confirm, and commit per `§Updating` as `docs(steering): sync after <feature-name>`, in the commit style detected in Step 4e. Declined: leave steering untouched; it can be synced anytime with `/sdd-steering`.

For a review beyond what this feature touched, point the user to `/sdd-steering`.

### Step 6: Canon Sync (non-blocking, when a canon layer exists)

If `docs/steering/product.md §Canon References` declares a canon root, follow `docs/settings/rules/canon-layer.md §Change Control` for this feature — like Step 5, only on GO, after Step 4, never blocking. What this step puts in the canon:

1. **`Used by`**: for every registry ID this feature adopted (rows carrying `spec: <this-feature>` plus IDs its code references), append `code: <path Symbol>` in `<canon-root>/registry.md`. The `spec:` entry stays — the spec now lives in `done/`, so the script classifies it as implemented.
2. **Orphans**: grep the enums / const catalogs this feature touched; an identifier with no registry row is reported. Norm → propose the row in the Canon changes section; implementation detail → ignore; unsure → an Open Question in the canon README. Never silently adopt or delete a norm.
3. Run `bash docs/settings/scripts/check_canon.sh check` and report its findings.
4. When this step changed the canon, present the Canon changes section and ask once — commit? On yes, commit as `docs(canon): sync after <feature-name>`; on no, revert (`canon-layer.md §Change Control` 5) and report what was not landed. Nothing changed → report "Canon current".

</instructions>

## Output Description

Provide output in the language specified in spec.json:

### If NO-GO

1. **Verification Summary**: Table of all checks with pass/fail status
2. **Issues**: by severity (Critical / Warning / Info), each with the problem, the file(s) or location affected, and the corrective action (including the number of B items left as code fixes and the fix task added to tasks.md for each)
3. **Next Steps**: Specific commands to fix issues and re-run

**Format**: Markdown with severity indicators, under 500 words (the Step 3 message is not counted)

### If GO

1. **Requirements changes** (when any criterion changed): at the top — per criterion ID, previous → new, grounds (file:line), class; `## Canon changes` follows when present
2. **Verification Summary**: Table of all checks — all passed, including one line `Criteria reconciled: n (confirmed m · closed by a run record e)`, the product-check report path, item 2 of the Step 3 message, every `user` scenario left `not run`, and for `verify` the tasks a `fails` removed (`spec-kinds.md` §6)
3. **Completion Actions**: Confirm spec moved and commit created
4. **Commit Details**: Show commit hash and message
5. **Steering Sync**: One of — "Steering current — no update needed", "Steering updated (separate commit `<hash>`)", or "Steering update declined"
6. **Canon Sync** (when a canon layer exists): "Canon current", or the Canon changes landed (commit hash) or declined and reverted, orphans routed, and `check_canon.sh` findings

**Format**: Concise Markdown, under 300 words (the Step 3 message is not counted)

## Safety & Fallback

### Error Scenarios

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
