# Research Template

---
**Purpose**: Capture discovery findings and the evidence behind them, so the design rests on verified claims rather than plausible prose.

**Usage**:
- Every finding is one claim with its evidence. Field semantics, the measurement rule, the `probe/` convention: `docs/settings/rules/evidence-discipline.md`.
- Put trade-off detail here that is too fine for `design.md`.
- Verification artifacts (scripts, logs, results) go in `probe/`, not in this file.
---

## Summary
- **Feature**: `<feature-name>`
- **Discovery Scope**: New Feature / Extension / Simple Addition / Complex Integration
- **Key Findings**: 3 at most, each naming the `C<n>` it comes from.
  - `C1` — Finding
  - `C2` — Finding

_Every entry needs a `C<n>` below **at the same scope** — a lower bound does not become a total by being summarized._

## Research Log
One entry per claim, grouped by topic. Tag lines per `evidence-discipline.md` §2.

### [Topic or Question]
- **Context**: What triggered this investigation?
- **Method**: What you did — commands run, code read, sources consulted, probes executed.

#### C1: `<the claim>`
- Type: measured | sourced | inferred | unverified
- Verification: `<probe/<file> | test name | command + output | URL + retrieval date | none>`
- Confidence: high | medium | low
- Load-bearing: `<what breaks in the design if this is wrong — blank if nothing does>`
- **Implications**: How this affects architecture, contracts, or implementation.

_Repeat `#### C<n>` for each claim, and the `###` subsection for each topic._

## Unverified & Open
Claims that could not be settled, and what it would take to settle them. Leaving this empty is a claim in itself.

| ID | What is unknown | Why it could not be measured | What would settle it | Load-bearing? |
|----|-----------------|------------------------------|----------------------|---------------|
| C_ |                 |                              |                      | yes / no      |

## Architecture Pattern Evaluation
Candidate patterns considered, with the claims that inform the comparison.

| Option | Description | Strengths | Risks / Limitations | Evidence |
|--------|-------------|-----------|---------------------|----------|
| Hexagonal | Ports & adapters around the core domain | Clear boundaries, testable core | Adapter layer build-out | `C3`, steering principle X |

## Recommendation
Provisional. What the design should do, one line each, naming the claims it rests on. `/sdd-spec-design` moves each line into design.md §Design Decisions and deletes it here; when the section is empty, it is removed. Claims stay.
- `<recommendation>` — based on `C<n>`, `C<n>`; alternative not taken: `<one phrase>`

## Risks & Mitigations
- Risk — mitigation

## References
- [Title](https://example.com) — relevance, retrieval date
- `probe/README.md` — verification artifacts index
