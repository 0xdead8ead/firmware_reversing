#-------------------------------------------------------------------------
#  Copyright 2010, NETGEAR
#  All rights reserved.
#-------------------------------------------------------------------------

# common vars
nvram=/bin/config
export LANG=en_US.utf8
SYS_PREFIX=$(${nvram} get leafp2p_sys_prefix)
PATH=${SYS_PREFIX}/bin:${SYS_PREFIX}/usr/bin:/sbin:/usr/sbin:/bin:/usr/bin

TMP_PREFIX=/tmp

# return codes
OK=0
ERROR=1

IFS='
'
