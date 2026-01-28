#!/bin/zsh

# Directory where Claude stores project logs
CLAUDE_DIR="$HOME/.claude/projects"

# 1. Find the most recently modified JSONL file in the directory structure
# We look inside subdirectories because the structure is [project_name]/[uuid].jsonl
LATEST_FILE=$(find "$CLAUDE_DIR" -type f -name "*.jsonl" -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)

if [ -z "$LATEST_FILE" ]; then
    echo "No Claude conversation logs found."
    exit 1
fi

# 2. Extract the last message content
# The logic:
# - Read the file as a stream of JSON objects (-s)
# - Select the last item in the array (.[-1])
# - Check if content is an array (new format) or string (old format)
# - If array, filter for type="text" and join them
LAST_MESSAGE=$(jq -rs '
  .[-1]
  | if (.message.content | type) == "array" then
      [.message.content[] | select(.type=="text") | .text] | join("\n")
    else
      .message.content
    end
' "$LATEST_FILE")

# 3. Copy to clipboard (Linux specific)
if command -v wl-copy &> /dev/null; then
    # Wayland
    echo "$LAST_MESSAGE" | wl-copy
    echo "Last message copied to clipboard (Wayland)."
elif command -v xclip &> /dev/null; then
    # X11
    echo "$LAST_MESSAGE" | xclip -selection clipboard
    echo "Last message copied to clipboard (X11)."
else
    echo "Error: No clipboard utility found (install xclip or wl-copy)."
    echo "Message content:"
    echo "$LAST_MESSAGE"
fi
