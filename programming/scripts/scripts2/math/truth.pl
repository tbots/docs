#!/usr/bin/perl
use warnings;
use strict;

my $condition = <STDIN>;
print "\$condition: $condition\n";
chomp $condition;

if ($condition) {
	print "$condition returnes [TRUE]\n";
} 
else {
	print "$condition returnes [FALSE]\n";
}
