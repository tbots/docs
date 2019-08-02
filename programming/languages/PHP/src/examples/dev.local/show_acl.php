<?php

require('db.php');	/* needed? */

# Get an ACL number set on the server 
$acl_num	=  user_in_acl($mysqli,$_POST['server'],$_POST['user']);
if(is_null($acl_num)) 	# no number was fetched
	$acl = json_encode("$_POST[user] has no access to '$_POST[server]'");
else {
	$acl_desc = acl_desc($mysqli,$acl_num);	# Get ACL description
	$acl = json_encode("$_POST[user] has $acl_desc to the $_POST[server]");
}
echo "$acl";		# return a response 
#header('Location: ./srv_kx.html');
?>
