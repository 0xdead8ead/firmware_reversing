#!/bin/sh /etc/rc.common

START=60

nvram=/bin/config
SYS_PREFIX=$(${nvram} get leafp2p_sys_prefix)
BROKER_BIN=${SYS_PREFIX}/bin/brokerd
BROKER_PID=/var/run/brokerd.pid

PATH=${SYS_PREFIX}/bin:${SYS_PREFIX}/usr/bin:/sbin:/usr/sbin:/bin:/usr/bin

start()
{
    remote_login=$(${nvram} get leafp2p_remote_login)
    [ -z ${remote_login} ] && return
    ${BROKER_BIN}
}

stop()
{
    killall -KILL brokerd >/dev/null 2>&1
    killall -KILL hook.sh >/dev/null 2>&1
    killall -KILL curl >/dev/null 2>&1
    rm -f ${BROKER_PID}
}

[ "$1" = "start" ] && start
[ "$1" = "stop" ] && stop
