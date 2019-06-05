#!/usr/bin/perl

use strict;
use warnings;
use v5.26;

print "Field separator: |".$"."|\n";
$" = 'XXX';
print "Field separator: |".$"."|\n";
my @array = qw(One, Two);			# how to split it with ',' commas, for example
print "@array\n";			# OneXXXTwo
#foreach(@array) { print $_."\n"; };
