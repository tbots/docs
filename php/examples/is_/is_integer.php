<?php

$num = 5;

is_integer($num);     // integer
var_dump(is_integer("5"));    // false
var_dump(is_integer(5));      // true
var_dump(is_integer(intval("5")));    // true

$var = "55x";
var_dump(is_integer($var));   // false
