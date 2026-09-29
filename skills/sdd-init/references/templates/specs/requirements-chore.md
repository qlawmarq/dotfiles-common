# Requirements Document

## Introduction
{{INTRODUCTION}}
<!-- One or two sentences: what in the environment, dependencies, tooling, documents or data changes, and why now. -->

## Target State

<!-- What changes and how: versions, configuration, structure, documents, data. One line per change. -->

- {{SUBJECT}}: {{CURRENT_STATE}} → {{TARGET_STATE}} — {{REASON}}

## Requirements

<!--
Each requirement is one reached state and what must survive the change. The reached state uses `shall`;
what stays uses `shall continue to` and names the test, probe or check that guards it.
-->

### 1: {{TARGET_STATE_AREA}}
**Priority:** Must | Should | Could

#### Acceptance Criteria
1. The {{SUBJECT}} shall {{REACHED_STATE}}
2. When {{CONDITION}}, the {{COMPONENT}} shall continue to {{EXISTING_BEHAVIOR}} — guard: {{TEST_OR_PROBE}}

<!-- Additional areas follow the same pattern -->

## Out of Scope

Changes deliberately left out — adjacent upgrades, cleanups, or product behavior changes.

- {{OUT_OF_SCOPE_ITEM}} — reason / where it was excluded

## Assumptions & Open Questions

Omit when nothing is open.

- **Assumption:** {{ASSUMPTION}} — impact if wrong / needs confirmation
- **Open question:** {{QUESTION}} — who/what is needed to resolve it
