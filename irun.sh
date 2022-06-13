#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 '<filename>'"
    exit 2
fi

if [ -z "$TMUX" ]; then
    # We are outside a tmux session, start a new one.
    IRUN_SESSION=irun-$$
    tmux new-session -s $IRUN_SESSION -d "IRUN_SESSION=$IRUN_SESSION $0 $1" \; split-window -h $SHELL
    tmux select-pane -t $IRUN_SESSION:0.0
    tmux attach-session -t "$IRUN_SESSION"
    exit 0
fi

paginate () {
    # Do pagination if needed. $1 is the highlighted line if there is
    # no pagination
    if [ $line -lt $start_line ]; then
        end_line=$start_line
        start_line=$((end_line - TERM_LINES))
        if [ $start_line -lt 1 ]; then
            start_line=1
        fi
        clear
    elif [ $line -gt $end_line ]; then
        start_line=$end_line
        end_line=$((start_line + TERM_LINES))
        if [ $end_line -gt $FILE_LINES ]; then
            end_line=$FILE_LINES
        fi
        clear
    else
        tput cup $1 0
        tput el
    fi
}

process_input () {
    case $1 in
        j)
            if [ $line -ne $FILE_LINES ]; then
                line=$((line+1))
                paginate $((line-start_line-1))
            fi
            ;;
        k)
            if [ $line -ne 1 ]; then
                line=$((line-1))
                paginate $((line-start_line+1))
            fi
            ;;
        q)
            tmux kill-session -t $IRUN_SESSION
            exit 0
            ;;
        e)
            cmd=`bat -p -r $line:$line $FILE`
            tmux send-keys -t $IRUN_SESSION:0.1 "$cmd" Enter
            if [ $line -ne $FILE_LINES ]; then
                line=$((line+1))
                paginate $((line-start_line-1))
            fi
            ;;
        E)
            cmd=`bat -p -r $line:$line $FILE`
            tmux send-keys -t $IRUN_SESSION:0.1 "$cmd"
            tmux select-pane -t $IRUN_SESSION:0.1
            if [ $line -ne $FILE_LINES ]; then
                line=$((line+1))
                paginate $((line-start_line-1))
            fi
            ;;
        *)
            ;;
    esac
}

FILE=$1
TERM_LINES=$(tput lines)
((--TERM_LINES))
FILE_LINES=`cat $FILE | wc -l`

start_line=1
line=1
end_line=$(( TERM_LINES < FILE_LINES ? TERM_LINES : FILE_LINES ))

while true; do
    tput cup 0 0
    cut -c -$COLUMNS $FILE | bat -p -H $line -r $start_line:$end_line
    read -s -n1 input
    process_input $input
done

