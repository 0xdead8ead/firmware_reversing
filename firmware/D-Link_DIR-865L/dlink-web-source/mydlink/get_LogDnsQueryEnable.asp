<?
include "/htdocs/mydlink/header.php";
include "/htdocs/phplib/xnode.php";
include "/htdocs/webinc/config.php";

$DNSLOGP	="/device/mydlink/dnslog/enable";
$ENABLE		=query($DNSLOGP);

?>
<enable><?=$ENABLE?></enable>
