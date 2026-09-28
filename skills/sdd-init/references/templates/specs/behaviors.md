# Behavior Scenarios

## Introduction

{{INTRODUCTION}}

<!--
Concrete example scenarios (BDD Formulation) for this spec. EARS criteria in requirements.md are
the rules; these scenarios are the examples that make them vivid — named actors, real values.
Every scenario MUST carry:
  Grounds:      — forward traceability: the product purpose it serves (product.md section, canon
                  decision, or steering/behaviors.md invariant). See rules/behavior-formulation.md.
  Verification: — auto-test | probe | manual, with a pointer or planned name.
A scenario serving no citable purpose is scope without a reason. A scenario contradicting the
canon is a Critical finding — report it, do not reword it to fit.
-->

## Scenarios

### Scenario 1: {{BEHAVIOR_TITLE}}

- **Given** {{CONCRETE_INITIAL_STATE}}
- **When** {{TRIGGERING_EVENT}}
- **Then** {{OBSERVABLE_OUTCOME}}
- **Grounds:** product.md §{{SECTION}} — "{{QUOTED_PURPOSE}}"
- **Verification:** auto-test — {{TEST_NAME_OR_PLAN}}
- **Requirements:** {{NUMERIC_REQUIREMENT_IDS}}

<!-- Additional scenarios follow the same pattern -->

## Open Questions

<!-- Gaps surfaced while formulating examples: unclear edge cases, thresholds requirements did not
settle, conflicts needing user or change-control resolution. Resolve scope-affecting ones before
design. -->

- {{QUESTION}}

## Promotion Candidates

<!-- Product-level, cross-spec invariants this feature establishes — one line each. Proposed for
docs/steering/behaviors.md, confirmed by the user at /sdd-spec-done. "None" is the common outcome. -->

- {{INVARIANT_STATEMENT}} — Grounds: {{CITATION}} / Verify: {{TEST_OR_PROBE}}
