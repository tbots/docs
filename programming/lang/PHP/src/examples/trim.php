<?php

$str = "  aaaxzxx ";
var_dump($str);			// string always displayed with ""
var_dump(trim($str));     # "aaxZxx"
var_dump(ltrim($str));    # "aaxZxx "
var_dump(rtrim($str));    # " aaxZxx"
var_dump(rtrim($str," "));    # " aaxZxx"
var_dump(rtrim($str," x"));   # " aaxZ"
var_dump(rtrim($str," xz"));  # space, 'x' or 'z' -> " aaa"
