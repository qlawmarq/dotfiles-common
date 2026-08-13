# Document Hygiene

Applies to every document an SDD skill writes. Three failures with one cause: a fact written where it does not belong.

- **One fact, one seat.** Approval and status facts live in their seat and nowhere else — a spec's approvals in `spec.json`, a proposal's state in its `status:` value alone, a ratification in the Ratification Record and the item's status marker. Never write a dated approval note into body prose ("2026-08-12 confirmed by user"); the seat already holds it, and the copy is what later contradicts the original.
- **Never restate the adjacent structure.** What a table, diagram, or parent section already says is not repeated in the prose beside it. Reference it and add only what it does not carry.
- **Scaffolding stays out of the product.** Template comments, restatements of the rule being followed, and sections nobody asked for (session statistics, meta-narration) are drafting aids. Delete them before the file is written.

Brevity is not the goal — a fact stated once, in the right place, is. Delete the copy, not the original.
