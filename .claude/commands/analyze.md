---
allowed-tools: Bash(find:*), Bash(ls:*), Bash(cat:*), Bash(head:*), Bash(wc:*), Bash(file:*), Baseh(tree:*), Bash(grep:*)
argument-hint: [file-or-directory-path]
description: Analyze code structure and provide concise 150-char summary
context: fork
disable-model-invocation: false
---

## Instructions

1. Parse the provided path argument ($ARGUMENTS):
   - File: analyze single file
   - Directory: analyze directory structure and key files

2. For file analysis, examine:
   - File type and language
   - Main functions/classes/components
   - Dependencies and imports
   - Key logic flow

3. For directory analysis:
   - Run `find <path> -type f` to list files
   - Run `ls -lah <path>` for structure overview
   - Identify main entry points, configs, key modules
   - Read critical files (main, __init__, index, config, etc)

4. Analyze:
   - **Purpose**: What does this code do? What problem does it solve?
   - **Structure**: How is it organized? (architecture/pattern)
   - **Key components**: Main files/functions/classes
   - **Dependencies**: External libraries or internal modules

5. Generate summary (max 150 chars):
   - Purpose in 1 sentence
   - Structure/approach in 1 sentence
   - Format: "[목적] [구조/방식]"

6. Present results:
   - Path analyzed
   - Type (file/directory)
   - Language/framework detected
   - **AI Summary** (150 chars max, Korean)
   - Key files/components list (if directory)
