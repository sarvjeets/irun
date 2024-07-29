#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 '<filename>'"
    exit 2
fi

if [ -z "$TMUX" ]; then
    IRUN_SESSION=irun-$$
    tmux new-session -s $IRUN_SESSION -d \
        "IRUN_SESSION=$IRUN_SESSION $0 $1" \; split-window -h $SHELL
    tmux select-pane -t $IRUN_SESSION:0.0
    tmux attach-session -t "$IRUN_SESSION"
    exit 0
fi

if [ -z "$IRUN_SESSION" ]; then
    echo "Cannot run inside a tmux session"
    exit 3
fi

FILE=$1

bat -p -f $FILE | fzf --disabled --layout=reverse --ansi --no-info \
--bind=\
"up:up+change-query(),down:down+change-query(),\
q:execute-silent(tmux kill-session -t $IRUN_SESSION),\
enter:execute-silent(tmux send-keys -t $IRUN_SESSION:0.1 {} Enter)+down,\
e:execute-silent(tmux send-keys -t $IRUN_SESSION:0.1 {}; \
tmux select-pane -t $IRUN_SESSION:0.1)+down"

