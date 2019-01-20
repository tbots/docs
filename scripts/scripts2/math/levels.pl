#!/usr/bin/env perl
use warnings;
use strict;

my %level=(1,50,2,100);

for (keys %level) {
	print "$_ => $level{$_}\n";
}
