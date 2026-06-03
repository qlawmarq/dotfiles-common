# Requirements Review Process

## Objective

Validate that `requirements.md` reflects what the user actually asked for — nothing invented, nothing ambiguous, nothing untestable — before the requirements propagate into research, design, tasks, and code. The most valuable thing this review does is catch **gold-plating**: requirements that crept in without a legitimate source. Those are the ones that cause silent rework, because every later phase faithfully builds whatever the requirements say.

## Review Philosophy

- **Detect, don't redesign**: surface problems and route them back; don't rewrite the user's requirements for them.
- **Source-first**: the primary question for every requirement is "where did this come from?" A requirement that traces to nothing is the headline finding, not a footnote.
- **Critical focus**: limit to the ~3 most important concerns, but always run the full traceability sweep first.
- **Interactive dialogue**: engage with the user, especially to confirm whether a suspicious requirement was actually wanted.
- **Clear decision**: definitive GO/NO-GO with rationale.

## Scope & Non-Goals

- Scope: assess whether the requirements are *grounded* (traceable to user input), *bounded* (scope is explicit), *clear* (unambiguous, testable), and *well-formed* (EARS, singular, consistent).
- Non-Goals: do not evaluate technical design, choose implementations, or research solutions. Do not invent the missing requirements yourself — flag gaps for the user to fill.

## Core Review Criteria

### 1. Backward Traceability — the gold-plating check (Critical)

For every requirement, verify it carries a **Source** and that the source is legitimate:

- **User-stated / User-confirmed / Derived / Steering-constraint** are valid sources.
- A requirement with **no source**, a vague source ("best practice", "users would expect"), or a source that is really the agent's own inference is **gold-plating** — flag it.
- For **Derived** requirements, check the derivation is actually necessary, not a convenient excuse to add scope. ("We store X" genuinely implies "X is retrievable"; it does not imply "X is exportable to CSV.")
- Cross-check against the **Project Description (Input)** and the dialogue: does each requirement map to something the user said or confirmed? List any requirement that does not.

This is the criterion most directly tied to the rework the user is trying to prevent. Run it on *every* requirement, even when you stop at three critical issues overall.

### 2. Scope Conformance (Critical)

- Is there an explicit **Out of Scope** section? Its absence is itself a finding — unbounded scope is how creep enters.
- Does any requirement contradict the Out of Scope list or an exclusion the user stated ("just X for now")?
- Are requirements prioritized (MoSCoW or equivalent)? Are there "nice-to-have" requirements with no user backing that should be demoted or removed?

### 3. Ambiguity & Vagueness

- Lint for unmeasurable terms — *fast, scalable, user-friendly, efficient, robust, flexible, adequate, intuitive, as appropriate, etc.* Each should be replaced by a measurable criterion or recorded as an open question.
- Apply the two-reviewer test: would two readers reach the same pass/fail decision from this requirement? If not, it's ambiguous.

### 4. Testability & EARS Conformance

- Every acceptance criterion should be verifiable — you can state how to confirm it. Flag anything you couldn't write a test for.
- Acceptance criteria follow EARS patterns (`ears-format.md`): correct trigger/precondition keywords, a single `shall`, concrete subject. Flag free-form prose masquerading as acceptance criteria.

### 5. Set-Level Quality

- **Singular**: no requirement smuggles two needs via "and"/"or".
- **Consistent**: no two requirements conflict.
- **Complete (within stated scope)**: are there obvious gaps the user *did* ask for but that are missing? (Missing requested requirements are as much a defect as invented ones — but resolve them by asking, not by inventing.)
- **Assumptions surfaced**: are unresolved assumptions and open questions logged explicitly rather than baked silently into requirements?

## Review Process

### Step 1: Build the trace map

Read the **Project Description (Input)** and all steering context first, then walk each requirement and classify its source as: clearly grounded, derived-and-reasonable, or **unsourced/suspicious**. This map is the backbone of the review.

### Step 2: Identify Critical Issues (≤3)

Prioritize unsourced/invented requirements and scope violations. For each issue:

```
🔴 **Critical Issue [1-3]**: [Brief title]
**Concern**: [Specific problem — e.g., "Requirement 4 has no traceable source"]
**Type**: [Gold-plating | Scope violation | Ambiguity | Untestable | Inconsistency]
**Impact**: [Why it matters — what rework it risks]
**Suggestion**: [Concrete fix — remove, demote, clarify, or confirm with user]
**Evidence**: [requirements.md requirement ID + its Source line vs. the actual input]
```

### Step 3: Recognize Strengths

Acknowledge 1-2 well-grounded, well-formed aspects to keep feedback balanced.

### Step 4: Decide GO/NO-GO

- **GO**: every requirement traces to a legitimate source, scope is explicitly bounded, criteria are testable and unambiguous, no unconfirmed invented features remain.
- **NO-GO**: one or more requirements are unsourced/invented, scope is unbounded or violated, or pervasive ambiguity makes the requirements untestable. Invented features are a NO-GO by default — confirm with the user or remove before proceeding.

## Output Format

### Requirements Review Summary

2-3 sentences on overall grounding and readiness.

### Unrequested / Unsourced Requirements

The headline list: every requirement that does not trace to user input, each with its ID and what the user actually said (or the absence thereof). If there are none, say so explicitly — that's a strong positive signal.

### Critical Issues (≤3)

For each: Concern, Type, Impact, Suggestion, Evidence.

### Strengths

1-2 positive aspects.

### Final Assessment

Decision (GO/NO-GO), Rationale (1-2 sentences), Next Steps.

### Interactive Discussion

For each suspicious requirement, ask the user directly whether they wanted it — this resolves the ambiguity between "the agent invented it" and "the user wanted it but forgot to say so" without you having to guess.

## Length & Focus

- Summary: 2-3 sentences
- Unsourced list: one line per requirement
- Each critical issue: 6-8 lines
- Overall review: concise (~450 words guideline)

## Final Checklist

- **Every requirement's Source verified** against the actual input — unsourced ones listed explicitly
- **Out of Scope section present** and not contradicted
- **Critical Issues ≤ 3**, each with Type, Impact, Suggestion, Evidence
- **Ambiguity/testability** spot-checked
- **Decision**: GO/NO-GO with clear rationale and next steps
