<?php

$host="localhost";
$user ="root";
$pw="root";

$mysqli = new mysqli($host,$user,$pw);
var_dump($mysqli);

// Error check
if($mysqli->connect_error) 
	printf("%s\n",$mysqli->connect_error);
