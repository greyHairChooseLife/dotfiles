---
name: project-documentation
description: Use when starting documentation for a new or existing project, or when asked to organize/restructure technical docs. Applies when docs are missing, scattered, or a project needs a maintainable documentation structure for long-term solo maintenance.
---

# Project Documentation

## Overview

Technical documentation structure for solo-maintained projects. Core criterion: **"Someone unfamiliar (including future me after 6 months) can start working within 30 minutes using only the docs."**

## Document Structure

```
docs/
    README.md          # Entry point - document map
    contributing.md    # How to work on it (procedures)
    architecture.md    # How it's built (structure)
    features.md        # What exists (feature status)
    decisions.md       # Why it's built this way (ADRs)
    runbook.md         # What to do when things break (ops)
```

## Role of Each File

### `README.md` - Document Map
- One-line project description
- For each doc file, list two things explicitly:
    - **When to read**: specific situations that send you to this file
    - **When to update**: concrete triggers that mean this file needs updating
- This makes README the maintenance guide for the docs themselves, not just a reading index

### `contributing.md` - Procedure Document
- How to run the development environment
- Deployment steps
- Branching strategy, versioning
- DevOps (server access, tunneling)
- Troubleshooting

### `architecture.md` - System Understanding
- Tech stack (with versions and rationale)
- Component relationships and request flows
- Auth flow (token lifecycle)
- Role/permission matrix
- Key data model relationships

### `features.md` - Feature Status
- List of implemented features + status (done / partial / deprecated)
- Known issues / technical debt
- Future improvement ideas
- **Most critical for maintenance** - answers "is this a bug or intended behavior?"

### `decisions.md` - Decision Log (lightweight ADR)
- Key technology choices and why
- Trade-offs at the time of decision
- **Value increases over time** - answers "why on earth did we do it this way?"

Each ADR format:
```
### ADR-NNN: Title
- **Date**: YYYY-MM
- **Status**: Adopted / Superseded
- **Decision**: One-line summary
- **Reason**: Why this was chosen
- **Trade-offs**: What was given up
```

### `runbook.md` - Operations Playbook
- Recurring tasks (cert renewal, backup schedule)
- Incident response checklist
- Log file locations
- How to directly manipulate DB when needed
- Where credentials/access info live (location only, not actual values)

## Writing Priority

Most valuable for maintenance, in order:

1. `features.md` - write while memory is fresh (scope, known debt)
2. `decisions.md` - write before context fades (why things are the way they are)
3. `architecture.md` - structure reference (derivable from code but needs compression)
4. `contributing.md` - procedure doc (most immediately painful when missing)
5. `runbook.md` - fill in as operational experience accumulates

## Filename Conventions

- `contributing.md` (not `dev.md`) - unambiguous: "how to work on this"
- Lowercase with hyphens
- `README.md` is the only uppercase exception

## Handling Existing Planning Docs

If `specs/` or similar initial planning documents exist:
- Keep as reference until technical docs are complete
- Note in `README.md`: "retained as reference until migration complete"
- Specs diverge from code naturally over time - `features.md` becomes the source of truth
- Remove specs once technical docs are complete

## Writing Principles

- Tables and bullet lists over prose (scannable)
- Specific: actual commands, versions, paths
- For credentials: record *where* they live, not the actual values
- Treat as a living document - update as the system evolves
