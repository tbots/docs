<?php


$array = array('one','two');
print_r($array);

$array[] = 'three';		// always added on the top
print_r($array);

/* explode() */

$str = "one,two,three,four,five";

$arr1 = explode(',', $str, $limit =4 );   # basically limit is the resulting number of elements
var_dump($arr1);

$arr2 = explode(',', $str, $limit=1);     # if $limit is set to 1, all the string returned as only
var_dump($arr2);
                                          # one element of array
$arr3 = explode(',', $str, $limit = -2);  # all the elements except of the last $limit elements
var_dump($arr3);


#string implode([string $field_separator,] array $arr); 

$str1 = implode(', ', $arr3);   # "one, two, three" 
                                #      ^ notice the space
var_dump($str1);

$str2 = implode($arr3);
var_dump($str2);        # "onetwothree"
