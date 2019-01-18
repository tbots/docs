#!/bin/bash
#
# Looking for already initialized git repositories on the system.
#
# Examine each home directory for any username set on which level
# and display repositories related to a specific user specified on the command line.
find -P ~ -name .git -print
