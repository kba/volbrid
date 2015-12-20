#!/bin/bash
user=$(whoami)
SOCK=/tmp/$user/volbrid.sock
if [[ ! -e $SOCK ]];then
    echo "Server socket at $SOCK not found. Starting server with volbrid(1)."
fi
status() {
    pid=$(pgrep -f volbrid)
    if [[ -z "$pid" ]];then
        echo "STOPPED"
    else
        echo "RUNNING[$pid]"
    fi
}
stop() {
    if [[ $(status) != 'STOPPED' ]];then
        echo "Stopping volbrid"
        pkill -ef volbrid
    fi
}
start() {
    stopped=$(stop)
    if [[ -z "$stopped" ]];then
        echo "Starting volbrid"
    else
        echo "Restarting volbrid"
    fi
    volbrid
}
if [[ -z "$1" ]];then
    start
elif [[ "$1" == '--quit' ]];then
    stop
elif [[ "$1" == '--status' ]];then
    status
else
    echo $@|socat - "UNIX-CONNECT:$SOCK"
fi
