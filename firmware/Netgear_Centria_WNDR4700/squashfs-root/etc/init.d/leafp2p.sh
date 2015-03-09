#!/bin/sh /etc/rc.common

#START=50

nvram=/bin/config
SYS_PREFIX=$(${nvram} get leafp2p_sys_prefix)
CHECK_LEAFP2P=${SYS_PREFIX}/bin/checkleafp2p.sh
CHECK_LEAFNETS=${SYS_PREFIX}/bin/checkleafnets.sh

PATH=${SYS_PREFIX}/bin:${SYS_PREFIX}/usr/bin:/sbin:/usr/sbin:/bin:/usr/bin

start()
{
    # Ready Share Remote: if we had not registered, we must not start the module
    local SHARE_LOGIN=$(${nvram} get leafp2p_remote_login)
    if [ -z ${SHARE_LOGIN} ]; then
	exit 0
    fi

    ${CHECK_LEAFP2P} &
    ${CHECK_LEAFNETS} &
}

stop()
{
    killall checkleafnets.sh 2>/dev/null
    killall -INT leafp2p 2>/dev/null
    killall checkleafp2p.sh 2>/dev/null
}

[ "$1" = "start" ] && start
[ "$1" = "stop" ] && stop
