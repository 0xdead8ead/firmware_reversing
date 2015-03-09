#! /bin/sh

CONFIG=/bin/config
sata_diskname=`$CONFIG get sata_diskname`

# no sata 
if [ "x$sata_diskname" = "x" ]; then
	echo "[SMART] can't get the sata diskname!" > /dev/console
	exit
else
	/usr/sbin/smartctl -a /dev/$sata_diskname > /dev/null
	smart_value=`$CONFIG get smart_value`
	if [ "x$smart_value" = "x" ]; then
		echo "[SMART] can't get the smart value by smartctl!" > /dev/console
		exit
	fi
fi

Old_Reallocated_Sector_Ct=`echo "$smart_value" | awk -F '*' '{print $3}'`
Old_Power_On_Hours=`echo "$smart_value" | awk -F '*' '{print $4}'`

echo "start HDD SMART ERROR Checking" > /dev/console

while [ 1 ];
do
	email_flag=0
	smartctl -a /dev/$sata_diskname > /dev/null
	Reallocated_Sector_Ct=`echo "$smart_value" | awk -F '*' '{print $3}'`
	[ $Reallocated_Sector_Ct -eq 0 ] && sleep 307 && continue
	Power_On_Hours=`echo "$smart_value" | awk -F '*' '{print $4}'`
	fixed_checking_day=`expr $Power_On_Hours - $Old_Power_On_Hours`
	fixed_checking_reallocated=`expr $Old_Reallocated_Sector_Ct \* 15`
	if [ $Power_On_Hours -le 24 -a $Reallocated_Sector_Ct -ge 50 ] || [ $Reallocated_Sector_Ct -gt 2500 ]; then
		logger "[HDD ERROR] Warning! The internal hard drive have the reallocated sector error frequently, we suggest you to replace the internal hard drive now." 
  		email_flag=1	
 	elif [ $fixed_checking_day -eq 720 -a $Reallocated_Sector_Ct -ge $fixed_checking_reallocated -a $Reallocated_Sector_Ct -gt 1000 ]; then
 		Old_Power_On_Hours=$Power_On_Hours
 		Old_Reallocated_Sector_Ct=$Reallocated_Sector_Ct
	 	logger "[HDD ERROR] Warning! The internal hard drive have the reallocated sector error frequently, we suggest you to replace the internal hard drive now."
		email_flag=1
	fi

	time_h=`date +%H`
	time_m=`date +%M`
	if [ $time_h -eq 9 -a $time_m -gt 20 -a $time_m -lt 29 ]; then
		if [ $email_flag -eq 1 ]; then
			# When the time is 09:20~09:29, the issue still exist, we'll add the rule to crontab to send email to user at 9:30 AM.
			cat /tmp/etc/crontabs/root | grep email_HDD_err_log
			if [ $? != 0 ]; then
				echo "30 09 * * * /etc/email/email_HDD_err_log" >> /tmp/etc/crontabs/root
				echo "root" > /tmp/etc/crontabs/cron.update
			fi
		else
			#Maybe the user has replace the internal hard driver, we need to clean the rule if the user has resolve it.
			sed -i '/email_HDD_err_log/d' /tmp/etc/crontabs/root
		fi
	fi

 	sleep 307
done
