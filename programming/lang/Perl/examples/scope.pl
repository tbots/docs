#!/usr/bin/perl

use strict;
use warnings;
use v5.26.1;

{
	my $counter = say "world";
	sub count{
		$counter++;
		return $counter;
	}

	sub reset_counter {
		$counter=0;
	}
}

say "hello";
say count();
#say $counter;
say count();
say count();
reset_counter();
say count();
