# Concept Alignment

## Objective

Keep every layer in step with the product's purpose: the spec documents, the code, and the product as it actually runs. A spec can pass every internal check (requirements ↔ design ↔ code) and still build the wrong thing, and a product can satisfy every spec and still fail what it promises. This file is the one definition of the check, what a finding is, and where it goes; how a change is carried to the documents that cite it is `document-hygiene.md §After a Change`.

**The user** is the person these skills work for. A role an agent plays (a director, a product manager) is never the user: what it rules is never the user's decision. **The product's main uses** are what `product.md` says a person does with the product — under whatever heading it says so (in the template, Target Use Cases) — together with the decision records it points to. A `product.md` that nowhere says what a person does with the product is itself a finding against steering.

## Resolving Product Intent

1. **Baseline (always)**: `docs/steering/product.md` — the product's purpose, themes, and core capabilities.
2. **Decision records (when declared)**: if `product.md` contains a `## Decision Records` section, it names the decisions root (structure and loading: `decision-records.md`) and how to search it. For enumerable norms — catalogs, entity lists, guards — the decision records' `registry.md` is the authoritative seat; cite entries by ID. Look up cited decisions **JIT** — grep by the declared keywords for the topics the spec touches. Never bulk-load the decision records. **Committed text binds**: an uncommitted decision edit or a README Open Question is not a decision — reliance on it is itself a finding.
3. **Established invariants**: `docs/steering/behaviors.md` — cross-spec behavior invariants distilled from completed features. Already loaded with steering.

When `product.md` and the decision records disagree, the decision records win if `product.md` says so; otherwise flag the inconsistency itself as a finding.

## The Check

For each requirement / scenario / design decision under review — and for each fact a run shows — ask three questions:

1. **What does it serve?** Name the product purpose, theme, or capability it advances (a citable section or decision). "It was requested" is a *source*, not a *purpose* — both are required.
2. **Does it contradict?** Check against the product's Value Proposition and Core Capabilities, the Out of Scope lists (the spec's and the product's), and every applicable invariant in `steering/behaviors.md`.
3. **Would the behavior read as the product?** For behavior a person using the product sees: does the resulting behavior express the product's philosophy, or would it feel like a different product? (This is the question that pure traceability checks never ask.)

Scale effort to exposure: mechanical/internal changes need only a contradiction check; behavior-shaping changes need all three questions.

A measured fact is held to the same questions as a document: a probe result, a research measurement, or what a product run shows can contradict the product's purpose exactly as a requirement can. A clause that says an observation is recorded and not judged does not exempt it.

## Product Check

Before a spec is completed, when its kind's completion checks include it (`spec-kinds.md` §4), the product itself is run and looked at. A passing test, a constructed configuration, or a count read from a log does not by itself show what a person using the product meets, and the look is not put off to a later spec.

- **Who and record**: the implementer, as the spec's last task. The record is `{spec_path}/probe/product-check-<k>.md`, k being 1 + the largest existing k, in the form of `docs/settings/templates/specs/product-check.md`. A re-run adds a new record; an earlier record is never edited.
- **What is walked**: from the product's entry, in its default configuration, the spec's criteria and scenarios that the entry reaches — for `refactor`, the behaviors it must preserve. Of the product's main uses, only those this spec touched.
- **Entry that cannot be operated**: where the entry (a screen, a device) cannot be operated, the same default configuration is driven by the closest means the product offers, and the record says which.
- **What is asked**: what the walk meets is held to the three questions of §The Check.
- **Findings**: each is routed at once by the table of §Findings — a fix task, a report to the user, a `fix` spec — and its entry in the record carries a `Route:` line with a closure word of §Findings 4, or `open`, and where it went. One the user must decide is `Route: open — the user`, and goes into the `/sdd-spec-done` Step 3 message; `open` and `stands` are closed by the user's answer (`probe/user-run-<n>.md`, heading `## P<k>`). Where a Director holds the spec, the implementer reports the finding with its proposed route and the Director lands it (`/sdd-director` §Landing). P numbers continue across this spec's records.
- **Time**: the waiting on the running product, all runs together, stays inside the limit of §Waiting on a Run.
- **Invalidation**: when code of this spec changes after the latest record, the product-check task is reopened (`[ ]`) and run again after the fix, adding a new record. Wherever it sits in tasks.md, the product-check task runs after every other open task of the spec.
- **Independence**: the completion review re-walks, once, the paths of the latest record.

## Independent Runs

A run that must not inherit the session — the completion review, any audit a skill dispatches — goes to a fresh sub-agent through the delegation tool the host harness provides, on a model no smaller than the dispatching session's where the harness lets it choose. Where the harness has no sub-agents, the user is asked to run it in a separate session.

## Waiting on a Run

Nobody waits on a run — a probe, a measurement, the product check — for longer than ten minutes on their own. A longer wait needs the user's word first: a duration the user approved with the run (a budget, a task that states it), another limit the user set, or the answer to being told how long it would take and asked what would shorten it — the user looking at the product themselves, a configuration or saved state the user accepts as standing for the default, or a run left in the background while the other work goes on. The limit is given as the runner's own timeout argument — the test runner's, the browser driver's, `timeout`, or, where none exists, a shell wrapper that kills the run (`perl -e 'alarm shift; exec @ARGV' <seconds> <command>`) — never only as an instruction in prose.

## User Check

Some things only a person using the product can judge: whether it is fun, readable, the product they meant. A user check is that judgment as evidence: what the user did with the running product, on which build, and what they said, in their words, saved under the spec's `probe/`. The judgment is evidence as given — nobody reproduces it, turns a summary into it, or fills it in. A claim inside it about what the product does is checked like any other (§Findings 1).

Two things are user checks, both planned in an approved document:

- a scenario with tier `user` (`behavior-formulation.md`), asked once, at completion, with everything else that needs the user — as what to do and what should happen;
- a `verify` question the user answers (`spec-kinds.md` §6), whose run is the user's session.

An answer that differs from what should happen is a finding. A `user` scenario whose record does not exist is `not run`; `check_completion.sh outstanding` lists them. Completing a spec with one `not run` is the user's decision. A check made before a fix holds unless the fix touches what it judged. A record that arrives after completion is added to that spec's `probe/`.

## Findings

A finding is a disagreement between two layers that a check, a review, a measurement, or use of the product brings up — whoever reports it: a reviewer, a test, a probe, the implementer, the user. (A test written first and failing until its code exists is not one.) The layers, upstream first: product intent (decision records, steering) → the plan → requirements → the spec's other documents → code → the running product.

1. **Check it before it changes anything.** A claim about what the product does — the user's included — is run before any document changes (`evidence-discipline.md` §1), and sorted: is it about what the product does, or about how it is shown? Quoting what someone said is not a check.
2. **State it in use** when it concerns product intent: what happens to a person using the product — how long they wait, what they can do meanwhile — not only a count or a mechanism.
3. **Route it to the most upstream layer that is wrong**; the layers below follow by `document-hygiene.md §After a Change`. Work that depends on the finding waits until it is closed; the rest goes on.

| What is wrong | Where it goes | The user decides |
| --- | --- | --- |
| Decision records or steering | `decision-records.md §Change Control` / `steering-principles.md §Updating`, or the process the project's root AGENTS.md declares | yes |
| The plan — a boundary, the order, what a gate tests | The plan, re-cut (`plan-decomposition.md` §8) | yes |
| Requirements | `requirements.md`, after the user's yes | yes |
| The spec should not be built | Its `todo/` directory is deleted after the user's yes; git keeps it. Code it already landed stays or goes by the user's word | yes |
| The open spec's behaviors, research, design or tasks | That document; approved text is re-approved (`dialogue-grounding.md`, "Approved artifacts are not edited silently") — by the user, or, where a Director holds the spec, by the Director's ruling (`/sdd-director` §Landing) | no — approved text: its re-approval |
| Code, inside the open spec | A fix task in its tasks.md — or, when the code is right and the design is not, `design.md`, as in the row above. Never neither | no |
| Code, outside the open spec | Reported to the user at once with the evidence, and filed as its own `fix` spec in `docs/specs/todo/` unless the user has it fixed directly | no — reported |
| Cannot tell which, or a judgment that needs the product running to be seen | The user, with the evidence | yes |

4. **Close it, in writing**, in one of four ways: *changed* — what and where; *rejected* — it does not hold, with quoted evidence of the same kind as the finding's (a run answers a run); *stands* — left as it is, with the reason; *filed* — the wrong layer lies outside the open spec and the finding now sits where that layer keeps open items (a spec in `docs/specs/todo/`, the decision records' Open Questions). The completion review's findings are closed in `{spec_path}/reviews/routing-<n>.md`, one line per finding; the product-check record's, in its `Route:` lines (§Product Check); any other, in the seat the table names and the report of the turn that closed it. "A consequence of the boundary", "out of scope" and "left for a later gate" are not closures, and text approved before a fact was measured does not close the finding that fact raises.
5. **Who closes.** The user closes what the table gives to the user, and every *stands* except a Warning's. A completion-review finding (`{spec_path}/reviews/review-<n>.md`) — whatever row of the table it falls under — is closed only by the user, by a change to the code or to re-approved text that a later review re-checks and no longer finds, or as *rejected* by the lead (the session running `/sdd-spec-done`), with quoted evidence of the same kind as the finding's (a run answers a run); for one the user closes, the user is shown the reviewer's own words (its `Conflict:` line), not a summary, and the user's answer is saved in their words under `probe/` — evidence, not a note in a document's body. Nobody reclassifies a finding to change who closes it — the user's own choice excepted. A finding the user has closed no longer blocks completion. What was closed without the user is listed for the user, one line each, when the spec completes.
6. **A finding raised again with no new fact** — in this spec or another — is closed by pointing at its earlier closure, when that closure was the user's.
7. **When two checks disagree**, what a run shows outranks what a reading concludes.

A product that satisfies every spec and still fails what it promises is a finding against the plan, where there is one, or against the requirements or the decision records — to be revisited with the user, not recorded and passed on.

### Severity

- **Contradiction** with product purpose, Out of Scope, decision record, or an established invariant → **Critical (NO-GO)**; never reword a decision record to fit the artifact under review.
- **Unsupported**: no citable purpose can be named → **Critical (NO-GO)** unless the user explicitly confirms it belongs.
- **Weak grounding**: purpose citable but stretched or vague → **Warning** with a suggested tightening.

### Finding Format

```
🔴 Critical (Concept): <title>
Artifact: <requirement ID / scenario N / design section>
Grounds: <product.md section, decision ID, or behaviors.md invariant cited>
Conflict: <what the artifact does vs. what the cited grounds say>
In use: <what happens to a person using the product — when the finding concerns product intent>
Action: <the row of the table above>
```
