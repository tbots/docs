tmux new-session -d -s docker -c ~/docs/docker -n notes
tmux new-window  -t docker:1 -c ~/docs/docker -n cli
tmux attach-session -t docker:1
