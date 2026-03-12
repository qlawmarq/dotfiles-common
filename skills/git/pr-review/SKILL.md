---
name: git-pr-review
description: >-
  Review a pull request and provide constructive feedback.
  Use this skill when you need to perform code review, check for bugs,
  security issues, and suggest improvements.
argument-hint: [PR-number or PR-URL]
---

# Skill: Review Pull Request

This skill helps you perform thorough code reviews and provide constructive feedback on pull requests.

## 起動方法

ユーザーから PR 番号または PR の URL を受け取ってください。
まだ提供されていない場合は、どの PR をレビューすべきか質問してください。

## What This Skill Does

1. Fetches the PR details using `gh pr view <number>`:
   - Title and description
   - Changed files
   - Commits included
   - Current status and checks
2. Reviews the diff using `gh pr diff <number>`
3. Analyzes the changes for:
   - Code quality and best practices
   - Potential bugs or issues
   - Performance considerations
   - Security concerns
   - Test coverage
   - Documentation completeness
4. Checks that the PR follows project conventions:
   - Coding style
   - Commit message format
   - PR description completeness
5. Prepares structured feedback with:
   - Overall assessment
   - Specific comments on code changes
   - Suggestions for improvements
   - Questions for clarification if needed
6. Optionally posts the review using `gh pr review <number>`

## Review Focus Areas

### Code Quality
- Readability and maintainability
- Adherence to project coding standards
- Proper error handling
- Appropriate abstractions

### Functionality
- Logic correctness
- Edge cases handled
- Backward compatibility
- Breaking changes documented

### Testing
- Test coverage adequate
- Test cases comprehensive
- Edge cases tested

### Documentation
- Code comments clear
- README updated if needed
- API changes documented

### Security
- No hardcoded secrets
- Input validation present
- SQL injection prevention
- XSS prevention

## Review Guidelines

- **Be constructive**: Focus on improving the code, not criticizing the author
- **Be specific**: Point to exact lines and explain your concerns
- **Suggest solutions**: Don't just point out problems, offer alternatives
- **Ask questions**: If something is unclear, ask for clarification
- **Acknowledge good work**: Highlight well-written code or clever solutions
- **Distinguish between**: Must-fix issues vs. suggestions for improvement

## Additional Guidance

ユーザーから追加の指示がある場合は、それに従ってください。
