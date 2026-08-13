---
name: sdd-validate-gap
description: >-
  Analyze implementation gap between requirements and existing codebase.
  Evaluates multiple implementation approaches for brownfield projects.
argument-hint: "<feature-name>"
---

# Implementation Gap Validation

<background_information>

- **Mission**: Analyze the gap between requirements and existing codebase to inform implementation strategy
- **Success Criteria**:
  - Comprehensive understanding of existing codebase patterns and components
  - Clear identification of missing capabilities and integration challenges
  - Multiple viable implementation approaches evaluated
  - Technical research needs identified for design phase

</background_information>

<instructions>

## Input

This skill expects:
1. **Feature name** (required): The feature directory name in `docs/tasks/`

If inputs were provided with this skill invocation, use them directly.
Otherwise, ask the user for the feature name.

## Core Task

Analyze implementation gap for the specified feature based on approved requirements and existing codebase.

## Execution Steps

1. **Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

2. **Load Context**:
   - Read `{spec_path}/spec.json` for language and metadata
   - Read `{spec_path}/requirements.md` for requirements
   - **Load ALL steering context**: Read the entire `docs/steering/` directory — default and custom files alike, regardless of mode settings

3. **Read Analysis Guidelines**:
   - Read `docs/settings/rules/gap-analysis.md` for comprehensive analysis framework

4. **Execute Gap Analysis**:
   - Follow gap-analysis.md framework for thorough investigation
   - Analyze existing codebase using search and read tools
   - Use WebSearch/WebFetch for external dependency research if needed
   - Evaluate multiple implementation approaches (extend/new/hybrid)
   - Use language specified in spec.json for output

5. **Generate Analysis Document**:
   - Write the analysis to `{spec_path}/gap-analysis.md`, following the output guidelines in gap-analysis.md
   - Present multiple viable options with trade-offs
   - Flag areas requiring further research

   This file is what carries the analysis into the next phase: `/sdd-spec-research` reads `{spec_path}/gap-analysis.md` if it is there. This skill is optional — when it is skipped the file simply does not exist, and research proceeds without it. Do NOT modify spec.json; the file's existence is the only record that gap analysis ran.

## Important Constraints

- **Information over Decisions**: Provide analysis and options, not final implementation choices
- **Multiple Options**: Present viable alternatives when applicable
- **Thorough Investigation**: Use tools to deeply understand existing codebase
- **Explicit Gaps**: Clearly flag areas needing research or investigation

</instructions>

## Tool Guidance

- **Read first**: Load all context (spec, steering, rules) before analysis
- **Search extensively**: Examine codebase for patterns, conventions, and integration points
- **WebSearch/WebFetch**: Research external dependencies and best practices when needed
- **Write last**: Generate analysis only after complete investigation

## Output Description

Provide output in the language specified in spec.json with:

1. **Analysis Summary**: Brief overview (3-5 bullets) of scope, challenges, and recommendations
2. **Document Status**: Confirm the analysis was written to `{spec_path}/gap-analysis.md`
3. **Next Steps**: Guide user on proceeding to the research phase (`/sdd-spec-research`), which precedes design in the workflow

**Format Requirements**:

- Keep the chat summary concise (under 300 words); the full analysis lives in `gap-analysis.md`
- Detailed analysis follows gap-analysis.md output guidelines

## Safety & Fallback

### Error Scenarios

- **Missing Requirements**: If requirements.md doesn't exist, stop with message: "Run `/sdd-spec-requirements <feature-name>` first to generate requirements"
- **Requirements Not Approved**: If requirements not approved, warn user but proceed (gap analysis can inform requirement revisions)
- **Empty Steering Directory**: Warn user that project context is missing and may affect analysis quality
- **Complex Integration Unclear**: Flag for comprehensive research in design phase rather than blocking
- **Language Undefined**: If spec.json omits `language`, fall back to `docs/settings/templates/specs/init.json` `language`, then to `ja` (the `/sdd-init` default)

### Next Phase: Research & Discovery

The workflow is **Requirements → Behaviors → Gap (optional) → Research → Validate Research → Design → Tasks**. Gap analysis surfaces "Research Needed" items; the research phase resolves them and `/sdd-validate-research` checks that they were actually resolved rather than assumed. Do NOT skip research and jump to design.

**If Gap Analysis Complete**:

- Review gap analysis insights, especially the "Research Needed" items
- Run `/sdd-spec-research <feature-name>` to investigate the open unknowns and generate `research.md` (research & discovery)
- Then run `/sdd-spec-design <feature-name>` to create the technical design document (use `-y` only for intentional fast-track / to auto-approve requirements)

**Note**: Gap analysis is optional but recommended for brownfield projects to inform research and design decisions.
