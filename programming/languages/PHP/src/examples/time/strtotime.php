<?php 

# Exploring strtotime() function behavior
#
# The idea is to display a requested date in the specified format following by the representation
# provided by the cal(1) program. Desired is highlighting of relative and resulting date.

/* Return formatted date relatively ($relative) to the time ($time).
 *
 *  d   - day of month (0[1-31])
 *  D   - textual representation of the day (Mon through Sun)
 *  j   - day of the month without leading zeroes ([1-31])
 *  l   - full textual representation of the day of the week (Sunday through Saturday)
 *  N   - ISO-8601 numeric representation of the of the week (1(for Monday) through 7 (for Sunday))
 *  S   -
 *  m   -
 *  Y   - 
*/
function _date($time = "now", 
               $format = 'Y-m-d',
               $relative = "now") {

  /* DEBUG */
  /* print_r(func_get_args()); */

  /* Indent for the.. */
  $indent = 80;   

  if(is_integer($time)) {   # time was passed a timestamp value, not a string
    if($time == time()) 
      $time = "now"; // if equals to time(), can be represented by "now" string
    else {      /* timestamp differs from the current time
    printf("Passed an integer time value that does not correspond to the current time. ".
          "Impossible to represent it!\n");
    exit(1);
    }
  }
  if($time == "now")
    $requested_time = "Current time/date ";
  else 
    $requested_time = "Time in $time ";
  $requested_time .= "relatively to '".date('l jS F Y',strtotime($relative))."'in format of '".$format."'\n   => ";
  $date = date($format, strtotime($time,strtotime($relative)));
  $date = sprintf(sprintf("%s %%+%ds",$requested_time, $indent-strlen($requested_time)), 
                                                          $date);
  printf("%s\n",$date);
 
  /* $time = date($format, strtotime($time,strtotime($relative)));   # Uncomment me */
	return $date; 		
}

# Here time() will have the same effect as 'now' string for the call to strtotime() resulting
# in current Unix timestamp value to be passed to the _date() function that was in turn formatted 
# in to the human-readable representation of the current day (because of the 'd' format specification).
_date(time(),'d');     # 28
_date("now",'d');      # 28

# All of the following calls will result in "31" to be printed, that is the next Sunday. NOTE that dayname
# is not case sensitive.
_date('Sunday','d');
_date('sunday','d');  
_date('sun','d'); 
_date('Sun','d');      # 31

# number [+-]?[0-9]+
_date('-1 day','d D F');   # 27 Wed March
_date('+3 weekdays','d D F');  #  02 Tue April

# ordinal 'first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eight', 'ninth', 'tenth', 'eleventh',
#   'next', 'last', 'previous', 'this'
_date('first day','j D F');    # 29 Fri March; 'of March' is not implied; 
_date('first day of March','j D F');    # 1 Fri March (real date)
_date('first weekday','j D F');    # 29 Fri March (first following weekday)
_date('first weekday', 'j D F', 'first day of March');    # 4 Mon March

_Date('this Sunday', 'j D F');
_date('first Sunday of April', 'd D(N '.'day)');  # will not work
_date('first Sunday of April', 'd D(N \d\a\y)');  # escaped successfully
