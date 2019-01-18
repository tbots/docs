<?php

function dump($var) {
echo "$var\n";
var_dump(floatval($var));
var_dump(intval($var));
var_dump(strval($var));
}

dump("3.14");			// 3.14
dump("aa3.14");		// 0
dump("3.14aa");		// int(3) dot is not encounterea
