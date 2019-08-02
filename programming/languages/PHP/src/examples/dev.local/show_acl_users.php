<?php

require('db.php');

$query = q($mysqli,"SELECT (user) FROM `$_POST[server]` WHERE acl = '$_POST[acl]'");
while($user = $query->fetch_assoc())
	$acl .= "$user[user]\n";
echo $acl;

?>
