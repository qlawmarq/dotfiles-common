# dotfiles-common

Common configurations shared across [dotfiles-linux](https://github.com/qlawmarq/dotfiles-linux) and [dotfiles-macos](https://github.com/qlawmarq/dotfiles-macos).

## Contents

### Cross-Agent Skills (Agent Skills Open Standard)

Reusable skills compatible with Claude Code, Codex CLI, and Gemini CLI.

### Claude Code Configuration

- **tools/**: Additional tool integrations
- **settings.json**: Claude Code settings with permission automation
- **hooks/**: Hook scripts
  - `auto-approve-safe-commands.sh`: Cross-platform safe command auto-approval
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
│   ├── tools/
│   └── skills/             # Claude-only skills
├── scripts/
│   └── sync-upstream-skills.sh  # Sync skills from upstream repos
├── upstream-skills.conf    # Upstream skill mappings
├── git/
└── tmux/
    └── .tmux.conf          # Cross-platform tmux config
```
