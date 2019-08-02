<html>
	<head>
		<title>Bob's Auto Parts - Order Results</title>
	</head>
  <body>
    <h1>Bob's Auto Parts</h1>
    <h2>Order Results</h2>

	  <?php
    # PHP CODE
    
    # Print time stamp
	  $date    = date('H:i, jS F Y');       # 00-23:00-59 1-31(st,nd,rd,th) January-December YYYY
    echo "<p>Order processed at ".$date."</p>";


	  include ( 'db.php' );    # connect to database
		$tireqty = $_REQUEST['tireqty'];
		$oilqty  = $_REQUEST['oilqty'];
		$sparkqty= $_REQUEST['sparkqty'];
	  $address = $_REQUEST['address']; 

    # Calculate total sum of the elements. Unset address element before.
    unset($_REQUEST['address']);

    # Total quantity with array_sum()
    $totalqty = array_sum( $_REQUEST );

    if( $totalqty ) 
    {
	    echo "<p>Items ordered";
	
	    echo "<table border=\"0\" style=\"border-collapse:collapse\">";
	    foreach($_REQUEST as $item => $value) {
	      if( $value != 0 ) {   # generate a row
	       switch($item) {
	         case 'tireqty': $item_name = 'Tires'; break; 
	         case  'oilqty': $item_name = 'Oil'; break; 
	         case  'sparkqty': $item_name = 'Sparks'; break; 
	       }
	       echo "
	         <tr>
	          <td>$item_name</td>
	          <td  width=\"100\" align=\"right\">$value</td>
	         </tr>              ";
	      }
	    }
	    echo "</table>";
      echo "<p>Total: ".$totalqty."</p>"; 
    }
    
    else
      echo "You didn't order anything!<br />";

    echo "<p>Address to ship to is ".$address."</p>";

    $totalamount = 0.0;
    define('TIREPRICE',100);
    define('OILPRICE',10);
    define('SPARKPRICE',4);

    $totalamount = $tireqty  * TIREPRICE
                 + $oilqty   * OILPRICE
                 + $sparkqty * SPARKPRICE;

    $totalamount=number_format($totalamount, 2, '.', ' ');

    echo "<hr /><p>Total of order is $".$totalamount;   # here </p> was added automatically

    $outputstring = $date."\t".$tireqty." tires \t".$oilqty." oil\t"
                   .$sparkqty." spark plugs\t\$".$totalamount."\t".$address."\n";
    
    # Write log file
    #
    # a   pointer at the end of the file; create a file; append text
    # w   pointer at the beginning of the file; create file; truncate file

    $mode = 'w';
    if( ! $fp = fopen("$_SERVER[DOCUMENT_ROOT]/orders.txt", $mode) )
      die( "Cann't open file ".error_get_last()['message']."</br>" );

    # review
    if(!$fp) {
      echo "<p><strong>Your oder could not be processed at this time.
                Please try again later.</strong></p></body></html>";
      exit;
    }
    flock($fp, LOCK_EX);

    fwrite($fp,$outputstring,strlen($outputstring));
    fclose($fp);

    echo "<p>Order written.</p>";

    # function write_log_file($mode) {
    
    # Store order in database
    store_order($mysqli);
  ?>
  </body>
</html>
