tmux new-session -d -s gordon -n qrcode  -c ~/ftp
tmux new-window  -t gordon    -n php-doc -c ~/docs/php
tmux attach-session -t gordon
