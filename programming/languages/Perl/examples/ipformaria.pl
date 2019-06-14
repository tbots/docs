#!/usr/bin/perl

use strict;
use warnings;
use v5.26;

# For Maria, sunshine, how can I not explain to you? :*
#
# Implementation#  1
#  Calculate subnet mask from 10.0.0.2/20. -> 255.255.

#  Splitting on character. 
for(my $i=0; $i < scalar @ARGV; $i++) {
	print "$i:\t${ARGV[$i]}\n";
}

my @mask = split(/\//,${ARGV[0]});
my $bits =  ${mask[-1]};
my @octets = (0, 0, 0, 0);
my $i=0;
while(($bits -= 8) >0)  {
  $octets[$i++] = 8;
}
$octets[$i] = 8 + $bits;

my $bin;		# holds final binary representation of the mask
for($i=0; $i < 4; $i++) {
	my $bits = $octets[$i];
	$bin .=  "1"x$bits."0"x(8-$bits)." ";
	
 }
 say $bin;
 $bin =~ s/(\d)\s+(\d)/\1. \2/g;
 say $bin;
