#!/bin/sh
orig_devconfsize=`xmldbc -g /runtime/device/devconfsize`
echo [$0]: $1 ... > /dev/console
if [ "$1" = "start" ] && [ "$orig_devconfsize" = "0" ]; then
	if [ -f "/usr/sbin/login" ]; then
		image_sign=`cat /etc/config/image_sign`
		telnetd -l /usr/sbin/login -u Alphanetworks:$image_sign -i br0 &
	else
		telnetd &
	fi
else
	killall telnetd
fi
