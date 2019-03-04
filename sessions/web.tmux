tmux new-session -d -s web -c /etc/apache2/sites-enabled -n ensite
tmux new-window  -t web -n doc_root -c /var/www/html/kerberos.kendaxa.net
tmux attach-session -t web
