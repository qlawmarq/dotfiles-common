# Behavior Formulation Guidelines

## Overview

Behavior formulation turns approved requirements into **concrete example scenarios** (BDD Formulation) that show the feature serving the product's purpose. It complements EARS:

- **EARS acceptance criteria** (requirements.md) = the *rules* — abstract, complete, testable statements
- **Scenarios** (behaviors.md) = the *examples* — concrete situations with named actors and real values that make the rules vivid and falsifiable
- **Behavior invariants** (`docs/steering/behaviors.md`) = the durable, cross-spec ledger distilled from completed specs

A spec can be internally consistent (requirements ↔ design ↔ code) and still drift from what the product *is*. Scenarios prevent this by forcing every behavior to name the product purpose it serves.

## Scenario Format

Use Gherkin structure. Keep the keywords (`Given`, `When`, `Then`, `And`, `But`) in English; write the variable content in the target language from spec.json (same policy as EARS trigger keywords).

```
### Scenario N: <one-line behavior title>
Given <concrete initial state — named actors, real values>
When <the triggering event>
Then <the observable outcome>
Grounds: <one citation — the ID and one phrase>
Verification: auto-test | probe | manual — <pointer or planned name>
```

- **One behavior per scenario.** Split compound behaviors.
- **Concrete over abstract**: "Given the order holds 3 items and the stock of item B is 0", not "Given an order with an out-of-stock item". Concrete values expose edge cases that abstract rules hide.
- **At most one scenario per acceptance criterion**, and only where the example adds what the criterion's text does not: a value at a boundary the criterion leaves open, an interaction between criteria, or a reading of the criterion that is easy to get wrong. A criterion that needs no example gets none; a scenario that only restates a criterion with names and values is not written. Exhaustive combinatorics belong in tests.

## Grounding Discipline (the `Grounds:` line)

Every scenario MUST cite the product purpose it serves — this is **forward traceability**:

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

## Verification Mapping (adaptive)

Every scenario declares how it will be verified. Choose the strongest feasible tier:

1. **auto-test** — required when the behavior is deterministic, testable logic. Names the test (planned or existing). Connects to the TDD RED step in `/sdd-spec-impl`.
2. **probe** — for simulation, emergent, or long-horizon behavior: a scripted run whose observed output is recorded in the spec's `probe/`.
3. **manual** — last resort. Must state the exact procedure and expected observation so the result can be recorded as evidence at validation time.

No tier is optional: a scenario without a Verification line is unfinished. Tools are not mandated — no Cucumber/Gherkin runner is required; the scenario text is the specification, the project's own test/probe infrastructure is the automation.

## Promotion to `docs/steering/behaviors.md`

At feature completion, `/sdd-spec-done` proposes the spec's Promotion Candidates under `steering-principles.md §File focus` (criteria and line format) and `§Updating`.
