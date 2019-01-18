<?php

$array = array('one','two');
print_r($array);

$array[1] = 'one';
$array[] = 'two';		// add on the top
print_r($array);

echo $array."\n";
