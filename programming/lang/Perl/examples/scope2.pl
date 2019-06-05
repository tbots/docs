#!/usr/bin/perl

use strict;
use warnings;
#use v5.26.1;

sub count{
	state $counter=0;
	$counter++;
	return $counter;
}

say count();
say count();
say count();
say count();
