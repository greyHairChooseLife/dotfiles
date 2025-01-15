#!/bin/bash

main() {
  if [ -n "${TMUX_RESURRECT_DIR}" ] && [ -d "${TMUX_RESURRECT_DIR}" ]; then
    rm -f ${TMUX_RESURRECT_DIR}/*
    tmux display-message "all cleared"
  else
    echo "Error: TMUX_RESURRECT_DIR is not set or invalid."
  fi
}
main
