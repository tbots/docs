<?php
# nice
  $number = 3.14159265359 ;
  echo number_format($number) . PHP_EOL;    # 3
  echo number_format($number, 3) . PHP_EOL; # 3.141
  
  $number += 1546;
  echo $number . PHP_EOL;     # 1549.1415926536
  echo number_format($number, 5) . PHP_EOL;     # 1,549.14159
  echo number_format($number, 3, ',' , '.') . PHP_EOL;     # 1.549,142
?>
