#!/usr/bin/perl

use strict;
use warnings;
use v5.26;

#  q// and qq//	literal string operators   '',""
my $name = "Vasyliy";
print q/$name/.qq/\n/;			# $name does not interpolates, new line interpolates
print qq!Hello, "$name"\n!;			# Hello, "Vasyliy"
print qq"Hello, \"$name\"\n";			# Hello, "Vasyliy" <- have to be escaped
print qq<Hello, '$name'\n>;				# Hello, 'Vasyliy'	<- does interpolates even in single quotes

my $condition = 1;			# Don't know how to implement yet
## First '{' part of the q{} modifier
my $chunk_of_code = q {			
	if($condition) {
		print "Gotcha!\n";
	}
};

# qx// command execution operator
my $ls_output= qx/ls -1 | head/;
print "$ls_output";

my @ls_output = ( qx/ls -1 | head/ );			#  new line is stored as well
print scalar @ls_output."\n";		#  10 elements - as expected
for(my $i=0; $i < scalar @ls_output; $i++) {
	$ls_output[$i] =~ s/\s/X/g;		# substitute each new line by a 'X' character
	print "$ls_output[$i]\n";
}

#my @ls_output = qw( qx/ls -1 | head/ );			#  each element gonna be treated separately - no command will run


# qw() word list operator

#my @currency_symbols = ( $name,"Oleg");		# works without quoting
#my @currency_symbols = qw( $name "Oleg");		#  does not interpolates
																						# !NOTE no commas in qw() context

my @currency_symbols = ( "$name","Oleg");		#  does interpolate
print "@currency_symbols\n";

@currency_symbols = qq( "$name","Oleg");		#  treated as one string, even sees the space before, interpolates
print "@currency_symbols\n";

# Pattern matching with alternate quotes:   m//
$_ = '../home';
print "relative path\n" if m/..\//;			# YO! Default search is '$_';
print "relative path\n" if /..\//;			# YO! Default search is '$_';
print "relative path\n" if m{../};			#  beauty of avoiding escaping of the backslash with alternate delimiters

$_ = "Putta";
s<(.utta)>($1 l'cura);
print "$_\n";

my @range =  ("a" .. "z");
print "@range"."\n";
my $range = join '',@range;
print "$range\n";
$range =~ tr/a-z/0-7/;			# !NOTE  that rest of the unmatched characters are converted to 7
print "$range\n";
