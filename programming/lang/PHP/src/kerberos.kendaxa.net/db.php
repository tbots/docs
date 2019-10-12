<?php

$database = "kerberos_acl";
$pass			= "kendaxa";

# CSV's
$ref_t = "reference_tables";

$mysqli = mysqli_connect('localhost', 'root', "$pass") or die("Cannot connect to database server: ".$mysqli->connect_error);

// Run mysqli query
function q($mysqli,$query) {			// does $mysqli is mandatory?
	$query = preg_replace('/\s+/',' ',$query); // truncate extra spaces
# ^ why not trim???!!!
	if( ! $result = $mysqli->query($query) )
		die("Failed on :  '$query' :  ".$mysqli->error);
	else
		echo "$query\tSUCCESS\n";

	return $result;
}
	

# When parsing csv's and storing them in database - keep in mind 
# that file names and table names are the same!
function get_rel_tbl($column,$ref_tbl) {

	$fp = fopen("$ref_tbl", 'r');	// open for reading

	# jump over column names in '$ref_tbl'
	fgetcsv($fp);
	$relational_table = False;
	
	while($reference_line = fgetcsv($fp))	{

		if($reference_line[0] == $column) {
			 $relational_table  = $reference_line[1];
			 break;
		}
	}

	fclose($fp);
	return $relational_table;
}


// Inserts values from csv file into table. Assumes that table is the same
// as file name.
//
function insert_csv($mysqli,$ref_tbl,$file) {

	$table = $file;
	
	$fp = fopen("$file", 'r');
	$fields = fgetcsv($fp);
	
	$r[$i=0] = Null;
	foreach ($fields as $field) {
			
		if($relation_table = get_rel_tbl($field,$ref_tbl)) {
			if($relation_table != $table)	# same table, no need relation
				$r[$i] = $relation_table;
		}
		$i++;
	}

	# Debug
	foreach($r as $k => $v) 
		echo "$k => $v\n";


	// Processing actual values...

	$columns = (implode(",",$fields));	# construct table columns 

#user,project
#v.caponi,SE
#t.kamaras,BE
	while ($values = fgetcsv($fp)) {
		# construct row values
		foreach($r as $index=>$relation_table) {
			if(is_null($r[$index]))
				continue;
			$result = q($mysqli,"SELECT id FROM $relation_table WHERE $fields[$index] = '$values[$index]'" ); 		
			$id = implode("",$result->fetch_assoc());
			var_dump($id);
			print_r($values);
			$values[$index] = $id;
		}

		$values = "'".(implode("','",$values))."'";
	
		$query = "INSERT INTO $table ($columns) VALUES ($values)";
		q($mysqli,$query);
	}
}

q($mysqli,"DROP DATABASE $database");
?>
