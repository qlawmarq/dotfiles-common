# Concept Alignment Lens

## Objective

Verify that a spec artifact (requirements, scenarios, design, or implementation) actually serves the product's purpose and philosophy — not merely that it is internally consistent. A spec can pass every spec-internal check (requirements ↔ design ↔ code) and still build the wrong thing; internal consistency is not correctness. This lens is the **forward-traceability** check: every behavior must trace *forward* to the product intent, just as every requirement traces *backward* to user input.

This lens is shared by `/sdd-spec-behavior`, `/sdd-validate-requirements`, `/sdd-validate-design`, `/sdd-validate-impl`, and `/sdd-spec-done`. It is defined once here — skills reference it, they do not restate it.

## Resolving the Canon

1. **Baseline (always)**: `docs/steering/product.md` — the product's purpose, themes, core capabilities, and Out of Scope.
2. **Canon layer (when declared)**: if `product.md` contains a `## Canon References` section, it names the canon root (structure: `canon-layer.md`; default `docs/canon/`) and how to search it. For enumerable norms — catalogs, entity lists, guards — the canon's `registry.md` is the authoritative seat; cite entries by ID. Look up cited decisions **JIT** — grep by the declared keywords for the topics the spec touches. Never bulk-load the canon. **Committed text binds**: an uncommitted canon edit or a README Open Question is not a decision — reliance on it is itself a finding.
3. **Established invariants**: `docs/steering/behaviors.md` — cross-spec behavior invariants distilled from completed features. Already loaded with steering.

When `product.md` and a deeper canon disagree, the canon wins if `product.md` says so; otherwise flag the inconsistency itself as a finding.

## The Check

For each requirement / scenario / design decision under review, ask three questions:

1. **What does it serve?** Name the product purpose, theme, or capability it advances (a citable section or decision). "It was requested" is a *source*, not a *purpose* — both are required.
2. **Does it contradict?** Check against the product's Value Proposition and Core Capabilities, the Out of Scope lists (the spec's, and the product's when steering keeps one), and every applicable invariant in `steering/behaviors.md`.
3. **Would the behavior read as the product?** For user-facing behavior: does the resulting behavior express the product's philosophy, or would it feel like a different product? (This is the question that pure traceability checks never ask.)

Scale effort to exposure: mechanical/internal changes need only a contradiction check; behavior-shaping changes need all three questions.

## Severity

- **Contradiction** with product purpose, Out of Scope, canon decision, or an established invariant → **Critical (NO-GO)**. Route back: fix the artifact, or — if the canon itself should change — land it through the phase's Canon changes section or `/sdd-canon-update` (`canon-layer.md §Change Control`), or whatever change-control process the project's root AGENTS.md declares instead; never reword canon to fit the artifact under review.
- **Unsupported**: no citable purpose can be named → **Critical (NO-GO)** unless the user explicitly confirms it belongs.
- **Weak grounding**: purpose citable but stretched or vague → **Warning** with a suggested tightening.

## Finding Format

```
🔴 Critical (Concept): <title>
Artifact: <requirement ID / scenario N / design section>
Canon: <product.md section, decision ID, or behaviors.md invariant cited>
Conflict: <what the artifact does vs. what the canon says>
Action: <fix the artifact | confirm with user | file to change control>
```
