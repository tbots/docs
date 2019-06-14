#!/usr/bin/perl
#
# math game
use strict;
use warnings;

# Display usage
print <<EOF;
Arithmetic game.
Choose a desired number of questions that you will be prompted to answer.
Provide an answer by giving a literally names of the numbers (e.g., one, eleven etc.)
And have a fun!
EOF

my $i;			# declare loop iterator

# Prompt for the number of repetitions
print "Enter a desired number of repetitions: ";
chomp (my $L1 = <STDIN>);

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

# Holds a numbers. Storing it in array allow us to refer to the element by index
# randomaly generated.
my @num_keys = sort {$a <=> $b} keys %num;		# @num   0 .. 9

# When read an answer used to fetch it's corresponding numeric value and compare with the result.
my %answers = reverse %num;		

#
# Maybe need to create a reverse hash, thus keeping operation names unique

### arithmetic operators
my %op=(
		"minus"			=> "-",
		"plus"			=> "+",
		"multiply by"	=> "*",
		"divide by"		=> "/"
);


# Holds a arithmetic operator. Storing it in array allows to us to refer to the element by index
# generated randomaly.
my @op_keys = keys %op;		# @op  + -

# Count correct, wrong, and typo results
my ($correct, $wrong, $typo) = (0, 0, 0);

# Holds a questions
my (%questions, @questions);

while ($L1--) {			
		
	# Holds the first and second operands of the arithmetic expression.
	my @operand;		

	# Initialize two operands.
	for $i (0..1) {		
		$operand[$i] = $num_keys[int rand(10)];
	}

	# Initialize arithmetic operator
	my $operator = $op_keys[int rand(4)];	

	# Compute the result
	my $res = abs(eval("$operand[0] $operator $operand[1]"));

	my $behavior = int rand(2);
	
	# random of 2 will produce 0 or 1, leading for initializing one of the
	# indexed elements by its corresponding literal name
	$operand[$behavior] = $num{$operand[$behavior]};

	# Randomaly choose how to display operator (literally or as is)
	$behavior = int rand(2);
	if ($behavior) {		# 1
		# dealing with literals
		$behavior = int rand(2);
		if ($behavior) {	# 1
		# dealing with %op
	 	$operator = $op{$operator};
		}
		else {
		# dealing with %op2
			$operator = $op2{$operator};
			if ($operator == "from") {
				$res = -$res;	# negotiate result
			}
		}
	}

	my $q = "$operand[0] $operator $operand[1] = ";

	# Add a generated question to the array
	push @questions, $q;
	if (not exists $questions{$q}) {
		#
		# Store corresponding result for the new generated question
		$questions{$q} = $res;			# store question in %questions
	}
}

print "Questions generated: ",scalar @questions,"\n";
print "Questions hash: ", scalar (keys %questions), "\n";
for (@questions) {
	
	print $_;	# print a question
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
