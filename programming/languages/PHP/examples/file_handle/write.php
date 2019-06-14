<?php


# Writing to a file example. 

echo "$_SERVER[DOCUMENT_ROOT]";
# @$fp = fopen("/var/www/html/test_file.txt",'r+'); #or die("Cann't open the file");

$fp = @fopen("/var/www/html/test_file.txt",'x'); #or die("Cann't open the file");
if (!$fp) {
	die("FUCK YOU");
}
fwrite($fp,"xx\n") or die("Cann't write to the file");
fclose($fp);
?>
