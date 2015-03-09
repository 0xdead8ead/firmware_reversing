<?
//include "/htdocs/phplib/trace.php";
function addevent($name,$handler)
{
	$cmd = $name." add \"".$handler."\"";
	event($cmd);
} 
function runservice($cmd)
{
	addevent("PHPSERVICE","service ".$cmd." &");
	event("PHPSERVICE");
	event("PHPSERVICE remove default");
}
//runservice("HTTP restart");
?>

