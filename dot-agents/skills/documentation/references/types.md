# Note types

5 types. Each maps to a template in `.zk/templates/<type>.md`.

## default

Raw capture, unfiled thoughts, fleeting notes. Default for `zk new` without
`--template`. Minimal structure — frontmatter only. Lives in `inbox/` until triage.

```
---
title, type: default, created, updated
---
```

## taskwarrior

Task-linked note. Full spec in `task` skill.

```
---
title, type: taskwarrior, task-uuid, created, updated
---

## Context
## Done when
```

-   `## Context`: what, why, evolving context, reference links, attachments.
-   `## Done when`: completion criteria as checkboxes. Minimum 1, always present.
-   Progress logging: TW annotations (`task <id> annotate`), not the note.

## journal

Date-anchored personal record. Used by `reflect-event`.

```
---
title, type: journal, created, updated
---

# title (date or topic)

## Notes
```

-   `## Notes`: free-form narrative or bullet list.
-   No rigid sections — the date is the structure.

## blueprint

Design document, decision record, roadmap. Formerly `master`.

```
---
title, type: blueprint, created, updated
tags: [...]
---

# title

## Context/problem
## Decision
## Consequences
```

-   `## Context`: what problem or decision this addresses, relevant constraints.
-   `## Decision`: the resolution, model, or architecture. Core of the note.
-   `## Consequences`: what follows — action items, trade-offs, affected areas.

## reference

Polished knowledge. The catch-all for everything that isn't one of the above:
study notes, cheatsheets, troubleshooting guides, plans, meeting summaries.

```
---
title, type: reference, created, updated
tags: [...]
---

# title

## Context/overview

(body — free structure, use ## sections as needed)

## Reference
```

-   `## Context` or `## Overview`: brief intro to the topic.
-   Body: whatever the content demands — free `##` sections, tables, code blocks.
-   `## Reference`: external links and related notes.
-   Use `tags` to differentiate subtypes (e.g. `tags: [study, rust]`).
