<?php

function iter_array($array) {
	foreach($array as $key=>$value) {
		echo "$key : $value\n";
	}
}

$array[] = "zero";
$array[] = "one";
$array[] = "two";


iter_array($array);
