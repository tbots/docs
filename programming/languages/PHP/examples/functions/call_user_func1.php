<?php

/* This is the example where function name is not known, and there is no other way
 * to call to the function except of using call_user_func().
 */

function hello_from_Venus($name) {
  echo "Hello from Venus $name!\n";
}

function hello_from_Jupiter($name) {
  echo "Hello from Jupiter $name!\n";
}

function hello_from_Uranus($name) {
  echo "Hello from Uranus $name!\n";
 }

$rand = rand(1,3);
//var_dump($rand);
switch($rand) {
  case 1: $function_name="hello_from_Venus"  ; break;
  case 2: $function_name="hello_from_Jupiter"; break;
  case 3: $function_name="hello_from_Uranus" ; break;
}

$name = "Oleg";
call_user_func($function_name,$name);
?>
