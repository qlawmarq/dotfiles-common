# Change Review

<!-- Provenance run: this file; the session record (`bash docs/settings/scripts/session_record.sh dump`, saved outside the repository); and `git diff HEAD -- <changed files>`, or the statements asked about. Consistency run: this file; the same diff; the decisions `README.md` and `registry.md`; and `docs/steering/` — as committed. -->

You did not write this text. Propose no wording. The provenance run does steps 1–4 and reports A–C; the consistency run does steps 1, 5 and 6 and reports D.

1. Split the changed text into numbered claims, one checkable statement each. Each removed or replaced line is a claim `removed: <line>`. IDs, links, `keywords` lines, `Used by` cells and the rows of the decisions `README.md` (decision log and Open Questions) are not claims.

## Provenance

2. Find each claim's source, in this order:
   - **U** — the user's words in a `USER` turn.
   - **A** — an `AGENT` turn the user explicitly accepted in a later `USER` turn of the same session (the last field of their `=====` lines); quote both. A yes to a plan covers only what the plan stated.
   - **D** — a sentence of steering or the decision records as committed. `docs/reference/` is never D.
   - **R** — for a `tech.md` or `structure.md` line only: the committed code, configuration or manifest it describes, quoted with its path.
   - **F** — for a statement of fact in a decision file's Background only: the `docs/reference/` section it cites, which states it.
   - **none**.
3. Verdicts:
   - **LAND** — the source states the claim, no more and no less.
   - **HOLD** — neither LAND nor ASK. When in doubt, HOLD.
   - **ASK** — the claim overturns or deletes an existing decision item or steering line, or changes or removes a registry `Norm` or adds a `TERM` row, and its source is neither U nor A naming that very change.
4. List each pair of the user's own statements that conflict on a topic the text touches.

For a provenance question: steps 1–2 without D for each statement, plus the user's later statements on its subject; no verdict.

## Consistency

5. For each claim, list every row of the decisions `README.md` (decision log and Open Questions) and `registry.md`, and every line of `docs/steering/`, whose topic it touches — or `none`.
6. For each pair: **contradicts**; **stale** — the row or line still lists as open, or as a candidate, what the claim decides; or **consistent**.

## Report

Provenance:
A. `| # | claim | source | verdict |`
B. Each quote on its own line, character for character: `<#>⇥USER|AGENT⇥<timestamp from its ===== line>⇥<quote>` or `<#>⇥DOC⇥<path>⇥<quote>` (D, R and F; ⇥ is a tab; `…` marks an omission).
C. Each pair of step 4, both quotes with speaker and timestamp, or `Conflicts: none`.

Consistency:
D. Each pair of step 6 that is not consistent: the claim, the row ID or section, the verdict, and the words of both that decide it — or `Conflicts: none`.
