<?php

$str = "hello, world! PHP calling!\n";
print_r(str_split($str));
print_r(str_split($str,5));   // each captured element is now 5 characters long
$char_array = str_split($str);
print_r($char_array);
foreach($char_array as $char)
  echo("$char:\t".ord($char)."\n");
