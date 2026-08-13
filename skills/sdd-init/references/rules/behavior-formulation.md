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
Grounds: <which product purpose this serves — see Grounding Discipline>
Verification: auto-test | probe | manual — <pointer or planned name>
```

- **One behavior per scenario.** Split compound behaviors.
- **Concrete over abstract**: "Given 信者ユメの空腹が0.1で共同備蓄が空", not "Given a hungry resident". Concrete values expose edge cases that abstract rules hide.
- Cover the *product-meaningful* cases, not every permutation: the happy path, the case that best expresses the product's philosophy, and any case where drift is plausible. Exhaustive combinatorics belong in tests, not here.

## Grounding Discipline (the `Grounds:` line)

Every scenario MUST cite the product purpose it serves — this is **forward traceability**, the counterpart of the requirement `Source:` line (which traces backward to user input):

- `product.md §<section>` — a purpose, theme, or capability stated in steering
- A canon decision, when `product.md` declares Canon References (see `concept-alignment.md` for lookup rules)
- `registry.md #<ID>` — a canon registry entry, the authoritative seat for enumerable norms (`normative-registry.md`); only `ratified` entries ground anything
- `steering/behaviors.md #<invariant>` — an established cross-spec invariant

Rules:

- A scenario that serves **no citable purpose** is scope without a reason — raise it as a question, don't keep it.
- A scenario (or the requirement behind it) that **contradicts** the cited canon, product 主題, or an established invariant is a **Critical finding**: report it before design proceeds. Do not silently reword the scenario to fit.
- Do not stretch citations. "The product is about X, therefore anything adjacent to X" is not grounding.

## Verification Mapping (adaptive)

Every scenario declares how it will be verified. Choose the strongest feasible tier:

1. **auto-test** — required when the behavior is deterministic, testable logic. Names the test (planned or existing). Connects to the TDD RED step in `/sdd-spec-impl`.
2. **probe** — for simulation, emergent, or long-horizon behavior: a scripted run whose observed output is recorded to a results file in the spec directory.
3. **manual** — last resort. Must state the exact procedure and expected observation so the result can be recorded as evidence at validation time.

No tier is optional: a scenario without a Verification line is unfinished. Tools are not mandated — no Cucumber/Gherkin runner is required; the scenario text is the specification, the project's own test/probe infrastructure is the automation.

## Promotion to `docs/steering/behaviors.md`

At feature completion (`/sdd-spec-done`), propose promoting only invariants that are:

- **Product-level**: they express the product's purpose or philosophy, not an implementation detail
- **Cross-spec**: future specs could plausibly violate them
- **Verified**: their evidence exists (test/probe/manual record)

Promote as **one line per invariant** — statement + Grounds + Verify pointer. Each candidate is presented individually with its grounds and confirmed on its own, never as a summarized batch. Scenario bodies are NEVER promoted: they persist in the spec archive, and their executable forms persist in the test suite. "No promotion" is the expected outcome for most features (same golden rule as steering sync).
