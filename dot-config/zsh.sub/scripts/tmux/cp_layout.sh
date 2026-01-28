#!/bin/zsh
tmux list-w \
          | grep \* \
          | sed 's/.*\[layout //' \
          | sed 's/\] .*//' \
          | tee >(xclip -selection clipboard) \
          | tmux display-message "layout copyed"
                # >(xargs tmux display-message)
