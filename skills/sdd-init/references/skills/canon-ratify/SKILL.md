---
name: sdd-canon-ratify
description: >-
  Ratify canon proposals by section-level review: the human reads the final
  text with only the risky points flagged, and gives explicit verdicts. The
  sole path by which content gains canonical force.
argument-hint: "[proposal-file | \"topic\"]"
disable-model-invocation: true
---

# Canon Ratification Session

<background_information>

- **Mission**: Grant canonical force to a proposal's final text through per-section explicit verdicts. The human reads the actual text — the agent surfaces the few points worth judging, not a narration of every item. Rationale lives in `ratification.md`.
- **Relation to `/sdd-grill`**: grill settles *open* decisions; ratify judges *drafted* norms. A genuinely open question found here defers out to the canon README.
- **Success Criteria**: every section's full final text shown with its flags before its verdict; verdicts recorded; statuses merged; proposal archived.

</background_information>

<instructions>

## Input

1. **Proposal file** (optional positional): a path under `<canon-root>/proposals/`.
2. **Topic** (optional positional): scope the session to draft items matching a topic.
3. Neither given: list what awaits judgment — open proposals, plus `draft` items in `decisions/` and `registry.md` — and ask.

## Methodology

Read `docs/settings/rules/ratification.md` — the protocol this skill executes. Read `canon-layer.md` only at merge (Stage 2), `normative-registry.md` only if the target touches `registry.md`. Retrieval, inlined: gather grounds and dependents by JIT grep — never bulk-load the canon; hold citations and answer with them when asked; never ask the user for facts the repository can answer.

## Stage 0 — Prepare

1. **Resolve the canon root** from `docs/steering/product.md §Canon References` (default `docs/canon/`). None → point to `/sdd-canon-propose` (which scaffolds it) and stop.
2. **Fix the record seat** (`ratification.md §Recording`). A proposal is its own seat; for loose `draft` items already in `decisions/` or `registry.md`, create `proposals/YYYY-MM-DD-ratify-<slug>.md` from the template as the seat.
3. **Independent flag check** — never just trust the proposal's flags. Grep for conflicts with ratified items, supersessions and removals, irreversibles, floating items. Findings become flags on the sections they bear on.
4. **Budget check** (`ratification.md §Section Review`): over the reading budget, propose a split by section cluster and let the user pick the first.
5. **Open plainly**: two or three sentences on what the proposal changes, the section list with flag counts, expected length. No per-item preview.

## Stage 1 — Section Review

One section per round — one target file/section of the proposal. Render the scaffold in the session language; the order is the contract: text first, flags after, verdict last.

```
## <n>/<N> — <target file §section>

<the final text, in full; MODIFIED items diff-style: previous → new>

Flags:
- <one line each, high-risk only, max 3–5>

→ approve / amend / reject / defer?
```

Rules in every round:

- **No recommendations before the verdict.** State risks as flags; opine only when asked. A recommendation shown first is what the user anchors on instead of reading.
- **Questions are the user's to ask** — answer with grounds before re-asking for the verdict.
- **Explicit verdict word required.** Ambiguity re-asks; an unanswered section stays `draft`.
- **Amend loop**: the user states the change → edit that section of the proposal file → re-present only the revised section as a diff against what was just shown → fresh verdict.
- **Adoption mode** (pre-existing corpus): present at file granularity; the user chooses the granularity.
- Keep the tally visible between sections: approved / amended / deferred / remaining.
- **Speed bump**: if every section so far was approved with zero questions and zero amendments, before closing re-present the highest-risk flag with one concrete scenario and get explicit confirmation.

## Stage 2 — Record, Apply, Review

1. **Record first.** Append the verdict table (section, verdict, date, granularity) to the seat's Ratification Record. Amended text already lives in the proposal — the archived proposal *is* the record. No Q&A transcription.
2. **Apply directly.** Copy the proposal's final text (post-amendment) verbatim into `decisions/` / `registry.md`; markers in the anchored format `ratified: YYYY-MM-DD (item|batch)`; supersession cross-references both ways; deferred items → canon-README open-question rows; decision-log rows; proposal → `proposals/archive/` (date-prefixed name kept) or `partially-ratified`.
3. **Review the diff against the proposal file, never memory.** Every hunk traces to a proposal Text block or a recorded amendment — the check for invention; changed files equal the approved sections' targets; the `ratification.md §Grep Contract` commands return the expected results. Commit as its own `docs(canon):` commit, never bundled with implementation changes.

## Important Constraints

- Do NOT draft new norms here. A gap found mid-session defers to the canon README or `/sdd-canon-propose`; amending presented text is the one exception, and it re-presents before it merges.
- Do NOT merge anything whose verdict was not explicitly given this session or recorded previously.

</instructions>

## Tool Guidance

- **Read** the rules in §Methodology, the proposal, and only the canon files its sections touch; **Grep** for the Stage 0 flag check.
- **Edit/Write** the proposal for amendments (Stage 1) and the merge targets (Stage 2) — targets only per recorded verdicts.

## Output Description

Resolve the output language from `docs/settings/templates/specs/init.json` `language` (default `ja`); render everything in it, scaffold labels included. Verdict words and status markers stay English (`ratification.md §Verdict Vocabulary`), glossed on first use.

**Format**: Markdown, one section per message — present, then wait. Never present a section and its verdict in the same breath. Session close reports per-section verdicts, landing paths, archive location, and the audit commands.

## Safety & Fallback

- **No canon root**: point to `/sdd-canon-propose` and stop.
- **Nothing awaiting judgment**: say so, cite what you checked, stop — do not manufacture items.
- **Old-format proposal** (per-item What-changes / What-you-are-judging / Example / Tier fields): reinterpret in place — regroup items into sections by target file/section, use each `Item` field as the final text, derive flags from `Tier: contentious` reasons, ignore the narrative fields. Offer regeneration only if the targets are ambiguous.
- **Oversized target**: split by cluster, ratify the first, leave the proposal `partially-ratified`.
- **User stops mid-session**: record verdicts given so far per Stage 2; resumable by re-running on the same proposal.
- **Contradiction discovered mid-review**: surface as a flag on that section; options are "amend here" or "file a superseding proposal" — never edit the ratified side inline.
- **Canon drifted since drafting**: stop the merge, show the divergence, re-present affected sections against the current state.
