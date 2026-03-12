---
name: git-pr-create
description: >-
  Create a well-structured pull request with comprehensive descriptions.
  Use this skill when you need to push changes and create a PR with
  proper title, description, and labels.
---

# Skill: Create Pull Request

This skill helps you create well-structured pull requests with comprehensive descriptions.

## What This Skill Does

1. Checks the current branch and ensures it's not the main/master branch
2. Verifies that changes have been committed (use `/git-commit` first if needed)
3. Runs `git log` and `git diff` to understand all commits that will be included in the PR
4. Analyzes the changes to create a comprehensive PR description:
   - Summarizes the purpose of the changes
   - Lists key changes and improvements
   - Identifies any breaking changes
   - Notes dependencies or related issues
5. Checks if a pull request template exists (`.github/pull_request_template.md`) and follows its format
6. Pushes the current branch to remote if not already pushed
7. Creates the PR using `gh pr create` with:
   - A clear, descriptive title
   - A comprehensive description following the template or best practices
   - Appropriate labels if applicable
8. Displays the PR URL for review

## Pull Request Best Practices

- **Clear title**: Summarize the changes in one line (e.g., "Add user authentication with OAuth2")
- **Comprehensive description**: Include:
  - What changes were made
  - Why the changes were made
  - How to test the changes
  - Any breaking changes or migration notes
  - Related issues or dependencies
- **Follow templates**: Use the project's PR template if available
- **Link issues**: Reference related issues using `#issue-number`
- **Request reviews**: Tag appropriate reviewers if needed

## Requirements

- `gh` CLI must be installed and authenticated
- Current branch should have commits to push
- Changes should be committed before creating PR

## Additional Guidance

ユーザーから追加の指示がある場合は、それに従ってください。
