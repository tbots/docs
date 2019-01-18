<?php

function dump($str) {
	var_dump(intval($str));
	var_dump(gettype($str));
	var_dump($str);
}

dump("4str");
dump("4st4r");
dump("44tr");
