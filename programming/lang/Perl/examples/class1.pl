#!/usr/bin/perl

use strict;
use warnings;

use lib '/home/osergiyuk/docs/lang/Perl/examples/';
use Product;

my $iphone = Product->new({
											serial => "100",
											name   => "iPhone5",
											price  => 650.00});

print $iphone->get_name()."\n";
$iphone->set_name("iphuy");
print $iphone->get_name()."\n";
