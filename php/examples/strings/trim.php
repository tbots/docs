<?php

$str = "  aaaxx ";
var_dump($str);			// string always displayed with ""
var_dump(trim($str));
var_dump(ltrim($str));
var_dump(rtrim($str));
var_dump(rtrim($str," "));
var_dump(rtrim($str," x"));
