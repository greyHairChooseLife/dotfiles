---
name: documentation
description: Writing and editing conventions for zk notes. Load this skill when creating, editing, or restructuring any zettelkasten note (any type — task, default, journal, blueprint, reference). Also load when another skill produces output destined for a zk note, or when the user asks to write, document, record, edit, revise, or summarize something into the zk notebook. Covers prose style, formatting, link rules, atomic decomposition, editing workflow, and the 5 note type definitions.
---

# Documentation

Applies to all zk note creation and editing. The driving skill decides what to
write; this skill defines how.

## Prose conventions

-   Concise, direct, no honorifics (반말).
-   Bullet points and tables over prose paragraphs.
-   No emoji. No horizontal rules (`---`) for decoration.
-   Plain lists indent with 4 spaces between marker and text (`-    item`).

### Language

-   Technical terms, CLI commands, file paths, and code identifiers: English.
-   Explanations, context, and narrative: Korean.
-   No mid-sentence English-Korean switching unless the English term has no
    natural equivalent.

### Sections

-   `## Section` for top-level, `### Subsection` for nesting.
-   Don't go deeper than `###`.
-   Section titles are bare nouns: `## Context`, not `## The Context`.

## Formatting rules

-   **Lists**: 4-space indent after marker. `-    item`. `1.    item`.
-   **Code**: inline `code` for short references, fenced ``` blocks for
    multi-line or shell output.
-   **Tables**: pipe tables for structured comparisons.
-   **Checkboxes**: `-   [ ]` for incomplete, `-   [x]` for done (task notes only).

## Link conventions

-   Internal zk notes: `[[path/to/note]]` or `[[path/to/note|alias]]`.
    Use alias when the filename is not human-readable.
-   External URLs: bare URL in a list or reference section. Not inline
    hyperlinks unless the URL is the subject.
-   Attachments: `![[../resource/task-static/<uuid>/file]]` for task resources.

## Atomic decomposition

A note should cover one well-defined topic. When a section grows into its own
topic, propose splitting it into a separate note:

-   "The `## Foo` section in [[note]] could stand alone as a reference note.
    Split it?"

Don't split preemptively — only when the section has enough substance to
justify its own file. Link back from the original with `## Reference` or inline
in Context.

## Environment context

-   Notes live in `~/Documents/zk/`, a zk notebook.
-   Created via `zk new --template <type>.md`, edited in nvim.
-   Templates live in `.zk/templates/` (5 types: default, taskwarrior, journal,
    blueprint, reference).
-   Full type reference: [[documentation/types]].

## Editing an existing note

1.  Divide the note into sections based on its current headings. Identify the
    logical dependency order — information is a DAG; earlier sections should
    not assume knowledge from later ones. Confirm the restructured outline
    with the user before rewriting.
2.  For each section, rewrite for clarity, coherence, and conciseness.
    Maximum 240 characters per paragraph. Preserve all factual content
    unless the user explicitly asks to remove it.
