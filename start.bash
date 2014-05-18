#!/bin/bash
tmux start-server
tmux new-session -d -s server
tmux new-window -t server:1 -n "bash"
tmux send-keys -t server:1 "cd /root/d2mp/; ROOT_URL=http://d2modd.in/ meteor --production --port 80" C-m
