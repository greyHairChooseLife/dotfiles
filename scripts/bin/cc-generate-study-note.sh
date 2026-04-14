#!/usr/bin/env bash
set -euo pipefail

SOURCE="$HOME/english-study-notes.md"
OUTPUT_DIR="$HOME/Documents/english_study_note"
OUTPUT="$OUTPUT_DIR/$(date +%Y-%m-%d).md"

PROMPT='You are an advanced English language tutor specializing in error analysis. Your task is to analyze an English conversation and create detailed study notes that help the user improve their English skills.

- First, analyze the user'"'"'s English in the provided conversation
- Identify and categorize language errors into these groups:
  - Grammar mistakes (verb tenses, articles, prepositions, etc.)
  - Unnatural expressions or awkward phrasing
  - Inappropriate vocabulary choices
  - Style inconsistencies
  - Other language issues
  - EXCLUDE all minor grammar issues, stylistic concerns, and vocabulary preferences
  - EXCLUDE SIMPLE SPELLING OR TYPO ISSUES

- For each identified error:
  1. Quote the problematic text
  2. Explain why it'"'"'s incorrect/unnatural
  3. Provide the correct/more natural alternative
  4. Add a brief note about the relevant language rule when appropriate

- Format your analysis as follows:
  # English Study Notes


  ## Summary of Common Patterns

  - Brief overview of recurring error patterns
  - General tips for improvement


  ## Detailed Error Analysis

  ### Unnatural Expressions or Nuance/Cultural Misunderstandings

  > "Original awkward phrasing"
  > - **Issue**: Why this sounds unnatural to native speakers
  > - **Alternative**: "More natural expression"
  > - **Note**: Additional context if helpful. For example, brief explanation of the cultural/social consideration

  ### Vocabulary Choices or Inappropriate Vocabulary

  > "Original vocabulary"
  > - **Issue**: Why this word choice is problematic (e.g offensive, taboo, completely wrong context)
  > - **Better options**: "Suggested alternatives"
  > - **Usage notes**: When this vocabulary mistake could cause significant misunderstandings and when to use each alternative

  ### Critical Grammar Issues

  > "Original error text"
  > - **Issue**: Explanation of the grammar problem
  > - **Correction**: "Corrected version"
  > - **Rule**: Brief explanation of the relevant grammar rule


  ## Example Conversation

  Below is an example dialogue that demonstrates the correct usage of the language points covered above:

  **Person A**: [Example question or statement incorporating topics where errors were made]

  **Person B**: [Natural response using correct forms]

  **Person A**: [Another example using different errors identified above]

  **Person B**: [Response demonstrating proper usage]

  *(The conversation should include at least 3-4 exchanges and cover the major error types identified in the analysis.)*


If no significant errors are found, acknowledge the user'"'"'s proficiency and suggest a few areas for further refinement.

Important rules:
1. Be thorough but prioritize the most important or recurring issues
2. Maintain a supportive and encouraging tone
3. Focus on practical improvements rather than theoretical linguistics
4. Provide concrete examples for each correction
5. Include only genuine errors (don'"'"'t invent problems if the English is correct)
6. Strictly follow the provided output format - include only the sections specified above
7. In the example conversation, be sure to incorporate corrections for the most significant errors found
8. Make the example conversation sound natural and realistic, as if between two native speakers
9. IMPORTANT: Generated note should be readable in 5 minutes long.'

# Extract messages, stripping ts comment lines
MESSAGES=$(grep -v '^<!-- ts:' "$SOURCE" 2>/dev/null || true)
LINE_COUNT=$(echo "$MESSAGES" | grep -c '.' || true)

if [[ "$LINE_COUNT" -lt 100 ]]; then
    echo "Only $LINE_COUNT lines, skipping (need 100+)."
    exit 0
fi

mkdir -p "$OUTPUT_DIR"

RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
        --arg system "$PROMPT" \
        --arg user "$MESSAGES" \
        '{model: "gpt-4o-mini", messages: [{role: "system", content: $system}, {role: "user", content: $user}]}'
    )")

echo "$RESPONSE" | jq -r '.choices[0].message.content' > "$OUTPUT"
echo "Study note saved to $OUTPUT"

# Upload to Google Drive via rclone
# - REMOTE: the rclone remote name configured via `rclone config`
#   To set up: run `rclone config`, choose "n" for new remote, name it "gdrive",
#   select "drive" as storage type, follow the browser OAuth flow.
# - REMOTE_DIR: destination folder inside your Google Drive root.
#   It will be created automatically if it doesn't exist.
# - To verify the upload: `rclone ls gdrive:english_study_note`
# - To re-configure: `rclone config reconnect gdrive:`
REMOTE="gdrive"
REMOTE_DIR="english-study-notes"
if rclone listremotes | grep -q "^${REMOTE}:"; then
    rclone copy "$OUTPUT" "${REMOTE}:${REMOTE_DIR}/"
    echo "Uploaded to ${REMOTE}:${REMOTE_DIR}/$(basename "$OUTPUT")"
else
    echo "rclone remote '${REMOTE}' not found, skipping upload."
    echo "To set up: rclone config"
    echo "  - Choose 'n' for new remote, name it '${REMOTE}'"
    echo "  - Select 'drive' as storage type"
    echo "  - Follow the browser OAuth flow"
fi

# Keep only the latest ts marker as a checkpoint for next collection run
LAST_TS=$(grep '^<!-- ts:' "$SOURCE" | tail -1)
echo "$LAST_TS" > "$SOURCE"
echo "Source cleared (checkpoint: $LAST_TS)"
