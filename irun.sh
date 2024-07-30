#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 '<filename>'"
    exit 2
fi

# Prints an error message if a command is not found.
not_found() {
    echo "Error: $1 command not found"
    exit 1
}

TMUX_BIN=$(command -v tmux) || not_found tmux
BAT_BIN=$(command -v bat) || not_found bat
FZF_BIN=$(command -v fzf) || not_found fzf

if [ -z "$TMUX" ]; then
    IRUN_SESSION=irun-$$
    $TMUX_BIN new-session -s $IRUN_SESSION -d \
        "IRUN_SESSION=$IRUN_SESSION $0 $1" \; split-window -h $SHELL
    $TMUX_BIN select-pane -t $IRUN_SESSION:0.0
    $TMUX_BIN attach-session -t "$IRUN_SESSION"
    exit 0
fi

if [ -z "$IRUN_SESSION" ]; then
    echo "Cannot run inside a tmux session"
    exit 3
fi

FILE=$1

$BAT_BIN -p -f $FILE | $FZF_BIN --disabled --layout=reverse --ansi --no-info \
--bind=\
"up:up+change-query(),down:down+change-query(),\
q:execute-silent($TMUX_BIN kill-session -t $IRUN_SESSION),\
enter:execute-silent($TMUX_BIN send-keys -t $IRUN_SESSION:0.1 {} Enter)+down,\
e:execute-silent($TMUX_BIN send-keys -t $IRUN_SESSION:0.1 {}; \
$TMUX_BIN select-pane -t $IRUN_SESSION:0.1)+down"

