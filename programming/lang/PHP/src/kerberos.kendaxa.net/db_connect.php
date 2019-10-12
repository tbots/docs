<?php

require('db.php');

function populate($mysqli,$ref_t) {
	insert_csv($mysqli,$ref_t,"projects");
	insert_csv($mysqli,$ref_t,"users");
	# then servers
	# then acl_lst
	# then acl
}

// Create and populate initial database set.
function init_db($mysqli) {
	global $database;
	global $ref_t;

	q($mysqli,"CREATE DATABASE $database");
	$mysqli->select_db($database) or die("Cannot select schema '$database':".$mysqli->error);

	# Create a server table
	q($mysqli, "CREATE TABLE servers (id SMALLINT NOT NULL AUTO_INCREMENT,
																		hostname VARCHAR(30), 
																		project SMALLINT,
																		description TINYTEXT,
																		PRIMARY KEY(id))" );
	# Create a users table 
	q($mysqli, "CREATE TABLE users (user VARCHAR(50) NOT NULL, 
																	project TINYINT DEFAULT NULL)" );

	# Create a projects table
	q($mysqli, "CREATE TABLE projects (id SMALLINT NOT NULL AUTO_INCREMENT,
																		project VARCHAR(50) NOT NULL,
																		description VARCHAR(100),
																		PRIMARY KEY(id))" );

	# Create an acl_lst table
	q($mysqli, "CREATE TABLE acl_lst (id SMALLINT NOT NULL AUTO_INCREMENT,
																		access VARCHAR(100),
																		PRIMARY KEY(id))" );

	# Create acl reference table
	q($mysqli, "CREATE TABLE acl (server SMALLINT NOT NULL,
																		user SMALLINT NOT NULL,
																		acl SMALLINT NOT NULL)" );

	# Populate projects table
	populate($mysqli,$ref_t);
}


// Create database if needed
if( !$mysqli->select_db("$database") )
	init_db($mysqli);
