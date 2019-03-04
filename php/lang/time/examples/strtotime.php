<?php 

function real_date($time = null, $format = 'Y-m-d') {
	$time = $time ? $time : strtotime("now");
	return date($format,$time); 		
}

$reg_date = "2017-06-27";
$reg_date = strtotime($reg_date);		// formatted to timestamp
var_dump(real_date(strtotime("+1 year",$reg_date)));
var_dump(real_date(strtotime("+1 year",$reg_date)));
