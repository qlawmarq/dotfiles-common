# Behavior Scenarios

## Introduction

{{INTRODUCTION}}
<!-- One sentence mapping this feature to the product purpose it serves, and one line naming the actors the examples use.
No values, thresholds or defaults here — those live in requirements.md and design.md. -->

<!--
Concrete example scenarios (BDD Formulation) for this spec. EARS criteria in requirements.md are
the rules; these scenarios are the examples that make them vivid — named actors, real values.
Every scenario MUST carry:
  Grounds:      — forward traceability: one citation — the ID and one phrase (product.md section,
                  canon decision, or steering/behaviors.md invariant). See rules/behavior-formulation.md.
  Verification: — <tier> — <pointer>, the test name and paths in backticks; per rules/behavior-formulation.md
                  §Verification Mapping.
A scenario serving no citable purpose is scope without a reason. A scenario contradicting the
canon is a Critical finding — report it, do not reword it to fit.
-->

## Scenarios

### Scenario 1: {{BEHAVIOR_TITLE}}

- **Given** {{CONCRETE_INITIAL_STATE}}
- **When** {{TRIGGERING_EVENT}}
- **Then** {{OBSERVABLE_OUTCOME}}
- **Grounds:** product.md §{{SECTION}} — {{ONE_PHRASE}}
- **Verification:** auto-test — planned: `{{TEST_NAME}}`
- **Requirements:** {{NUMERIC_REQUIREMENT_IDS}}

<!-- Additional scenarios follow the same pattern -->

## Open Questions

<!-- Gaps surfaced while formulating examples: unclear edge cases, thresholds requirements did not
settle, conflicts needing user or change-control resolution. Resolve scope-affecting ones before
design. -->

- {{QUESTION}}

## Promotion Candidates

<!-- Invariants proposed for docs/steering/behaviors.md at /sdd-spec-done; criteria and line format:
docs/settings/rules/steering-principles.md §File focus. -->

- {{INVARIANT_STATEMENT}} — Grounds: {{CITATION}} / Verify: {{TEST_OR_PROBE}}
