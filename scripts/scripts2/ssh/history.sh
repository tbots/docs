#!/bin/bash
#
# report all hosts found in $HOME/.bashrc that were accessed by ssh command

#grep ssh ~/.bash_history
address=( `sed -n "/.*ssh.*@\(\S*\).*/s//\1/p" ~/.bash_history` )

i
