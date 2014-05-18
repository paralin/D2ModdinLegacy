#!/bin/bash
tmux start-server
tmux new-session -d -s server -n "bash"
tmux send-keys -t server:0 "cd /root/d2mp/; ROOT_URL=http://d2modd.in/ meteor --production --port 80" C-m
