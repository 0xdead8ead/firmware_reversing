#!/bin/sh

nvram=/bin/config
SYS_PREFIX=$(${nvram} get leafp2p_sys_prefix)
P2P_BIN=${SYS_PREFIX}/bin/leafp2p

PATH=${SYS_PREFIX}/bin:${SYS_PREFIX}/usr/bin:/sbin:/usr/sbin:/bin:/usr/bin

#If this is script is already running dont start it again
local pid=`pidof checkleafp2p.sh`
[ ! "x${pid}" == "x$$" ] && return ${OK}

#If leafp2p is not running for any reason start it
while [ 1 ]
do
local lpid=`pidof leafp2p`
if [ -z "${lpid}" ]
then
    ${P2P_BIN} >/dev/null 2>/dev/null &
fi
sleep 5 2>/dev/null
done
