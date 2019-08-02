<?php

require('db.php');

$hosts = q($mysqli,"SELECT (hostname) FROM `hosts`");
while($host = $hosts->fetch_array())
	if(user_in_acl($mysqli,$host[0],$_POST['user']))
		$acl .= "$host[0]\n";
echo $acl;
