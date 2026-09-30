# Spec Kinds

Every spec carries a `kind` in `spec.json`. The kind selects which templates the phases read and which phases run. A spec without `kind` is a `feature`.

## 1. The five kinds

Ask the questions in order; the first "yes" decides.

| Kind | Deliverable | Deciding question |
|------|-------------|-------------------|
| `verify` | A verdict on a question; no product code kept | Is the deliverable a verdict on a question, with no product code kept? |
| `fix` | Corrected behavior plus a regression test | Does observed behavior contradict behavior that already existed? |
| `refactor` | New structure, same behavior | Does the structure change while every behavior stays? |
| `chore` | A new state of the environment, dependencies, tooling, documents or data | Is the deliverable a state of the environment, dependencies, tooling, documents or data rather than a product behavior? |
| `feature` | New product behavior | Does the product do something new for a person using it? |

In an inception plan, a verification-gate unit is `verify`. `refactor` moves code; `chore` changes what surrounds it (dependencies, tooling, CI, documents, data).

A batch of unrelated defects is one `fix` spec with several ledger rows. Work that mixes kinds — a fix that also restructures — is split into one spec per kind.

## 2. No spec needed

When the change is describable in one sentence, its diff is obvious, and nothing needs a new guard or a run to be believed (a typo, a renamed variable, a one-line change an existing test already covers), recommend implementing it directly and do not create a spec. Create one only if the user says so.

## 3. Choosing and changing the kind

- State the chosen kind and the question that decided it in one line, and let the user override it.
- When in doubt, take `feature`.
- The ratchet is one-way: until design is approved, any other kind may be upgraded to `feature`: rewrite `kind`, then re-run `/sdd-spec-requirements` with the feature templates. Complexity found after design approval is scoped out and gets its own spec. Nothing downgrades.

## 4. Attributes per kind

Templates live in `docs/settings/templates/specs/`; a phase reads `<doc>-<kind>.md` when that file exists, else `<doc>.md`. Skills read these columns; a kind's name appears in a skill only where that kind has a procedure of its own.

| Kind | Produces behaviors | Completion artifact | Completion checks | Commit type |
|------|--------------------|---------------------|-------------------|-------------|
| `feature` | yes | code | `criteria-audit`, `product-check` | `feat` |
| `fix` | no | code + regression test | `criteria-audit`, `product-check` | `fix` |
| `refactor` | no | code, behavior unchanged | `criteria-audit`, `product-check` | `refactor` |
| `verify` | no | `verdict.md` + `probe/` records | `verdict` | `docs` |
| `chore` | no | changed environment, tooling, documents or data | `criteria-audit` | `chore` |

Phase order: init → requirements → (behavior, when the kind produces behaviors) → research → design → tasks → impl → done. A kind that does not produce behaviors has no `approvals.behaviors` in spec.json and no `behaviors.md`.

## 5. What each kind elicits and measures

Requirements elicit the first column; research settles the second by measurement (`evidence-discipline.md` §1), never by reading.

| Kind | Requirements elicit | Research measures |
|------|---------------------|-------------------|
| `feature` | what the product must do, per `requirements-elicitation.md` | per the discovery depth |
| `fix` | current behavior, expected behavior, unchanged behavior, where the reproduction lives | the reproduction: each ledger row re-run, result in `probe/` |
| `refactor` | the structural goal, every behavior to preserve with the test that guards it | that a test or probe guards every behavior to preserve; an unguarded behavior gets a guard before the structure moves |
| `verify` | the questions, the verdict rule for each, what each run records, the budget | the cost of one run, and that a provisional procedure executes end to end (design fixes the protocol) |
| `chore` | the target state and what must stay unchanged | current versions, compatibility with the target, the breaking changes between them; when the current state is absent, that the target installs and runs here |

## 6. Verdict vocabulary (`verify`)

- `holds` — the runs meet the rule for holds, and every reproduction and run the rule depends on was actually exercised.
- `partial` — the runs meet the rule in part, or a supporting reproduction or run was not exercised.
- `fails` — the runs meet the rule for fails.
- `unmeasured` — the runs were attempted but the recorded items needed to apply the rules could not be observed, or the runs were not made.

Do not over-claim: a reproduction or run not actually exercised cannot support `holds`; lower the verdict to `partial` and name what was skipped in verdict.md.

**A question the user answers.** A question may be one only the user can answer (`concept-alignment.md §User Check`). Its runs are the user's sessions with the product; a session's record is what the verdict rules read, like any other record. A session that could settle a Must question is the spec's first run: its task comes first in tasks.md and is complete only when the record exists, and nothing is prepared for later runs before that. Before the session, the `fix` specs filed for defects that touch what the question asks are closed.

When a Must question's verdict is `fails`, the runs not yet made are not made: their tasks are removed from tasks.md (the verdict decides this; no re-approval) and listed in the completion report, their questions are `unmeasured`, and the spec completes with its verdict. A verdict other than `holds` is a finding (`concept-alignment.md §Findings`).
