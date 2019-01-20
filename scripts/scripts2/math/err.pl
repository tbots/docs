#!/usr/bin/perl
#
# Handle an error on incorrect input
#


my %num=(
		0			=> "zero",
		1			=> "one",
		2			=> "two",
		3			=> "three",
		4			=> "four",
		5			=> "five",
		6			=> "six",
		7			=> "seven",
		8			=> "eight",
		9			=> "nine",
		10			=> "ten",
		11			=> "eleven",
		12			=> "twelve",
		13			=> "thirteen",
		14			=> "fourteen",
		15			=> "fifteen",
		16			=> "sixteen",
		17			=> "seventeen",
		18			=> "eighteen",
#		19			=> "nineteen"
);

# Holds a numbers. Storing it in array allow us to refer to the element by index
# randomaly generated.
#my @num_keys = sort {$a <=> $b} keys %num;		# @num   0 .. 9

# When read an answer used to fetch it's corresponding numeric value and compare with the result.
my %answers = reverse %num;		

print "Enter an answer: ";
chomp (my $answer = <STDIN>);

exists $answers{$answer} or print "Element doesn't exists.\n";
