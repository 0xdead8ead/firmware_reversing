#!/bin/sh
#-------------------------------------------------------------------------
#  Copyright 2010, NETGEAR
#  All rights reserved.
#-------------------------------------------------------------------------

# load environment
. /opt/remote/bin/env.sh

# get Url for hook server
REMOTE_URL=$(${nvram} get leafp2p_remote_url)
URL=$(${nvram} get leafp2p_replication_url)

PROXY_NEED=False

# auth data
leafp2p_pid=`pidof leafp2p`
if [ "x${leafp2p_pid}" == "x" ]; then
	echo "[comm.sh]No leafp2p is running..." > /dev/console
	${SYS_PREFIX}/bin/leafp2p >/dev/null 2>/dev/null &
	sleep 5
else
	echo "[comm.sh]leafp2p is running on !!!" > /dev/console
fi
NAS_NAME=$(${nvram} get leafp2p_username)
NAS_PASS=$(${nvram} get leafp2p_password)

# construct comm exec
COMM_EXEC="${SYS_PREFIX}/bin/curl --basic -k --user ${NAS_NAME}:${NAS_PASS} --url ${URL}"

#
# args: <post.data> [<store.path>]
#
comm_post()
{
    local data="${1}"
    local store="${2}"
    
    local tmp="${TMP_PREFIX}/tmp.post"
    echo "${data}" > "${tmp}"

    comm_post_file "${tmp}" "${store}" || {
	echo "comm_post error!!!" > /dev/console
        rm -f "${tmp}"
	return $ERROR
    }
    rm -f "${tmp}"
    return $OK
}

#
# args: <file.path> [<store.path>]
#
comm_post_file()
{
    COMM_RESULT=""
    local file="${1}"
    if [ "x${file}" == "x" ]; then
	echo comm_post_file error: invalid input parameter ${1}  > /dev/console
	return $ERROR
    fi
    if [ "x${store}" == "x" ]; then
	FULL_EXEC="\`cat "${file}" | ${COMM_EXEC} -X POST --data-binary @- 2>/dev/null\`"
    else
	FULL_EXEC="\`cat "${file}" | ${COMM_EXEC} -X POST --data-binary @- 2>/dev/null > "${store}"\`"
    fi
    eval COMM_RESULT="${FULL_EXEC}" || {
	echo error executing request ${FULL_EXEC} > /dev/console
	return $ERROR
    }
    return $OK
}

#
# args: <job.guid> <path>
#
fetch_job()
{
    local guid="${1}"
    local path="${2}"

    # make payload
    local DATA="<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    DATA="$DATA<request moniker=\"/root/devices\" method=\"jobfetch\">"
    DATA="$DATA<body type=\"text\">"
    DATA="$DATA<value>${guid}</value>"
    DATA="$DATA</body></request>"

    # fetch job
    comm_post "${DATA}" "${path}" || return $ERROR
    return $OK
}

#
# args: <job.guid> <job.state>
#
send_job_state()
{
    local guid="${1}"
    local state="${2}"

    # make payload
    local DATA="<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    DATA="$DATA<request moniker=\"/root/devices\" method=\"jobstate\">"
    DATA="$DATA<body type=\"jobstate\">"
    DATA="$DATA<guid>${guid}</guid>"
    DATA="$DATA<state>${state}</state>"
    DATA="$DATA</body></request>"

    # send update
    comm_post "${DATA}" || {
	sleep 2
	comm_post "${DATA}" || {
	    return $ERROR
	}
    }
    JOB_STATE="${state}"
    return $OK
}

#
# args: <user name> <password>
#
do_register()
{
	# construct request
	USER_NAME=$1
	USER_PASS=$2

	DATA="<?xml version=\"1.0\" encoding=\"utf-8\"?>"
	DATA="${DATA}<request moniker=\"/root/devices\" method=\"register\">"
	DATA="${DATA}<body type=\"registration\">"
	DATA="${DATA}<username>${USER_NAME}</username>"
	DATA="${DATA}<password>${USER_PASS}</password>"
	DATA="${DATA}<license><LicenseKey>sdfsfgjsflkj</LicenseKey><hardwareSN>2496249</hardwareSN><StartTime>0</StartTime><ExpiredTime>999</ExpiredTime><valid>true</valid></license>"
	DATA="${DATA}</body></request>"

	comm_post "${DATA}" && {
		if [ "xSUCCESS" == "x$COMM_RESULT" ]; then

			${SYS_PREFIX}/bin/checkleafp2p.sh &
			${SYS_PREFIX}/bin/checkleafnets.sh &

			${nvram} set leafp2p_run="1"
			${nvram} commit >/dev/null

			$nvram set leafp2p_remote_login="${USER_NAME}"
			$nvram set leafp2p_remote_password="${USER_PASS}"
			$nvram commit >/dev/null
			echo "Register to Server Successfully" > /dev/console
			${SYS_PREFIX}/bin/brokerd
			${SYS_PREFIX}/bin/leafnetadmin create ${NAS_NAME} ${USER_NAME} >/dev/null &
			echo ok > /dev/console
			# Should restart ftp to let readyshare cloud app access.
			/sbin/cmdftp restart
			return $OK
		else
			echo "COMM_RESULT is failed!!!" > /dev/console
			killall leafp2p 2>/dev/null
		fi
	}
	echo "Invalid User Name or Password" > /dev/console
	killall leafp2p 2>/dev/null
	return $ERROR
}

#
# arg: <user name> <password>
#
do_unregister()
{
    # construct request
	USER_NAME=$1
	USER_PASS=$2

	DATA="<?xml version=\"1.0\" encoding=\"utf-8\"?>"
	DATA="${DATA}<request moniker=\"/root/devices\" method=\"unregister\">"
	DATA="${DATA}<body type=\"registration\">"
	DATA="${DATA}<username>${USER_NAME}</username>"
	DATA="${DATA}<password>${USER_PASS}</password>"
	DATA="${DATA}<license><LicenseKey>sdfsfgjsflkj</LicenseKey><hardwareSN>2496249</hardwareSN><StartTime>0</StartTime><ExpiredTime>999</ExpiredTime><valid>true</valid></license>"
	DATA="${DATA}</body></request>"

	comm_post "${DATA}" && {
	if [ "xSUCCESS" == "x$COMM_RESULT" ]; then
		
		/etc/init.d/leafp2p.sh stop
		${nvram} set leafp2p_run="0"
		${nvram} commit >/dev/null
		kill -HUP `pidof leafp2p | awk '{print $1}'`

		${SYS_PREFIX}/bin/leafnetadmin drop >/dev/null
		/etc/init.d/brokerd.sh stop >/dev/null
		$nvram unset leafp2p_remote_login
		$nvram unset leafp2p_remote_password
		$nvram commit >/dev/null
		echo "Unregister to Server Successfully"
		# Should restart ftp to let readyshare cloud app access.
		/sbin/cmdftp restart
		return $OK
	fi
	}
	echo "Connect to Server fail, Please check inernet connection"
	return $ERROR
}

#
# args: <alias>
#
do_updatealias()
{
	# construct request
	ALIAS=$1

	DATA="<?xml version=\"1.0\" encoding=\"utf-8\"?>"
	DATA="${DATA}<request moniker=\"/root/devices\" method=\"updatealias\">"
	DATA="${DATA}<body type=\"alias\">"
	DATA="${DATA}<alias>${ALIAS}</alias>"
	DATA="${DATA}</body></request>"

	comm_post "${DATA}" && {
		if [ "xSUCCESS" == "x$COMM_RESULT" ]; then

			$nvram set leafp2p_device_alias="${ALIAS}"
			$nvram commit >/dev/null
			echo "Updated Device Alias Successfully"
			echo ok
			return $OK
		fi
	}
	echo "Update alias error: connect to Server fail, Please check inernet connection"
	return $ERROR
}

#
# arg: <owner> <password>
#
add_remote_network()
{
	COMM_RESULT=""
	local owner="${1}"
	local password="${2}"
	local member="${NAS_NAME}"

	local tmp="${TMP_PREFIX}/soap.response"
	local REMOTE_REQUEST="\`${SYS_PREFIX}/bin/curl/curl --basic -k --user ${owner}:${password} --url ${REMOTE_URL} -X POST -H 'soapaction: http://tempuri.org/addNetworkWithType' --data-binary \"<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='https://peernetwork.netgear.com/peernetwork/services/LeafNetsWebServiceV2' xmlns:types='https://peernetwork.netgear.com/peernetwork/services/LeafNetsWebServiceV2/encodedTypes' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'><soap:Body soap:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'><ns1:addNetworkWithType xmlns:ns1='http://v2.websvc.leafnets.com'><in0>${owner}_net_321</in0><in1>${owner}</in1><in2 href='#id1'/><in3>2</in3></ns1:addNetworkWithType><soapenc:Array id='id1' soapenc:arrayType='xsd:string[2]'><item>${owner}</item><item>${member}</item></soapenc:Array></soap:Body></soap:Envelope>\" >${tmp} 2>/dev/null\`"
	eval COMM_RESULT="${REMOTE_REQUEST}" || {
		echo error executing request "${REMOTE_REQUEST}"
	}
	return $OK
}
