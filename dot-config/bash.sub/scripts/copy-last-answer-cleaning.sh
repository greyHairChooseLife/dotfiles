#!/bin/bash

# 1. Find the most recently modified project file
# We look in ~/.claude/projects, go 2 levels deep, and sort by modification time
LATEST_FILE=$(find ~/.claude/projects -maxdepth 2 -name "*.jsonl" -type f -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)

if [ -z "$LATEST_FILE" ]; then
    echo "No Claude project files found."
    exit 1
fi

# 2. Extract the last message using jq
# 3. Use perl to remove <function_calls> blocks and trim whitespace
# 4. Copy to clipboard (detects xclip or wl-copy)

CONTENT=$(jq -rs '
  .[-1]
  | if (.message.content | type) == "array" then
      [.message.content[] | select(.type=="text") | .text] | join("\n")
    else
      .message.content
    end
' "$LATEST_FILE")

# Clean the content: remove function_calls and trim extra whitespace
CLEAN_CONTENT=$(echo "$CONTENT" | perl -0777 -pe 's/<function_calls>.*?<\/function_calls>//gs' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# Copy to clipboard based on available tool
if command -v wl-copy &> /dev/null; then
    echo -n "$CLEAN_CONTENT" | wl-copy
    echo "Copied last response to clipboard (Wayland)."
elif command -v xclip &> /dev/null; then
    echo -n "$CLEAN_CONTENT" | xclip -selection clipboard
    echo "Copied last response to clipboard (X11)."
else
    echo "Error: No clipboard utility found (install xclip or wl-copy)."
    echo "Here is the content:"
    echo "$CLEAN_CONTENT"
fi
