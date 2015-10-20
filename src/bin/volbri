#!/bin/bash
user=$(whoami)
SOCK=/tmp/$user/volbrid.sock
if [[ ! -e $SOCK ]];then
    echo "Server socket at $SOCK not found. Start server with volbrid(1)"
    exit 12
fi
echo $@|socat - "UNIX-CONNECT:$SOCK"
