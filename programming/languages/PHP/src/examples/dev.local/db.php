<?php

require('db_connect.php');

$database = "kerberos_acl";
$pass			= "kendaxa";
$hosts_table = "hosts";
define("CSV_DIR","csv/");

### MAIN ####
$mysqli = mysqli_connect('localhost', 'root', "$pass") 
	or die("Cannot connect to database server: ".$mysqli->connect_error);

// Create database if needed
if( !$mysqli->select_db("$database") )
  init_db($mysqli);

// Return acl_num if user is in acl of the server.
function user_in_acl($mysqli,$server,$user) {
  if ( $acl_num = q($mysqli,"SELECT (acl) FROM `$server` WHERE user = '$user'")->fetch_assoc() ) {
	  $acl_num = implode($acl_num);
  }
  return $acl_num;
}

// Returns a string description of ACL by number
function acl_desc($mysqli,$acl_num) {
 return implode(q($mysqli,"SELECT (description) FROM `acl` WHERE number = '$acl_num' ")->fetch_assoc());
}

# Run mysqli query
function q($mysqli,$query) {			// does $mysqli is mandatory?
	$query = preg_replace("/\s+/"," ","$query"); // truncate extra spaces
	if( ! $result = $mysqli->query($query) )
		die("Failed on :  '$query' :  ".$mysqli->error);
	#else
		#echo "$query\tSUCCESS\n";
	return $result;
}

// Inserts values from csv file into table. Assumes that table is the same
// as file name.
//
function insert_csv($mysqli,$file) {

  // Parse servers, insert into servers (name) values (value)
	// For each server name found in the database read corresponding csv file
	$table  = basename($file);
	
	$fp = fopen("$file", 'r');
	$fields  = fgetcsv($fp);			### FIELDS ###
	$columns = (implode(",",$fields));

	while ($values = fgetcsv($fp)) {	# read line by line CSV file; values[] is the array of parsed records
		$values = "'".(implode("','",$values))."'";
		$query = "INSERT INTO `$table` ($columns) VALUES ($values)";
		q($mysqli,$query);
	}
}

?>
