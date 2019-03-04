<?php

/* Time functions awesome */

function now() {
	return(date('Y-m-d',strtotime("now")));
}

# Accept input from the user with readline()?
function from_till($start_date = "now", $interval) {		# here, which intervals are accepted?! :)
	return date('Y-m-d',strtotime($interval,strtotime($start_date)));
}



function get_valid_interval(
								$renewal_date 		= "now",
								$renewal_interval = "+1 year") {

	$now = date_create(date('Y-m-d',strtotime("now")));
	$renewal_date = strtotime($renewal_date);
	$exp_date = date('Y-m-d',strtotime("$renewal_interval", $renewal_date));
	$exp_date = date_create($exp_date);

	return $exp_date->diff($now);
}

function expires_in($renewal_date 		= "now",
										$renewal_interval = "+1 year")  {

	$interval = get_valid_interval($renewal_date);

	#var_dump($interval);


	if($interval->invert) {		# it is a valid card then

		if($interval->y)
			$exp_date = $interval->y." year(s)";

		if($interval->m) {
			if($interval->y)
				$exp_date.=", ";
			$exp_date.= $interval->m." month(s)";
		}

		if($interval->d) {
			if($interval->m)
				$exp_date.=" and ";
			$exp_date.=$interval->d." day(s)";
		}

	}
	else
		$exp_date = "expired";

	return $exp_date;
}
?>
