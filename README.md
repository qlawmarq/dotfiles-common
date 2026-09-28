# dotfiles-common

Common configurations shared across [dotfiles-linux](https://github.com/qlawmarq/dotfiles-linux) and [dotfiles-macos](https://github.com/qlawmarq/dotfiles-macos).

## Contents

### Cross-Agent Skills (Agent Skills Open Standard)

Reusable skills compatible with Claude Code, Codex CLI, and Gemini CLI.

## Installing the Skills

The `skills/` directory follows the layout the [`skills` CLI](https://github.com/vercel-labs/skills)
scans, so the skills can be installed into any supported agent without cloning this repository:

```bash
# Interactive: pick the skills and the agents to install into
npx skills add qlawmarq/dotfiles-common

# User-level, every skill, Claude Code only
npx skills add qlawmarq/dotfiles-common -g -a claude-code -s '*' -y

# Preview what would be installed
npx skills add qlawmarq/dotfiles-common --list
```

Notes:

- Only `skills/` is picked up. The Claude-only skills under `claude/skills/` are not
  installed this way.
- Do not run this on a machine where the dotfiles already link these skills into
  `~/.claude/skills` or `~/.agents/skills`: the CLI replaces a same-named link with a
  copy without asking, and edits made through the agent then no longer reach this repository
  until the next dotfiles apply moves the copy aside and restores the link.
- Read the skills before installing them; they run with the agent's permissions.

### Claude Code Configuration

- **settings.json**: Claude Code settings (permissions, model, hooks)
- **hooks/**: Hook scripts
  - `platform/macos/`: macOS-specific notification hooks
  - `platform/linux/`: Linux-specific hooks (reserved for future use)

### tmux Configuration

- **.tmux.conf**: Cross-platform tmux configuration with automatic clipboard detection (pbcopy/xclip/wl-copy)

## Syncing Upstream Skills

Some skills (e.g., `skill-creator`) are synced from external repositories. The sync configuration is defined in `upstream-skills.conf`.

```bash
# Preview changes
bash scripts/sync-upstream-skills.sh --dry-run

# Sync all upstream skills
bash scripts/sync-upstream-skills.sh

# Sync a specific skill
bash scripts/sync-upstream-skills.sh skill-creator
```

To add a new upstream skill, add an entry to `upstream-skills.conf`:

```
my-skill  https://github.com/org/repo  path/to/skill  main
```

The last column is the ref to fetch: a branch, a tag, or a full commit SHA. A SHA pins
the skill to that exact upstream commit.

`upstream-skills.lock` records the upstream commit each vendored skill was last synced
from (`<name> <sha> <date>`). The sync script writes it whenever a skill is applied, or
when the vendored copy already matches upstream, so a diff of the lock file in a commit
shows which upstream commits a sync moved between. Review the file diff before applying:
vendoring is the only step where upstream code enters this repository.

## Usage

This repository is designed to be used as a git submodule in platform-specific dotfiles repositories.

## Platform-Specific Dotfiles

- **Linux/WSL**: [dotfiles-linux](https://github.com/qlawmarq/dotfiles-linux)
- **macOS**: [dotfiles-macos](https://github.com/qlawmarq/dotfiles-macos)

## Structure

```
dotfiles-common/
├── skills/                 # Cross-agent skills (Agent Skills Open Standard)
├── claude/                 # Claude Code specific
│   ├── settings.json
│   ├── hooks/
│   └── skills/             # Claude-only skills
├── scripts/
│   └── sync-upstream-skills.sh  # Sync skills from upstream repos
├── upstream-skills.conf    # Upstream skill mappings
├── upstream-skills.lock    # Upstream commit each vendored skill was synced from
├── git/
└── tmux/
    └── .tmux.conf          # Cross-platform tmux config
```
