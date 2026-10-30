# Task Generation Rules

## Core Principles

### 1. Natural Language Descriptions

Focus on capabilities and outcomes, not code structure.

**Describe**:

- What functionality to achieve
- Business logic and behavior
- Features and capabilities
- Domain language and concepts
- Data relationships and workflows

**Avoid**:

- File paths and directory structure
- Function/method names and signatures
- Type definitions and interfaces
- Class names and API contracts
- Specific data structures

**Rationale**: Implementation details (methods, types, contracts) are defined in design.md. Tasks describe the functional work to be done.

A detail bullet names the design block it realizes (for example `per design §<ComponentName>`) — the block is the contract's seat (`document-hygiene.md`, one contract, one seat).

### 2. Task Integration & Progression

**Every task must**:

- Build on previous outputs (no orphaned code)
- Connect to the overall system (no hanging features)
- Progress incrementally (no big jumps in complexity)
- Validate core functionality early in sequence
- Respect the architecture boundaries the design defines
- Honor interface contracts documented in design.md

**End with integration tasks** to wire everything together, before the product-check task (§5).

### 3. Flexible Task Sizing

**Guidelines**:

- **Major tasks**: As many sub-tasks as logically needed (group by cohesion)
- **Sub-tasks**: 1-3 hours each, 3-10 details per sub-task
- Balance between too granular and too broad

**Don't force arbitrary numbers** - let logical grouping determine structure.

### 4. Requirements Mapping

**End each task detail section with**:

- `_Requirements: X.X, Y.Y_` — criterion IDs; `ears-format.md` §Requirement IDs holds their form, how they are cited, and the stop when requirements.md has none.
- For cross-cutting requirements, list every relevant criterion ID.

### 5. Code-Only Focus

**Include only**:

- Coding tasks (implementation)
- Testing tasks requiring separate execution (§6)
- Technical setup tasks (infrastructure, configuration)
- The product check, as the last task, when the kind's completion checks (`spec-kinds.md` §4) list `product-check` — its definition is `concept-alignment.md §Product Check`; its `_Requirements:` lists the criteria reachable from the product's entry, e.g. `- [ ] 4. Product check: walk the changed paths from the product's entry`

**Exclude**:

- Unit tests covered by TDD cycles (§6)
- Deployment tasks
- Documentation tasks
- Asking the user to look at the product for a `user` scenario — asked at completion (`concept-alignment.md §User Check`), never a task an agent completes
- Marketing/business activities

`verify`: tasks are per `tasks-verify.md`; §1's file-path avoidance (records go to `probe/…`), §2's integration ending and §5 do not apply. `chore`: the deliverable itself (documents, configuration, data) is the task's work; §5's exclusion of documentation tasks does not apply. Neither has a product-check task.

### 6. TDD Test Deduplication

Unit tests naturally covered by the TDD cycle (Red-Green-Refactor) in the implementation phase are never generated as independent sub-tasks.

**Principles**:

- Integration tests, E2E tests, and performance tests that require separate execution outside TDD cycles are still generated as independent tasks
- Describe behaviors to verify as regular detail items, not with a "Unit test:" label

**Examples**:

❌ Before:
- `Unit test: forward lookup for all mapping entries, fallback for unknown keys`

✅ After:
- `Forward lookup for all mapping entries and fallback for unknown keys work correctly`

## Task Hierarchy Rules

### Maximum 2 Levels

- **Level 1**: Major tasks (1, 2, 3, 4...)
- **Level 2**: Sub-tasks (1.1, 1.2, 2.1, 2.2...)
- **No deeper nesting** (no 1.1.1)
- If a major task would contain only a single actionable item, collapse the structure and promote the sub-task to the major level (e.g., replace `1.1` with `1.`).
- When a major task exists purely as a container, keep the checkbox description concise and avoid duplicating detailed bullets—reserve specifics for its sub-tasks.

### Sequential Numbering

- Major tasks increment: 1, 2, 3, 4, 5...
- Sub-tasks reset per major task: 1.1, 1.2, then 2.1, 2.2...

### Checkbox Format

```markdown
- [ ] 1. Major task description
- [ ] 1.1 Sub-task description
  - Detail item 1
  - Detail item 2
  - _Requirements: X.X_

- [ ] 1.2 Sub-task description
  - Detail items...
  - _Requirements: Y.Y_

- [ ] 1.3 Sub-task description
  - Detail items...
  - _Requirements: Z.Z, W.W_

- [ ] 2. Next major task (never 1 again)
- [ ] 2.1 Sub-task...
```

A completed task with a `_Requirements:` line also carries an `_Evidence:` line inside its block (the lines from its `- [x]` line up to the next line starting with `- [`), at the indentation of `_Requirements:`:

```markdown
  - _Requirements: 1.2, 3.5_
  - _Evidence: `test_name`, `probe/run-1.md`, `probe/product-check-1.md`_
```

Implementation writes it when it marks the task `[x]`; task generation never does. Its backticked tokens take the pointer forms of `behavior-formulation.md §Verification Mapping`.

## Requirements Coverage

**Mandatory Check**:

- Every requirement in requirements.md is covered by at least one task
- Review any designs with ambiguous work content
- Split any tasks with excessive workload
- Cross-reference every criterion ID with task mappings
- If gaps found: Return to requirements or design phase

A criterion no task cites is raised to the user at completion, to fix the criterion or add a task; nothing is deferred silently.
