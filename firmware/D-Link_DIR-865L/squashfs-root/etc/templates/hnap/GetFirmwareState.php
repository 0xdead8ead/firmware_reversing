HTTP/1.1 200 OK
Content-Type: text/xml; charset=utf-8

<? 
echo "\<\?xml version='1.0' encoding='utf-8'\?\>";
include "/htdocs/phplib/xnode.php";
include "/htdocs/webinc/config.php";
include "/htdocs/phplib/trace.php"; 

$result = "OK";
$IsTheLatest = false;
//$enable = get("","/upnpav/dms/active");
//
//if($enable==1) $enable = true; else $enable = false;

//setattr("/runtime/hnap/GetFirmwareState/get_ver","get","ls -ld");
//
//$get_ver = get("","/runtime/hnap/GetFirmwareState/get_ver");
//
//TRACE_error("@@@get_ver=".$get_ver);

?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<GetFirmwareStateResponse xmlns="http://purenetworks.com/HNAP1/">
	<GetFirmwareStateResult><?=$result?></GetFirmwareStateResult>
	<IsTheLatest><?=$IsTheLatest?></IsTheLatest>
</GetFirmwareStateResponse>
</soap:Body>
</soap:Envelope>
