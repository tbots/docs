tmux new -d -s ansible -c ~/docs/ansible -n docs
tmux new-window -t ansible:1 -c ~/docs/ansible/playbooks -n playbooks
tmux attach -t ansible
