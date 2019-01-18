<?php

$num = 5;

if(is_integer($num))
	echo "integer\n";
	//echo "<br>integer</br>";
else
	echo "is not integer\n";

var_dump(gettype($num));
