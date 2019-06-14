#!/usr/bin/perl
#
use strict;
use warnings;

my @digits = split('', 14);

print "\@digits count: ", scalar @digits, "\n";
for my $i (reverse(0 .. $#digits)) {
	print "\$digits[$i]:\t$digits[$i]\n";

}
