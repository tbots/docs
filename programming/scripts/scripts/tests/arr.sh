#!/bin/bash

time=`sed -n '/Torah\s\+Reading.*Tazria-Metzora/,$ {/\(Light\s\+Candles\s\+at\|Shabbat\s\+Ends\)/,/[0-9]/p}' file | grep -m2 -o '[[:digit:]].*'` 

shabbat_start=`echo $time | sed -n '/\(\S\+\s\w\+\).*/s//\1/p'`
shabbat_end=`echo $time | sed -n '/.*\s\([0-9].*$\)/s//\1/p'`
echo "shabbat_start: $shabbat_start"
echo "shabbat_end: $shabbat_end"
