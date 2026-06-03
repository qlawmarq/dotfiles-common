# Requirements Document

## Introduction
{{INTRODUCTION}}

<!--
Every requirement below must trace back to the user's input or an explicit confirmation.
Each requirement carries a **Source** line recording where it came from:
  - User-stated      — the user asked for this directly (quote/paraphrase the input)
  - User-confirmed   — you proposed it and the user explicitly agreed
  - Derived from N    — a necessary consequence of Requirement N (state which)
  - Steering: <file> — mandated by project steering / a standard / a regulation
A requirement that fits none of these has no legitimate source — it is gold-plating. Remove it or
raise it as a proposal in "Assumptions & Open Questions". Tag each requirement with a MoSCoW priority
(Must / Should / Could) traceable to user intent.
-->

## Requirements

### Requirement 1: {{REQUIREMENT_AREA_1}}
<!-- Requirement headings MUST include a leading numeric ID only (for example: "Requirement 1: ...", "1. Overview", "2 Feature: ..."). Alphabetic IDs like "Requirement A" are not allowed. -->
**Objective:** As a {{ROLE}}, I want {{CAPABILITY}}, so that {{BENEFIT}}
**Priority:** Must | Should | Could
**Source:** User-stated — "{{QUOTE_OR_PARAPHRASE_OF_USER_INPUT}}"

#### Acceptance Criteria
1. When [event], the [system] shall [response/action]
2. If [trigger], then the [system] shall [response/action]
3. While [precondition], the [system] shall [response/action]
4. Where [feature is included], the [system] shall [response/action]
5. The [system] shall [response/action]

### Requirement 2: {{REQUIREMENT_AREA_2}}
**Objective:** As a {{ROLE}}, I want {{CAPABILITY}}, so that {{BENEFIT}}
**Priority:** Must | Should | Could
**Source:** User-confirmed | Derived from Requirement 1 | Steering: product.md

#### Acceptance Criteria
1. When [event], the [system] shall [response/action]
2. When [event] and [condition], the [system] shall [response/action]

<!-- Additional requirements follow the same pattern -->

## Out of Scope

Capabilities deliberately **not** included in this specification — especially ones a reasonable reader
might assume are present. Writing them down turns silent assumptions into auditable decisions.

- {{OUT_OF_SCOPE_ITEM}} — reason / where it was excluded (e.g., user said "just X for now")

## Assumptions & Open Questions

Unresolved gaps and the assumptions made to proceed. Items here are **not yet confirmed requirements**.
Scope-/behavior-affecting questions should be resolved with the user before this document is approved;
trivial, reversible assumptions may stay logged here for confirmation.

- **Assumption:** {{ASSUMPTION}} — impact if wrong / needs confirmation
- **Open question:** {{QUESTION}} — who/what is needed to resolve it
- **Proposal (not included):** {{PROPOSED_FEATURE}} — left out pending user confirmation
