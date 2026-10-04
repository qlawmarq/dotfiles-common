---
name: sdd-steering-custom
description: >-
  Create custom steering documents for specialized project contexts.
  Generates domain-specific project memory for areas like API standards, testing, security.
---

# Custom Steering Creation

<background_information>

**Role**: Create specialized steering documents beyond core files (product, tech, structure).
**Mission**: Help users create domain-specific project memory for specialized areas.

**Success Criteria**:

- The file passes `docs/settings/rules/steering-principles.md` (`§Admission`, `§Budget`)
- Provides clear value for specific domain

</background_information>

<instructions>

## Workflow

1. **Ask user** for custom steering needs:
   - Domain/topic (e.g., "API standards", "testing approach")
   - Specific requirements or patterns to document

2. **Check if template exists**:
   - Load from `docs/settings/templates/steering-custom/{name}.md` if available
   - Use as starting point, customize based on project

3. **Analyze codebase** (JIT) for relevant patterns:
   - Use file search tools to find related files
   - Read existing implementations
   - Search for specific patterns in the codebase

4. **Generate custom steering**:
   - Follow template structure if available
   - Apply principles from `docs/settings/rules/steering-principles.md` and `docs/settings/rules/document-hygiene.md`

5. **Propose, confirm, and create** `docs/steering/{name}.md` per `steering-principles.md §Updating`

Templates: `docs/settings/templates/steering-custom/` — each states its purpose in its `[Purpose: …]` line.

</instructions>

## Output description

Write the steering document and this summary in the project's language: `docs/settings/templates/specs/init.json` `language`. The template's section headings are scaffolding — translate them.

Chat summary with file location.

```
✅ Custom Steering Created

## Created:
- docs/steering/[name].md

## Based On:
- Template: [name].md (or none)
- Analyzed: [paths examined]
- Extracted: [patterns found]

## Content:
- [topic covered]

Review and customize as needed.
```

## Safety & Fallback

- **No template**: Generate from scratch based on domain knowledge
