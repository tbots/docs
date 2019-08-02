<?php

require('db.php');	/* really? */

switch(user_in_acl($mysqli,$_POST["server"],$_POST["user"])) {

	case $_POST['acl']:	
		$acl = json_encode("User already set to the requested ACL");
		break;

	case Null:
		q($mysqli,"INSERT INTO `$_POST[server]` (user,acl) VALUES ('$_POST[user]','$_POST[acl]')");
  	$acl = json_encode("$_POST[user] was added to the $_POST[server] access list");
		break;

	default:
		q($mysqli,"UPDATE `$_POST[server]` SET acl = '$_POST[acl]' WHERE user = '$_POST[user]'");
		$acl = json_encode("ACL on the $_POST[server] was updated. $_POST[user] has now ".acl_desc($mysqli,$_POST["acl"]));
}
echo $acl;
?>
