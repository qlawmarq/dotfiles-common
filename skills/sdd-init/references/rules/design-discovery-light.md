# Light Discovery Process for Extensions

## Objective

Quickly analyze existing system and integration requirements for feature extensions.

## Focused Discovery Steps

### 1. Extension Point Analysis

**Identify Integration Approach**:

- Locate existing extension points or interfaces
- Determine modification scope (files, components)
- Check for existing patterns to follow
- Identify backward compatibility requirements

### 2. Dependency & Technology Check

**For new or changed dependencies only**:

- Confirm version compatibility, that API contracts have not changed, and licensing — by checking, not by assuming (`evidence-discipline.md` §1: documentation alone does not settle an external spec)
- Search the web for official documentation and known compatibility issues

### 3. Integration Risk Assessment

**Quick Risk Check**: impact on existing functionality, performance implications, security considerations, testing requirements.

## When to Escalate to Full Discovery

Switch to full discovery if you find:

- Significant architectural changes needed
- Complex external service integrations
- Security-sensitive implementations
- Performance-critical components
- Unknown or poorly documented dependencies

## Output

Findings go to `research.md` in the claim form of `evidence-discipline.md` §2: the integration approach and boundary impacts, files/components to modify, new dependencies with versions, risks, and testing focus areas.
