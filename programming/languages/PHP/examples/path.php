<?php

# Experimenting with the functions affecting file path.

$filepath = "/usr/bin/crontab";
var_dump(basename($filepath));    // crontab

$filepath = "~/src/read.c";
var_dump(basename($filepath, ".c"));  // read
var_dump(basename($filepath, "d.c"));  // rea


echo "PATHINFO_DIRNAME: ".PATHINFO_DIRNAME.PHP_EOL;
echo "PATHINFO_BASENAME: ".PATHINFO_BASENAME.PHP_EOL;
echo "PATHINFO_EXTENSION: ".PATHINFO_EXTENSION.PHP_EOL;
echo "PATHINFO_FILENAME: ".PATHINFO_FILENAME.PHP_EOL;
print_r(pathinfo($filepath));
print_r(pathinfo($filepath,$options=PATHINFO_FILENAME|PATHINFO_DIRNAME));   
print_r(pathinfo($filepath,$options=PATHINFO_DIRNAME|PATHINFO_FILENAME));   
print_r(pathinfo($filepath,$options=PATHINFO_BASENAME|PATHINFO_FILENAME));   
print_r(pathinfo($filepath,$options=PATHINFO_DIRNAME|PATHINFO_BASENAME|PATHINFO_FILENAME));   

# ^    Doesn't matter in which order constants were specified, the first element in the PATHINFO[] array is 
#      displayed..
