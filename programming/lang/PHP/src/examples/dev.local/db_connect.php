<?php

function add_host($mysqli,$server) {
	#echo "processing $csv for the ".basename($csv)."\n";
	
	q($mysqli, "CREATE TABLE `$server` (id SMALLINT NULL AUTO_INCREMENT,
																	user VARCHAR(50),
																	acl TINYINT(50),
																	PRIMARY KEY(id))" );
	$csv = CSV_DIR.$server;
	insert_csv($mysqli,$csv);
}

/* Process servers in loop. */
function populate_schema($mysqli) {

	global $hosts_table;

	insert_csv($mysqli,CSV_DIR."users");
	insert_csv($mysqli,CSV_DIR."acl");
	insert_csv($mysqli,CSV_DIR."hosts");

	# Process all the servers in loop.
	$query = q($mysqli,"SELECT hostname FROM $hosts_table");
	while($server = $query->fetch_assoc()) {
		add_host($mysqli,$server['hostname']);
	}
}

// Create and populate initial database set.
function init_db($mysqli) {

	/* Servers database */
	global $database;
	global $hosts_table;


	q($mysqli,"CREATE DATABASE $database");
	$mysqli->select_db($database) 
	 or die("Cannot select schema '$database':".$mysqli->error);

	q($mysqli, "CREATE TABLE `users` (id SMALLINT NULL AUTO_INCREMENT,
																	user VARCHAR(50),
																	project VARCHAR(50),
																	PRIMARY KEY(id))" );

	q($mysqli, "CREATE TABLE `acl` (number TINYINT NULL, 
																	description TINYTEXT)" );

	q($mysqli, "CREATE TABLE $hosts_table (id SMALLINT NULL AUTO_INCREMENT,
																	hostname VARCHAR(50),
																	project VARCHAR(50),
																	description TINYTEXT,
																	PRIMARY KEY(id))" );

	# Populate projects table
	populate_schema($mysqli);
}

?>
