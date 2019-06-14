<?php

// Good example of variable variables.

$name1 = "Maria";
$name2 = "Goyenko";
$name3 = "Love";
$name4 = "to Suck";

$maxnames = 4;
// Suppose form fields are names1, names2, etc.
for ( $i = 1; $i <= $maxnames; $i++)
{
	$name = "name$i";
	echo $$name.PHP_EOL;
}
