---
description: Initialize SDD (Spec-Driven Development) in the current project
allowed-tools: Bash, Read, Write, Edit, Glob
argument-hint: [--lang=ja]
---

# SDD Project Initialization

<background_information>

- **Mission**: Set up Spec-Driven Development infrastructure in the current project by deploying rules, templates, commands, and project configuration from user-level SDD resources
- **Success Criteria**:
  - All SDD directory structures created (`docs/settings/`, `docs/steering/`, `docs/tasks/`, `.claude/commands/sdd/`)
  - Rules and templates deployed to `docs/settings/`
  - SDD commands deployed to `.claude/commands/sdd/`
  - Steering stubs initialized in `docs/steering/`
  - CLAUDE.md updated with SDD configuration section
  - Language configuration applied throughout

</background_information>

<instructions>

## Core Task

Initialize SDD infrastructure in the current project using resources from `$HOME/.claude/commands/sdd/`.

## Argument Parsing

- `--lang=<code>`: ISO 639-1 language code (default: `ja`)
  - Determines the `language` field in `docs/settings/templates/specs/init.json`
  - Determines the language instruction appended to CLAUDE.md
  - Derive the full language name from the code (e.g., `ja` → `Japanese`, `en` → `English`, `ko` → `Korean`, `zh` → `Chinese`)

## Execution Steps

### Step 0: Pre-flight Checks

1. **Verify Git Repository Root**: Check that `.git/` exists in the current working directory. If not, stop with error (see Safety & Fallback).

2. **Detect Existing SDD Setup**: Check if `docs/settings/` directory exists.
   - **If exists**: Inform the user that SDD is already initialized and ask how to proceed:
     - **Update**: Overwrite rules, templates, and commands. Preserve `docs/steering/` and `docs/tasks/` content.
     - **Full Reinitialize**: Overwrite rules, templates, commands, and steering stubs. Preserve `docs/tasks/` only.
     - **Cancel**: Abort initialization.
   - **If not exists**: Proceed with fresh initialization (no prompt needed).

3. **Check .gitignore**: If `.claude/` is matched by `.gitignore`, warn the user that project-level SDD commands will not be tracked by git. Suggest reviewing `.gitignore` if version control of commands is desired.

### Step 1: Create Directory Structure

Create all required directories using `mkdir -p`:

```
docs/
├── settings/
│   ├── rules/
│   └── templates/
│       ├── specs/
│       ├── steering/
│       └── steering-custom/
├── steering/
└── tasks/
    ├── done/
    └── todo/
.claude/
└── commands/
    └── sdd/
```

### Step 2: Deploy Rules

Copy all rule files from user-level to project:

- **Source**: `$HOME/.claude/commands/sdd/rules/*.md`
- **Target**: `docs/settings/rules/`

Expected files (9):
- design-discovery-full.md
- design-discovery-light.md
- design-principles.md
- design-review.md
- ears-format.md
- gap-analysis.md
- steering-principles.md
- tasks-generation.md
- tasks-parallel-analysis.md

### Step 3: Deploy Templates

Copy all template files from user-level to project:

| Source | Target |
|---|---|
| `$HOME/.claude/commands/sdd/templates/specs/*` | `docs/settings/templates/specs/` |
| `$HOME/.claude/commands/sdd/templates/steering/*` | `docs/settings/templates/steering/` |
| `$HOME/.claude/commands/sdd/templates/steering-custom/*` | `docs/settings/templates/steering-custom/` |

**Post-copy**: Read `docs/settings/templates/specs/init.json` and update the `"language"` field to the value specified by `--lang`. Write the updated content back.

### Step 4: Initialize Steering Stubs

For each file in `docs/settings/templates/steering/` (`product.md`, `structure.md`, `tech.md`):

- If `docs/steering/<filename>` does **NOT** exist: Copy the template as an initial stub
- If `docs/steering/<filename>` **already exists**: Skip (preserve user content)

### Step 5: Deploy SDD Commands

Copy SDD command files from user-level to project:

- **Source**: `$HOME/.claude/commands/sdd/*.md`
- **Target**: `.claude/commands/sdd/`
- **Exclude**: `sdd-init.md` (initialization command remains user-level only)

Expected files (12):
- spec-design.md
- spec-impl.md
- spec-init.md
- spec-requirements.md
- spec-status.md
- spec-tasks.md
- steering.md
- steering-custom.md
- validate-design.md
- validate-gap.md
- validate-impl.md
- validate-tasks.md

### Step 6: Update CLAUDE.md

1. **Read template**: Load `$HOME/.claude/commands/sdd/templates/AGENTS.md`
2. **Replace placeholder**: Replace `{{DEFAULT_LANGUAGE_NAME}}` with the full language name derived from `--lang`
3. **Wrap with markers**:
   ```
   <!-- SDD:BEGIN -->
   [processed template content]
   <!-- SDD:END -->
   ```
4. **Apply to CLAUDE.md**:
   - **CLAUDE.md exists + markers found**: Replace content between `<!-- SDD:BEGIN -->` and `<!-- SDD:END -->` (inclusive) with new wrapped content
   - **CLAUDE.md exists + no markers**: Append wrapped content to end of file (with a preceding blank line)
   - **CLAUDE.md does not exist**: Create new file with wrapped content only

## Important Constraints

- DO NOT modify any files inside `docs/tasks/` (preserves existing specifications)
- DO NOT overwrite `docs/steering/*.md` files that already contain user content (Step 4 skip logic)
- Preserve all existing CLAUDE.md content outside `<!-- SDD:BEGIN -->` / `<!-- SDD:END -->` markers
- Use absolute paths for all file operations to ensure reliability
- Copy files individually using Read + Write (not Bash cp) to ensure content integrity and allow per-file error handling

</instructions>

## Tool Guidance

- Use **Glob** to discover files in source directories and check existing project structure
- Use **Read** to load source files (rules, templates, commands, AGENTS.md)
- Use **Write** to create new files in target directories
- Use **Edit** to update existing files (CLAUDE.md marker replacement, init.json language field)
- Use **Bash** only for `mkdir -p` directory creation and `.gitignore` checks (`git check-ignore`)

## Output Description

Provide output in the language derived from `--lang`:

1. **Initialization Summary**: Brief description of what was set up
2. **Deployed Components**:
   - Rules: X files deployed
   - Templates: X files deployed
   - Commands: X files deployed
   - Steering stubs: created / skipped (per file)
   - CLAUDE.md: created / updated / appended
3. **Configuration**: Language set to `<language name>` (`<code>`)
4. **Next Steps** (numbered action items):
   - Run `/sdd:steering` to generate project steering from codebase analysis
   - Run `/sdd:steering-custom` to add domain-specific steering (optional)
   - Run `/sdd:spec-init "description"` to start your first specification
5. **Created Directory Structure**: Show the final tree

**Format**: Concise Markdown, under 300 words

## Safety & Fallback

### Error Scenarios

**Not in Git Repository Root**:

- **Stop Execution**: Cannot proceed without git repository
- **User Message**: "SDD initialization must be run from the git repository root. Current directory does not contain `.git/`."
- **Suggested Action**: "Navigate to the repository root and retry"

**Existing SDD Setup Detected**:

- **Prompt User**: Ask to choose Update / Full Reinitialize / Cancel
- **Default Recommendation**: Update (safest, preserves user content)
- **Behavior by choice**:
  - Update: Steps 2, 3, 5, 6 execute (overwrite). Steps 1, 4 create only missing items.
  - Full Reinitialize: All steps execute. Step 4 overwrites steering stubs.
  - Cancel: Exit with no changes.

**File Copy Failure**:

- **Continue**: Report the specific file and error, continue with remaining files
- **Summary**: List all failures at the end of output
- **Suggested Action**: "Check file permissions or disk space"

**CLAUDE.md Marker Inconsistency**:

- **Detection**: `<!-- SDD:BEGIN -->` found without matching `<!-- SDD:END -->`, or vice versa
- **Action**: Warn user about malformed markers, append new complete marked section to end of file
- **User Message**: "Existing SDD markers in CLAUDE.md are malformed. New SDD section appended to end of file. Please manually remove the orphaned marker."

**.claude/ in .gitignore**:

- **Warning only**: "`.claude/` is excluded by .gitignore. Project-level SDD commands will not be version controlled. Review .gitignore if you want to track these files."
- **Do not modify .gitignore**: Leave the decision to the user
