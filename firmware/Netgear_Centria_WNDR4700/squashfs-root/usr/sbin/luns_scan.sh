#!/bin/sh 
PRINT_OUT=/dev/null
#PRINT_OUT=/dev/console
card_reader_dev_name=
have_card_device=
card_dev_list=
cd /sys/block/
for i in `ls -d sd*`
do
	#echo "check $i"  > ${PRINT_OUT}
        ls -l /sys/block/$i/device 2>&1 | grep otg 2>&1 > ${PRINT_OUT}
        if [ $? -eq 0 ]; then
                #echo "$i is card reader"  > ${PRINT_OUT}
        	card_reader_dev_name=$i
		config set sd_card_diskname=$i
		break;
        fi
done

while [ "x$card_reader_dev_name" != "x" ]; do
		list=""
		# To fix bug 38194, sd card can't be mounted normally for GUID partition table, fdisk can't list all of the partitions
		fdisk -l /dev/$card_reader_dev_name 2>&1 | grep "/dev/sd" | awk '{if($1!="Disk") print $1;}' | sed 's/\/dev\///g' > ${PRINT_OUT}
                for i in `cat /proc/partitions | grep "$card_reader_dev_name" | awk '{print $4}'`
		do
			if [ "x$i" != "xWARNING:" -a "$i" != "$card_reader_dev_name" ]; then
				list="$list*$i"
			fi
		done
                if [ "x$list" = "x$card_dev_list" ]; then
			sleep 1
			continue
		fi
	
                if [ "$list" \< "$card_dev_list" ]; then
                        echo "$i SD card is removed" > ${PRINT_OUT}
                        for j in `ls /sys/block/$card_reader_dev_name | grep "$card_reader_dev_name"`
                        do
				mount_status=`mount | grep $j`
				echo "$card_dev_list" | grep $j 2>&1 > ${PRINT_OUT}
                                if [ "x$mount_status" != "x" -o $? -eq 0 ]; then
					card_dev_list="`echo $card_dev_list | sed 's/'*$j'//g'`"
					echo remove > /sys/block/$card_reader_dev_name/$j/uevent
						sleep 7 
                                else
				  	echo "/dev/$j not existed" > ${PRINT_OUT}
                                fi
                        done
                else
			sleep 11
                        #echo "$i SD card is added"  > ${PRINT_OUT}
                        for j in `ls /sys/block/$card_reader_dev_name | grep "$card_reader_dev_name"`
                        do
				mount_status=`mount | grep $j`
				echo "$card_dev_list" | grep $j 2>&1 > ${PRINT_OUT}
                                if [ "x$mount_status" != "x" -o $? -eq 0 ]; then
                                        echo "/dev/$j existed" > ${PRINT_OUT}
					card_dev_list="`echo $card_dev_list | sed 's/'*$j'//g'`"
					card_dev_list="$card_dev_list*$j"
                                else
					card_dev_list="$card_dev_list*$j"
                                        echo add > /sys/block/$card_reader_dev_name/$j/uevent
					have_card_device=1
					sleep 5 
                                fi
                        done
                fi
done
