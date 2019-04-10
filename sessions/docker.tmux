tmux new-session -d -s docker -c ~/docs/docker -n notes
tmux new-window  -t docker:1 -n cli sudo -i
tmux attach-session -t docker:1
