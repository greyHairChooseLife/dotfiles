COMMANDER_YAML="$HOME/.commands.yaml"

# Build fzf entry list: "desc\x01cmd\x01note"
# Fields separated by \x01 (unit separator):
#   field 1: desc (displayed)
#   field 2: cmd  (searched, used for execution/copy)
#   field 3: note (shown in preview as comment)
_commander_build_list() {
    local cat_filter="$1"
    if [[ "$cat_filter" == "all" || -z "$cat_filter" ]]; then
        yq -r 'keys[]' "$COMMANDER_YAML" 2>/dev/null | while read -r cat; do
            yq -r ".${cat}[]? | [(.desc // \"\"), (.cmd // \"\" | rtrimstr(\"\n\")), (.note // \"\")] | join(\"\u0001\")" "$COMMANDER_YAML" 2>/dev/null
        done
    else
        yq -r ".${cat_filter}[]? | [(.desc // \"\"), (.cmd // \"\" | rtrimstr(\"\n\")), (.note // \"\")] | join(\"\u0001\")" "$COMMANDER_YAML" 2>/dev/null
    fi | grep -v $'^\x01\x01$'
}

# Category selector: shows all categories + "all" option
_commander_select_category() {
    { echo "all"; yq -r 'keys[]' "$COMMANDER_YAML" 2>/dev/null; } | fzf-tmux -p 40% \
        --prompt 'category> ' \
        --border \
        --color='border:yellow'
}

# Shared fzf picker: takes category arg, returns selected entry
_commander_pick() {
    local cat="$1"
    local header_label
    [[ "$cat" == "all" ]] && header_label="all" || header_label="$cat"

    local sep=$'\x01'
    _commander_build_list "$cat" | fzf-tmux -p 70% \
        --ansi \
        --border \
        --padding 0 \
        --color='border:green' \
        --delimiter "$sep" \
        --with-nth=1 \
        --nth=1,2 \
        --expect='ctrl-o' \
        --header "[$header_label] ENTER: run | Ctrl-E: copy+quit | Alt-E: copy | Ctrl-O: edit source" \
        --preview "f2=\$(echo {} | cut -d\$'\\001' -f2 | sed 's/^ *//'); f3=\$(echo {} | cut -d\$'\\001' -f3); [ -n \"\$f3\" ] && printf '# %s\\n' \"\$f3\"; printf '%s' \"\$f2\" | bat --color=always --style=plain --language=sh" \
        --preview-window='top:6:wrap' \
        --bind "ctrl-e:execute(echo {} | cut -d\$'\\001' -f2 | sed 's/^ *//' | tr -d '\\n' | $_fzf_copy_cmd)+abort" \
        --bind "alt-e:execute(echo {} | cut -d\$'\\001' -f2 | sed 's/^ *//' | tr -d '\\n' | $_fzf_copy_cmd)"
}

a() {
    [[ -f "$COMMANDER_YAML" ]] || { echo "No commands file: $COMMANDER_YAML"; return 1; }

    local cat key selected cmd desc lineno
    local ansi_strip='s/\x1b\[[0-9;]*m//g'

    cat=$(_commander_select_category)
    [[ -z "$cat" ]] && return

    local pick_output
    pick_output=$(_commander_pick "$cat")
    [[ -z "$pick_output" ]] && return

    key=$(echo "$pick_output" | head -1)
    selected=$(echo "$pick_output" | tail -n +2)
    [[ -z "$selected" ]] && return

    if [[ "$key" == "ctrl-o" ]]; then
        desc=$(echo "$selected" | cut -d$'\x01' -f1 | sed 's/[]\/$*.^[]/\\&/g' | head -c 60)
        lineno=$(grep -n "desc:.*${desc}" "$COMMANDER_YAML" | head -1 | cut -d: -f1)
        if [[ -n "$lineno" ]]; then
            nvim +"$lineno" "$COMMANDER_YAML"
        else
            nvim "$COMMANDER_YAML"
        fi
        return
    fi

    cmd=$(echo "$selected" | cut -d$'\x01' -f2 | sed 's/^ *//' | tr -d '\n')
    cmd=$(echo "$cmd" | sed "$ansi_strip")
    [[ -z "$cmd" ]] && return

    print -s "$cmd" 2>/dev/null
    echo -e "\033[1;32mExecuting:\033[0m $cmd"
    eval "$cmd"
}
