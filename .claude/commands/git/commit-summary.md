---
allowed-tools: Bash(git show:*), Bash(git log:*), Bash(git diff:*)
argument-hint: [<commit-hash> | <commit-hash..commit-hash> | <branch..branch>]
description: Analyze commits and provide concise 200-char summaries
context: fork
disable-model-invocation: false
---

## Instructions

1. Parse the provided commits argument ($ARGUMENTS):
   - Single hash: analyze one commit
   - Multiple hashes (space-separated): analyze each
   - Range (A..B or HEAD~N..HEAD): analyze all commits in range
   - Branch comparison (main..feature): analyze commits between branches

2. For each commit, run:
   - `git show <commit> --stat` for file changes overview
   - `git show <commit>` for full diff

3. Analyze each commit:
   - **Purpose**: What problem does it solve? (feature/fix/refactor/etc)
   - **Logic flow**: How is it implemented? (key steps/changes)
   - **Impact**: Which components/files are affected?

4. Generate summary (max 200 chars) including:
   - Purpose in 1 sentence
   - Core logic/approach in 1-2 sentences
   - Format: "[목적] [구현 방식]"

5. Present results for each commit:
   - Commit hash (short, 7 chars)
   - Summary of commit message
   - **AI Summary** (200 chars max, Korean)

6. If multiple commits analyzed, provide:
   - Individual summaries first
   - Overall summary of the commit series at the end (200 chars max)
