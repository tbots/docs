<?php

# string implode(string $str, array $arr);
$str = "project,projects";
$str = array($str);
var_dump($str);
$str = implode(",",$str);
var_dump($str);
