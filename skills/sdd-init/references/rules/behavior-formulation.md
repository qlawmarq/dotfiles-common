# Behavior Formulation Guidelines

## Overview

Behavior formulation turns approved requirements into **concrete example scenarios** (BDD Formulation) that show the feature serving the product's purpose. It complements EARS:

- **EARS acceptance criteria** (requirements.md) = the *rules* — abstract, complete, testable statements
- **Scenarios** (behaviors.md) = the *examples* — concrete situations with named actors and real values that make the rules vivid and falsifiable
- **Behavior invariants** (`docs/steering/behaviors.md`) = the durable, cross-spec ledger distilled from completed specs

A spec can be internally consistent (requirements ↔ design ↔ code) and still drift from what the product *is*. Scenarios prevent this by forcing every behavior to name the product purpose it serves.

## Scenario Format

Use Gherkin structure. Keep the keywords (`Given`, `When`, `Then`, `And`, `But`) in English; write the variable content in the target language from spec.json (same policy as EARS trigger keywords); the form is `docs/settings/templates/specs/behaviors.md` §Scenarios.

- **One behavior per scenario.** Split compound behaviors.
- **Concrete over abstract**: "Given the order holds 3 items and the stock of item B is 0", not "Given an order with an out-of-stock item". Concrete values expose edge cases that abstract rules hide.
- **At most one scenario per acceptance criterion**, and only where the example adds what the criterion's text does not: a value at a boundary the criterion leaves open, an interaction between criteria, or a reading of the criterion that is easy to get wrong. A criterion that needs no example gets none; a scenario that only restates a criterion with names and values is not written. Exhaustive combinatorics belong in tests.

## Grounding Discipline (the `Grounds:` line)

Every scenario cites the product purpose it serves — this is **forward traceability**:

- `product.md §<section>` — a purpose, theme, or capability stated in steering
- A canon decision, when `product.md` declares Canon References (see `concept-alignment.md` for lookup rules)
- `registry.md #<ID>` — a canon registry entry, the authoritative seat for enumerable norms (`canon-layer.md §Registry`)
- `steering/behaviors.md #<invariant>` — an established cross-spec invariant

Rules:

- A scenario that serves **no citable purpose** is scope without a reason — raise it as a question, don't keep it.
- A scenario (or the requirement behind it) that **contradicts** the cited canon, the product's Value Proposition, or an established invariant is a **Critical finding**: report it before design proceeds. Do not silently reword the scenario to fit.
- Do not stretch citations. "The product is about X, therefore anything adjacent to X" is not grounding.
- One citation per scenario — the ID and one phrase, never the source's full text. A second citation only when the scenario sits at the junction of two decisions.

The Introduction is one sentence of mapping and one line of actors; values and defaults are not listed there.

## Verification Mapping

Every scenario declares how it will be verified, by the first tier that fits:

| Tier | For | Pointer | Produced by |
| --- | --- | --- | --- |
| `auto-test` | Deterministic, testable logic | The test's name and file | Implementation (the TDD RED step) |
| `probe` | What only a run shows — emergent or long-horizon behavior, anything read on screen or in output | A results file under this spec's `probe/`, from a scripted or recorded run | Implementation, as its own task |
| `user` | What only a person using the product can judge | `probe/user-S<N>.md`, the record the user check will leave (`concept-alignment.md §User Check`) | The user — never a task an agent completes |

What an agent can observe is a `probe`, never `user`. A probe in a constructed configuration shows the mechanism; what the default configuration does is the product check's (`concept-alignment.md §Product Check`).

A pointer writes test names and paths in backticks. Until its evidence exists, an `auto-test` or `probe` pointer reads `planned: <name>`. At completion no pointer is `planned:`, a `probe` pointer names a file that exists under this spec, and an `auto-test` pointer names a test that exists in the repository — never another spec's future run. A scenario without a Verification line is unfinished. Tools are not mandated — no Cucumber/Gherkin runner is required; the scenario text is the specification, the project's own test/probe infrastructure is the automation.

## Promotion to `docs/steering/behaviors.md`

At feature completion, `/sdd-spec-done` proposes the spec's Promotion Candidates under `steering-principles.md §File focus` (criteria and line format) and `§Updating`.
