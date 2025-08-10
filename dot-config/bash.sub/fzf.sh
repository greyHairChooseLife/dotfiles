export FZF_DEFAULT_OPTS="
  --multi
  --bind 'ctrl-r:clear-query'
  --bind 'ctrl-g:jump'
  --bind 'ctrl-h:last'
  --bind 'ctrl-l:first'
  --bind 'ctrl-b:half-page-up'
  --bind 'ctrl-f:half-page-down'
  --bind 'ctrl-u:half-page-up'
  --bind 'ctrl-d:half-page-down'
  --bind 'alt-k:preview-half-page-up'
  --bind 'alt-j:preview-half-page-down'
  --bind 'alt-p:toggle-preview'
  --bind 'tab:toggle-up'
  --bind 'shift-tab:toggle-down'
  --bind 'ctrl-e:execute(printf "%s" {} | xclip -selection clipboard)+abort'
  --bind 'alt-e:execute(printf "%s" {} | xclip -selection clipboard)'
  --bind 'ctrl-alt-w:execute(echo {+} | xargs -d \" \" -I{} printf \"%s\\n\" {} | tac | xclip -selection clipboard)'
  --color='preview-bg:#222222,hl:#1e90ff,hl+:#1e90ff,bg+:#444444,border:#222222,pointer:#1e90ff,bg+:#444444,scrollbar:#1e90ff,preview-scrollbar:#1e90ff'
  --pointer=' '
  --marker='●∙'
  --scrollbar='▉'
"
# √

# reference by https://github.com/junegunn/fzf/blob/master/ADVANCED.md
