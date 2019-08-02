<?php

// Return difference in months between passed date (timestamp) and current time.
function get_month_diff($timestamp) {

	// Create time object for the current time 
 	$now      = date_create(date('Y-m-d',strtotime('now')));

	// Create time object for the timestamp passed
	$date = date_create(date('Y-m-d',strtotime($timestamp)));

	$interval = $now->diff($date);
	return $interval->y; #format('%m');
}


$dates = array('2018-12-10', '2018-11-10', '2018-10-10');

foreach($dates as $date) {

	echo get_month_diff($date)."\n";
	if(get_month_diff($date) >= 2)
		echo "This is the registered date: $date\n";
}
?>
