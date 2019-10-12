<?php

define( 'DEBUG', true );   # set to 0 to disable

function q( $mysqli, $query, $schema='' ) {

  # remove extra whitespaces; useful when $query that is passed was split
  # to several lines for the readability
  $query = preg_replace( '/\s+/', ' ', $query );
  
  if ( ! $r = $mysqli->query( $query ) )
    die( "Failed on: '$query'\n" . $mysqli->error );
  else
    if ( DEBUG  )
      echo "'$query'   SUCCESS\n";

  return $r;
}

function drop_schema( $mysqli, $query, $schema ) {
  q( $mysqli, "DROP SCHEMA $schema" );
?>
