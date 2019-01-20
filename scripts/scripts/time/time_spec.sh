#!/bin/bash
#
# Script sets the time temporary. Will be merged in lib.
#
# Accepted formats:
#		'09:00 PM|AM'
#		'May 1 09:00:00 PM|AM UTC 2017'
#		'May 1 2017 09:00:00 PM|AM UTC'
#		'Friday, May 5, 2017 8:09 PM'
#
# In case of month is prepended with the day it is ignored and date is displayed with the correct day.
#
# sed constrain expression should be created to check for the proper formats and fix in case if it is possible
