#-------------------------------------------------------------------------
#  Copyright 2010, NETGEAR
#  All rights reserved.
#-------------------------------------------------------------------------

P2P_CLIENT=/opt/p2p/bin/p2pnetclient
P2P_ZERO=0

#
# arg: <net.id> <peer.name>
#
p2p_connect()
{
    # check for localhost connection
    #local my_name=$(rxml ${REMOTE_CONFIG} /Configuration/AccountInformation/Username)
	local my_name="local"
    if [ "x${2}" == "x${my_name}" ]; then
	PEER_IP="${LOCAL_IP}"
	return $OK
    fi    

    log_inf "p2p connect to ${2} in ${1} network"
    local out=($(${P2P_CLIENT} connect ${1} ${2}))
    local p2pnet_retval=${out[0]#p2pnet_retval=}
    log_dbg "p2pnet_retval ${p2pnet_retval}"
    if [ ${p2pnet_retval} -lt ${P2P_ZERO} ]; then
	return ${ERROR}
    fi
    PEER_IP="${out[1]#p2pnet_peer_ip=}"
    PEER_IP=$(echo ${PEER_IP} | tr -d '\015')
    log_inf "p2p peer ip is: ${PEER_IP}"
    return $OK
}

#
# arg: <net.id> <peer.name>
#
p2p_disconnect()
{
    # check for localhost connection
    local my_name=$(rxml ${REMOTE_CONFIG} /Configuration/AccountInformation/Username)
    if [ "x${2}" == "x${my_name}" ]; then
	PEER_IP=""
	return $OK
    fi    
    
    if [ "x${PEER_IP}" != "x" ]; then
        log_inf "p2p disconnect with ${2} in ${1} network"
    fi
    local out=($(${P2P_CLIENT} disconnect ${1} ${2}))
    PEER_IP=""
    return $OK
}

#
# arg: -
#
p2p_set_local_ip()
{
    local out=($(${P2P_CLIENT} getlocalip))
    local p2pnet_retval=${out[0]#p2pnet_retval=}
    [ "x${p2pnet_retval}" == "x" ] && p2pnet_retval=-1000
    if [ ${p2pnet_retval} -lt ${P2P_ZERO} ]; then
	return ${ERROR}
    fi
    LOCAL_IP="${out[1]#p2pnet_local_ip=}"
    LOCAL_IP=$(echo ${LOCAL_IP} | tr -d '\015')
    log_dbg "p2p local ip is: ${LOCAL_IP}"
    return $OK
}
