#!/usr/bin/perl
use strict;
use warnings;
use 5.26.1;

my @range = (0..9);
sub i{
	for my $num (@range) {
		print $num." ";
	}
	print "\n";
}

i();
for(@range) { $_*=2; }
i();
for(my $i=0;$i < 10;$i++)
{
	$range[$i] /= 2;
}
i();
