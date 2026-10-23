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

-   Create via `zk new --template <type>.md --print-path`.
    -   No TTY available — `--print-path` skips the editor, just creates the
        file and prints its path.
    -   Then `read` the created file to get the filename, `edit` to fill content.
-   Templates live in `~/Documents/zk/.zk/templates/`

### Template variables

| Template | Has `{{content}}` | Best for |
|----------|-------------------|----------|
| `reference.md` | Yes | Learning/concept notes with Overview and Reference sections |
| `taskwarrior.md` | Yes | Task notes with Context, Done when, Log |
| `default.md` | No | Blank slate — no body structure, use with `write` |
| `journal.md` | No | Freeform journal entries |
| `blueprint.md` | No | Architecture decisions with Context/Decision/Consequences |

Only templates with `{{content}}` reserve a body slot — but content is always
filled via `edit` after creation, not through stdin.

Or use `read`/`edit`/`write` tools directly on the note path.

### Writing rules

1.  Keep concise, direct.
2.  Write content as a unit of learning (per vault rules).
3.  If part of a numbered sequence, use the hierarchical numbering scheme
4.  All indent is 4 spaces.
5.  Wrap line at 120 characters.
