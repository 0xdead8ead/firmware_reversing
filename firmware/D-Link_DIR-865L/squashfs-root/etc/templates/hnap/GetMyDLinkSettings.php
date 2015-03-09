HTTP/1.1 200 OK
Content-Type: text/xml; charset=utf-8

<? 
echo "\<\?xml version='1.0' encoding='utf-8'\?\>";
include "/htdocs/phplib/xnode.php";
include "/htdocs/webinc/config.php";
include "/htdocs/phplib/trace.php"; 

$result = "OK";
//$mcast = get("","/device/multicast/igmpproxy");
//
//if($mcast == "1") 	$enable = "true"; 
//else 								$enable = "false";

?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<GetMyDLinkSettingsResponse xmlns="http://purenetworks.com/HNAP1/">
	<GetMyDLinkSettingsResult><?=$result?></GetMyDLinkSettingsResult>
	<Enabled><?=$enable?></Enabled>
	<Email><?=$enable?></Email>
	<Password><?=$enable?></Password>
	<LastName><?=$enable?></LastName>
	<FirstName><?=$enable?></FirstName>
	<DeviceUserName><?=$enable?></DeviceUserName>
	<DevicePassword><?=$enable?></DevicePassword>
</GetMyDLinkSettingsResponse>
</soap:Body>
</soap:Envelope>

