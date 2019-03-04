<?php

$string = "CREATE TABLE users (
									project)";
#$pattern = array('/\n/','/\t+/','/\s+/');
#$string = preg_replace($pattern," ",$string);

#$string = preg_replace('/(\n|\t|\s)+/',' ',$string);
$string = preg_replace('/\s+/',' ',$string);
echo "$string\n";
