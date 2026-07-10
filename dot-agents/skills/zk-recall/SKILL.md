---
name: zk-recall
description: Search the user's zk notes to ground the current request in their own accumulated knowledge, decisions, and preferences. Use when the user says "check my notes", "what did I decide about X", "내 zk 참고해서", or when a request would clearly benefit from past context the user has written down (a recurring topic, a prior decision, a personal convention). SKIP for searching the codebase (use Grep), for general web knowledge, and for writing/filing notes (that's zk-triage).
---

# zk-recall

Read the user's zk notebook to answer the current request with THEIR context —
past decisions, recorded preferences, prior work on the same topic — instead of
generic knowledge. This is the **recaller** in the zk-agent skill family
(producer → inbox → organizer → filed; **recaller reads the filed knowledge**).

Read-only. This skill never creates, moves, or edits a note.

The value is a *synthesized* answer grounded in what the user already knows, not a
pile of file paths. Surface the relevant substance, cite the notes, move on.

## Engine: `zk` CLI

Run from `~/Documents/zk`. Index is auto-maintained; if results look stale run
`zk index` first. Combine these — don't rely on one:

```bash
zk list -m "QUERY" -f oneline -n 8          # full-text search (default fts)
zk list -t TAG,TAG2 -f oneline              # by tag (see .zk/metadata.json for the tag vocabulary)
zk list --related PATH -f oneline           # notes sharing links with a seed note
zk list -L PATH / -l PATH                    # linked-by / links-to a seed note (follow the graph)
zk list -m "Q" --created "after:2026-01" -f full   # scope by time when recency matters
```

- `-f full` to read a note's body; `-f oneline` to scan candidates first.
- Prefer scanning `oneline` → pick the 2–4 most relevant → read those in full.
  Don't dump every match into context.

## Procedure

1.  **Extract search keys** from the request: the topic, any proper nouns, and the
    *kind* of context wanted (a decision? a preference? prior art?).
2.  **Search in layers**, widening only if needed:
    -   full-text (`-m`) on the topic terms;
    -   tags (`-t`) if the topic maps to a known tag;
    -   if a strong seed note turns up, follow its graph (`--related`, `-L`, `-l`)
        to reach notes that share context but not keywords.
3.  **Read the top few in full**, not all matches.
4.  **Synthesize**: state what the user's notes actually say about this — the
    decision they made, the preference they hold, the context they built — and
    cite each with its `[[note-id]]` or path. Distinguish "the notes say X" from
    your own inference.
5.  **Exit criterion**: if two independent searches (e.g. a topic-term FTS and a
    tag or graph query) both return nothing relevant, stop and say so plainly —
    "nothing in your notes on this" — rather than stretching a weak match into
    false context. A wrong "you decided X" is worse than "no record".

## What this skill does NOT do

- Not a codebase search (that's Grep/ripgrep over the repo).
- Not general knowledge or web lookup — only the user's notebook.
- Never writes, moves, or files notes (that's zk-triage).
- Doesn't invent a preference the notes don't state; absence of a note is a valid,
  reportable result.
