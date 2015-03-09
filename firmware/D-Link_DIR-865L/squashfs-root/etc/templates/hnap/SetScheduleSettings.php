HTTP/1.1 200 OK
Content-Type: text/xml; charset=utf-8

<? 
echo "\<\?xml version='1.0' encoding='utf-8'\?\>";
include "/htdocs/phplib/xnode.php";
include "/htdocs/webinc/config.php";
include "/htdocs/phplib/trace.php"; 

/* am		MidDateValue:false 
 * pm		MidDateValue:true 
 */
function convert_to_24_hour_clock($HourValue, $MinuteValue, $MidDateValue)
{
	if($HourValue=="" || $MinuteValue=="" || $MidDateValue=="") {return "";}
	
	if($MidDateValue == "false" && $HourValue == 12)	{$HourValue = 0;}
	else if($MidDateValue == "true" && $HourValue != 12) {$HourValue = $HourValue + 12;}
	
	if($HourValue == 0) {$HourValue = "00";}
	
	return $HourValue.":".$MinuteValue;
}

$result = "OK";
$NumberOfEntry = get("","/runtime/hnap/SetScheduleSettings/NumberOfEntry");

/* remove old entrys */
$max = get("","/schedule/max");
del("/schedule");
set("/schedule/seqno", 1);
if($max != "") {set("/schedule/max", $max);}
else					 {set("/schedule/max", 10);}
set("/schedule/count", 0);

/* add new entrys */
foreach("/runtime/hnap/SetScheduleSettings/ScheduleInfoLists/ScheduleInfo")
{
	$ScheduleName = get("","ScheduleName");
	$ScheduleDate = get("","ScheduleDate");	
	$ScheduleAllDay = get("","ScheduleAllDay");	
	$ScheduleTimeFormat = get("","ScheduleTimeFormat");	

	$StartTimeHourValue = get("","ScheduleStartTimeInfo/TimeHourValue");	
	$StartTimeMinuteValue = get("","ScheduleStartTimeInfo/TimeMinuteValue");	
	$StartTimeMidDateValue = get("","ScheduleStartTimeInfo/TimeMidDateValue");	
	$EndTimeHourValue = get("","SchedleEndTimeInfo/TimeHourValue");	
	$EndTimeMinuteValue = get("","SchedleEndTimeInfo/TimeMinuteValue");	
	$EndTimeMidDateValue = get("","SchedleEndTimeInfo/TimeMidDateValue");					
	
	$newentry = XNODE_add_entry($tmp_node,"SCH");
	
	anchor($newentry);
	set("description",$ScheduleName);
	set("exclude", "0");
	if($ScheduleDate=="0")
	{
		set("mon","1");
		set("tue","1");
		set("wed","1");
		set("thu","1");
		set("fri","1");
		set("sat","1");
		set("sun","1");
	}
	else if($ScheduleDate=="1")			{set("mon","1");}
	else if($ScheduleDate=="2")			{set("tue","1");}
	else if($ScheduleDate=="3")			{set("wed","1");}
	else if($ScheduleDate=="4")			{set("thu","1");}
	else if($ScheduleDate=="5")			{set("fri","1");}
	else if($ScheduleDate=="6")			{set("sat","1");}
	else if($ScheduleDate=="7")			{set("sun","1");}
	
	if($ScheduleAllDay == "true")
	{
		set("start","00:00");	
		set("end","23:59");
	}
	else if($ScheduleAllDay == "false")
	{

		if($ScheduleTimeFormat == "true") //24-hour clock
		{
			set("start",$StartTimeHourValue.":".$StartTimeMinuteValue);	
			set("end",$EndTimeHourValue.":".$EndTimeMinuteValue);
		}
		else if($ScheduleTimeFormat == "false") //12-hour clock
		{
			$start = convert_to_24_hour_clock($StartTimeHourValue, $StartTimeMinuteValue, $StartTimeMidDateValue);
			$end = convert_to_24_hour_clock($EndTimeHourValue, $EndTimeMinuteValue, $EndTimeMidDateValue);
			
			if($start!="" && $end!="")
			{
				set("start", $start);	
				set("end", $end);
			}
			else 
				{$result = "ERROR_BAD_ScheduleInfo";}
		}
		else 
			{$result = "ERROR_BAD_ScheduleInfo";}
	}
	else 
		{$result = "ERROR_BAD_ScheduleInfo";}					
}
?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
<soap:Body>
<SetScheduleSettingsResponse xmlns="http://purenetworks.com/HNAP1/">
	<SetScheduleSettingsResult><?=$result?></SetScheduleSettingsResult>
</SetScheduleSettingsResponse>
</soap:Body>
</soap:Envelope>
