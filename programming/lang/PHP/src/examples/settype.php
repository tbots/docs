<?php

$foo = "5bar";

var_dump(gettype($foo));

// Complete all conversions
settype($foo,"integer");
var_dump(gettype($foo));	// integer
var_dump($foo);		// 5 
