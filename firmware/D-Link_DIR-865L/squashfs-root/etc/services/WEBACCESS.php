<?
include "/htdocs/phplib/trace.php"; 
include "/htdocs/phplib/xnode.php";
include "/htdocs/phplib/phyinf.php";
include "/htdocs/phplib/inf.php";

fwrite("w",$START, "#!/bin/sh\n");
fwrite("w",$STOP,  "#!/bin/sh\n");

function startcmd($cmd)	{fwrite(a,$_GLOBALS["START"], $cmd."\n");}
function stopcmd($cmd)	{fwrite(a,$_GLOBALS["STOP"], $cmd."\n");}
function http_error($errno)
{
}

// Create /var/run/storage_account_root
function get_alldisklist($rw)
{
	$sotragelist = "";
	foreach("/webaccess/device/entry")
	{ 
		//iphone app enable only one device at same time
		$valid = query("valid");
		if($valid == "1")
		{
			foreach("entry")
			{
				$sotragelist = $sotragelist.",".query("uniquename").":::".$rw;
			}
		}
	}
	return $sotragelist;
}

function comma_handle($password) //password 
{
	// because of ',' is special charcter in storage_account_root
	// so we add '\' in front of ',' to do special handle
	// handle '\' first then ','
	// admin only, i block special character use in creating WFA normal user account
	//start 
	$bslashcount = cut_count($password, "\\");
	$count_tmp = 1;
	if($bslashcount > 0)
		$tmp_pass = cut($password, 0, "\\");
	else
		$tmp_pass = "";
	while($count_tmp < $bslashcount)
	{
		$tmp_str = cut($password, $count_tmp, "\\");
		$tmp_pass = $tmp_pass ."\\\\".$tmp_str;
		$count_tmp = $count_tmp + 1;
	}
	if($bslashcount > 0)
		$password = $tmp_pass;
		
		
	$commacount = cut_count($password, ",");
	$count_tmp = 1;
	if($bslashcount > 0)
		$tmp_pass = cut($password, 0, ",");
	else
		$tmp_pass = "";
	while($count_tmp < $commacount)
	{
		$tmp_str = cut($password, $count_tmp, ",");
		$tmp_pass = $tmp_pass ."\\,".$tmp_str;
		$count_tmp = $count_tmp + 1;
	}
	if($commacount > 0)
		return $tmp_pass;
	else
		return $password;
	//end
}
function setup_wfa_account()
{
	$ACCOUNT = "/var/run/storage_account_root";
	/*for the admin is special*/
	$admin_path = XNODE_getpathbytarget("/device/account", "entry", "name", "Admin", 0);
	$admin_passwd = query($admin_path."/password");
	$admin_disklist=get_alldisklist("rw");
	$check_dist=get_alldisklist();
/*	
	// because of ',' is special charcter in storage_account_root
	// so we add '\' in front of ',' to do special handle
	// handle '\' first then ','
	// admin only, i block special character use in creating WFA normal user account
	//start 
	$bslashcount = cut_count($admin_passwd, "\\");
	$count_tmp = 1;
	if($bslashcount > 0)
		$tmp_admin_pass = cut($admin_passwd, 0, "\\");
	else
		$tmp_admin_pass = "";
	while($count_tmp < $bslashcount)
	{
		$tmp_str = cut($admin_passwd, $count_tmp, "\\");
		$tmp_admin_pass = $tmp_admin_pass ."\\\\".$tmp_str;
		$count_tmp = $count_tmp + 1;
	}
	if($bslashcount > 0)
		$admin_passwd = $tmp_admin_pass;
		
	
	$commacount = cut_count($admin_passwd, ",");
	$count_tmp = 1;
	if($bslashcount > 0)
		$tmp_admin_pass = cut($admin_passwd, 0, ",");
	else
		$tmp_admin_pass = "";
	while($count_tmp < $commacount)
	{
		$tmp_str = cut($admin_passwd, $count_tmp, ",");
		$tmp_admin_pass = $tmp_admin_pass ."\\,".$tmp_str;
		$count_tmp = $count_tmp + 1;
	}
	if($commacount > 0)
		$admin_passwd = $tmp_admin_pass;
	//end
*/	
	$admin_passwd = comma_handle($admin_passwd);
	
	/* note1: we hope even if there has no partition on the device,
	   the user still can login sharePort (but see nothing),
	   instead of showing the "authentication fail message" */
	if($admin_disklist==""){$admin_disklist=",:::";}
	
	fwrite("w", $ACCOUNT, "admin:".$admin_passwd.$admin_disklist."\n");
	
	foreach("/webaccess/account/entry")
	{
		if(tolower(query("username"))==tolower("Admin"))
		{
			continue;	
		}
		$storage_msg = "";
		foreach("entry")
		{
			if(tolower(query("path"))=="root")
			{
				$rw = query("permission");
				$storage_msg = get_alldisklist($rw);
			}
			else if(tolower(query("path"))=="none")   //jef add to allow user login without set any path
			{
				$storage_msg = ",:::";
			}
			else  // if(tolower(query("path")) !="none")
			{
				$device = cut(query("path"), 0, ":");	
				$path = cut(query("path"), 1, ":");
				$permission = query("permission");
				$storage_msg = $storage_msg.",".$device.":".$path.":".$path.":".$permission;
			}		
		}
			
	//	if($storage_msg!="")
	//	{
			if($check_dist==""){$storage_msg=",:::";} //same with note1
			$user_passwd = query("passwd");
			$user_passwd = comma_handle($user_passwd);
			fwrite("a", $ACCOUNT, query("username").":".$user_passwd.$storage_msg."\n");
	//	}	
	}
}

/*  prepare data for http to create httpd.conf (service WEBACCESS) */
function webaccesssetup($name)
{
	/* Get the interface */
	$infp = XNODE_getpathbytarget("", "inf", "uid", $name, 0);

	if ($infp=="")
	{
		SHELL_info($_GLOBALS["START"], "webaccesssetup: (".$name.") not exist.");
		SHELL_info($_GLOBALS["STOP"],  "webaccesssetup: (".$name.") not exist.");
		http_error("9");
		return;
	}

	/* Get the "runtime" physical interface */
	$stsp = XNODE_getpathbytarget("/runtime", "inf", "uid", $name, 0);

	if ($stsp!="")
	{
		$phy = query($stsp."/phyinf");
		if ($phy!="")
		{
			$phyp = XNODE_getpathbytarget("/runtime", "phyinf", "uid", $phy, 0);
			if ($phyp!="" && query($phyp."/valid")=="1")
				$ifname = query($phyp."/name");
		}
	}

	/* Get address family & IP address */
	$atype = query($stsp."/inet/addrtype");

	if      ($atype=="ipv4") {$af="inet"; $ipaddr=query($stsp."/inet/ipv4/ipaddr");}
	else if ($atype=="ppp4") {$af="inet"; $ipaddr=query($stsp."/inet/ppp4/local");}
	else if ($atype=="ipv6") {$af="inet6";$ipaddr=query($stsp."/inet/ipv6/ipaddr");}
	else if ($atype=="ppp6") {$af="inet6";$ipaddr=query($stsp."/inet/ppp6/local");}

	if($af != "inet")
	{
		SHELL_info($_GLOBALS["START"], "webaccesssetup: (".$name.") not ipv4.");
		SHELL_info($_GLOBALS["STOP"],  "webaccesssetup: (".$name.") not ipv4.");
		http_error("9");
		return;
	}

	if ($ifname==""||$af==""||$ipaddr=="")
	{
		SHELL_info($_GLOBALS["START"], "webaccesssetup: (".$name.") no phyinf.");
		SHELL_info($_GLOBALS["STOP"],  "webaccesssetup: (".$name.") no phyinf.");
		http_error("9");
		return;
	}
	$webaccess = query("/webaccess/enable");
	$port = query("/webaccess/httpport");
	if($port == "")	$port=8181;
	if($name=="LAN-1")
	{
		$webaccess_http=1;
		$dirty = 0;
	}
	else
	{
		
    		$webaccess_http = query("webaccess/httpenable");
    		$dirty = 0;
    		$ifname="";
	}
	
	
	$stsp = XNODE_getpathbytarget("/runtime/services/http", "server", "uid", "WEBACCESS.".$name, 0);
	if ($stsp=="")
	{
		if ($webaccess != 1)
		{
			SHELL_info($_GLOBALS["START"], "webaccesssetup: (".$name." with code ".$webaccess.") not active.");
			SHELL_info($_GLOBALS["STOP"],  "webaccesssetup: (".$name." with code ".$webaccess.") not active.");
			http_error("8");
			return;
		}
		else
		{
			$dirty++;
			if($webaccess_http=="1")
			{
				$stsp = XNODE_getpathbytarget("/runtime/services/http","server","uid","WEBACCESS.".$name,1);
				set($stsp."/mode",  "WEBACCESS");
				set($stsp."/inf",   $name);
				set($stsp."/ifname", $ifname);
				set($stsp."/ipaddr",$ipaddr);
				set($stsp."/port",  $port);
				set($stsp."/af",    $af);
			}
		}
	}
	else
	{
		if ($webaccess != 1) { $dirty++; del($stsp);}
		else
		{
			if($webaccess_http=="1")
			{
				if (query($stsp."/mode")!="WEBACCESS")   { $dirty++; set($stsp."/mode", "WEBACCESS"); }
				if (query($stsp."/inf")!=$name)         { $dirty++; set($stsp."/inf", $name); }
				if (query($stsp."/ifname")!=$ifname)    { $dirty++; set($stsp."/ifname", $ifname); }
				if (query($stsp."/ipaddr")!=$ipaddr)    { $dirty++; set($stsp."/ipaddr", $ipaddr); }
				if (query($stsp."/port")!=$port)        { $dirty++; set($stsp."/port", $port); }
				if (query($stsp."/af")!=$af)            { $dirty++; set($stsp."/af", $af); }
			}
		}
	}

	stopcmd('sh /etc/scripts/delpathbytarget.sh runtime/services/http server uid WEBACCESS.'.$name);
}

if(query("webaccess/enable")=="1") 
{
	setup_wfa_account();
	webaccesssetup("WAN-1");
	webaccesssetup("LAN-1");
}

/* start HTTP service */
if ($dirty>0) $action="restart"; else $action="start";


$partition_count = query("/runtime/device/storage/disk/count");

startcmd("killall -9 fileaccessd"); //jef
startcmd("fileaccessd &"); //jef

startcmd("service STUNNEL restart");
startcmd("service HTTP restart");
startcmd("service IPT.WAN-1 restart");


/*
if($partition_count =="" || $partition_count=="0")
{
	fwrite("a", $START, "echo \"No HD found\"  > /dev/console\n");
	startcmd("service WEBACCESS stop");
}
*/
startcmd("exit 0");

stopcmd("killall -9 fileaccessd"); //jef
stopcmd("service HTTP restart");
stopcmd("rm /var/run/storage_account_root");
stopcmd("exit 0");

?>
