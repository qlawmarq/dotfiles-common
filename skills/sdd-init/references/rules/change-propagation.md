# Change Propagation

Whatever you change, the documents in the right-hand column follow it — carried through by whoever made the change, in the same turn. Nothing is left for a later pass to reconcile. `/sdd-spec-done` 2b (criteria audit) and 2c (design alignment) are the completion check for the "Code" row.

| What changed | What must follow |
| --- | --- |
| An acceptance criterion in requirements.md | The behaviors.md Scenarios whose `Grounds:` cite that requirement / its row in design.md's Requirements Traceability table / the `_Requirements:` lines in tasks.md / the code, if already implemented (a fix task) |
| A contract or structure in design.md | The tasks in tasks.md that touch that component / the behaviors.md Scenarios whose behavior changes / the code, if already implemented (a fix task) |
| A Scenario in behaviors.md | How design.md realizes it / its verification task in tasks.md |
| Canon or steering | The criteria that inherit it (`/sdd-spec-done` class D) / design.md's Steering compliance |
| A unit boundary or order in the inception plan | Each affected spec's spec.json `plan` / its requirements.md scope |
| Code (implemented differently from design) | Fix design.md (the deviation is approved) or add a fix task (it is sent back). Never leave it as neither |
