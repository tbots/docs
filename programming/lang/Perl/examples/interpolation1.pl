#!/usr/bin/perl

use strict;
use warnings;

my $Pr = "HaHaHa";
my $Price = '$100';
print "The price for the product is $Price\n";
print "The price for the product is ${Pr}ice\n"; 		# The price of the product is HaHaHaice   :D

print "My name is Shl\@mo\n";
my $name = 'Shl@mo';	
print "My name is $name\n";			#  Works, also my $name = "Shl\@mo"
