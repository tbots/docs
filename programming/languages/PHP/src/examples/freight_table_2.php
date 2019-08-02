<html>
	<body>
		<table border='1' cellpadding='8' rules='all' width='400'>
			<tr>
				<td bgcolor="#CCCCCC" align="center">Distance</td>
				<td bgcolor="#CCCCCC" align="center">Cost</td>
			</tr>
			<?php
				for($distance = 50; $distance <= 250; $distance += 50) {
					echo
						"<tr>
								<td align = 'right'/>".$distance."</td>
								<td align = 'right'/>".($distance / 10)."</td>
						</tr>";
			 }
		 ?>
		</table>
	</body>
</html>
