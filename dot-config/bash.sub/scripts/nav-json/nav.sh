#!/usr/bin/env bash
set -euo pipefail

# source "/home/sy/dotfiles/dot-config/bash.sub/scripts/core/main.sh"

##? JSON navigator
##?
##? Usage:
##?    json  # it is aliased
##?
##? Examples:
##?    cat my.json | nav2
has() {
    type "$1" &> /dev/null
}

_fzf() {
   # shellcheck disable=SC2016
   local -r preview='i={}; echo "$i" | grep -q "^\." || i=".${i}"; echo "$i" | grep -q "^\. = " && q="." || q="$(echo "$i" | sed -E "s|(\.[^ ]+).*|\1|")"; cat "'"$1"'" | jq -C "$q"'
   fzf --ansi --exact --preview "$preview"
}

_input() {
   if has gron; then
      printf '.'
      echo "$1" | gron -c
   else
      echo "$1" | jq '[path(..)|map(if type=="number" then "[]" else tostring end)|join(".")|split(".[]")|join("[]")]|unique|map("."+.)|.[]' -r
   fi
}

_pretty() {
   sed 's|json||' # | sed '/^\./! s/.*/\.&/' \
   }

main() {
   local -r content="$(cat)"
   local -r temp_file=$(mktemp)
   trap 'rm -f "$temp_file"' 0 2 3 15
   echo "$content" > "$temp_file"
   _input "$content" | _pretty | _fzf "$temp_file"
}

main "$@"
