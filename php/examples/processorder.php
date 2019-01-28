<html>
	<?php
		// create a short variable names
		$tireqty = $_REQUEST['tireqty'];
		$oilqty  = $_REQUEST['oilqty'];
		$sparkqty= $_REQUEST['sparkqty'];
		$totalqty= $tireqty + $oilqty + $sparkqty;
	
		define('TIREPRICE',100);
		define('OILPRICE',10);
		define('SPARKPRICE',4);
	
		$totalamount = $tireqty * TIREPRICE
								 + $oilqty  * OILPRICE
								 + $sparkqty* SPARKPRICE;
	?>

	<head>
		<title>Bob's Auto Parts - Order Results</title>
	</head>

	<body>
			<?php
			echo "<h1>Bob's Auto Parts</h1>";
			echo "<p>Order details</p>";

			echo $tireqty ." tires</br>";
			echo $sparkqty." spark plugs</br>";
			echo $oilqty  ." bottles of oil</br>";

			echo "<p>Items ordered: $totalqty</p>";

			echo "Subtotal:      $".number_format($totalamount,2)."</br>";
			
			$taxrate = 0.10;
			$totalamount = $totalamount * ( 1 + $taxrate );

			echo "Total including tax: $".number_format($totalamount,2)."</br>";

			echo "<p>Order processed at ".date('H:i, js F Y')."</p>";

			//switch($find) {
				//case 'a':
					////action
					//break;

			// need to add check box and the help sign for the 'freight table"
			?>
</body>
</html>
