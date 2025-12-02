# dotfiles-common

Common configurations shared across [dotfiles-linux](https://github.com/qlawmarq/dotfiles-linux) and [dotfiles-macos](https://github.com/qlawmarq/dotfiles-macos).

## Contents

### Claude Code Configuration

- **agents/**: Specialized agents for development workflows
- **commands/**: Custom slash commands
- **skills/**: Reusable skill definitions
- **tools/**: Additional tool integrations
- **settings.json**: Claude Code settings with permission automation
- **hooks/**: Hook scripts
  - `auto-approve-safe-commands.sh`: Cross-platform safe command auto-approval
  - `platform/macos/`: macOS-specific notification hooks
  - `platform/linux/`: Linux-specific hooks (reserved for future use)

### tmux Configuration

- **.tmux.conf**: Cross-platform tmux configuration with automatic clipboard detection (pbcopy/xclip/wl-copy)

## Usage

This repository is designed to be used as a git submodule in platform-specific dotfiles repositories.

## Platform-Specific Dotfiles

- **Linux/WSL**: [dotfiles-linux](https://github.com/qlawmarq/dotfiles-linux)
- **macOS**: [dotfiles-macos](https://github.com/qlawmarq/dotfiles-macos)

## Structure

```
dotfiles-common/
├── claude/
│   ├── agents/              # Development workflow agents
│   ├── commands/            # Custom slash commands
│   ├── skills/              # Reusable skills
│   ├── tools/               # Tool integrations
│   ├── settings.json        # Claude Code settings
│   └── hooks/
│       ├── auto-approve-safe-commands.sh  # Cross-platform
│       └── platform/
│           ├── macos/       # macOS-specific
│           └── linux/       # Linux-specific
└── tmux/
    └── .tmux.conf           # Cross-platform tmux config
```
