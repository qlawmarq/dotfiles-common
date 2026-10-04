---
name: sdd-steering
description: >-
  Manage docs/steering/ as persistent project knowledge.
  Bootstraps steering from codebase analysis or syncs existing steering with code changes.
---

# Steering Management

<background_information>

**Role**: Maintain `docs/steering/` as persistent project memory.

**Mission**:

- Bootstrap: Generate core steering from codebase (first-time)
- Sync: Keep steering and codebase aligned (maintenance)

**Success Criteria**:

- Code drift detected and reported

</background_information>

<instructions>

## Scenario Detection

Check `docs/steering/` status:

**Bootstrap Mode**: Empty OR missing core files (product.md, tech.md, structure.md)
**Sync Mode**: All core files exist

> **Scope**: the whole codebase — the initial bootstrap and periodic broad reviews (after several merges, a refactor, or an architecture change). `/sdd-spec-done` applies the same rules to what one feature changed.

---

## Bootstrap Flow

1. Load `docs/settings/rules/steering-principles.md`, `docs/settings/rules/document-hygiene.md`, and the templates in `docs/settings/templates/steering/`
2. Analyze codebase (JIT):
   - Use file search tools to find source files
   - Read the README and build manifests
   - Search for patterns in the codebase
3. Extract what passes `§Admission`, into the files `§File focus` assigns
4. Propose the files (following the templates), confirm, write, and commit per `steering-principles.md §Updating`

---

## Sync Flow

1. Load all existing steering (`docs/steering/*.md`) and the rules from Bootstrap step 1
2. Analyze codebase for changes (JIT)
3. Detect drift:
   - **Steering → Code**: Missing elements → Warning
   - **Code → Steering**: New patterns → Update candidate
   - **Existing lines**: facts that changed, or that now fail `§Admission` → Replace or delete candidate
   - **behaviors.md**: Invariants whose `Grounds:` or `Verify:` pointers no longer resolve, or that a canon change has superseded → Warning
   - **Custom files**: Check relevance
4. Total the lines against `steering-principles.md §Budget`
5. Propose, confirm, and commit per `§Updating`
6. Report: Updates, warnings, recommendations

</instructions>

## Output description

Write the steering documents and this summary in the project's language: `docs/settings/templates/specs/init.json` `language`. The templates' section headings are scaffolding — translate them.

Chat summary only.

### Bootstrap:

```
✅ Steering Created

## Generated:
- product.md: [Brief description]
- tech.md: [Key stack]
- structure.md: [Organization]

Confirmed and committed per steering-principles.md §Updating.
```

### Sync:

```
✅ Steering Updated

## Changes:
- tech.md: State management decision replaced
- structure.md: Added API pattern

## Budget: N lines (steering-principles.md §Budget)

## Code Drift:
- Components not following import conventions

## Recommendations:
- Consider api-standards.md
```

## Safety & Fallback

- **Uncertainty**: Report both states, ask user

## Notes

- Templates and principles are external for customization
