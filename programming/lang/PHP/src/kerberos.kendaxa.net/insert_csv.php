<?php

# When parsing csv's and storing them in database - keep in mind 
# that file names and table names are the same!


# Returns table name that holds a foreign key for the 
# column.
#
# $rt_fd		reference table file descriptor
# In future, after you learn how to lseek()
#
function get_rel_tbl($column,$ref_tbl) {

	$fp = fopen("$ref_tbl", 'r');	// open for reading

	# jump over column names in '$ref_tbl'
	fgetcsv($fp);
	$relational_table = False;
	
	while($reference_line = fgetcsv($fp))	{

		echo "[DEBUG] Processing relation pair:\n";
		print_r($reference_line);

		if($reference_line[0] == $column) {
			 $relational_table  = $reference_line[1];
			 break;
		}
	}
	return $relational_table;
}


// Inserts values from csv file into table. Assumes that table is the same
// as file name.
//
function insert_csv($mysqli,$file,$ref_tbl) {

	$table = $file;
	
	$fp = fopen("$file", 'r');
	$columns = fgetcsv($fp);
	
	$i=0;
	foreach ($columns as $column) {
			
		if($column == $table)
			continue;

		if($relation_table = get_rel_tbl($column,$ref_tbl)) {
			#echo "Relative table for column '$column' found. ";
			#echo "Quering '$relation_table' for the id of the specific value. ";
			#echo "Continuing from here...\n";
			$r[$i] = $relation_table;
		}
	}

	// Processing actual values...

	$columns = (implode(",",$columns));	# construct table columns 

	while ($values = fgetcsv($fp)) {
																			# construct row values
		foreach($values as $key=>$value) {
			echo "change '$values[$key]' to $value\n";

		$values = "'".(implode("','",$values))."'";
	
		$query = "INSERT INTO $table ($columns) VALUES ($values)";
		q($mysqli,$query);
	}
}
?>
