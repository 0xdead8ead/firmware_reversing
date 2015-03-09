#!/bin/sh
#-------------------------------------------------------------------------
#  Copyright 2010, NETGEAR
#  All rights reserved.
#-------------------------------------------------------------------------
# arg: -
#-------------------------------------------------------------------------

# load environment
. /opt/remote/bin/env.sh

while true;
do

    # changed to work with nvram
    leafp2p_username=$(${nvram} get leafp2p_username)
    [ -z $leafp2p_username ] && {
	sleep 30
	continue
    }

    # connect entry
    URL=$(${nvram} get leafp2p_replication_hook_url)

    # auth data
    NAS_NAME=$(${nvram} get leafp2p_username)
    NAS_PASS=$(${nvram} get leafp2p_password)

    # construct exec
    EXEC="${SYS_PREFIX}/bin/curl -N --tcp-nodelay --basic --user ${NAS_NAME}:${NAS_PASS} --keepalive-time 30 --connect-timeout 15 --max-time 360000 -k --url ${URL}"

    # no need to analise any errors
    EXEC="${EXEC} 2>/dev/null"

    eval "${EXEC}"

    sleep 5

done
