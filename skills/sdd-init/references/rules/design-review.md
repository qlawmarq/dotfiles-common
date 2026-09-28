# Design Review Process

## Objective

Conduct interactive quality review of technical design documents to ensure they are solid enough to proceed to implementation with acceptable risk.

## Review Philosophy

- **Quality assurance, not perfection seeking**
- **Critical focus**: Limit to 3 most important concerns
- **Interactive dialogue**: Engage with designer, not one-way evaluation
- **Balanced assessment**: Recognize strengths and weaknesses
- **Clear decision**: Definitive GO/NO-GO with rationale

## Scope & Non-Goals

- Scope: Evaluate the quality of the design document against project context and standards to decide GO/NO-GO.
- Non-Goals: Do not perform implementation-level design, deep technology research, or finalize technology choices. Defer such items to the design phase iteration.

## Core Review Criteria

### 0. Concept & Behavior Alignment (Critical)

A design can integrate perfectly with the architecture and still build the wrong product. Apply the lens in `concept-alignment.md`: does any design decision contradict `product.md`, the declared canon, or a `steering/behaviors.md` invariant? When the spec has `behaviors.md`, also verify each scenario is realizable by the design — an unrealizable scenario, or a design behavior contradicting a scenario's `Grounds:`, is Critical.

### 1. Existing Architecture Alignment (Critical)

- Integration with existing system boundaries and layers
- Consistency with established architectural patterns
- Proper dependency direction and coupling management
- Alignment with current module organization

### 2. Design Consistency & Standards

- Adherence to project naming conventions and code standards
- Consistent error handling and logging strategies
- Uniform configuration and dependency management
- Alignment with established data modeling patterns

### 3. Extensibility & Maintainability

- Design flexibility for future requirements
- Clear separation of concerns and single responsibility
- Testability and debugging considerations
- Appropriate complexity for requirements

### 4. Type Safety & Interface Design

- Proper type definitions and interface contracts
- Avoidance of unsafe patterns (e.g., `any` in TypeScript)
- Clear API boundaries and data structures
- Input validation and error handling coverage

### 5. Premise Soundness

A design is only as sound as what it assumes. Where `research.md` exists, check that no major decision rests on a claim typed `unverified` or carrying no reproducer without that being **declared** in the design's Assumptions section with its impact and signpost. An undeclared premise is the finding; a declared one is a managed risk and is acceptable.

### 6. Recomputation

Check what the design asserts against its own text and against the code, instead of taking the document's word for it:

| Kind | Target | Method |
| --- | --- | --- |
| A — internal contradiction | The same contract stated in two or more places (a table and a diagram, Data Models and a Service Interface) | Quote both and compare. A difference is a discrepancy |
| B — concrete expression | Formulas, thresholds, enum values, and function, class, or string names the design asserts about existing code | Grep or read the code and quote it. Report names that do not exist, values that differ, and names that collide |
| C — missed branch site | A design that adds a value to an existing enum or kind | Grep every site that branches on that kind (match / switch / assert / tables) and list the ones the design does not mention |

## Review Process

### Step 1: Analyze

Analyze design against all review criteria, focusing on critical issues impacting integration, maintainability, complexity, and requirements fulfillment.

### Step 2: Identify Critical Issues (≤3)

For each issue:

```
🔴 **Critical Issue [1-3]**: [Brief title]
**Concern**: [Specific problem]
**Impact**: [Why it matters]
**Suggestion**: [Concrete improvement]
**Traceability**: [Requirement ID/section from requirements.md]
**Evidence**: [Design doc section/heading]
```

### Step 3: Recognize Strengths

Acknowledge 1-2 strong aspects to maintain balanced feedback.

### Step 4: Decide GO/NO-GO

- **GO**: No concept/behavior conflict, no critical architectural misalignment, requirements addressed, clear implementation path, acceptable risks
- **NO-GO**: Concept or behavior-invariant contradiction, fundamental conflicts, critical gaps, high failure risk, disproportionate complexity

## Traceability & Evidence

- Link each critical issue to the relevant requirement(s) from `requirements.md` (ID or section).
- Cite evidence locations in the design document (section/heading, diagram, or artifact) to support the assessment.
- When applicable, reference constraints from steering context to justify the issue.

## Output Format

### Design Review Summary

2-3 sentences on overall quality and readiness.

### Critical Issues (≤3)

For each: Issue, Impact, Recommendation, Traceability (e.g., 1.1, 1.2), Evidence (design.md section).

### Recomputation discrepancies

Every discrepancy found under criterion 6, each with its kind (A / B / C) and both quotes (design and code, or the two design locations). Separate from Critical Issues (≤3), with no cap on the count. List the discrepancies only; whether the design or the code is wrong is settled in dialogue with the designer.

### Design Strengths

1-2 positive aspects.

### Final Assessment

Decision (GO/NO-GO), Rationale (1-2 sentences), Next Steps.

### Interactive Discussion

Engage on designer's perspective, alternatives, clarifications, and necessary changes.

## Length & Focus

- Summary: 2–3 sentences
- Each critical issue: 5–7 lines total (including Issue/Impact/Recommendation/Traceability/Evidence)
- Overall review: keep concise (~400 words guideline; the Recomputation discrepancies list is outside it)

## Review Guidelines

1. **Critical Focus**: Only flag issues that significantly impact success
2. **Constructive Tone**: Provide solutions, not just criticism
3. **Interactive Approach**: Engage in dialogue rather than one-way evaluation
4. **Balanced Assessment**: Recognize both strengths and weaknesses
5. **Clear Decision**: Make definitive GO/NO-GO recommendation
6. **Actionable Feedback**: Ensure all suggestions are implementable
7. **Grounded Claims**: Before raising an issue about how code, tests or probes behave, check it against the source — run it or quote the `file:line` — never infer it from names or reasoning alone

## Final Checklist

- **Critical Issues ≤ 3** and each includes Impact and Recommendation
- **Traceability**: Each issue references requirement ID/section
- **Evidence**: Each issue cites design doc location
- **Recomputation**: every contract stated twice, every concrete expression about existing code, and every branch site of an extended kind checked, with each discrepancy quoted
- **Decision**: GO/NO-GO with clear rationale and next steps
