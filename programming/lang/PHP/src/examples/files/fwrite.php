<?php


# Writing to a file example. 

$filename = 'test_file.txt';
$file = $_SERVER[DOCUMENT_ROOT].DIRECTORY_SEPARATOR.$filename;    # cool :)

var_dump($file);
$mode = 'a';
$fp = fopen($file,$mode) or die(error_get_last()['message']);

var_dump(fwrite($fp,"hello, world\n")); # or die(error_get_last()['message']);
fclose($fp);
?>
