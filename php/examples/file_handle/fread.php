<?php


# Writing to a file example. 

$filename = 'test_file.txt';
$file = $_SERVER[DOCUMENT_ROOT].$filename;

$mode = 'r';
$fp = fopen($file,$mode) or die(error_get_last()['message']);

echo "filesize(\$fp): ".filesize($fp)."</br>";

$content = fread($fp,filesize($fp)) or die(error_get_last()['message']);
echo "\$content: $content";
fclose($fp);
?>
