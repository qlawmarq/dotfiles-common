# Requirements Document

## Introduction
{{INTRODUCTION}}
<!-- One or two sentences: which part of the code is restructured and what the current structure costs. -->

## Structural Goal

<!-- What changes and how, in terms of structure: modules, boundaries, dependencies, names. -->

- {{CURRENT_STRUCTURE}} → {{TARGET_STRUCTURE}} — {{REASON}}

## Requirements

<!--
Each requirement is a group of behaviors the refactor must preserve. Criteria use `shall continue to` and name the
test or probe that guards them. Do not invent a requirement to fill the document: a behavior with no guard is
recorded under Assumptions & Open Questions until research adds one.
-->

### 1: {{PRESERVED_BEHAVIOR_AREA}}
**Priority:** Must | Should | Could

#### Acceptance Criteria
1. When {{CONDITION}}, the {{COMPONENT}} shall continue to {{EXISTING_BEHAVIOR}} — guard: {{TEST_OR_PROBE}}
2. The {{COMPONENT}} shall continue to {{EXISTING_BEHAVIOR}} — guard: {{TEST_OR_PROBE}}

<!-- Additional areas follow the same pattern -->

## Out of Scope

Behavior changes are out of scope by definition. List the adjacent restructuring deliberately left for later.

- {{OUT_OF_SCOPE_ITEM}} — reason / where it was excluded

## Assumptions & Open Questions

Omit when nothing is open.

- **Assumption:** {{ASSUMPTION}} — impact if wrong / needs confirmation
- **Open question:** {{QUESTION}} — who/what is needed to resolve it
