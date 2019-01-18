#!/bin/bash

source /etc/icewarp/icewarp.conf
TOOL=$IWS_INSTALL_DIR/tool.sh

$TOOL --filter="(U_Type='0')" get account "*@*" | sed '/^$/d'
