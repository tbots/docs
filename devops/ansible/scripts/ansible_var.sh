#!/bin/bash

ansible -k -m setup $1 | grep -o "ansible_\w\+"
