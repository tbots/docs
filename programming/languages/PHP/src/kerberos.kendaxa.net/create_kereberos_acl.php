<?php

require('db.php');

q($mysqli,"DROP DATABASE $database");
q($mysqli,"CREATE DATABASE $database");
$mysqli->select_db($database) or die("Cannot select schema '$database':".$mysqli->error);

# Create a server table
q($mysqli, "CREATE TABLE servers (id SMALLINT NOT NULL AUTO_INCREMENT,
																	hostname VARCHAR(30), 
																	project SMALLINT,
																	desription TINYTEXT,
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
																	access_level VARCHAR(100),
																	PRIMARY KEY(id))" );

# Create acl reference table
q($mysqli, "CREATE TABLE acl (server SMALLINT NOT NULL,
															user SMALLINT NOT NULL,
															acl SMALLINT NOT NULL)" );
 populate_tables();
?>
