#!/usr/bin/perl
use strict;
use warnings;
use 5.26.1;

sub fib {
	state @y;
	@y = (1,1) if not @y;
	push @y,$y[0]+$y[1];
	return shift @y;
}

say fib();
say fib();
say fib();
say fib();
say fib();
