COMMANDER_YAML="$HOME/.commands.yaml"

# Build fzf entry list from YAML: "[category] desc  |  cmd"
_commander_build_list() {
    local cat_filter="$1"
    if [[ -n "$cat_filter" ]]; then
        yq -r ".${cat_filter}[]? | \"[${cat_filter}] \(.desc)  |  \(.cmd)\"" "$COMMANDER_YAML" 2>/dev/null
    else
        yq -r 'keys[]' "$COMMANDER_YAML" 2>/dev/null | while read -r cat; do
            yq -r ".${cat}[]? | \"[${cat}] \(.desc)  |  \(.cmd)\"" "$COMMANDER_YAML" 2>/dev/null
        done
    fi | sed '/^\[.*\]  *|  *$/d; s/\\n$//'
}

# Category selector
_commander_select_category() {
    yq -r 'keys[]' "$COMMANDER_YAML" 2>/dev/null | fzf-tmux -p 40% \
        --prompt 'category> ' \
        --border \
        --color='border:yellow'
}

a() {
    [[ -f "$COMMANDER_YAML" ]] || { echo "No commands file: $COMMANDER_YAML"; return 1; }

    local selected cmd
    local ansi_strip="s/\x1b\[[0-9;]*m//g"

    selected=$(_commander_build_list | fzf-tmux -p 70% \
        --ansi \
        --border \
        --padding 0 \
        --color='border:green' \
        --delimiter '  \\|  ' \
        --header "ENTER: execute | Alt-c: filter category | Ctrl-C: cancel" \
        --preview 'echo {-1} | sed "s/^ *//" | bat --color=always --style=plain --language=sh' \
        --preview-window='top:5:wrap' \
    )

    [[ -z "$selected" ]] && return

    # Extract command: everything after "  |  "
    cmd="${selected##*  |  }"
    # Trim whitespace
    cmd="${cmd#"${cmd%%[![:space:]]*}"}"
    cmd="${cmd%"${cmd##*[![:space:]]}"}"
    [[ -z "$cmd" ]] && return

    print -s "$cmd" 2>/dev/null
    cmd=$(echo "$cmd" | sed "$ansi_strip")
    echo -e "\033[1;32mExecuting:\033[0m $cmd"
    eval "$cmd"
}

# Category-filtered version: select category first, then command
ac() {
    [[ -f "$COMMANDER_YAML" ]] || { echo "No commands file: $COMMANDER_YAML"; return 1; }

    local cat selected cmd
    local ansi_strip="s/\x1b\[[0-9;]*m//g"

    cat=$(_commander_select_category)
    [[ -z "$cat" ]] && return

    selected=$(_commander_build_list "$cat" | fzf-tmux -p 70% \
        --ansi \
        --border \
        --padding 0 \
        --color='border:green' \
        --delimiter '  \\|  ' \
        --header "[$cat] ENTER: execute | Ctrl-C: cancel" \
        --preview 'echo {-1} | sed "s/^ *//" | bat --color=always --style=plain --language=sh' \
        --preview-window='top:5:wrap' \
    )

    [[ -z "$selected" ]] && return

    cmd="${selected##*  |  }"
    cmd="${cmd#"${cmd%%[![:space:]]*}"}"
    cmd="${cmd%"${cmd##*[![:space:]]}"}"
    [[ -z "$cmd" ]] && return

    print -s "$cmd" 2>/dev/null
    cmd=$(echo "$cmd" | sed "$ansi_strip")
    echo -e "\033[1;32mExecuting:\033[0m $cmd"
    eval "$cmd"
}
