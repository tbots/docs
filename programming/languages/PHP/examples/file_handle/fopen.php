<?php


#echo $_SERVER['DOCUMENT_ROOT']."</br>";
#

$filename = 'test_file.txt';
$file = $_SERVER[DOCUMENT_ROOT].DIRECTORY_SEPARATOR.$filename;

function check_fopen($mode) {
  global $file;

  echo "Trying to open '$file' using '$mode' mode<br>";
	if( $fp =  fopen($file,$mode) ) 
  {
    echo var_dump($fp).'</br>';
    switch($mode) {
      case 'r':
        echo "in r";
        #if( $content =fileread($fp,filezie($fp)) )
          #echo "Read successfull. Read string: '$content'<br/";
        #else
        $content = fileread($fp,filesize($fp)) or  die("Cannot read file: ".error_get_last()['message']."<br/>");
        echo "\$content: $content";
        break;

      case 'w':
      echo "in w";
        #if($count = fwrite( $fp, "hello, world!"))
          #echo "Write successfull. $count characters were written</br>";
         #else
         fwrite($fp,"hello, world") or  die("Cannot write file: ".error_get_last()['message']."<br/>");
        break;

      default:
         echo "in default";
        die("'$mode': wrong mode specification</br");
    }
  }
  else 
    echo error_get_last()['message']."</br>";
}

# r - open file for reading only; place file pointer at the beginning of the file; error if file does not exist
check_fopen("r");

# 
check_fopen("w");
#check_fopen("r+");
?>
