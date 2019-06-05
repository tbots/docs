#!/usr/bin/perl
use strict;
use warnings;
use v5.26;

print "length \$#ARGV: length $#ARGV\n";
if (length $#ARGV > 0) 
{
	print "Hello \U$ARGV[0]! How are you doing?\n";			# Uppercase till end of the line
	print "Hello \U$ARGV[0]!\E How are you doing?\n";		# Uppercase till '\E'
	print "Hello \u$ARGV[0]! How are you doing?\n";			# Uppercase (titlecase) following character
	print "Hello \u $ARGV[0]! How are you doing?\n";		# Whitespace got's uppercased :)
	print "Hello \L$ARGV[0]! How are you doing?\n";		# Lowercase all
	print "Hello \l$ARGV[0]! How are you doing?\n";		# Lowercase following character
	print "Hello \F$ARGV[0]! How are you doing?\n";		# Foldcase.. had the same effect as \L and used for the caseinsensitive comparisons
	print "Hello \F$ARGV[0]! How are you doing?\n";		# Foldcase.. had the same effect as \L and used for the caseinsensitive comparisons
}
else
{
	print "No arguments :(\n";
}

# \Q  backslash all following nonalphanumeric characters; ends at \E

my $string = '5+10';		
my $regexp = '\d+\d';		

#if($string =~ /5+10/) {
$regexp = '5+10';		# what is the difference between \d+\d that is matches and 5+10 that is fucking not?!!!!
#if($string =~ /\Q$regexp\E/) {		# same as 5\+ <- literal and 10
if($string =~ /$regexp/) {
	say "matched";
}
else {
	say "does not matched";
}
