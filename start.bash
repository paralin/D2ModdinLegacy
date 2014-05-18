#!/bin/bash
tmux start-server
tmux new-session -d -s server
#tmux new-window -t server:1 -n bash
tmux send-keys -t server:0 "bash" C-m
sleep 1s
tmux send-keys -t server:0 "cd /root/d2mp/ && ROOT_URL=http://d2modd.in/ /usr/local/bin/meteor --production --port 80" C-m
