<?php

$str = "hello, world! Marce calling!\n";
$splitted = preg_split("/[ \n]+/",$str,3,PREG_SPLIT_NO_EMPTY);   // regexp here is a delimiter; EOF is also somehow returned,
                                                                  // use PREG_SPLIT_NO_EMPTY to get only non-empty elements
                                                        // limit is the number of elements to be returned, -1 indicates no limit
var_dump($splitted);  // 'hello' 'world' Marce' 'calling\n'
