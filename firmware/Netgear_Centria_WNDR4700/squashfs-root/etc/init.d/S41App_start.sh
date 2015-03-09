#!/bin/sh

mode=`cat /etc/app_mode`

if [ $mode == "router" ]
then 
	echo "Starting WNDR4700 as Router!"
	. /usr/local/sbin/router_app.sh
elif [ $mode == "ap" ]
then
	echo "Starting WNDR4700 as Access Point !"
	. /usr/local/sbin/accesspoint_app.sh

elif [ $mode == "ap_dumb" ]
then
	echo "Starting WNDR4700 as Access Point, AR8327 as dump switch !"
	. /usr/local/sbin/accesspoint_dumb_sw_app.sh
fi
