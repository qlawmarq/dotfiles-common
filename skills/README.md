# Cross-Agent Skills

[Agent Skills Open Standard](https://agentskills.io) に準拠したスキル集。Claude Code, Codex CLI, Gemini CLI で共通利用可能。

## Directory Structure

ソースはグループごとにサブフォルダで管理し、デプロイ時にフラット化して Open Standard に準拠させる。

```
skills/                      # Source (this repository) - grouped
├── dev/
│   ├── design/SKILL.md          → deploys as: dev-design/
│   ├── implement/SKILL.md       → deploys as: dev-implement/
│   ├── review-design/SKILL.md   → deploys as: dev-review-design/
│   ├── review-implementation/   → deploys as: dev-review-implementation/
│   └── documentation/SKILL.md   → deploys as: dev-documentation/
├── git/
│   ├── commit/SKILL.md          → deploys as: git-commit/
│   ├── pr-create/SKILL.md       → deploys as: git-pr-create/
│   └── pr-review/SKILL.md       → deploys as: git-pr-review/
├── writing/
│   ├── review/SKILL.md          → deploys as: writing-review/
│   └── translate/SKILL.md       → deploys as: writing-translate/
├── sdd/
│   ├── init/SKILL.md            → deploys as: sdd-init/
│   ├── spec-init/SKILL.md       → deploys as: sdd-spec-init/
│   ├── spec-requirements/       → deploys as: sdd-spec-requirements/
│   ├── spec-design/SKILL.md     → deploys as: sdd-spec-design/
│   ├── spec-tasks/SKILL.md      → deploys as: sdd-spec-tasks/
│   ├── spec-impl/SKILL.md       → deploys as: sdd-spec-impl/
│   ├── spec-status/SKILL.md     → deploys as: sdd-spec-status/
│   ├── steering/SKILL.md        → deploys as: sdd-steering/
│   ├── steering-custom/SKILL.md → deploys as: sdd-steering-custom/
│   ├── validate-design/SKILL.md → deploys as: sdd-validate-design/
│   ├── validate-gap/SKILL.md    → deploys as: sdd-validate-gap/
│   ├── validate-impl/SKILL.md   → deploys as: sdd-validate-impl/
│   └── validate-tasks/SKILL.md  → deploys as: sdd-validate-tasks/
├── debugger/SKILL.md            → deploys as: debugger/
├── dx-optimizer/SKILL.md        → deploys as: dx-optimizer/
└── skill-creator/SKILL.md       → deploys as: skill-creator/
```

## Deploy Mechanism

`modules/claude/apply.sh` の `deploy_skills_flat()` 関数がサブフォルダ構造をフラット化してデプロイする。

**変換ルール**: ソースの相対パスの `/` を `-` に置換してフラット名を生成する。

| Source path | Deployed as |
|---|---|
| `dev/design/SKILL.md` | `dev-design/SKILL.md` |
| `sdd/spec-init/SKILL.md` | `sdd-spec-init/SKILL.md` |
| `debugger/SKILL.md` | `debugger/SKILL.md` |

**デプロイ先**:

| Path | Consumer |
|---|---|
| `~/.claude/skills/<flat-name>/` | Claude Code |
| `~/.agents/skills/<flat-name>/` | Codex CLI, Gemini CLI |

## Naming Convention

### `name` フィールド

SKILL.md の `name` フィールドには**フラット化後の名前**（ハイフン区切り）を記載する。

```yaml
# skills/dev/design/SKILL.md
---
name: dev-design        # flat name (not "design")
description: ...
---
```

ソースでは親ディレクトリ名（`design`）と `name` フィールド（`dev-design`）が一致しないが、デプロイ先では `dev-design/SKILL.md` となり Open Standard に準拠する。

### Group prefix

グループプレフィックスは以下の通り:

| Group | Prefix | Skills |
|---|---|---|
| Development | `dev-` | design, implement, review-design, review-implementation, documentation |
| Git | `git-` | commit, pr-create, pr-review |
| Writing | `writing-` | review, translate |
| SDD | `sdd-` | init, spec-\*, steering\*, validate-\* |
| Standalone | (none) | debugger, dx-optimizer, skill-creator |

## Adding a New Skill

### Grouped skill (recommended)

```bash
# Example: add a new "dev-test" skill
mkdir -p modules/common/skills/dev/test
# Create SKILL.md with name: dev-test
```

### Standalone skill

```bash
# Example: add a new "linter" skill
mkdir -p modules/common/skills/linter
# Create SKILL.md with name: linter
```

### New group

```bash
# Example: add a new "ops" group with "deploy" skill
mkdir -p modules/common/skills/ops/deploy
# Create SKILL.md with name: ops-deploy
```

## Cross-Agent Compatibility

| Agent | Scan depth | Subfolder grouping | Status |
|---|---|---|---|
| Claude Code | Recursive | N/A (deployed flat) | Compatible |
| Codex CLI | Max depth 6 (BFS) | N/A (deployed flat) | Compatible |
| Gemini CLI | Depth 1 only | N/A (deployed flat) | Compatible |

フラット化デプロイにより全エージェントとの互換性を保証する。ソース側のサブフォルダ構造はデプロイ先に影響しない。

## References

- [Agent Skills Open Standard](https://agentskills.io)
- [Specification](https://agentskills.io/specification)
- [Client Implementation Guide](https://agentskills.io/client-implementation/adding-skills-support)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
