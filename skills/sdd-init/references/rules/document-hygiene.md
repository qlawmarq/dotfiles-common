# Document Hygiene

Applies to every document an SDD skill writes. Every failure in the list below has one cause: a fact written where it does not belong.

- **One fact, one seat.** A fact or a definition — a decision, a rule, an enumeration, a status — is written in one document, the way a type is declared once; every other document names that seat (file and section, or ID) and adds only what is its own. A restated definition is a second definition: the two drift apart, and a change to the first never reaches the readers of the second. Approval and status facts follow the same rule — a spec's approvals in `spec.json`, a document's history in `git log`, an open question in the canon README's table. Never write a dated approval note into body prose ("<date> confirmed by user"), a revision-history section, or an "added after …" note; the seat already holds it, and the copy is what later contradicts the original. The same goes for crediting a ruling in body prose ("(User-confirmed <date> · <role>)", "<role> ruling <date>") — state the decision, not who made it or when.
- **One contract, one seat.** A contract — a signature, field, value, threshold or branch rule — has one seat: the block of the component that owns it in design.md; flows, overviews, tables, diagrams and tasks name it and never restate its content.
- **Never restate the adjacent structure.** What a table, diagram, or parent section already says is not repeated in the prose beside it. Reference it and add only what it does not carry.
- **One concept, one term.** Before coining a word for something, grep for the term the documents already use and reuse it — a near-synonym is a defect, not a style choice. When the project keeps a controlled vocabulary (registry `TERM` domain, `canon-layer.md §Registry`), a rejected synonym is registered there as a banned term so the machine check catches its next occurrence.
- **A rename replaces every live occurrence.** No "(formerly X)" labels, no transitional aliases: grep the live layers and replace completely; records keep the old name (both: §After a Change) — git history and the archive resolve it.
- **Scaffolding stays out of the product.** Template comments, restatements of the rule being followed, and sections nobody asked for (session statistics, meta-narration) are drafting aids. Delete them before the file is written.

Brevity is not the goal — a fact stated once, in the right place, is. Delete the copy, not the original.

## After a Change

The live layers are every document that is not a record. A record — a done spec, an archive, a run's result once a document cites it — is not edited; a later record is added beside it, and what the result now means is said in the document that cites it.

Whoever changes a document, or the code or product it describes, carries the change, in the same turn, to every document in the live layers that cites the changed item — `bash docs/settings/scripts/check_refs.sh refs <item>` lists what it can resolve; grep the ID, number or term for the rest. Code that implements the changed item follows through a tracked change — in this workflow a fix task or a `fix` spec (`concept-alignment.md §Findings`) — never as a silent edit. A follower that is the user's to change goes to the user in the same turn.

## Mechanical Check

`check_refs.sh check` lists references whose seat does not exist; `check_refs.sh unused` lists the documents no other document cites (entry files apart; records count as citers only with `--include-records`). Neither sees a definition restated in a second seat; that is found by reading.
