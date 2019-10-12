<?php


function error_get_last_array() {
  #print_r(error_get_last());
  foreach (error_get_last() as $key => $value)
    echo "$key:     $value</br>";
  exit(1);
}


#echo $_SERVER['DOCUMENT_ROOT']."</br>";


$filename = 'test_file.txt';
$file = $_SERVER[DOCUMENT_ROOT].DIRECTORY_SEPARATOR.$filename;
$text = "hello, world<\n>";

# 'w' (write)    open file for writing only; place file pointer at the beginning of
#                the file and truncate it to zero length; if the file does not exist
#                 attempt to create it
#
# resource fopen( string $filename, string $mode [, bool $use_include_path = FALSE [, resource $context]] )

echo "Attempting to write and create '$file'</br>";
if ( ! $handle = fopen($file,"w") ) 
{ 
 error_get_last_array();
 # echo "Cannot create the file: ".error_get_last()['message']."</br>"; 
}

var_dump($handle);

if ( ! $result = fwrite($handle, $text) ) {
  echo "Cannot write to the file: ".error_get_last()['message']."</br>";
}
var_dump($result);

?>
