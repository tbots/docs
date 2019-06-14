#!/usr/bin/env perl
#
# allow minus please
use warnings;
use strict;

my %level=(1,49,2,149);				# set questions count for each level
my $i;		# loop iterator

#
# numbers
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

#
# numbers keys
# 
my @num_keys = sort { $a <=> $b } keys %num;

#
# operators
#
my %op=(
		"minus"			=> "-",
		"plus"			=> "+",
		"from"			=> "-",
		"add"				=> "+"
);

#
# operators keys
#
my @op_keys = keys %op;

#
# print @op_keys
#
#print '@op_keys elements count: ', scalar @op_keys, "\n";
#for my $i (reverse(0..$#op_keys)) {
#	print "\$op_keys[$i]: $op_keys[$i]\n";
#}

for (keys %level) {

	print "Welcome to stage #$_...\n\n";
	
	# Reinitialize allowed answers, quuestions and results,
	# as each new level will change it behavior.
	#
	my %answers = reverse %num;
	
	my (%questions,
		 $expression, 		# key
		 $result);			# value

	# Answer counters
	my ($correct, $wrong, $typo);

	for (0..$level{$_}) {

		do {
			my @operands;
			#
			# operands init
			#
			for $i (0..1) {
				$operands[$i] = $num_keys[int(rand(10))];
			}
		
			# operator is literal, because it's name is unique and
			# hash value is repeated
			my $operator = $op_keys[int(rand(scalar @op_keys))];
			
			# store only absolute value of the result (positive)
			# important when performing: 6 from 10 is -4 
			$result = abs(eval("$operands[0] $op{$operator} $operands[1]"));
		
			# 
			# Construct an expression
			#
	
			# $r is now randomaly generated index in @operands
			my $r = int(rand(scalar @operands));
			# assign a literal value to the one of the operands, depends on $r
			$operands[$r] = $num{$operands[$r]};
		
			# if $r returns true change literal operator to numeric
			$r = int(rand(2));
			if ($r) {	# 1
				$operator = $op{$operator};
			}
			
			# expression
			$expression = "$operands[0] $operator $operands[1] = ";
			
		} while (exists $questions{$expression});
	
		# store expression with its computed result
		$questions{$expression} = $result;
	}
	
	#
	# DEBUG
	#
	print "\%question elements: ", scalar (keys %questions), "\n";
#	for (keys %questions) {
#		print "$_ = $questions{$_}\n";
#	}
	
	for (keys %questions) {
	
		print;	# print a question
		chomp (my $answer = <STDIN>);
	
		if (exists $answers{$answer}) {		# answer read is exists hash element
			if ($questions{$_} == $answers{$answer}) {
				$correct++;
			}
			else {
				$wrong++;
			}
		}
		# answer read is a typo
		else {
			$typo++;	
		}
	}
	
	# Report results
	print "Correct: $correct  Wrong: $wrong  Typo: $typo\n";
}
