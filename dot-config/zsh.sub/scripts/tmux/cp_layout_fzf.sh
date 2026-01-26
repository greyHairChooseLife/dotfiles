#!/bin/bash
tmux list-w \
          | fzf \
          | sed 's/.*\[layout //' \
          | sed 's/\] .*//' \
          | tee >(xclip -selection clipboard)
                # >(xargs tmux display-message)
