#!/usr/bin/perl

use strict;
use warnings;
use v5.26;

my @ls_output = ( qx/ls -1 | head/ );			#  new line is stored as well
#my @ls_output = qw( qx/ls -1 | head/ );			#  each element gonna be treated separately - no command will run

print scalar @ls_output."\n";		#  10 elements - as expected
for(my $i=0; $i < scalar @ls_output; $i++) {
	$ls_output[$i] =~ s/\s/X/g;		# substitute each new line by a 'X' character
	print "$ls_output[$i]\n";
}
