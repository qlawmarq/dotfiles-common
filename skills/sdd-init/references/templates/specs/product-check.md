# Product Check

<!-- The implementer's record of the product check (docs/settings/rules/concept-alignment.md §Product Check).
Written by the implementer in the spec's last task, at `{spec_path}/probe/product-check-<k>.md`. -->

Start the product from its entry in its default configuration, as `concept-alignment.md §Product Check` (What is walked, Entry that cannot be operated) says; say which means you used.

1. Walk the paths this spec changed: the criteria and scenarios that can be reached from the product's entry. What cannot be reached that way goes under D.
2. Put what you met to the three questions of `concept-alignment.md §The Check`.

A main use that a person can only perform through a debug hook or your own script, because the product gives them no way to do it, is a finding. A clean result is a normal outcome. Every claim needs evidence — the command and its output, a log excerpt, a screenshot. Route each finding at once by `concept-alignment.md §Findings` and write its `Route:` line. Evidence and throwaway scripts go in `probe/product-check-<k>/` beside this record; `git status` shows nothing changed by you apart from this record, that directory and tasks.md.

## Report

Whatever language you write in, keep these as they are: the section letters A. to E., the `#### P<k>` headings, the `Findings: none` line, and the `Route:` line with its closure words.

### A. Run
Every command in a fenced code block, one per line; the configuration; how long; `git status` before and after.

### B. Walked
What you did from the product's entry, in order, along the paths this spec changed; each item names the criterion and scenario IDs it covered, e.g. `(1.2, S3)`. The section ends with the three questions of `concept-alignment.md §The Check`, answered for what you met.

### C. Findings
One `#### P<k>` heading per finding (k continues from this spec's earlier records), then the fields of the Finding Format in `concept-alignment.md` as plain lines (not fenced), then one line `- Route: <closure> — <where>` with a closure word of `concept-alignment.md §Findings` 4 or `open` (`- Route: open — the user`; `stands` and `open` point at the user's answer). Or the single line `Findings: none`.

### D. Not reached
Criteria and scenarios that cannot be reached from the product's entry, one line each with the ID and the reason.

### E. Questions for the user
What only a person can judge, where what you met leaves a real question: what to do, what to look for. None is a normal outcome.
