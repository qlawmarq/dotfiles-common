# Cross-Agent Skills

This directory contains Agent Skills that are designed to be compatible across multiple agents. Each skill is defined in its own subdirectory with a `SKILL.md` file that describes the skill's functionality, inputs, and outputs. These skills can be used by Claude Code, Codex CLI, and Gemini CLI without modification, as they conform to the [Agent Skills Open Standard](https://agentskills.io) for cross-agent compatibility

**Where to Deploy**:

| Path                             | Consumer              |
| -------------------------------- | --------------------- |
| `~/.claude/skills/<skill-name>/` | Claude Code           |
| `~/.agents/skills/<skill-name>/` | Codex CLI, Gemini CLI |

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

| Agent       | Scan depth        | Status     |
| ----------- | ----------------- | ---------- |
| Claude Code | Recursive         | Compatible |
| Codex CLI   | Max depth 6 (BFS) | Compatible |
| Gemini CLI  | Depth 1 only      | Compatible |

## References

- [Agent Skills Open Standard](https://agentskills.io)
- [Specification](https://agentskills.io/specification)
- [Client Implementation Guide](https://agentskills.io/client-implementation/adding-skills-support)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
