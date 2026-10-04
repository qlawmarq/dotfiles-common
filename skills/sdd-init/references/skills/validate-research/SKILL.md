---
name: sdd-validate-research
description: >-
  Independently verify research findings before they become design premises.
  Re-runs the recorded evidence, checks citations, and surfaces unverified load-bearing assumptions.
---

# Research Validation

<background_information>

- **Mission**: Catch a wrong research finding *before* `/sdd-spec-design` turns it into a premise that nothing downstream is allowed to question
- **Success Criteria**:
  - Every claim's recorded reproducer was actually re-run, or explicitly marked un-reproduced
  - Every claim that must be measured (`evidence-discipline.md` §1) but was not is listed — all of them, not a sample
  - Load-bearing unverified claims are put to the user as decisions; nothing else is
  - Clear GO/NO-GO with rationale

</background_information>

<instructions>

## Input

1. **Feature name** (required): the feature directory name in `docs/tasks/`
2. **`--batch`** (optional): non-interactive. List the contested claims as open assumptions instead of asking; never NO-GO on them alone.

If not provided, ask for the feature name.

## Core Task

Verify `research.md` independently. **Start from its claims and check them yourself** — do not re-read the reasoning that produced them and agree with it. An author checking their own work reproduces their own blind spots; that is why this is a separate pass.

## Execution Steps

1. **Resolve Spec Path**: `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Error if neither exists.

2. **Load Context**: `{spec_path}/spec.json` (language, `kind`), `research.md`, `requirements.md`, `behaviors.md` and `gap-analysis.md` (if they exist), `{spec_path}/probe/README.md` (if it exists), and `docs/settings/rules/evidence-discipline.md`.

3. **Run the five checks**. Dispatch the independent lookups as parallel sub-agents so large files and command output stay out of the main context (`dialogue-grounding.md`).

   1. **Reproduce** — for each claim typed `measured`, actually run what `Verification` names (probe script, test, command) and compare the output to the claim. Anything you cannot run is **un-reproduced**, not verified.
   2. **Citation fidelity** — for each `sourced` claim, check the cited source actually supports it, and that `file:line` references say what the claim says they say. A citation that is merely *adjacent* to the claim does not support it.
   3. **Unmeasured assertions** — list **every** claim that falls under one of the four kinds in `evidence-discipline.md` §1 but has `Verification: none` or only a document reference. This list is not capped.
   4. **Coverage** — check the investigation items required by `requirements.md`, `behaviors.md` (Verification lines), `gap-analysis.md`, and the items `docs/settings/rules/spec-kinds.md` requires measured for this kind against what `research.md` actually investigated. List anything untouched.
   5. **Design premises** — a claim that is `Load-bearing` and not verified by checks 1–2 is **contested**. Also work backwards: if a recommendation rests on a claim whose `Load-bearing` line is blank, the line is wrong — flag it.

4. **Report and decide** (see Output Description). In interactive mode, put each contested claim to the user and record the answer. In `--batch`, list them as open assumptions.

5. **Carry the outcome forward**: claims the user chose to proceed on become assumption-register entries for `design.md` (`evidence-discipline.md` §4). State them in the output so `/sdd-spec-design` can pick them up.

## Critical Constraints

- **Do not update spec.json.** No phase transition, no approval state. This skill reports; it does not gate on record.
- **Do not rewrite `research.md`.** Detect and report. Re-investigation is `/sdd-spec-research`.
- **NO-GO only on facts, never on taste**: NO-GO when check 3 or check 4 is non-empty. Quality opinions are advice, not blocks.
- **Only contested claims reach the user.** Everything else is machine work.

</instructions>

## Tool Guidance

- **Shell/test runners**: check 1 requires actually executing things. A validation that only reads is the failure this skill exists to fix.
- **Sub-agents**: run independent checks in parallel; report back findings, not file contents.
- **Grep**: confirm or refute a claim's `file:line` citations against the current code.

## Output Description

In the language from spec.json (the labels below translated with it), these four blocks in this order. Do not add sections.

```
Verdict: GO | NO-GO — <one line of rationale>

Missing evidence (checks 3–4, all):
- C<n>: <claim> — <which of the four kinds> / Evidence now: <what evidence exists>
- <required item> — not investigated / Required by: <document>

Contested (needs a decision):
C<n>: <claim>
Breaks: <what in the design fails if this is wrong>   Evidence: <current evidence>
Measure by: <command / test / probe>   → measure / keep / redo

Other notes: <max 3, one line each>
```

- `Verdict` and `Contested` always appear ("nothing contested" when none — it is itself a finding worth recording); omit any other block that is empty.
- Keep the whole report under ~400 words plus the lists.

## Safety & Fallback

- **No `research.md`**: stop — "Run `/sdd-spec-research <feature-name>` first."
- **`research.md` predates the claim format** (no `C<n>` entries): do not fail. Derive claims from its Findings and Recommendation, report that the format is missing as the first of `Other notes`, and run the five checks on what you derived.
- **Reproducer cannot run here** (missing runtime, too slow, needs credentials): mark the claim un-reproduced with the reason and treat it as unverified for check 5. Do not silently pass it.
- **Language undefined**: fall back to `docs/settings/templates/specs/init.json` `language`, then `ja`.

### Next Phase

- **GO** → `/sdd-spec-design <feature-name>`. Carry the assumption-register entries into its Assumptions section.
- **NO-GO** → measure what check 3 listed, or re-run `/sdd-spec-research <feature-name>` for what check 4 found missing, then re-validate.
