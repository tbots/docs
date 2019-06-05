#!/usr/bin/perl
use strict;
use warnings;
use 5.26.1;

my @coins = ('Bit', 'Alt', 'Manero');
foreach (@coins) {
	print "$_"."coin"."\n";
}


my @luck = qw(two attempts);

for(@luck) {
	say $_;
}

my @range = (0..9);
for my $num (@range) {
	say $num;
}
