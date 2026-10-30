# Decision Records

## Objective

Keep the product decisions in one place, changed only by §Change Control. Two accidents this prevents: an AI draft gaining canonical force beyond what the user said or accepted, and the same enumerable norm living in several seats. A product decision is a rule the product follows, a scope boundary, a threshold, a non-goal, or a behavior invariant. Decision records are optional; a product whose philosophy fits in `docs/steering/product.md` does not need them.

## Structure

The records are declared when `docs/steering/product.md §Decision Records` names a decisions root (default `docs/decisions/`); the template's bracketed placeholder is not a declaration. Never hardcode the root. Templates: `docs/settings/templates/decisions/`.

- `README.md` — index only: decision log (`ID | Decision | Keywords | File`) and Open Questions. No normative text.
- `<id>-<slug>.md` (template `decision.md`) — one topic per file (a file beyond ~100 lines opens with a table of contents): `keywords` line (the JIT grep index), Background (why), Decision (numbered items), optional Consequences, Registry refs (IDs only).
- `registry.md` — the sole seat of enumerable norms (§Registry).

**Committed text is in force**: an uncommitted edit or a README Open Question is not a decision.

## Change Control

The one protocol for changing steering (`docs/steering/`) and the decision records; humans may also edit them directly.

1. **Dirty check.** Before touching a file, `git status -- <file>`; uncommitted changes from outside this session are shown before anything else. Mark a file you create with `git add -N -- <file>`.
2. **Write only claims (`docs/settings/templates/decisions/change-review.md` step 1) whose source is U, A, D, R or F** (its step 2) — removals and rewrites included. Anything else is a proposal (`dialogue-grounding.md §Facts are yours, decisions are the user's`) and is not written.
3. **Review** a change that has claims as two independent runs (`concept-alignment.md §Independent Runs`) with `docs/settings/templates/decisions/change-review.md`, each handed only what its comment lists — one for provenance, one for consistency. When `bash docs/settings/scripts/session_record.sh dump` reports no session record, or it lacks the user's latest message, skip the provenance run and report the skip with its reason.
4. **Apply the verdicts.** In what this session wrote, undo every HOLD claim, and every LAND claim that lacks a quote — both quotes for A — that `bash docs/settings/scripts/session_record.sh verify` finds: delete only the words that carry it, and the whole sentence only when what remains no longer reads as one; for a `removed:` claim, restore the line. Put each ASK claim — after a skipped provenance run, each `removed:` claim — to the user as *previous → new*; without an explicit yes, undo it. The reviewer proposes no wording and you apply none: a claim lands as written or is undone.
5. **Report**, per file: the number of claims landed and undone, one line per decision item or section naming what was undone, the ASK answers, and the conflicts both runs list (`document-hygiene.md §After a Change`) — or the provenance run's skip. Nothing changed → no report.
6. **Commit** as its own commit, listing only the files this session edited: `git commit -m "docs(decisions): <phase> <topic>" -- <files>` (`docs(steering):` for steering). Never `git add` the decisions root or `docs/steering/`. `/sdd-spec-design`, `/sdd-spec-done` Step 6 and `/sdd-decision` first ask once — commit? — and on no revert with `git checkout -- <edited files>` and `git rm -f -- <created files>`.

## Registry

Line: **a set whose members downstream cites by name is registry; a classification whose *n* is itself the decision stays in prose.** One section per domain, one row per norm:

`| ID | Norm | Grounds | Used by |`

- **ID** `<DOMAIN>-<NN>`.
- **Norm** — 1–2 lines; longer is prose (put it in a decision file and cite the ID).
- **Grounds** — a relative Markdown link to the decision item or spec it derives from (the link check verifies it resolves).
- **Used by** — fixed vocabulary, space-separated: `code: <path Symbol>` · `spec: <feature-dir-name>` (directory *name*, not path — specs move from `todo/` to `done/`) · `plan: <plan-id/Un>` · `—`. Written at the phase that adopts the ID (plan / requirements / spec-done). `check_decisions.sh used-by` verifies each entry resolves and classifies: `code:` present or `spec:` in `done/` = implemented; `spec:` in `todo/` or `plan:` = planned; `—` = unadopted.

Prose cites IDs and never restates a list; an enumeration outside the registry is a Warning (check d).

**Controlled vocabulary.** When the product controls its terminology, the vocabulary lives here as the `TERM` domain — one row per concept. The Norm cell uses the fixed form `**<canonical term>** — <one-line definition>. 禁止＝<synonym>, <synonym>` (label `禁止＝` or `banned=`; this is what the checks parse). Adding, renaming, or re-banning a term is a Norm change. `check_decisions.sh check` greps the decisions root, steering, plans and `docs/specs/todo/` for banned terms (e) and verifies each canonical term is reachable through some decision's `keywords` line (f); `check_decisions.sh terms-prh` emits the vocabulary as a [prh](https://github.com/prh/prh) rule file for optional textlint integration.

**Behavior invariants.** The product's behavior invariants live here as the `INV` domain, one row per invariant. `Used by` names the spec that established it (`spec:`) and, when a test verifies it, that test (`code: <test file> <test name>`).

## Drafting Discipline

Five heuristics: (1) merge into an existing seat before creating a new one; (2) propose grounds from measurement — grep the code and the documents that cite it, don't recall, and cite an outside fact from `docs/reference/` (`evidence-discipline.md §5`); (3) do not record a policy declaration that specifies nothing concrete; (4) when a draft needs an exception or exemption note, first look for a form that makes it unnecessary; (5) one fact, one seat (`document-hygiene.md`).

## Loading

Always-loaded: `product.md §Decision Records` and the README index. A product-intent check also reads the registry's `INV` section. Everything else is JIT — grep `keywords` lines, open only the files that hit.

## Checks

`docs/settings/scripts/check_decisions.sh check` (registry-ID resolution, link liveness, `keywords` presence, enumerations outside the registry, banned terms from the `TERM` domain, canonical-term keywords coverage) reports and never blocks; run it in `/sdd-spec-done` and `/sdd-decision`. `commit-scope` is an optional pre-commit hook (`docs/settings/scripts/pre-commit.example`) that flags a decision change bundled with other files. Do not edit the script per project — configure by arguments; `/sdd-init` overwrites it.

## Adoption

Bringing an existing document set under the decision records: move it in **file by file** and fix files when you touch them. No item-level inventory or per-item review.
