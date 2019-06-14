<?php

function dump_cast_val($var) {
	echo "Casting variable: '$var'\n";
	echo "intval($var):\t".intval($var).PHP_EOL;
	echo "floatval($var):\t".floatval($var).PHP_EOL;
	echo "strval($var):\t".strval($var).PHP_EOL;
}

dump_cast_val("3.14");			// 3.14
dump_cast_val("aa3.14");		// 0
dump_cast_val("3.14aa");		// int(3) dot is not encountered
dump_cast_val("4st4r");
