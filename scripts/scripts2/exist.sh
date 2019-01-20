#!/bin/bash

test -a /tmp/notes && { echo "/tmp/notes    [ok]"; } || { echo "/tmp/notes   [missing]"; } 
