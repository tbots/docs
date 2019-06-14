#!/usr/bin/perl

use strict;
use warnings;
use v5.26;

say (my $x = 12345);
#print ($x = 0b11111100)."\n";			#  will not work, "print(...) interpreted as a function" warning

$x = 0b11111100;
print "$x\n";
