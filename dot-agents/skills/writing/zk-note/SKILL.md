---
name: zk-note
description: Search, create, and manage Zettelkasten notes with wikilinks. Use when user wants to find, create, or organize notes.
---

# Zettelkasten Note

## Notes location

`~/Documents/zk`

Mostly flat at root level.

## Linking

-   Use wikilink syntax `[[filename|alias]]`
-   Alias is required to describe what the link links because filenames are auto-generated uuid.

## Commands

Use `zk cli` tool above all else.

-   Created via `zk new --template <type>.md`.
-   Templates live in `~/Documents/zk/.zk/templates/`

Or use Read/Edit/Write tools directly on the note path.

### Writing rules

1.  Keep concise, direct.
2.  Write content as a unit of learning (per vault rules).
3.  If part of a numbered sequence, use the hierarchical numbering scheme
4.  All indent is 4 spaces.
5.  Wrap line at 120 characters.
