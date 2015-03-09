HTTP/1.1 200 OK
Content-Type: text/xml; charset=utf-8

<? 
echo "\<\?xml version='1.0' encoding='utf-8'\?\>";
include "/htdocs/phplib/xnode.php";
include "/htdocs/webinc/config.php";
include "/htdocs/phplib/trace.php"; 

$result = "OK";

$radioID = get("","/runtime/hnap/GetMultipleSSID/RadioID");
$MSSIDIndex = get("","/runtime/hnap/GetMultipleSSID/MSSIDIndex");

?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<GetMultipleSSIDResponse xmlns="http://purenetworks.com/HNAP1/">
	<GetWLanRadioSettings>
		<? 
			include "etc/templates/hnap/GetMultipleSSID_GetWLanRadioSettings.php";	
			if($result!="OK")
			{
				TRACE_error("GetWLanRadioSettings is not OK ret=".$result); 
			}
		?>
	</GetWLanRadioSettings>
	<GetWLanRadioSecurity>
		<? 
			include "etc/templates/hnap/GetMultipleSSID_GetWLanRadioSecurity.php"; 
			if($result!="OK")
			{
				TRACE_error("GetWLanRadioSecurity is not OK ret=".$result); 
			}
		?>
	</GetWLanRadioSecurity>
	<GetMultipleSSIDResult><?=$result?></GetMultipleSSIDResult>
</GetMultipleSSIDResponse>
</soap:Body>
</soap:Envelope>

