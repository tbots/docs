<?php

// Base conversion example. Always returns decimal.

$i=10;

var_dump(intval("$i",$base=10));    # 10
var_dump(intval("$i",8));     # 10 is 8 in octal. Will not work without quotes.

$i = '-5';
var_dump(intval($diff));    // keeping negative value when converting from string
