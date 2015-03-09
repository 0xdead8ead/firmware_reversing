#!/bin/sh
#-------------------------------------------------------------------------
#  Copyright 2010, NETGEAR
#  All rights reserved.
#-------------------------------------------------------------------------
# arg: -
#-------------------------------------------------------------------------

# load environment
. /opt/remote/bin/env.sh

ENCLOSURE="/home/netgear/log/enclosure.log"

get_enclosure()
{
    DATA="<enclosure>"
    DATA="${DATA}<temps>"
    local LINES=$(cat "${ENCLOSURE}" | grep "temp!!")
    for line in ${LINES[@]}
    do
	if [[ "$line" =~ "^temp!!(.*)!!status=(.*)::descr=(.*)::expected=(.*)" ]]; then
	    DATA="${DATA}<temp><id>${BASH_REMATCH[1]}</id><status>${BASH_REMATCH[2]}</status><descr>${BASH_REMATCH[3]}</descr><expected>${BASH_REMATCH[4]}</expected></temp>"
	fi
    done
    DATA="${DATA}</temps>"
    DATA="${DATA}<fans>"
    LINES=$(cat "${ENCLOSURE}" | grep "fan!!")
    for line in ${LINES[@]}
    do
	if [[ "$line" =~ "^fan!!(.*)!!status=(.*)::descr=(.*)::type=(.*)" ]]; then
	    DATA="${DATA}<fan><id>${BASH_REMATCH[1]}</id><status>${BASH_REMATCH[2]}</status><descr>${BASH_REMATCH[3]}</descr><type>${BASH_REMATCH[4]}</type></fan>"
	fi
    done
    DATA="${DATA}</fans>"
    DATA="${DATA}<volumes>"
    LINES=$(cat "${ENCLOSURE}" | grep "volume!!")
    for line in ${LINES[@]}
    do
	if [[ "$line" =~ "^volume!!(.*)!!status=(.*)::descr=(.*)" ]]; then
	    DATA="${DATA}<volume><id>${BASH_REMATCH[1]}</id><status>${BASH_REMATCH[2]}</status><descr>${BASH_REMATCH[3]}</descr></volume>"
	fi
    done
    DATA="${DATA}</volumes>"
    DATA="${DATA}<disks>"
    LINES=$(cat "${ENCLOSURE}" | tr -d '\015' | grep "disk!!")
    for line in ${LINES[@]}
    do
	if [[ "${line}" =~ "^disk!!(.*)!!status=(.*)::descr=(.*)$" ]]; then
	    DATA="${DATA}<disk><id>${BASH_REMATCH[1]}</id><status>${BASH_REMATCH[2]}</status><descr>${BASH_REMATCH[3]}</descr></disk>"
	fi
    done
    DATA="${DATA}</disks>"
    DATA="${DATA}</enclosure>"
    echo $DATA
}

get_enclosure
