---
name: sdd-ratify
description: >-
  Run a ratification session over canon proposals or draft norms: the agent
  explains each item with rationale and concrete scenarios, the human only
  judges. The sole path by which content gains canonical force.
argument-hint: "[proposal-file | \"topic\"]"
disable-model-invocation: true
---

# Ratification Session

<background_information>

- **Mission**: Convert `draft` normative content into `ratified` content item by item — the agent explains, the human only judges. This breaks the generation unit (a document) back down into the judgment unit (an item). Rationale lives in `ratification.md` and is not repeated here.
- **Relation to `/sdd-grill`**: grill settles *open* decisions — questions with no answer yet. Ratify judges *drafted* norms — answers awaiting a verdict. Canon-level grill outcomes arrive here as a proposal; a genuinely open question found here defers out to the canon README.
- **Success Criteria**:
  - Every item presented by name, briefly, in the session language — nothing summarized into a count, nothing padded past what a verdict needs.
  - The user's output is a verdict stream; the agent does all explaining, recording, and merging.
  - Verdicts and verbatim Q&A recorded in the record seat; statuses updated; proposal archived.

</background_information>

<instructions>

## Input

1. **Proposal file** (optional positional): a path under `<canon-root>/proposals/`.
2. **Topic** (optional positional): scope the session to draft items matching a topic.
3. If neither is given: list what is awaiting judgment — open proposals, plus `draft`-status items in `decisions/` and `registry.md` — and ask the user what to ratify.

## Methodology

Read `docs/settings/rules/ratification.md` — the protocol this skill executes — and `docs/settings/rules/dialogue-grounding.md` for retrieval and citation discipline. Read `canon-layer.md` and `document-hygiene.md` when the session will merge (Stage 2), and `normative-registry.md` **only if** the target touches `registry.md`. Do not load rules the target does not reach.

## Stage 0 — Resolve and Prepare

1. **Resolve the canon root** from `docs/steering/product.md §Canon References` (default `docs/canon/`). If none exists, tell the user to start with `/sdd-canon-propose` (which scaffolds it) and stop.
2. **Load the target**: the proposal's items, or the draft items in scope. For each, gather grounds and dependents by JIT grep — never bulk-load the canon.
3. **Fix the record seat** (`ratification.md §Recording`). A proposal target is its own seat. If the target is loose `draft` items already sitting in `decisions/` or `registry.md` — the normal case when an existing document set was adopted — create `proposals/YYYY-MM-DD-ratify-<slug>.md` from the proposal template, listing exactly those items, and use it as the seat. Never run a session with nowhere to record it.
4. **Check the tiering yourself** against `ratification.md §Presentation Discipline` — do not just trust the proposal's declaration. Grep for conflicts with ratified items; check for floating items, cross-catalog breaks, irreversibility. Your independent check is what makes a "no contentious items" claim worth anything.
5. **Open the session in plain language** — and with nothing else: what the proposal is about and what it would change, in two or three sentences a reader of no canon files could follow; then N items of which M contentious, **one line each**; then rounds and expected length. Over one timebox (~20–30 min), propose a split by cluster and let the user pick the first.

   Your step-4 findings get no section of their own. Each belongs inside the item it bears on, as that item's *what you are judging* — that is where the user can act on it. A finding that belongs to no item means the target is broken: say so in one line and offer to revise rather than opening the session.

## Stage 1 — Rounds

Work in rounds per `ratification.md §Presentation Discipline`: one decision, or 5–8 catalog entries, per round; contentious items first, one at a time.

The blocks below are **scaffolding** — render every label in the session language and keep the order. The order is the contract: plain meaning first, full norm text after it, verdict last.

**Contentious item**:

```
### <n>/<N> — <short title a human can hold in their head, not the bare ID>

**What changes**: <1–2 plain sentences — what is different once ratified, and for whom>
**What you are judging**: <the real conflict or trade-off, including your own findings; give numbered options when options exist>
**Example**: <"Under this item, in situation X, Y happens." — one case, real names and values>

**The item**: <the full normative text, verbatim> <(Previously: … ) for a modification>
**Recommendation**: <verdict + one line of reasoning — a proposal, not a decision>

→ Verdict? (ratify / amend / rework / remove / defer)
```

Grounds, citations, and dependents are **not printed** — hold them and answer with them when asked. Printing them is what buries the question.

**Minor batch** — every entry enumerated, one line each, no recommendations; a single batch verdict is allowed, and the user may pull any entry out for the full treatment:

```
Batch N (minor — each follows from <grounds>):
1. <ID> — <norm> — <one-line why>
2. …
→ Verdict for the batch? (or name any entry to examine individually)
```

Rules that hold in every round:

- **Answer questions before verdicts.** Any question pauses the verdict — explain, cite, extend the example, then re-ask.
- **Ambiguity is not a verdict.** Re-ask rather than resolving it in the agent's favor; an unanswered item stays `draft`.
- **Amend re-presents.** An amended item returns (same session if small) with its full new text — the human judges text, not descriptions of edits.
- Keep the tally visible between rounds: ratified / amended / deferred / remaining.

## Stage 2 — Record, Merge, Review

Only after verdicts, and exactly as verdicts direct. The three steps are separated on purpose: you hold the transcript, the sub-agent holds the files, and neither reviews its own work.

**1. Record — yours, never delegated.** Append the verdict table (item, verdict, date, granularity) and the session Q&A **verbatim** to the Ratification Record of the seat fixed in Stage 0. Do this first: if anything later fails, the evidence of judgment already exists.

**2. Merge — delegate.** Write a **merge instruction** and hand it to a sub-agent that never sees the session, so the instruction must be self-contained:

- per ratified item: target path, where in the file, **the final text verbatim** (post-amendment — never "apply the amendment"), the marker `ratified: YYYY-MM-DD (item|batch)` in the format the grep contract anchors on, and supersession cross-references both ways
- deferred items: the exact open-question rows for the canon README
- the proposal's disposition: `proposals/archive/` when fully resolved (keep the date-prefixed name), or left in `proposals/` as `partially-ratified` with its record showing what remains
- canon README decision-log rows for any status change
- the prohibition, stated to the sub-agent: **apply the given text and nothing else** — do not draft, reword, reformat, touch an unlisted file, or resolve an ambiguity. An ambiguity comes back unapplied.

If the harness has no sub-agent tool, apply the instruction yourself — writing it first is what keeps the merge honest either way.

**3. Review — yours.** Read the diff, not the files:

1. every ratified item present, its marker in the anchored format
2. the changed-file set equals the instruction's file set
3. no text appears that the instruction did not carry — this is the check for invention
4. the `ratification.md §Grep Contract` commands return the expected count
5. deferred items landed as open questions

Anything unexplained is corrected against the recorded verdicts, never against your memory of the discussion. Then commit if the repo's conventions expect it, as its own `docs(canon):`-style commit — never bundled with implementation changes.

## Important Constraints

- Do NOT draft new norms here. A gap found mid-session is deferred to the canon README or handed to `/sdd-canon-propose` — drafting and judging in the same breath is how unreviewed content slips through.
- Do NOT merge anything whose verdict was not explicitly given this session or recorded previously, and do NOT compress the Q&A when recording.
- Do NOT ask the user for facts the repository can answer — their attention is reserved for verdicts.

</instructions>

## Tool Guidance

- **Read** the rules named in §Methodology, then the proposal and only the canon files its items touch.
- **Grep** for conflict detection before declaring any item uncontentious.
- **Sub-agents**, via whatever delegation tool the host harness provides, for independent lookups (consumers across specs and code) — citations back, not file dumps — and for the Stage 2 merge, driven by the merge instruction alone.
- **Edit/Write** only in Stage 2, only per recorded verdicts. Never open a merge target in your own context to "check" it — the diff is the review surface.

## Output Description

Resolve the output language from `docs/settings/templates/specs/init.json` `language` (default `ja`) and render everything in it — including the block labels above, which are scaffolding, not wording. The verdict words and status markers stay English (`ratification.md §Verdict Vocabulary`), glossed on first use.

**Format**: Markdown, one round per message — present, then wait. Never present a round and its verdicts in the same breath. Session close reports ratified / amended / deferred, where each landed, the archive location, and the audit commands from `ratification.md §Grep Contract`.

## Safety & Fallback

- **No canon root**: point to `/sdd-canon-propose` for scaffolding and stop.
- **Nothing awaiting judgment**: say so, cite what you checked, and stop — do not manufacture items.
- **Target predates the current proposal format** (no *what changes* / *what you are judging* fields): derive them yourself before presenting — never present raw norm text and let the human work out what it means. If the gaps are wide enough that you would be re-drafting, stop and hand it back to `/sdd-canon-propose`.
- **Oversized target**: split by cluster, ratify the first, leave the proposal `partially-ratified` with its record current.
- **User stops mid-session**: record verdicts given so far exactly as in Stage 2; the session is resumable by re-running this skill on the same proposal.
- **Contradiction discovered mid-session**: surface it as that item's *what you are judging*; the options become "amend this item" or "file a proposal to supersede the ratified item" — never edit the ratified side inline.
- **Merge conflict** (canon changed since drafting): stop the merge, show the divergence, re-present affected items against the current state.
