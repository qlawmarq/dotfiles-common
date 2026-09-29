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

## Available Templates

Templates available in `docs/settings/templates/steering-custom/`:

1. **api-standards.md** - REST/GraphQL conventions, error handling
2. **testing.md** - Test organization, mocking, coverage
3. **security.md** - Auth patterns, input validation, secrets
4. **database.md** - Schema design, migrations, query patterns
5. **error-handling.md** - Error types, logging, retry strategies
6. **authentication.md** - Auth flows, permissions, session management
7. **deployment.md** - CI/CD, environments, rollback procedures

Load template when needed, customize for project.

</instructions>

## Tool guidance

- **Read**: Load template, analyze existing code
- **File search**: Find related files for pattern analysis
- **Search**: Look for specific patterns in the codebase

**JIT Strategy**: Load template only when creating that type of steering.

## Output description

Write the steering document and this summary in the project's language: `docs/settings/templates/specs/init.json` `language`, else `ja`. The template's section headings are scaffolding — translate them.

Chat summary with file location.

```
✅ Custom Steering Created

## Created:
- docs/steering/api-standards.md

## Based On:
- Template: api-standards.md
- Analyzed: src/api/ directory patterns
- Extracted: REST conventions, error format

## Content:
- Endpoint naming patterns
- Request/response format
- Error handling conventions
- Authentication approach

Review and customize as needed.
```

## Examples

### Success: API Standards

**Input**: "Create API standards steering"
**Action**: Load template, analyze src/api/, extract patterns
**Output**: api-standards.md with project-specific REST conventions

### Success: Testing Strategy

**Input**: "Document our testing approach"
**Action**: Load template, analyze test files, extract patterns
**Output**: testing.md with test organization and mocking strategies

## Safety & Fallback

- **No template**: Generate from scratch based on domain knowledge
