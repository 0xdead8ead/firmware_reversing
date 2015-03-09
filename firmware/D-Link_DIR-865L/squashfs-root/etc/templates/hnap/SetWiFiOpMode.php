HTTP/1.1 200 OK
Content-Type: text/xml; charset=utf-8

<? 
echo "\<\?xml version='1.0' encoding='utf-8'\?\>";
include "/htdocs/phplib/xnode.php";
include "/htdocs/webinc/config.php";
include "/htdocs/phplib/trace.php"; 
include "/htdocs/phplib/inf.php";

$result = "OK";
$WiFiOpMode = get("","/runtime/hnap/SetWiFiOpMode/WiFiOpMode");
$br1_infp = INF_getinfpath("BRIDGE-1");
$wan1_infp = INF_getinfpath("WAN-1");
$wan1_inetp = XNODE_getpathbytarget("inet", "entry", "uid", $wan1_infp."/inet");

if($WiFiOpMode == "AP")
{
	$result = "REBOOT";
	set("/device/layout", "router");
	
	/* restore the inet of bridge */
	if(get("", $br1_infp."/previous/inet") != "")
	{
		movc($br1_infp."/inet", $br1_infp."/previous/inet");
		del($br1_infp."/previous/inet");	
	}
}
else if($WiFiOpMode == "AP Client") //this function need to check carefully, Sammy
{
	$result = "REBOOT";
	set("/device/layout", "bridge");
	
	/* If WAN-1 uses static IP address, use the IP as the bridge's IP. */
	if(get("", $wan1_inetp."/addrtype")=="ipv4" && get("", $wan1_inetp."/ipv4/static")=="1")
	{
		mov($br1_infp."/inet", $br1_infp."/previous");
		mov($wan1_infp."/inet", $br1_infp);
	}
}
else
{
	$result = "ERROR_BAD_WiFiOpMode";
}

if($result == "OK" || $result == "REBOOT")
{
	fwrite("w",$ShellPath, "#!/bin/sh\n");
	fwrite("a",$ShellPath, "echo [$0] > /dev/console\n");
	fwrite("a",$ShellPath, "/etc/scripts/dbsave.sh > /dev/console\n");
	fwrite("a",$ShellPath, "service DEVICE.LAYOUT restart > /dev/console\n");
	fwrite("a",$ShellPath, "service INET.BRIDGE-1 restart > /dev/console\n");	
	set("/runtime/hnap/dev_status", "ERROR");
}

?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<SetWiFiOpModeResponse xmlns="http://purenetworks.com/HNAP1/">
	<SetWiFiOpModeResult><?=$result?></SetWiFiOpModeResult>
</SetWiFiOpModeResponse>
</soap:Body>
</soap:Envelope>

