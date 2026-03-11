# dotfiles-common

Common configurations shared across [dotfiles-linux](https://github.com/qlawmarq/dotfiles-linux) and [dotfiles-macos](https://github.com/qlawmarq/dotfiles-macos).

## Contents

### Cross-Agent Skills (Agent Skills Open Standard)

Reusable skills compatible with Claude Code, Codex CLI, and Gemini CLI.

- **dev-design/**: Design detailed implementation plans
- **dev-implement/**: Implement development tasks
- **dev-review-design/**: Review and verify designs
- **dev-review-implementation/**: Review and verify implementations
- **dev-documentation/**: Create and update documentation
- **git-commit/**: Create well-formatted git commits
- **git-pr-create/**: Create well-structured pull requests
- **git-pr-review/**: Review pull requests
- **writing-review/**: Review blog content quality
- **writing-translate/**: Translate documents to other languages
- **debugger/**: Debug errors and test failures
- **dx-optimizer/**: Optimize developer experience
- **skill-creator/**: Guide for creating new skills
- **sdd-\*/**: SDD (Spec-Driven Development) system (13 skills)

### Claude Code Configuration

- **skills/**: Claude-only skills (transcripts, setup-hooks)
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
├── skills/                 # Cross-agent skills (Agent Skills Open Standard)
│   ├── dev-design/
│   ├── dev-implement/
│   ├── git-commit/
│   ├── sdd-*/              # SDD system (13 skills)
│   ├── skill-creator/
│   └── ...
├── claude/                 # Claude Code specific
│   ├── settings.json
│   ├── hooks/
│   ├── tools/
│   └── skills/             # Claude-only skills
├── git/
└── tmux/
    └── .tmux.conf          # Cross-platform tmux config
```
