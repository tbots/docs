#!/usr/bin/perl
use strict;
use warnings;
use 5.26.1;

my @all_ports = (0..65536);
my (@public,@registered,@dynamic)  = @all_ports[0..1023,1024-49151,49152-65535];

#print "@public\n\n";			# no)) everything goes to @public
print "@registered\n\n";
#print "@dynamic\n\n";
