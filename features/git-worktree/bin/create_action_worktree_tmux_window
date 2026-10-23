#!/bin/bash

# Layout of tmux wnidow for action worktree

_base=$(basename "$PWD")
_default=${_base#*.}
[ "$_default" = "$_base" ] && _default=$_base

echo "🏳️  pwd:"
echo " - $PWD"
read -r -p "Window name [default: $_default]: " _input
WINDOW_NAME=${_input:-$_default}

if tmux select-window -t "$WINDOW_NAME" 2>/dev/null; then
    exit 0
fi

tmux new-window -n $WINDOW_NAME -c "$PWD"

# Plan
tmux send-keys -t $WINDOW_NAME "name_pane plan && vi docs/" Enter

# LLM
tmux split-window -t $WINDOW_NAME -h -c "$PWD"
tmux send-keys -t $WINDOW_NAME "name_pane LLM && claude" Enter

# Server
tmux split-window -t $WINDOW_NAME -h -c "$PWD"
tmux send-keys -t $WINDOW_NAME "name_pane Server && clear" Enter
tmux select-layout -t $WINDOW_NAME even-horizontal # layout

# Code
tmux split-window -t $WINDOW_NAME -v -c "$PWD"
tmux send-keys -t $WINDOW_NAME "name_pane Code && clear" Enter

# DB
tmux select-pane -l # move to Server-pane
tmux split-window -t $WINDOW_NAME -v -c "$PWD"
tmux send-keys -t $WINDOW_NAME "name_pane DB && clear" Enter
