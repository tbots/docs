<?php

include ( 'mysqli.php' );   # for the q() function


$host    = "localhost";
$user    = "root";
$password= "sweet";
$schema  = "bob_shop";
$orders_table = "orders";

$mysqli = mysqli_connect( $host, $user, $password )
    or die( "Cannot connect to database server: " . $mysqli->connect_error);

function init_db( $mysqli ) {
  echo __FUNCTION__;
  q($mysqli, "CREATE DATABASE bob_shop");
  q($mysqli, "USE `$schema`");
  q($mysqli, "CREATE TABLE $orders_table( 
        id SMALLINT NOT NULL AUTO_INCREMENT,
        tires SMALLINT DEFAULT 0,
        oil SMALLINT DEFAULT 0,
        sparks SMALLINT DEFAULT 0,
        address VARCHAR( 100 ),
        PRIMARY KEY( id ) )" );
}

function store_order($mysqli) {
  # all the fields should be declared here
  q($mysqli, "INSERT INTO orders (tires,oil,sparks,address,date) VALUES
        ('$tireqty','$oilqty','$sparkqty','$address','$date')");
}

# Create database if not created
if ( ! $mysqli->select_db( $schema ) ) {
    echo "Creating database..." . PHP_EOL;
    init_db( $mysqli );
}


#touch_schema($mysqli);
#function touch_schema($mysqli) {
#  global $orders_table;
#  q($mysqli, "INSERT INTO $orders_table (touch) VALUES (" . date( "'Y-m-d H:i:s'" ) . ")");
#}

?>
