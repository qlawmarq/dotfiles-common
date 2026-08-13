# Ratification Rules

## Objective

Define what "ratified" means and how a ratification session runs. These rules govern `/sdd-ratify` and every place a skill asks a human to confirm normative content.

The failure mode this exists to prevent: an AI drafts a document, the human says "looks good", and everything in it — including material they never read item by item — becomes canon. Reviewing AI-drafted prose at document granularity is not approval; past a few hundred lines it is a rubber stamp. Ratification replaces "read the document and approve it" with "**the agent explains item by item; the human only judges**" — approval at the human's judgment unit, not the AI's generation unit.

## Definition of Ratified

An item is **ratified** only when all four hold:

1. It was **presented individually** — by name, with its rationale — not folded into a summary or aggregate count.
2. The human had a real opportunity to **question it** (QA), with at least one concrete scenario for contentious items.
3. The human issued an **explicit verdict** on it (or on a batch that enumerated it — see Presentation Discipline).
4. The verdict is **recorded** with date and granularity (`item` / `batch`).

Anything that does not meet this definition is `draft`, whatever its prose claims. Silence, "I skimmed it", and an unanswered proposal are not verdicts.

## Status Vocabulary

`draft` → `ratified: YYYY-MM-DD (item|batch)` → `superseded-by: <id>` or `deprecated`.

## Grep Contract

Two commands must enumerate exactly what the human has judged, with dates — an audit that takes minutes, not a day of archaeology:

```
grep -rnE '`ratified: [0-9]{4}-[0-9]{2}-[0-9]{2} \((item|batch)\)`' <canon-root>/decisions/
grep -nE '^\|.*ratified: [0-9]{4}-[0-9]{2}-[0-9]{2} \((item|batch)\)' <canon-root>/registry.md
```

The anchors are load-bearing — decision markers inline in backticks, registry markers in a table cell at line start. A bare `grep -rn "ratified:"` also matches headers, index tables, and any document that merely *mentions* the contract (measured: 3 false positives on a canon with nothing ratified). Never write the marker in a third format, and never document the audit in a form that matches itself.

## Presentation Discipline

- **No item is omitted.** Presenting a catalog as "17 facilities added" or "the same entries as before, plus N" is prohibited. Every entry appears by name, every time it is up for judgment — that is how unreviewed content acquires force.
- **Every item is presented briefly.** The rule above bans *dropping items*, not brevity — it is not a licence to be exhaustive. An item the human cannot read is as unjudged as one they never saw. Detail a verdict does not need — citations, dependency lists, the agent's reasoning about these rules — stays out of the presentation and is offered on request.
- **Three questions, in this order.** Every item answers **what changes** (plain language, no undefined jargon), **what you are judging** (the actual conflict or trade-off — not the tier label), and, when contentious, **an example**: "under this item, in situation X, Y happens — correct?". Judgment engages with cases, not norm-prose. The full normative text is shown, but never first: a reader who does not already know the canon cannot start there.
- **Round size**: one decision, or 5–8 catalog entries, per round. Never more, even if the user asks to go faster — offer batch verdicts (below) instead of bigger rounds.
- **Tiering — declared, not silent.** Before presenting, classify every item and *say so*:
  - **Contentious**: structural or irreversible; conflicts with another decision; derives from no ratified decision (a floating item); breaks consistency across catalogs. → one at a time, full treatment.
  - **Minor**: mechanically derivable from already-ratified decisions; wording-level. → enumerated in a batch, one-line explanation each, a single batch verdict allowed.
  - A declaration of "no contentious items" is itself recorded — it is a claim the agent is accountable for.
- **Timebox as a design signal**: a decision that cannot be judged in one session (~20–30 minutes) is too big — split the decision, don't stretch the session.

## Verdict Vocabulary

Per item (or per enumerated batch): **ratify** / **amend** (state the change; re-present the amended item) / **rework** (back to drafting — the item is wrong, not just misworded) / **remove** / **defer** (file as an open question in the canon README). The verdict stream — not a narrative summary of it — is the approval evidence. These five words are the controlled vocabulary; keep them in English wherever they are recorded, and gloss them in the session language on first use.

**Recommendations** are given on **contentious items only**, marked as a proposal with one line of reasoning. That is where the human most needs something to push against, and a silent agent there just moves the drafting work onto them. Minor batches get none — a recommendation on an item nobody was going to contest only trains the reflex to agree. A recommendation is never a verdict: the default answer to an unconfirmed proposal is *no*, and silence is not agreement.

## Recording

- Every session has a **record seat**: the proposal under ratification. When the items being judged are loose `draft` content already sitting in the canon (typical when an existing document set was adopted), a proposal file is created to serve as their seat — so no verdict is ever recorded outside the audit trail.
- Verdicts are appended to that seat, each with date and granularity. The session's Q&A is preserved **verbatim** in the archived proposal — the human's questions are evidence of judgment; never compress them away.
- On merge, statuses update in the target files (`decisions/`, `registry.md`).
- The **merge may be delegated** to a sub-agent working from a self-contained instruction that carries the final text verbatim; the record and the review of the merge may not. A delegated merge applies given text — it never drafts, rewords, or resolves an ambiguity.
- Session close: report what was ratified / amended / deferred, and remind the user of the grep contract above — it audits the result in seconds.

## Scope — What Requires Ratification

- **Here**: canon-layer content (`decisions/`, `registry.md` norm entries) and delta proposals against them. Nothing else.
- **Not here**: steering — it is small, capped, and loaded into every session, so the human already sees it; ordinary present-diff-and-confirm is enough. Spec artifacts keep their own phase approvals.

The boundary matters in both directions: routing mechanical facts through ratification burns the attention that contentious norms need. A gate exercised on everything protects nothing.

## Anti-Rubber-Stamp Guards

- Keep the queue scarce. The session's value comes from what it *doesn't* ask the human to judge.
- If the user blanket-approves several consecutive rounds without a single question or amendment, slow down once: re-present the highest-risk pending item with a concrete scenario and ask about it specifically. If they confirm engaged agreement, continue at pace — the guard is a speed bump, not a lock.
