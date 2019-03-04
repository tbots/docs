<?php

# string implode([string $fs,] array $arr);
$str = "project,projects";
$array = explode(",",$str);   // create an array
var_dump($array);
$str = implode(",",$array);
var_dump($str);
$str = implode("",$array);
var_dump($str);
$str = implode($array);
var_dump($str);
