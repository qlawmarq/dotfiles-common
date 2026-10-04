# Design Document Template

---
**Purpose**: Provide the implementing agent — which also reads research.md, steering and the code — with every decision and contract stated once, so that a change has one place to land.

**Approach**:
- Include essential sections that directly inform implementation decisions
- Omit optional sections unless critical to preventing implementation errors
- Match detail level to feature complexity
- Use diagrams and tables over lengthy prose

**Warning**: Approaching 1000 lines indicates excessive feature complexity that may require design simplification.
---

> Sections may be reordered (e.g., moving Data Models nearer Architecture) when it improves clarity; keep the section headings intact. Within each section, keep the flow **Summary → Scope → Decisions → Impacts/Risks** so reviewers can scan consistently.

## Overview 
2-3 paragraphs max
**Users**: [Target user groups] will utilize this for [specific workflows].
**Impact** (if applicable): Changes the current [system state] by [specific modifications] (effects on the current system only — never a summary of a contract).


### Goals
- Primary objective 1
- Primary objective 2  
- Success criteria

### Non-Goals
- Explicitly excluded functionality
- Future considerations outside current scope
- Integration points deferred

### Assumptions
Omit the section when there are none.

- `<claim>` (`C<n>`) — impact: `<what fails if it is wrong>` / signpost: `<the observable sign that it has broken>`

## Design Decisions

One entry per decision that shaped this design, including decisions settled during implementation. This is the decision's only seat: research.md keeps the measurements and the option comparison, never the choice.

### D1: [title]
- Decision: [what was chosen] — based on `C<n>`
- Rejected: [option] — [one-phrase reason] (one line per option; the comparison itself stays in research.md §Architecture Pattern Evaluation)
- Consequences: [what this costs or forecloses, the negative included]

## Architecture

### Existing Architecture Analysis (if applicable)
When modifying existing systems:
- Current architecture patterns and constraints
- Existing domain boundaries to be respected
- Integration points that must be maintained
- Technical debt addressed or worked around

### Architecture Pattern & Boundary Map
**Recommended**: Include Mermaid diagram showing the chosen architecture pattern and system boundaries (required for complex features, optional for simple additions)

**Architecture Integration**:
- Selected pattern: [name only]
- Domain/feature boundaries: [how responsibilities are separated to avoid conflicts]
- Existing patterns preserved: [list key patterns]
- New components rationale: [why each is needed]
- Steering compliance: [principles maintained]

### Technology Stack

Only what differs from `docs/steering/tech.md`: a new dependency, a version change, or a placement rule for this feature. Omit the section when nothing differs.

| Layer | Choice / Version | Role in Feature | Notes |
|-------|------------------|-----------------|-------|
| | | | |

## System Flows

Provide only the diagrams needed to explain non-trivial flows. Use pure Mermaid syntax. Common patterns:
- Sequence (multi-party interactions)
- Process / state (branching logic or lifecycle)
- Data / event flow (pipelines, async messaging)

Skip this section entirely for simple CRUD changes.
> Diagrams carry participants and order. A branching rule belongs to the component that owns it — write it once in that block and refer to it from the diagram's caption as `per \`Component.method\``.

## Components and Interfaces

Group components by domain or layer; the headings are the index. Only components introducing new boundaries (logic hooks, external integrations, persistence) need a full block; presentation components need the Field table plus a short Implementation Note.

When multiple UI components share the same contract, reference a base interface definition instead of duplicating code blocks.

### [Domain / Layer]

#### [Component Name]

| Field | Detail |
|-------|--------|
| Intent | 1-line description of the responsibility |
| Requirements | 2.1, 2.3 |

**Responsibilities & Constraints**
- Primary responsibility
- Domain boundary and transaction scope
- Data ownership / invariants

**Dependencies**
- Inbound: Component/service name — purpose (Criticality)
- Outbound: Component/service name — purpose (Criticality)
- External: Service/library — purpose (Criticality)

Criticality: `P0` blocking, `P1` high-risk, `P2` informational.

Summarize external dependency findings here; deeper investigation (API signatures, rate limits, migration notes) lives in `research.md`.

**Contracts**: Service [ ] / API [ ] / Event [ ] / Batch [ ] / State [ ]  ← check only the ones that apply; the subsections of unchecked types are deleted.

##### Service Interface
```
[ComponentName].[method]([input]: [InputType]) → [OutputType] | [ErrorType]
```
(state each once — in the docstring when the language has one, otherwise here)
- Preconditions:
- Postconditions:
- Invariants:

##### API Contract
| Operation | Request | Response | Errors |
|-----------|---------|----------|--------|
| [name] | [shape] | [shape] | [error cases] |

##### Event Contract
- Published events:  
- Subscribed events:  
- Ordering / delivery guarantees:

##### Batch / Job Contract
- Trigger:  
- Input / validation:  
- Output / destination:  
- Idempotency & recovery:

##### State Management
- State model:  
- Persistence & consistency:  
- Concurrency strategy:

**Implementation Notes**
- Integration: 
- Validation: 
- Risks:

### Requirements without a component

Acceptance criteria no component block carries, and why. IDs only — never the criterion's text.

| Requirement | Realized by | Why |
|-------------|-------------|-----|
| | existing code / cross-cutting rule / verification only | |

## Data Models

Only structure that no single component owns: shared or persisted schemas, event payload fields. A field owned by a component lives in that component's State Management block, and a request/response schema in its API Contract; neither is repeated here.

### Domain Model
Invariants that span aggregates, one bullet each. A Mermaid class diagram only when 3 or more entities relate, with names, edges and cardinality only — no attributes.

### Shared Data
Structure no single component owns: input or configuration schemas, records with more than one writer. One table, then the rules that cross components — how references are made (by id, by name), which store is the source of truth, when a version number changes.

| Item | Type | Owner / writer | Constraint |
|------|------|----------------|------------|
| | | | |

### Storage
Only when this feature decides how data is stored. Per store, one table of structures (tables, collections, streams, key spaces) with their keys and indexes, then the store-specific decisions as bullets: partition or shard key, embedding vs referencing, TTL or compaction, snapshot and projection policy, migration steps.

| Store | Structure | Keys | Indexes | Notes |
|-------|-----------|------|---------|-------|
| | | | | |

### Event Schemas
- Published event structures
- Schema versioning strategy
- Backward/forward compatibility rules
- Cross-service consistency (saga, synchronization, eventual consistency) — only when the event crosses a service boundary

Skip subsections that are not relevant to this feature.

## Error Handling

Record only feature-specific decisions or deviations; baseline standards live in steering.

### Error Strategy
Concrete error handling patterns and recovery mechanisms for each error type.

### Error Categories and Responses
**User Errors**: Invalid input → field-level validation; Unauthorized → auth guidance; Not found → navigation help
**System Errors**: Infrastructure failures → graceful degradation; Timeouts → circuit breakers; Exhaustion → rate limiting  
**Business Logic Errors**: Rule violations → condition explanations; State conflicts → transition guidance

**Process Flow Visualization** (when complex business logic exists):
Include Mermaid flowchart only for complex error scenarios with business workflows.

### Monitoring
Error tracking, logging, and health monitoring implementation.

## Verification Plan

Test levels for this feature (unit, integration, end-to-end, performance — only the ones that apply), the regression policy (which existing suites must stay green, which are expected to change and why), and run configurations for probes, guard additions and budgets for long-running verification. When behaviors.md exists, list only what its scenarios do not cover. No test names — the seat of a test name is the scenario's `Verification:` line in behaviors.md, or the test file itself when there is no behaviors.md.

## Optional Sections (include when relevant)

### Security Considerations
_Use this section for features handling auth, sensitive data, external integrations, or user permissions. Capture only decisions unique to this feature; defer baseline controls to steering docs._
- Threat modeling, security controls, compliance requirements
- Authentication and authorization patterns
- Data protection and privacy considerations

### Performance & Scalability
_Use this section when performance targets, high load, or scaling concerns exist. Record only feature-specific targets or trade-offs and rely on steering documents for general practices._
- Target metrics and measurement strategies
- Scaling approaches (horizontal/vertical)
- Caching strategies and optimization techniques

### Migration Strategy
Include a Mermaid flowchart showing migration phases when schema/data movement is required.
- Phase breakdown, rollback triggers, validation checkpoints

## Supporting References (Optional)
- Create this section only when keeping the information in the main body would hurt readability (e.g., very long type definitions, vendor option matrices, exhaustive schema tables).
- Link to the supporting references from the main text instead of inlining large snippets.
- Background research notes and comparisons live in `research.md`.
