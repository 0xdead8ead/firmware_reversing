HTTP/1.1 200 OK
Content-Type: text/xml; charset=utf-8

<? 
echo "\<\?xml version='1.0' encoding='utf-8'\?\>";
include "/htdocs/phplib/xnode.php";
include "/htdocs/webinc/config.php";
include "/htdocs/phplib/trace.php"; 

$result = "OK";

function print_ScheduleInfoLists()
{
	echo "<ScheduleInfoLists>";
	foreach("/schedule/entry")
	{
		$mon = get("","mon");
		$tue = get("","tue");
		$wed = get("","wed");
		$thu = get("","thu");
		$fri = get("","fri");
		$sat = get("","sat");
		$sun = get("","sun");
		$start = get("","start");
		$end = get("","end");
		
		$ScheduleName = get("","description");
		$ScheduleTimeFormat = "true"; //we don't have this info. in xmldb
		/* WORKROUND, ScheduleDate should be multiple days, discuss with Joel, Sammy */
		if($mon == "1" && $tue == "1" && $wed == "1" && $thu == "1" && $fri == "1" && $sat == "1" && $sun == "1") {$ScheduleDate = "0";}
		else if($mon == "1") 	{$ScheduleDate = "1";}
		else if($tue == "1") 	{$ScheduleDate = "2";}
		else if($wed == "1") 	{$ScheduleDate = "3";}
		else if($thu == "1") 	{$ScheduleDate = "4";}
		else if($fri == "1") 	{$ScheduleDate = "5";}
		else if($sat == "1") 	{$ScheduleDate = "6";}
		else if($sun == "1") 	{$ScheduleDate = "7";}
		else 
		{ 
			TRACE_debug("DirectoryName=".$DirectoryName);
			$result = "ERROR";
		}
		if($start == "0:00" && $end == "23:59") {$ScheduleAllDay = "true";}
		else																		{$ScheduleAllDay = "false";}		
		
		$StartTimeHourValue = cut($start, 0, ":");
		$StartTimeMinuteValue = cut($start, 1, ":");
		$EndTimeHourValue = cut($end, 0, ":");
		$EndTimeMinuteValue = cut($end, 1, ":");
		
		/*
				12-hour clock:
					12:00am 1:00am 2:00am ... 11:00am 12:00pm 1:00pm ... 11:00pm

				24-hour clock:
					1. 00:00 - 23:59
					2. 24:00 = tomorrow 00:00	
		*/
		
		$StartTimeMidDateValue = "null"; //we use 24-hour clock, sammy
		$EndTimeMidDateValue = "null";
					
		
		
		echo "<ScheduleInfo>";
		echo "	<ScheduleName>".$ScheduleName."</ScheduleName>";
		echo "	<ScheduleDate>".$ScheduleDate."</ScheduleDate>";
		echo "	<ScheduleAllDay>".$ScheduleAllDay."</ScheduleAllDay>";
		echo "	<ScheduleTimeFormat>".$ScheduleTimeFormat."</ScheduleTimeFormat>";	
		
		echo "	<ScheduleStartTimeInfo>";
		echo "		<TimeHourValue>".$StartTimeHourValue."</TimeHourValue>";
		echo "		<TimeMinuteValue>".$StartTimeMinuteValue."</TimeMinuteValue>";
		echo "		<TimeMidDateValue>".$StartTimeMidDateValue."</TimeMidDateValue>";
		echo "	</ScheduleStartTimeInfo>";	
		
		echo "	<SchedleEndTimeInfo>";
		echo "		<TimeHourValue>".$EndTimeHourValue."</TimeHourValue>";
		echo "		<TimeMinuteValue>".$EndTimeMinuteValue."</TimeMinuteValue>";
		echo "		<TimeMidDateValue>".$EndTimeMidDateValue."</TimeMidDateValue>";
		echo "	</SchedleEndTimeInfo>";
		echo "</ScheduleInfo>";
		
	}	
	echo "</ScheduleInfoLists>";
}

?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<GetScheduleSettingsResponse xmlns="http://purenetworks.com/HNAP1/">
	<GetScheduleSettingsResult><?=$result?></GetScheduleSettingsResult>
	<? print_ScheduleInfoLists(); ?>
</GetScheduleSettingsResponse>
</soap:Body>
</soap:Envelope>

