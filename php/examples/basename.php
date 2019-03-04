<?php


$filepath = "/usr/bin/crontab";
var_dump(basename($filepath));    // crontab

$filepath = "~/src/read.c";
var_dump(basename($filepath, ".c"));  // read
