#!/usr/bin/perl
use strict;
use warnings;
use v5.26;

my $x;
$x = 12345;			#  integer
say $x;
$x = 12345.67;		#  floating point
say $x;
$x = 6.02e23;		# scientific notation
say $x;
$x = 4_294_967_296;		#  underline for legibility
say $x;
$x = 0377;				# octal
say $x;
$x = 0xffff;			# hexadecimal
say $x;
$x = 0b1100_0000;	#  binary
say $x;
