---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*)
description: AI analyzes git status and proposes logical commit splits
context: fork
disable-model-invocation: true
---

## Instructions

1. Run `git status` to see all changes
2. Run `git diff` for unstaged changes
3. Run `git diff --cached` for staged changes
4. Analyze the changes and group them by:
   - Logical purpose (feature, bugfix, refactor, docs, config)
   - Affected subsystems/modules
   - Dependencies between changes
5. Propose commit plan:
   - If changes are focused: suggest single commit with message
   - If changes are mixed: suggest multiple commits with:
     - Which files go in each commit
     - Suggested commit message for each
     - Rationale for the grouping
6. Ask user to approve the plan or request modifications
7. For each approved commit:
   - Stage the specified files
   - Show `git diff --cached` for review
   - Create commit with proposed message
   - Show result
8. Final `git status` to confirm all changes committed
9. Handle edge cases:
   - If no changes: inform user
   - If conflicts exist: notify and stop
   - If working tree is dirty after commits: report remaining files
