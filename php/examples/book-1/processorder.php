<?php
	// create a short variable names
	$tireqty = $_REQUEST['tireqty'];
	$oilqty  = $_REQUEST['oilqty'];
	$sparkqty= $_REQUEST['sparkqty'];
  $address = $_REQUEST['address'];
  $DOCUMENT_ROOT = $_SERVER['DOCUMENT_ROOT'];

  $date    = date('H:i, jS F Y');       # 00-23:00-59 1-31(st,nd,rd,th) January-December YYYY
?>
<html>
	<head>
		<title>Bob's Auto Parts - Order Results</title>
	</head>
  <body>
    <h1>Bob's Auto Parts</h1>
    <h2>Order Results</h2>
  <?php
    echo "<p>Order processed at ".date('H:i, jS F Y')."</p>";
    echo "<p>Your order is as follows: </p>";
    
    /* $totalqty = array_sum(array_slice($_POST,0,-1,$preserve_keys=true)); */
    $totalqty = $tireqty + $oilqty + $sparkqty;
    echo "Items ordered: ".$totalqty."<br />"; 
    if($totalqty == 0)
      echo "You didn't order anything on the previous page!<br />";
    else {
      if($tireqty > 0) {
        echo $tireqty." tires<br />";
      }
      if($oilqty > 0) {
        echo $oilqty." botlles of oil<br />";
      }
      if($sparkqty > 0) {
        echo $sparkqty." spark plugs<br />";
      }
    }
    $totalamount = 0.0;

    define('TIREPRICE',100);
    define('OILPRICE',10);
    define('SPARKPRICE',4);

    $totalamount = $tireqty * TIREPRICE
                 + $oilqty * OILPRICE
                 + $sparkqty * SPARKPRICE;

    $totalamount=number_format($totalamount, 2, '.', ' ');
        /* string number_format(float $number, int $decimal[, string $dec_point=".", string $thousand_sep=","; */
    echo "<p>Total of order is $".$totalamount."</p>";
    echo "<p>Address to ship to is ".$address."</p>";

    $outputstring = $date."\t".$tireqty." tires \t".$oilqty." oit\t"
                      .$sparkqty." spark plugs\t\$".$totalamount
                      ."\t".$address."\n";
    
    /* Open file for appending */
     $fp = fopen("$DOCUMENT_ROOT/book-1/orders.txt", 'ab');
    flock($fp, LOCK_EX);

    if(!$fp) {
      echo "<p><strong>Your oder could not be processed at this time.
                Please try again later.</strong></p></body></html>";
      exit;
    }
    fwrite($fp,$outputstring,strlen($outputstring));
    fclose($fp);

    echo "<p>Order written.</p>";
  ?>
  </body>
</html>
