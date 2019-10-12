<?php

require('db.php'); // are you sure we need it?
if( user_in_acl($mysqli,$_POST["server"],$_POST["user"]) ) {
# ACL is set for the user (0==false), remove him
 	q($mysqli,"DELETE FROM `$_POST[server]` WHERE user = '$_POST[user]'");
	$acl 	  = json_encode("$_POST[user] was deleted from '$_POST[server]' access list");
}
else
	$acl 		= json_encode("$_POST[user] is not in $_POST[server] access list");
echo $acl;
#header('Location: ./srv_kx.html');
?>
