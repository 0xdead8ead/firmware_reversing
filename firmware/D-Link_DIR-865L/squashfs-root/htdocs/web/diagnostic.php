HTTP/1.1 200 OK
Content-Type: text/xml

<?
if ($AUTHORIZED_GROUP < 0)
{
	$result = "Authenication fail";
}
else
{
	if ($_POST["act"] == "ping")
	{
		set("/runtime/diagnostic/tmptarget", $_POST["dst"]);
		$target = get("s","/runtime/diagnostic/tmptarget");
		del("/runtime/diagnostic/tmptarget");
		set("/runtime/diagnostic/ping", "\"".$target."\"");
		$result = "OK";
	}
	else if ($_POST["act"] == "ping6")
	{
		set("/runtime/diagnostic/tmptarget", $_POST["dst"]);
		$target = get("s","/runtime/diagnostic/tmptarget");
		del("/runtime/diagnostic/tmptarget");
		set("/runtime/diagnostic/ping6", "\"".$target."\"");
		$result = get("x", "/runtime/diagnostic/ping6");
	}
	else if ($_POST["act"] == "pingreport")
	{
		$result = get("x", "/runtime/diagnostic/ping");
	}
}
echo '<?xml version="1.0"?>\n';
?><diagnostic>
	<report><?=$result?></report>
</diagnostic>
