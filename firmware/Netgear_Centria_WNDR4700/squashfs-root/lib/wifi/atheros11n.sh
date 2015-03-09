#!/bin/sh
append DRIVERS "atheros11n"

DNICONFIG=/bin/config

clear_wifi_ebtables(){
ETH_P_ARP=0x0806
ETH_P_RARP=0x8035
ETH_P_IP=0x0800
IPPROTO_ICMP=1
IPPROTO_UDP=17
DHCPS_DHCPC=67:68
PORT_DNS=53

ebtables -D FORWARD -p $ETH_P_ARP -j ACCEPT
ebtables -D FORWARD -p $ETH_P_RARP -j ACCEPT
ebtables -D FORWARD -p $ETH_P_IP --ip-proto $IPPROTO_UDP --ip-dport $DHCPS_DHCPC -j ACCEPT
ebtables -D INPUT -p $ETH_P_IP --ip-proto $IPPROTO_UDP --ip-dport $DHCPS_DHCPC -j ACCEPT
ebtables -D INPUT -p $ETH_P_IP --ip-proto $IPPROTO_UDP --ip-dport $PORT_DNS -j ACCEPT

ebtables -L | grep  "ath" > /tmp/wifi_rules
while read loop
        do
		ebtables -D INPUT $loop;
		ebtables -D FORWARD $loop;
        done < /tmp/wifi_rules

}
enable_atheros11n() {
    local device="$1"
    local caller="$2"
    local ifs=

    [ "x$caller" != "xdni" ] && return
    update-wifi;
    config_get ifname_prefix "$device" ifname_prefix
    config_get hwmode "$device" hwmode
    config_get bridge "$device" bridge
    BRIDGE_IF=${bridge:-"br0"} PATH="$PATH:/etc/ath" /sbin/dni_apup;
    case "$hwmode" in
        dual)
            wlg_exist=on
            wla_exist=on
            ;;
        11an)
            wlg_exist=off
            wla_exist=on
            ;;
        *)
            wlg_exist=on
            wla_exist=off
            ;;
    esac
    if [ "$wlg_exist" = "on" ]; then
        wlg_radio=`ifconfig ${ifname_prefix}0 | grep "UP"`
        if [ -n "$wlg_radio" ]; then
            cat /proc/uptime | sed 's/ .*//' > /tmp/WLAN_uptime
        fi
    fi
    if [ "$wla_exist" = "on" ]; then
        wla_radio=`ifconfig ${ifname_prefix}1 | grep "UP"`
        if [ -n "$wla_radio" ]; then
            cat /proc/uptime | sed 's/ .*//' > /tmp/WLAN_uptime_5G
        fi
    fi
    if [ -f /proc/sys/dfs_detect/channel_interval -a -f /tmp/tmp_nol ]; then
        dfs_info=$(cat /tmp/tmp_nol);
        echo $dfs_info > /proc/sys/dfs_detect/channel_interval
    fi
    /sbin/cmdigmp restart
    /usr/sbin/net-wall restart >/dev/console
}

disable_atheros11n() {
    local device="$1"
    local caller="$2"

    [ "x$caller" != "xdni" ] && return

    config_get bridge "$device" bridge
    if [ -f /proc/sys/dfs_detect/channel_interval ]; then
        cat /proc/sys/dfs_detect/channel_interval > /tmp/tmp_nol
    fi
    # If WPS led is blinking, just stop it.
    test -f /var/run/wps_led.pid && {
        kill $(cat /var/run/wps_led.pid)
        /sbin/ledcontrol -n wps -c green -s off
        rm -f /var/run/wps_led.pid
    }
    wpsled wps_lock_down off;
    BRIDGE_IF=${bridge:-"br0"} PATH="$PATH:/etc/ath" /etc/ath/apdown;
    [ "on" = "${ebtables_exist}" ] && clear_wifi_ebtables;
    rm -f /tmp/WLAN_uptime*
}

update_config()
{
    local val
    case "$1" in
        on)
            val=1;
            ;;
        *)
            val=0;
            ;;
    esac

    $DNICONFIG set endis_wl_radio=$val
    if [ $NUM_RADIO -eq 2 ]; then
        $DNICONFIG set endis_wla_radio=$val
    fi
    $DNICONFIG commit
}

wifitoggle_atheros11n() {
    local device="$1"
    config_get hwmode "$device" hwmode
    case "$hwmode" in
        dual)
            wlg_exist=on
            wla_exist=on
            ;;
        11an)
            wlg_exist=off
            wla_exist=on
            ;;
        *)
            wlg_exist=on
            wla_exist=off
            ;;
    esac

    WIFI_TOGGLE_LOCK_FILE=/tmp/.wifi_toggle_lock
    [ -f /etc/ath/board.conf ] && . /etc/ath/board.conf
    if [ "$wlg_exist" = "on" -a "$wla_exist" = "on" ]; then
        NUM_RADIO=2
    else
        NUM_RADIO=1
    fi
    MAX_VAP=8

    if [ -f $WIFI_TOGGLE_LOCK_FILE ]; then
    # Just exit if previous wifi toggle is not done.
        exit
    fi
    touch $WIFI_TOGGLE_LOCK_FILE

    active_radio=0
    num=0
    while [ $num -lt $NUM_RADIO ]; do
    # check if wifi interface is up.
        radio_status=`ifconfig | grep wifi$num`
        if [ "x$radio_status" != "x" ]; then
        # if interface is up, increate active_radio counter.
            active_radio=`expr $active_radio + 1`
        fi
        num=`expr $num + 1`
    done

    if [ $active_radio -eq 0 ]; then
        NEXT_STATE=on
    else
    # if any one radio is down, then next action is to turn off every radio.
        NEXT_STATE=off
    fi

    echo "Turn Radio to $NEXT_STATE"

    # wps led should be turn on if security is not none and wireless is switch on
    if [ $NUM_RADIO -eq 1 ]; then
        WPS_LED_OFF='echo 1 > /proc/simple_config/simple_config_led'
        WPS_LED_ON='echo 2 > /proc/simple_config/simple_config_led'
    else
        WPS_LED_OFF='echo 0 > /proc/simple_config/tricolor_led'
        WPS_LED_ON='echo 1 > /proc/simple_config/tricolor_led'
    fi
    [ "$wlg_exist" = "on" ] && G_SECURITY_TYPE=`$DNICONFIG get wl_sectype`
    [ "$wla_exist" = "on" ] && A_SECURITY_TYPE=`$DNICONFIG get wla_sectype`

    if [ "$NEXT_STATE" = "on" ]; then
        num=0
        while [ $num -lt $NUM_RADIO ]; do
            ifconfig wifi$num up 2>&1 > /dev/null
            num=`expr $num + 1`
        done
        num=0
        while [ $num -lt $MAX_VAP ]; do
            vap_status=`ifconfig -a | grep ath$num`
            if [ "x$vap_status" != "x" ]; then
                ifconfig ath$num up 2>&1 > /dev/null
            fi
            num=`expr $num + 1`
        done
        if [ $NUM_RADIO -eq 1 ]; then
            [ "${G_SECURITY_TYPE}" -gt "1" ] && eval ${WPS_LED_ON} || eval ${WPS_LED_OFF}
        else
            [ "${G_SECURITY_TYPE}" -gt "1" -o "${A_SECURITY_TYPE}" -gt "1" ] && eval ${WPS_LED_ON} || echo "Ignore turn off WPS LED in wifitoggle on"
        fi
        if [ -f /tmp/conf_filename ]; then
            hostapd  -B `cat /tmp/conf_filename` -e /etc/wpa2/entropy
        elif [ -f /tmp/aplist0 -o -f /tmp/aplist1 ]; then
        # remove masked interface
            sed -i 's/^#//g' /tmp/topology.conf
            hostapd /var/run/topology.conf &
        fi
        if [ "$wlg_exist" = "on" ]; then
            cat /proc/uptime | sed 's/ .*//' > /tmp/WLAN_uptime
        fi
        if [ "$wla_exist" = "on" ]; then
            cat /proc/uptime | sed 's/ .*//' > /tmp/WLAN_uptime_5G
        fi
    else
        #to solve bug 35086,when call the command wlan toggle,if it will turn off the wireless radio,
        #then set /tmp/wps_process_state value NULL.
        echo "" > /tmp/wps_process_state
        num=0
        while [ $num -lt $MAX_VAP ]; do
            vap_status=`ifconfig | grep ath$num`
            if [ "x$vap_status" != "x" ]; then
                ifconfig ath$num down 2>&1 > /dev/null
            fi
            num=`expr $num + 1`
        done
        num=0
        while [ $num -lt $NUM_RADIO ]; do
            ifconfig wifi$num down 2>&1 > /dev/null
            num=`expr $num + 1`
        done
        if [ $NUM_RADIO -eq 1 ]; then
            [ -n "${G_SECURITY_TYPE}" ] && eval ${WPS_LED_OFF}
        else
            [ -n "${G_SECURITY_TYPE}" -a -n "${A_SECURITY_TYPE}" ] && eval ${WPS_LED_OFF}
        fi
        test -f /var/run/wps_led.pid && {
            kill $(cat /var/run/wps_led.pid)
            /sbin/ledcontrol -n wps -c green -s off
            rm -f /var/run/wps_led.pid
        }
        pidlist=`ps | grep 'hostapd' | cut -b1-5`
        for j in $pidlist
        do
            kill -9 $j
        done
        rm -f /tmp/WLAN_uptime*
    fi

    update_config $NEXT_STATE

    rm $WIFI_TOGGLE_LOCK_FILE
}

wifischedule_atheros11n() {
    local device=$1
    local band=$2               # 11g/11a
    local newstate=$3           # on/off

    [ -z "$band" -o -z "$newstate" ] && return
    config_get hwmode "$device" hwmode
    case "$hwmode" in
        dual)
            wlg_exist=on
            wla_exist=on
            ;;
        11an)
            wlg_exist=off
            wla_exist=on
            ;;
        *)
            wlg_exist=on
            wla_exist=off
            ;;
    esac

    [ -f /etc/ath/board.conf ] && . /etc/ath/board.conf
    if [ "$wlg_exist" = "on" -a "$wla_exist" = "on" ]; then
        NUM_RADIO=2
    else
        NUM_RADIO=1
    fi
    MAX_VAP=8

    if [ "$band" = "11g" ];then
        # for 802.11g
        if [ "$wlg_exist" != "on" ];then
            return;
        fi
        sched_status=wlg_onoff_sched
        hw_wifi=wifi0
        search_mode="IEEE 802.11ng|IEEE 802.11g|IEEE 802.11b"
        wifi_uptime_file=/tmp/WLAN_uptime
        log_message="2.4G"
    else
        # for 802.11a
        if [ "$wla_exist" != "on" ];then
            return
        fi
        sched_status=wla_onoff_sched
        if [ $NUM_RADIO -eq 2 ];then
            hw_wifi=wifi1
        else
            hw_wifi=wifi0
        fi
        search_mode="IEEE 802.11na|IEEE 802.11a"
        wifi_uptime_file=/tmp/WLAN_uptime5G
        log_message="5G"
    fi

    WIFI_SCHED_LOCK_FILE=/tmp/.wifi_sched_lock_$band
    if [ -f $WIFI_SCHED_LOCK_FILE ]; then
       # Just exit
        return
    fi
    touch $WIFI_SCHED_LOCK_FILE

    #when NTP is off, wireless schedule run its default setting
    #(No schedule to turn off the wireless signal)
    if [ -f /tmp/ntp_updated ];then
        ntp_success=1
    else
        ntp_success=0
    fi

    if [ $NUM_RADIO -eq 1 ]; then
        WPS_LED_OFF='echo 1 > /proc/simple_config/simple_config_led'
        WPS_LED_ON='/sbin/ledcontrol -n wps -c green -s on; echo 2 > /proc/simple_config/simple_config_led'
    else
    # wps led should be turn on if security is not none and wireless is switch on
        WPS_LED_OFF='echo 0 > /proc/simple_config/tricolor_led'
    #sometimes we will call /sbin/ledcontrol -n wps -c green -s off, at this time if we want to turn on wps led,
    #we should first call ledcontrol to turn on wps led first
        WPS_LED_ON='/sbin/ledcontrol -n wps -c green -s on; echo 1 > /proc/simple_config/tricolor_led'
    fi

    [ "$wlg_exist" = "on" ] && G_SECURITY_TYPE=`$DNICONFIG get wl_sectype`
    [ "$wla_exist" = "on" ] && A_SECURITY_TYPE=`$DNICONFIG get wla_sectype`

    radio_status=`ifconfig | grep $hw_wifi`

    if [ "$newstate" = "on" ]; then
        if [ "x$radio_status"  != "x" ];then
            rm $WIFI_SCHED_LOCK_FILE
            return
        fi
        # if NTP fail, just turn on do not check the overlop time
        if [ $ntp_success -eq 1 ];then
        # It will check whether the now time should turn on wireless.
        # if no, it will set wlg_onoff_sched to 1, or it will set to 0.
        # Then we will check wlg_onoff_sched value, to decide whether to
        # turn on wireles or just exit
            /sbin/cmdsched_wlan_status $band
            wl_off=`$DNICONFIG get ${sched_status}`
        fi
        ifconfig $hw_wifi up 2>&1 > /dev/null
        $DNICONFIG set ${sched_status}=0
        num=0
        while [ $num -lt $MAX_VAP ]; do
            vap_status=`ifconfig -a | grep ath$num`
            if [ "x$vap_status" != "x" ]; then
	        wlg_mode=`iwconfig ath$num |grep -E "$search_mode"`
	        if [ "x$wlg_mode" != "x" ];then
                    ifconfig ath$num up 2>&1 > /dev/null
                fi
            fi
            num=`expr $num + 1`
        done

        if [ $NUM_RADIO -eq 2 ];then
           #if one of the radio with security is up,we should turn on WPS LED
            [ "${G_SECURITY_TYPE}" -gt "1" -a "x`ifconfig | grep wifi0`" != "x" -o "${A_SECURITY_TYPE}" -gt "1" -a "x`ifconfig | grep wifi1`" != "x" ] && eval ${WPS_LED_ON} || echo "Ignore turn off WPS LED in wifischedule on"
            logger "[wireless signal schedule] The $log_message wireless signal is ON,"
        else
            [ "${G_SECURITY_TYPE}" -gt "1" -o "${A_SECURITY_TYPE}" -gt "1" ] && eval ${WPS_LED_ON} || eval ${WPS_LED_OFF}
            if [ -f /tmp/conf_filename ]; then
                hostapd  -B `cat /tmp/conf_filename` -e /etc/wpa2/entropy
            elif [ -f /tmp/aplist0 ]; then
            # remove masked interface
                sed -i 's/^#//g' /tmp/topology.conf
                hostapd /var/run/topology.conf &
            fi
            logger "[wireless signal schedule] The wireless signal is ON,"
        fi

        cat /proc/uptime | sed 's/ .*//' > $wifi_uptime_file
    else
        if [ $ntp_success = 0 -o "x$radio_status" = "x" ];then
            rm $WIFI_SCHED_LOCK_FILE
            return
        fi
        num=0
        while [ $num -lt $MAX_VAP ]; do
            vap_status=`ifconfig | grep ath$num`
            if [ "x$vap_status" != "x" ]; then
	        wlg_mode=`iwconfig ath$num | grep -E "$search_mode"`
                if [ "x$wlg_mode" != "x" ];then
                    ifconfig ath$num down 2>&1 > /dev/null
                fi
            fi
            num=`expr $num + 1`
        done
        ifconfig $hw_wifi down 2>&1 > /dev/null
        $DNICONFIG set ${sched_status}=1

        if [ $NUM_RADIO -eq 2 ];then
        # If none of the radio with security is up,we should turn off WPS led.
        # For wps_led.pid modification,it still has some issues, eg,2.4G radio
        # is with WPA security, 5G radio is in wps process,
        # we now is schedule 5G to off state,expected result we should stop
        # blink the wps led and keep wps led on.
        # Since we now can not check whether the WPS is for 2.4G or 5G, we will
        # just leave it blinking. This should be fixed in the future.

            if ! [ "${G_SECURITY_TYPE}" -gt "1" -a "x`ifconfig | grep wifi0`" != "x" -o "${A_SECURITY_TYPE}" -gt "1" -a "x`ifconfig | grep wifi1`" != "x" ];then
                echo "Ignore turn off WPS LED in wifischedule off"
                test -f /var/run/wps_led.pid && {
                    kill $(cat /var/run/wps_led.pid)
                    /sbin/ledcontrol -n wps -c green -s off
                    rm -f /var/run/wps_led.pid
                }
            fi
            logger "[wireless signal schedule] The $log_message wireless signal is OFF," 
        else
            [ "${G_SECURITY_TYPE}" -gt "1" -o "${A_SECURITY_TYPE}" -gt "1" ] && eval ${WPS_LED_OFF}
            test -f /var/run/wps_led.pid && {
                kill $(cat /var/run/wps_led.pid)
                /sbin/ledcontrol -n wps -c green -s off
                rm -f /var/run/wps_led.pid
            }
            pidlist=`ps | grep 'hostapd' | cut -b1-5`
            for j in $pidlist
            do
                kill -9 $j
            done
            logger "[wireless signal schedule] The wireless signal is OFF,"
        fi

        rm -f $wifi_uptime_file
    fi

    rm $WIFI_SCHED_LOCK_FILE
}

wps_atheros11n() {
    local device=$1
    config_get hwmode "$device" hwmode
    config_get ifname_prefix "$device" ifname_prefix
    config_get vap_prefix "$device" vap_prefix
    HOSTAPD_VER_PREFIX=`hostapd -v 2>&1|grep hostapd|cut -f2 -d' '|cut -c 1-4`

    if [ "${HOSTAPD_VER_PREFIX}" = "v0.7" -o "${HOSTAPD_VER_PREFIX}" = "v0.8" ]; then
        if [ "$hwmode" = "dual" ]; then
            config_get vifs "$device" vifs
            for vif in $vifs; do
                config_get ifindex "$vif" ifindex
                isup=`ifconfig ${ifname_prefix}${ifindex} | grep UP`
                [ -n "$isup" ] && vapname=${vap_prefix}${ifindex}
            done
        else
            vapname=${vap_prefix}0
        fi
    fi

    shift
    while [ "$#" -gt "0" ]; do
        case $1 in
            -c|--client_pin)
                if [ -n "$2" ]; then
                    if [ "${HOSTAPD_VER_PREFIX}" = "v0.7" -o "${HOSTAPD_VER_PREFIX}" = "v0.8" ]; then
                        hostapd_cli -i${vapname} wps_cancel
                        sleep 1
                        hostapd_cli -i${vapname} wps_pin any $2
                        shift 2
                    else
                        echo "stop" > /proc/simple_config/wps
                        sleep 1
                        echo "pin=$2" > /proc/simple_config/wps
                        shift 2
                    fi
                fi
                ;;
            -p|--pbc_start)
                if [ "${HOSTAPD_VER_PREFIX}" = "v0.7" -o "${HOSTAPD_VER_PREFIX}" = "v0.8" ]; then
                    if [ -d /var/run/hostapd ]; then
                        hostapd_cli -i${vapname} wps_cancel
                        sleep 1
                        hostapd_cli -i${vapname} wps_pbc
                    fi
                    if [ -d /var/run/wpa_supplicant ]; then
                        wpa_cli wps_cancel
                        sleep 1
                        wpa_cli wps_pbc
                    fi
                else
                    echo "stop" > /proc/simple_config/wps
                    sleep 1
                    echo 1 > /proc/simple_config/push_button
                fi
                shift
                ;;
            -s|--wps_stop)
                ledcontrol -n wps -c green -s off 2>/dev/null
                if [ "${HOSTAPD_VER_PREFIX}" = "v0.7" -o "${HOSTAPD_VER_PREFIX}" = "v0.8" ]; then
                    if [ -d /var/run/hostapd ]; then
                        hostapd_cli -i${vapname} wps_cancel
                    fi
                    if [ -d /var/run/wpa_supplicant ]; then
                        wpa_cli wps_cancel
                    fi
                else
                    echo "stop" > /proc/simple_config/wps
                fi
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

wifistainfo_atheros11n() {
    local device=$1
    local band=$2               # 11g/11a

    config_get vap_prefix "$device" vap_prefix

    tmpfile=/tmp/sta_info.$$
    touch $tmpfile
    for vif in `ifconfig | grep $vap_prefix | awk '{print $1}'`; do
        isap=`iwconfig ${vif} | grep Master`
        [ -n "$isap" ] && wlanconfig ${vif} list sta >> $tmpfile
    done
    [ -f /usr/lib/stainfo.awk ] && awk -f /usr/lib/stainfo.awk $tmpfile
    rm $tmpfile
}

wifiradio_atheros11n() {
    local device=$1
    local band=$2               # 11g/11a

    config_get hwmode "$device" hwmode
    config_get ifname_prefix "$device" ifname_prefix
    config_get vap_prefix "$device" vap_prefix

    shift
    while [ "$#" -gt "0" ]; do
        case $1 in
            -s|--status)
                if [ "$hwmode" = "dual" ]; then
                    config_get vifs "$device" vifs
                    for vif in $vifs; do
                        config_get op_mode "$vif" op_mode
                        if [ "$op_mode" = "11bgn" -a "$band" = "11g" ] || 
                            [ "$op_mode" = "11an" -a "$band" = "11a" ]; then
                            config_get ifindex "$vif" ifindex
                            isup=`ifconfig ${ifname_prefix}${ifindex} | grep UP`
                            break;
                        fi
                    done
                else
                    isup=`ifconfig ${ifname_prefix}0 | grep UP`
                fi
                [ -n "$isup" ] && echo "ON" || echo "OFF"
                shift
                ;;
            -c|--channel)
                for vif in `ifconfig | grep $vap_prefix | awk '{print $1}'`; do
                    isap=`iwconfig ${vif} | grep Master`
                    [ -z "$isap" ] && continue
                    vif_band=`iwconfig $vif | grep IEEE | awk '{printf "11%c", substr($3,length($3),1)}'`
                    if [ "$vif_band" = "$band" ]; then
                        chan=`iwlist $vif chan | grep Current | awk '{printf "%d\n", substr($5,1,length($5))}'`
                        echo "$chan"
                        break;
                    fi
                done
                shift
                ;;
            --coext)
                for vif in `ifconfig | grep $vap_prefix | awk '{print $1}'`; do
                    isap=`iwconfig ${vif} | grep Master`
                    [ -z "$isap" ] && continue
                    vif_band=`iwconfig $vif | grep IEEE | awk '{printf "11%c", substr($3,length($3),1)}'`
                    if [ "$vif_band" = "$band" ]; then
                        if [ "$2" = "on" ]; then
                            iwpriv $vif disablecoext 0
                            iwpriv $vif extbusythres 30 
                        else
                            iwpriv $vif disablecoext 1
                            iwpriv $vif extbusythres 100
                        fi
                    fi
                done
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
}

scan_atheros11n() {
    true
}

detect_atheros11n() {
    local caller="$1"
    [ "x$caller" != "xdni" ] && return

    local br_if=`/bin/config get lan_ifname`
    cat <<EOF
config wifi-device  wifi
	option type     atheros11n
	option ifname_prefix   wifi
        option vap_prefix      ath
        option bridge   $br_if
EOF
    
	devidx=0
        devnum=`cat /proc/bus/pci/devices | grep 168c | wc -l`
        if [ $devnum -eq 2 ]; then
            cat <<EOF
        option hwmode   dual

EOF
	    for dev in $(cat /proc/bus/pci/devices | grep 168c | awk '{print $1}'); do
                [ $devidx -eq 0 ] && {
                    oper_band=11bgn
                } || {
                    oper_band=11an
                }
                cat <<EOF
config wifi-iface
	option device   wifi
        option op_mode  ${oper_band:-11bgn}
        option ifindex  $devidx

EOF
                devidx=$(( $devidx + 1 ))
            done
        else
            if [ ! -f /etc/ath/board.conf ]; then
                cat <<EOF
        option hwmode   11bgn

config wifi-iface
	option device   wifi
        option op_mode  11bgn
        option ifindex  0

EOF
            else
                . /etc/ath/board.conf
                case ${wlg_exist}${wla_exist} in
                    onon)
                    # Force 11bgn as first interface and 11an as second interface
                        cat <<EOF
        option hwmode   dual

config wifi-iface
	option device   wifi
        option op_mode  11bgn
        option ifindex  0

config wifi-iface
	option device   wifi
        option op_mode  11an
        option ifindex  1

EOF
                        ;;
                    offon)
                        cat <<EOF
        option hwmode   11an

config wifi-iface
	option device   wifi
        option op_mode  11an
        option ifindex  0

EOF
                        ;;
                    *)
                        cat <<EOF
        option hwmode   11bgn

config wifi-iface
	option device   wifi
        option op_mode  11bgn
        option ifindex  0

EOF
                        ;;
                    esac
            fi
        fi
}
