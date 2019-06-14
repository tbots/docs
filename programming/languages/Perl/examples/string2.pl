#!/usr/bin/perl

use strict;
use warnings;
use v5.26;

my %numbers = (
		"one"			,		1,
		"two"			,		2,
		"three"		,		3,
		"four"		,		4,
		"five"		,		5,
		"six"			,		6,
		"seven"		,		7,
		"eight"		,		8,
		"nine"		,		9
	);

print "One is written as $numbers{one}\n";			#  ! NOTE no need in quoting because {} identifier is always a string
print "One is written as ".$numbers{one}."\n";
print "One is written as ".$numbers{"one"}."\n";
