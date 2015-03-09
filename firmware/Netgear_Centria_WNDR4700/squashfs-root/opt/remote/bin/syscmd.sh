#!/bin/sh
#-------------------------------------------------------------------------
#  Copyright 2011, NETGEAR
#  All rights reserved.
#-------------------------------------------------------------------------
# arguments: "<action>[:<msg.guid>]"
#-------------------------------------------------------------------------

# check args number
[ $# == 0 ] && exit $ERROR

# load environment
. /opt/remote/bin/comm.sh

# TODELETE
#echo "${1}" >> "${SYS_PREFIX}/bin/syscmd.log"

# parse arguments
# MSG_GUID=`echo "${1}" | tr -d '\015'`
# MSG_GUID=${1}

#
# arg: <msg.guid>
#
do_getinfo()
{
    local guid="${1}"
    DATA="<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    DATA="${DATA}<request moniker=\"/root/devices\" method=\"sendinfo\">"
    DATA="${DATA}<body type=\"deviceinfo\">"
    DATA="${DATA}<guid>${guid}</guid><value><![CDATA["
    DATA="${DATA}<deviceinfo>"
    # add date/time
    DATA="${DATA}<date>`date +'%s'000`</date>"
    # add TZ
    # tz=(`readlink /etc/localtime`)
    DATA="${DATA}<tz>UTC</tz>"
    # add uptime
    # up=(`uptime |awk '{print $3}'`)
    DATA="${DATA}<uptime>1</uptime>"
    # add hostname
    DATA="${DATA}<hostname>WNDR4700</hostname>"
    # add identity
    # DATA="${DATA}`${SYS_PREFIX}/bin/getinfo.pl`"
	DATA="${DATA}<identity><arch>powerpc</arch><model>WNDR4700</model><osname>OpenWRT</osname><osver>1.0.4.68</osver><serial>`remote_smb_conf -get_device_serial_number`</serial></identity>"
    # add enclosure
    # DATA="${DATA}`${SYS_PREFIX}/bin/enclosure.sh`"
	DATA="${DATA}<enclosure><temps></temps><fans></fans><volumes></volumes><disks></disks></enclosure>"
    # add meminfo
    DATA="${DATA}<mem><size>` cat /proc/meminfo | grep MemTotal | awk '{print $2}'`</size><free>`cat /proc/meminfo | grep MemFree | awk '{print $2}'`</free></mem>"
	# add fs
    # DATA="${DATA}<volumes>"
    # for f in "c" "d" "e" "f";
    # do
	# if [ -d "/${f}" ]; then
	#    DATA="${DATA}<volume mount=\"/${f}\"><size>`df "/${f}" | tail -1 | awk '{print $2}'`</size><free>`df "/${f}" | tail -1 | awk '{print $4}'`</free></volume>"
	# fi
    # done 
    # DATA="${DATA}</volumes>"
	DATA="${DATA}<volumes>"
	for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
	do
	    if [ -d "/mnt/sda${i}" ]; then
		DATA="${DATA}<volume mount=\"/u\"><size>`df "/mnt/sda${i}" | ${SYS_PREFIX}/bin/tail -1 | awk '{print $2}'`</size><free>`df "/mnt/sda${i}" | ${SYS_PREFIX}/bin/tail -1 | awk '{print $4}'`</free></volume>"
	    fi
	done
    DATA="${DATA}</volumes>"
    DATA="${DATA}</deviceinfo>"
    DATA="${DATA}]]></value></body></request>"
    
    # post it
	# echo "OUTPUT SYSTEM INFO: ${DATA}"
    comm_post "${DATA}" || {
	echo Failed to post data ${DATA}
	return $ERROR
    }
    exit $OK
}

#
# arg: -
#
do_unregister()
{
    rm -f "${SYS_PREFIX}/etc/registration.conf"
    :> "${SYS_PREFIX}/etc/cron.d/replication"
}

#########################################

[ $# == 0 ] && {
    print_usage
    exit $ERROR
}

action="${1}"

case "${action}" in
    "getinfo")
	do_getinfo "${2}"
	;;
    "unregister")
	do_unregister
	;;
    *)
	echo "Incorrect action parameter"
	exit $ERROR
	;;
esac

exit $OK
