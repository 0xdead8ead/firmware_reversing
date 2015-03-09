#!/bin/sh

UHTTPD_BIN="/usr/sbin/uhttpd"
PX5G_BIN="/usr/sbin/px5g"


uhttpd_stop()
{
	kill -9 $(pidof uhttpd)
}

uhttpd_start()
{
	/sbin/artmtd -r region

        [ -x "$PX5G_BIN" ] && {
                $PX5G_BIN selfsigned -der \
                        -days ${days:-730} -newkey rsa:${bits:-1024} -keyout "/tmp/uhttpd.key" -out "/tmp/uhttpd.crt" \
                        -subj /C=${country:-DE}/ST=${state:-Saxony}/L=${location:-Leipzig}/CN=${commonname:-OpenWrt}
        } || {
                echo "WARNING: the specified certificate and key" \
                        "files do not exist and the px5g generator" \
                        "is not available, skipping SSL setup."
        }

        $UHTTPD_BIN -h /www -r WNDR4700 -x /cgi-bin -t 60 -p 0.0.0.0:80 -C /tmp/uhttpd.crt -K /tmp/uhttpd.key -s 0.0.0.0:443
}

case "$1" in
	stop)
		uhttpd_stop
	;;
	start)
		uhttpd_start
	;;
	restart)
		uhttpd_stop
		uhttpd_start
	;;
	*)
		logger -- "usage: $0 start|stop|restart"
	;;
esac

