---
name: sdd-init
description: >-
  Initialize SDD (Spec-Driven Development) in the current project.
  Deploys rules, templates, skills, and project configuration from user-level SDD resources.
argument-hint: "[--lang=ja]"
---

# SDD Project Initialization

<background_information>

- **Mission**: Set up Spec-Driven Development infrastructure in the current project by deploying rules, templates, skills, and project configuration from user-level SDD resources
- **Success Criteria**:
  - All SDD directory structures created (`docs/settings/`, `docs/steering/`, `docs/tasks/`)
  - Rules and templates deployed to `docs/settings/`
  - SDD skills deployed to `.claude/skills/sdd-*/` and `.agents/skills/sdd-*/`
  - Steering stubs initialized in `docs/steering/`
  - CLAUDE.md and AGENTS.md updated with SDD configuration section
  - Language configuration applied throughout

</background_information>

<instructions>

## Input

This skill expects:
1. **Language flag** (optional): `--lang=<code>` — ISO 639-1 language code (default: `ja`)

If inputs were provided with this skill invocation, use them directly.
Otherwise, use the default language (`ja`).

## Source Files Location

SDD resources (rules, templates, skill files) are stored alongside this skill file.
Find them by checking these paths in order:

1. `${CLAUDE_SKILL_DIR}/references/` (Claude Code - auto-resolved)
2. `~/.claude/skills/sdd-init/references/` (Claude Code fallback)
3. `~/.agents/skills/sdd-init/references/` (Codex CLI / Gemini CLI)

Use the first path that exists and contains the expected subdirectories
(`rules/` and `templates/`). If none found, report an error.

## Core Task

Initialize SDD infrastructure in the current project using the resolved source path.

## Argument Parsing

- `--lang=<code>`: ISO 639-1 language code (default: `ja`)
  - Determines the `language` field in `docs/settings/templates/specs/init.json`
  - Determines the language instruction appended to CLAUDE.md and AGENTS.md
  - Derive the full language name from the code (e.g., `ja` → `Japanese`, `en` → `English`, `ko` → `Korean`, `zh` → `Chinese`)

## Execution Steps

### Step 0: Pre-flight Checks

1. **Verify Git Repository Root**: Check that `.git/` exists in the current working directory. If not, stop with error (see Safety & Fallback).

2. **Detect Existing SDD Setup**: Check if `docs/settings/` directory exists.
   - **If exists**: Inform the user that SDD is already initialized and ask how to proceed:
     - **Update**: Overwrite rules, templates, and skills. Preserve `docs/steering/` and `docs/tasks/` content.
     - **Full Reinitialize**: Overwrite rules, templates, skills, and steering stubs. Preserve `docs/tasks/` only.
     - **Cancel**: Abort initialization.
   - **If not exists**: Proceed with fresh initialization (no prompt needed).

3. **Check .gitignore**: If `.claude/` is matched by `.gitignore`, warn the user that project-level SDD skills will not be tracked by git. Suggest reviewing `.gitignore` if version control of skills is desired.

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
```

### Step 2: Deploy Rules

Copy all rule files from the resolved source path to project:

- **Source**: `<source_path>/rules/*.md`
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

Copy all template files from the resolved source path to project:

| Source | Target |
|---|---|
| `<source_path>/templates/specs/*` | `docs/settings/templates/specs/` |
| `<source_path>/templates/steering/*` | `docs/settings/templates/steering/` |
| `<source_path>/templates/steering-custom/*` | `docs/settings/templates/steering-custom/` |

**Post-copy**: Read `docs/settings/templates/specs/init.json` and update the `"language"` field to the value specified by `--lang`. Write the updated content back.

### Step 4: Initialize Steering Stubs

For each file in `docs/settings/templates/steering/` (`product.md`, `structure.md`, `tech.md`):

- If `docs/steering/<filename>` does **NOT** exist: Copy the template as an initial stub
- If `docs/steering/<filename>` **already exists**: Skip (preserve user content)

### Step 5: Deploy SDD Skills to Project

Deploy SDD skill files to project for team access.

**Source detection**: Find `sdd-*` skill directories (excluding `sdd-init`) from:
1. `~/.claude/skills/` (Claude Code)
2. `~/.agents/skills/` (Codex CLI / Gemini CLI)

Use whichever location contains `sdd-spec-init/SKILL.md`.

**Deployment targets** (deploy to BOTH for cross-agent compatibility):
- `.claude/skills/<skill-name>/SKILL.md` (Claude Code)
- `.agents/skills/<skill-name>/SKILL.md` (Codex CLI / Gemini CLI)

Expected skills (12):
- sdd-spec-init
- sdd-spec-requirements
- sdd-spec-design
- sdd-spec-tasks
- sdd-spec-impl
- sdd-spec-status
- sdd-steering
- sdd-steering-custom
- sdd-validate-design
- sdd-validate-gap
- sdd-validate-impl
- sdd-validate-tasks

For each skill, create the target directory and copy the SKILL.md file.

### Step 6: Update Agent Configuration Files

1. **Read template**: Load the AGENTS.md template from SDD resources
   (see Source Files Location for path resolution)

2. **Replace placeholder**: Replace `{{DEFAULT_LANGUAGE_NAME}}` with the full language name derived from `--lang`

3. **Deploy to CLAUDE.md**:
   - Wrap with `<!-- SDD:BEGIN -->` / `<!-- SDD:END -->` markers
   - CLAUDE.md exists + markers found: Replace content between markers (inclusive)
   - CLAUDE.md exists + no markers: Append wrapped content
   - CLAUDE.md does not exist: Create new file with wrapped content

4. **Deploy to AGENTS.md** (project root, for Codex CLI):
   - Same marker-based injection approach as CLAUDE.md
   - Create file if it doesn't exist

## Important Constraints

- DO NOT modify any files inside `docs/tasks/` (preserves existing specifications)
- DO NOT overwrite `docs/steering/*.md` files that already contain user content (Step 4 skip logic)
- Preserve all existing CLAUDE.md content outside `<!-- SDD:BEGIN -->` / `<!-- SDD:END -->` markers
- Preserve all existing AGENTS.md content outside `<!-- SDD:BEGIN -->` / `<!-- SDD:END -->` markers
- Use absolute paths for all file operations to ensure reliability
- Copy files individually using Read + Write (not Bash cp) to ensure content integrity and allow per-file error handling

</instructions>

## Tool Guidance

- Use file search tools to discover files in source directories and check existing project structure
- Read source files (rules, templates, skills, AGENTS.md template)
- Write to create new files in target directories
- Edit to update existing files (CLAUDE.md/AGENTS.md marker replacement, init.json language field)
- Use Bash only for `mkdir -p` directory creation and `.gitignore` checks (`git check-ignore`)

## Output Description

Provide output in the language derived from `--lang`:

1. **Initialization Summary**: Brief description of what was set up
2. **Deployed Components**:
   - Rules: X files deployed
   - Templates: X files deployed
   - Skills: X skills deployed (to both `.claude/skills/` and `.agents/skills/`)
   - Steering stubs: created / skipped (per file)
   - CLAUDE.md: created / updated / appended
   - AGENTS.md: created / updated / appended
3. **Configuration**: Language set to `<language name>` (`<code>`)
4. **Next Steps** (numbered action items):
   - Run `/sdd-steering` to generate project steering from codebase analysis
   - Run `/sdd-steering-custom` to add domain-specific steering (optional)
   - Run `/sdd-spec-init "description"` to start your first specification
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

**CLAUDE.md / AGENTS.md Marker Inconsistency**:

- **Detection**: `<!-- SDD:BEGIN -->` found without matching `<!-- SDD:END -->`, or vice versa
- **Action**: Warn user about malformed markers, append new complete marked section to end of file
- **User Message**: "Existing SDD markers are malformed. New SDD section appended to end of file. Please manually remove the orphaned marker."

**.claude/ in .gitignore**:

- **Warning only**: "`.claude/` is excluded by .gitignore. Project-level SDD skills will not be version controlled. Review .gitignore if you want to track these files."
- **Do not modify .gitignore**: Leave the decision to the user

**Source Files Not Found**:

- **Stop Execution**: Cannot proceed without SDD resources
- **User Message**: "SDD resources not found. Ensure SDD skills are installed at user level (run dotfiles apply.sh with claude module)."
