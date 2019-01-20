#!/usr/bin/perl
# op.pl
#
# Exploring operators
use warnings;
use strict;

print "Enter desired itertations count: ";
chomp (my $L1 = <STDIN>);
#
# Get a random key from the hash
#
my %operators=(
		"+"		=> "plus",
		"-" 		=> "minus" );

my @keys_operators = keys %operators;

for my $i (reverse(0..$#keys_operators)) {
	print "\$keys_operators[$i]:\t$keys_operators[$i]\n";
}

# while ($L1--) {
# 	print "$L1:\t$L1\n";
# }
