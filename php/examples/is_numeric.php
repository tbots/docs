<?php

$var = "4str";
var_dump(gettype($var));
var_dump(is_numeric($var));

$var = "44";
var_dump(is_numeric($var));		// true if all characters can be converted to numeric
