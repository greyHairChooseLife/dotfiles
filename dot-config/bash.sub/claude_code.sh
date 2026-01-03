export ASKED=~/Documents/claude_code/

alias cld='claude'
alias cldr='claude --resume'
alias ai='cd ${ASKED} && claude'

ask() {
    if [ $# -eq 0 ]; then
        echo "Usage: asks <question>"
        return 1
    fi

    # Ensure ASKED directory exists
    mkdir -p "$ASKED" || {
        echo "Error: Cannot create directory $ASKED"
        return 1
    }

    local question="$*"

    # Sanitize filename: lowercase, replace spaces/non-alphanumerics with hyphens
    local filename=$(echo "$question" \
                                      | tr '[:upper:]' '[:lower:]' \
                                   | sed 's/[^a-z0-9]/-/g' \
                              | sed 's/--*/-/g' \
                        | sed 's/^-\|-$//g' \
                          | cut -c1-50).md

    # Create date-based subdirectory
    local dir="$ASKED/$(date +%Y-%m-%d)"
    mkdir -p "$dir" || {
        echo "Error: Cannot create directory $dir"
        return 1
    }

    # Call Claude and capture output
    local output
    output=$(claude --no-session-persistence --print "$question") || {
        echo "Error: Claude command failed"
        return 1
    }

    # Save to file
    echo "$output" > "$dir/$filename" || {
        echo "Error: Cannot write to $dir/$filename"
        return 1
    }

    echo "$output"
}

asked() {
    # Ensure ASKED directory exists
    if [ ! -d "$ASKED" ]; then
        echo "Error: $ASKED directory not found"
        return 1
    fi

    # Find markdown files and use appropriate fzf method
    local selected
    local fzf_opts=(
        --ansi
        --height 80%
        --border
        --padding 0
        --color='border:green'
        --preview "bat --color=always --style=plain --language=md {}"
        --preview-window='top:90'
        --header "ENTER: open with vim | CTRL-C: Cancel"
    )

    if [[ -n "$TMUX" ]]; then
        # Inside tmux: use fzf-tmux popup
        selected=$(find "$ASKED" -name "*.md" -type f | fzf-tmux -p 60% "${fzf_opts[@]}")
    else
        # Not in tmux: use regular fzf
        selected=$(find "$ASKED" -name "*.md" -type f | fzf "${fzf_opts[@]}")
    fi

    # Display selected file if chosen
    if [[ -n "$selected" ]]; then
        nvim "$selected"
        # bat --color=always --style=plain --language=md "$selected" 2> /dev/null || cat "$selected"
    fi
}
