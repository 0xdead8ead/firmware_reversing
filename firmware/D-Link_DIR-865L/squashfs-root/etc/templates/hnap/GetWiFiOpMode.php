HTTP/1.1 200 OK
Content-Type: text/xml; charset=utf-8

<? 
echo "\<\?xml version='1.0' encoding='utf-8'\?\>";
include "/htdocs/phplib/xnode.php";
include "/htdocs/webinc/config.php";
include "/htdocs/phplib/trace.php"; 

$result = "OK";
$WiFiOpMode = get("","/device/layout");

if($WiFiOpMode == "router") 			$WiFiOpMode = "AP"; 
else if($WiFiOpMode == "bridge")	$WiFiOpMode = "AP Client";
else															$WiFiOpMode = "null";

?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<GetWiFiOpModeResponse xmlns="http://purenetworks.com/HNAP1/">
	<GetWiFiOpModeResult><?=$result?></GetWiFiOpModeResult>
	<WiFiOpMode><?=$WiFiOpMode?></WiFiOpMode>
</GetWiFiOpModeResponse>
</soap:Body>
</soap:Envelope>

