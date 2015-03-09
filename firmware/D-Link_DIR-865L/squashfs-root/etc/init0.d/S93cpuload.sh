#!/bin/sh

if [ -f "/etc/scripts/cpuload.sh" ]; then
    /etc/scripts/cpuload.sh &
fi

exit 0
