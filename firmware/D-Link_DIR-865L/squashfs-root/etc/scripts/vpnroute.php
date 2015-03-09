#!/bin/sh
<?
include "/htdocs/phplib/inet.php";
if (INET_validv4network($IP, $SERVER, $MASK) == 1)
{
	echo "ip route add ".$SERVER." dev ".$DEV."\n";
}
else
{
	echo "ip route add ".$SERVER." via ".$GW." dev ".$DEV."\n";
}
?>
