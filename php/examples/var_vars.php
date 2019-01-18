<?php

// Good example of variable variables.

// Suppose form fields are names1, names2, etc.
for ( $i = 0; $i < $maxnames); $i++)
{
	$name = "names$1";
	echo $$name;
}
