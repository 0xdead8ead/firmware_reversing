#!/bin/sh

BOOTVER=`getbootver "u-boot" "SVN revision:"`
BOOTCODE="/etc/boot/cfez-nvram-WRGAC01-svn668.bin"
BOOTCODEMD5="/etc/boot/upboot.md5"
BOOTMTD="/dev/mtdblock/6"
NVRAMMTD="/dev/mtdblock/7"
TMPBOOTCODE="/var/tmpbootcode.bin"

if [ "$BOOTVER" == "621" ] || [ "$BOOTVER" == "665" ]; then
  if [ -e "/usr/bin/md5sum" ]; then
    if [ -e "$BOOTCODE" ]; then
	  BOOTSIZE=`ls -l $BOOTCODE | scut -f 5`
	  BOOTMD5=`md5sum $BOOTCODE | scut -f 1`
	  BOOTFILEMD5=`cat $BOOTCODEMD5 | scut -f 1`
	  if [ "$BOOTMD5" != $ "$BOOTFILEMD5" ]; then
		  echo "bootcode md5 error" > /dev/console
		  exit 1
	  fi
	  COUNT=0
	  while [ "$BOOTMD5" != "$DDMD5" ]; do
	    cat $BOOTCODE > $BOOTMTD
	    dd if=$BOOTMTD of=$TMPBOOTCODE bs=1 count=$BOOTSIZE 1>/dev/null 2>&1
	    DDMD5=`md5sum $TMPBOOTCODE | scut -f 1`
		rm $TMPBOOTCODE
		COUNT=`expr $COUNT + 1`
		if [ "$COUNT" -eq "5" ]; then
		  echo "Upgrade failed" > /dev/console
		  exit 1
		fi
	  done
	  echo "Erase nvram data"
	  dd if=/dev/zero of=$NVRAMMTD bs=1 count=65536 1>/dev/null 2>&1
	  echo "Upgrade bootcode complete" > /dev/console
	  reboot
    fi
  fi
fi

exit 0
