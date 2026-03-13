# Cross-Agent Skills

[Agent Skills Open Standard](https://agentskills.io) に準拠したスキル集。Claude Code, Codex CLI, Gemini CLI で共通利用可能。

## Directory Structure

ソースをフラット構造で管理し、Open Standard に直接準拠する。各スキルディレクトリの名前と SKILL.md の `name` フィールドが一致する。

```
skills/
├── debugger/SKILL.md
├── dev-design/SKILL.md
├── dev-documentation/SKILL.md
├── dev-implement/SKILL.md
├── dev-review-design/SKILL.md
├── dev-review-implementation/SKILL.md
├── dx-optimizer/SKILL.md
├── git-commit/SKILL.md
├── git-pr-create/SKILL.md
├── git-pr-review/SKILL.md
├── sdd-init/SKILL.md              # references/, sdd-init.sh を含む
├── skill-creator/SKILL.md         # references/, scripts/ を含む
├── writing-review/SKILL.md
└── writing-translate/SKILL.md
```

## Deploy Mechanism

`modules/claude/apply.sh` の `deploy_skills()` 関数がスキルディレクトリをそのままコピーする。

**デプロイ先**:

| Path | Consumer |
|---|---|
| `~/.claude/skills/<skill-name>/` | Claude Code |
| `~/.agents/skills/<skill-name>/` | Codex CLI, Gemini CLI |

## Naming Convention

### `name` フィールド

SKILL.md の `name` フィールドには親ディレクトリ名と同一の値を記載する（Open Standard 準拠）。

```yaml
# skills/dev-design/SKILL.md
---
name: dev-design
description: ...
---
```

### Group prefix

論理的なグループはプレフィックスで表現する:

| Group | Prefix | Skills |
|---|---|---|
| Development | `dev-` | design, implement, review-design, review-implementation, documentation |
| Git | `git-` | commit, pr-create, pr-review |
| Writing | `writing-` | review, translate |
| SDD | `sdd-` | init |
| Standalone | (none) | debugger, dx-optimizer, skill-creator |

## Adding a New Skill

```bash
# Example: add a new "dev-test" skill
mkdir -p modules/common/skills/dev-test
# Create SKILL.md with name: dev-test
```

```bash
# Example: add a new standalone "linter" skill
mkdir -p modules/common/skills/linter
# Create SKILL.md with name: linter
```

## Cross-Agent Compatibility

| Agent | Scan depth | Status |
|---|---|---|
| Claude Code | Recursive | Compatible |
| Codex CLI | Max depth 6 (BFS) | Compatible |
| Gemini CLI | Depth 1 only | Compatible |

フラット構造により全エージェントとの互換性を保証する。

## References

- [Agent Skills Open Standard](https://agentskills.io)
- [Specification](https://agentskills.io/specification)
- [Client Implementation Guide](https://agentskills.io/client-implementation/adding-skills-support)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
