#!/bin/bash
SOCK=/tmp/volbrid.sock
if [[ ! -e $SOCK ]];then
    echo "Start server with volbrid(1)"
    exit 12
fi
echo $@|socat - "UNIX-CONNECT:$SOCK"
