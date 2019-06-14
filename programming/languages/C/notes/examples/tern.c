/* tern.c - an example of the ternary operator */
#include <stdio.h>

int main() {

	/* In the expression:   expr1 ? expr2 : expr3 
	 * expr1 is evaluated first. If it is non-zero (true), then the expression expr2 is 
	 * evaluated, and that is the value of the conditional expression. Otherwise expr3 is
	 * evaluated, and that is the value. Only one of the expr2 or expr3 is evaluated.
