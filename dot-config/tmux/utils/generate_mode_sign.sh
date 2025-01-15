#!/bin/bash

key_table="$1"
mode="$2"

# key_table별 표시와 스타일
main() {
  echo "key_table: $key_table" > ~/key_table.log

  case "$key_table" in
    root)
      mode_format='#[bg="#ffffff"#,fg="#000000"]      #[fg="#f00000"]󰜎 #[fg="#4169e1"]󰜎 #[fg="#00ff00"]󰜎 #[fg="#ff00ff"]󰜎      #[none,italics,fg="#000000"] tmux '
      mode_style="bg=#000000,fg=#00ff00"
      ;;
    copy-mode)
      mode_format='#[bg="#ffff00"#,fg="#000000"]          COPY            '
      mode_style="bg=#000000,fg=#00ff00"
      ;;
    session-mode)
      mode_format='#[bg="#ff0000"#,fg="#000000"]          SESSION         '
      mode_style="bg=#000000,fg=#ff0000"
      ;;
    window-mode)
      mode_format='#[bg="#4169e1"#,fg="#000000"]          WINDOW          '
      mode_style="bg=#000000,fg=#4169e1"
      ;;
    pane-mode)
      mode_format='#[bg="##00ff00"#,fg="#000000"]          PANE            '
      mode_style="bg=#000000,fg=#00ff00"
      ;;
    resize-mode)
      mode_format='#[bg="#ff00ff"#,fg="#000000"]          RESIZE          '
      mode_style="bg=#000000,fg=#ff00ff"
      ;;


    *)
      mode_format="$key_table"
      mode_style="bg=#000000,fg=#ffffff"
      ;;
  esac

  # mode 파라미터에 따라 다른 출력
  if [ "$mode" = "format" ]; then
    echo "$mode_format"
  elif [ "$mode" = "style" ]; then
    echo "$mode_style"
  fi
}
main
