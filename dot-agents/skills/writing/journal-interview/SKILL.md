---
name: journal-interview
description: Interview the user about one significant event to digest it into a reflection section in this week's journal. Use right after something notable happens (a conflict, a hard decision, a strong emotion) and the user wants to process it, not just log it. Mentions "reflect on this", "help me process".
---

# journal-interview

Interview the user about ONE significant event and turn it into a reflection
section appended to this week's journal file.

This is not logging — it is digestion. The goal is a lesson and a next action, not a transcript.

Interview in English (the user processes reflection in English). Keep the note's
section headers as-is (`### 사실` etc.).

## Before starting: consent check

Ask first, in one line:

> Do you want to dig into this, or just record it for now?

- If they want to just record → skip the interview, write the note with only the `### 사실` section filled, leave the rest as stubs.
- If they want to dig → run the interview below.

Never force the grill. Emotionally heavy events can be too much.

## Interview: 5-stage skeleton

Ask ONE question at a time. Follow the order, but only dig deeper where the answer is shallow.

1.  **사실 (facts)** — What exactly happened? In order, emotions aside.
2.  **감정 (emotion)** — What did you feel at that moment? Physically too?
3.  **해석 (interpretation)** — Why did you react / did it unfold that way? What part of you got touched?
4.  **교훈 (lesson)** — What did you learn here? Is it a pattern or a one-off?
5.  **행동 (next action)** — Next time in a similar situation, what would you do differently?

### Digging rule

Only follow up when an answer is shallow. Examples:

- "I was just angry." → "What's under the anger? Feeling dismissed? Fear?"
- "I'll do better next time." → "Concretely what? What signal triggers what action?"

Do not interrogate every answer. If a stage is already clear, move on.

## Output: append into this week's file

There is NO separate note file. Append the reflection as one section into this
week's file: `~/Documents/zk/journal-YYMMDD-HHMMSS.md`.

- If this week's file doesn't exist, tell the user to create it by hand first.
- Structure the conversation into these sections — do NOT dump the raw dialogue.
- Headers start at `##` (no h1). The event title is `##`, the 5 stages are `###`.

```markdown
## MM-DD <짧은 제목>

### 사실
- (있었던 일, 시간순, 감정 빼고)

### 감정
- (그때 느낀 것, 몸으로도)

### 해석
- (왜 그렇게 반응/전개됐나)

### 교훈
- (뽑아낸 것. 패턴인가 일회성인가)

### 다음 행동
- (다음에 비슷하면 뭘 다르게)
```

If the user chose "just record" at the consent check, fill only `### 사실` and leave the rest as stubs.
