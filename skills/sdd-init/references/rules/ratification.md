# Ratification Rules

## Objective

Define what "ratified" means and how a ratification session runs. These rules govern `/sdd-canon-ratify` and every place a skill asks a human to confirm normative content.

The failure mode this prevents: an AI drafts a document, the human says "looks good", and everything in it — including material they never read — becomes canon. The fix is not agent narration of every item (long walkthroughs breed fatigue and reflexive agreement); it is that the human reads the **actual final text, section by section**, with only the risky points flagged, and grants force through **explicit, recorded verdicts**.

## Definition of Ratified

An item is **ratified** only when all four hold:

1. Its full final text was **presented within a section the human reviewed** — never summarized into a count or a description of edits.
2. Its high-risk flags, if any, were **shown before the verdict**. Questioning is the human's right at any point, not a gate.
3. The human gave an **explicit verdict word** on the section (or on the item individually, if pulled out).
4. The verdict is **recorded** with date and granularity (`item` / `batch`).

Anything short of this is `draft`, whatever its prose claims. Silence, "I skimmed it", and an unanswered proposal are not verdicts.

## Status Vocabulary

`draft` → `ratified: YYYY-MM-DD (item|batch)` → `superseded-by: <id>` or `deprecated`.

## Grep Contract

Ratified markers live **only** in `decisions/` and `registry.md` — an item whose landing seat is anywhere else (steering, the canon README) is a routing defect: re-seat it in `decisions/` and let the other file point at it. Three commands audit the whole layer in seconds:

```
grep -rnE '`ratified: [0-9]{4}-[0-9]{2}-[0-9]{2} \((item|batch)\)`' <canon-root>/decisions/
grep -nE '^\|.*ratified: [0-9]{4}-[0-9]{2}-[0-9]{2} \((item|batch)\)' <canon-root>/registry.md
grep -rn 'ratified:' <canon-root> --include='*.md' --exclude-dir=decisions --exclude-dir=proposals --exclude=registry.md   # stray sweep — must return nothing
```

The anchors are load-bearing: decision markers inline in backticks, registry markers in a table cell at line start. Never write the marker in a third format, and never restate these commands inside the canon root (measured: doing so produces its own false positives) — canon files point here instead. The sweep excludes by **path**, never by line content: a README row linking to `decisions/` would otherwise exclude itself.

## Section Review

- **The unit of presentation is the section**: one target file/section of the proposal, its final text in full, MODIFIED items shown as previous → new. Nothing is summarized into a count.
- **Flags carry the risk**, one line each, at most 3–5 per section: conflicts with a ratified item, supersession or removal, irreversible, floating (no ratified grounds). Unflagged items are covered by the section verdict. No recommendations before the verdict.
- **Reading budget**: ~1,000–2,500 words (Japanese: ~2,000–5,000 characters) of new/changed text per session. Larger proposals split by section cluster — split the proposal, don't stretch the session.
- **Adoption** (an existing corpus entering the canon): present at file granularity; the human chooses the granularity. Neither the generation unit nor the drafter's decomposition is the judgment unit — that choice is the judge's.

## Verdict Vocabulary

Per section (or per item pulled out of one): **approve** / **amend** (state the change; the revised section re-presents) / **reject** (dropped from the proposal, recorded — back to `/sdd-canon-propose` if the idea survives in another form) / **defer** (open question in the canon README). Keep these words English wherever recorded, glossed in the session language on first use. A section verdict marks its items `(batch)`; an individually examined item, `(item)`. The default answer to an unconfirmed proposal is *no*.

## Recording

- Every session has a **record seat**: the proposal under ratification (created from the template when loose `draft` content is judged), so no verdict lands outside the audit trail.
- The record is the verdict table — section, verdict, date, granularity — plus the proposal's post-amendment final text. Q&A is not transcribed.
- The merge applies the proposal's text verbatim; the diff is reviewed against the proposal file — every hunk must trace to it.
- Session close: report what was approved / amended / deferred, and the audit commands above.

## Scope — What Requires Ratification

- **Here**: canon-layer content (`decisions/`, `registry.md` norm entries) and delta proposals against them. Nothing else.
- **Not here**: steering — small, capped, loaded into every session; present-diff-and-confirm is enough. Spec artifacts keep their own phase approvals. A gate exercised on everything protects nothing.

## Anti-Rubber-Stamp Guards

- Keep the queue scarce. The session's value comes from what it *doesn't* ask the human to judge.
- If every section was approved with zero questions and zero amendments, slow down once before closing: re-present the highest-risk flag with a concrete scenario and ask about it specifically. Engaged agreement confirmed, close at pace — a speed bump, not a lock.
