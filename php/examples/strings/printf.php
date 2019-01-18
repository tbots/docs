<?php

	/* printf() type specifiers and modifiers
	 		%{modifier}{type}*/

	$int = 97;
	printf("int: %b	[%%b]\n",$int);		/* the argument is an integer and is displayed as a binary number */
	printf("int: %c	[%%c]\n",$int);		/* the argument is an integer and is displayed as the character with that value */
	printf("int: %d	[%%d]\n",$int);		/* the argument is an integer and is displayed as a decimal */
	printf("int: %e	[%%e]\n",$int);		/* the argument is a double and is displayed in scientific notation */
	printf("int: %E	[%%E]\n",$int);		/* the argument is a double and is displayed in scientific notation in uppercase */
	printf("int: %f	[%%f]\n",$int);		/* the argument is a floating-point number and is displayed as such in a the current locale's format */
	printf("int: %F	[%%F]\n",$int);		/* the argument is a floating-point number and is displayed as such */

	//$int = 97.5;
	printf("int: %g	[%%g]\n",$int);		/* the argument is a double and is displayed in either in scientific notation (as with the %e) or 
																				as a floating point number (as with the %f type specifier), whichever is shorter */
	printf("int: %o	[%%o]\n",$int);		/* the argument is an integer and is displayed as an octal value */
	printf("int: %s	[%%s]\n",$int);		/* the argument is a string and is dispalyed as such */
	printf("int: %u	[%%u]\n",$int);		/* the argument is an unsigned integer and is displayed as a decimal number */
	printf("int: %x	[%%x]\n",$int);		/* the argument is an integer value and is displayed as a hexadecimanl (lowercase) */
	printf("int: %X	[%%X]\n",$int);		/* the argument is an integer value and is displayed as a hexadecimanl (uppercasee) */

	/* Modifiers */

	printf("|%3d|\n" ,7);				/* default padded by 'whitespaces' */
	printf("|%03d|\n",7);				/* 007 */
	printf("|%'x3d|\n",7);			/* xx7 */

	$str = "string";
	printf("%-10s\n",$str);			/* left justified */
	printf("%+10s\n",$str);			/* right justify is the default */
	printf("%10s\n",$str);			/* same as above */

	printf("%-+5dhello\n",$int);	/* justify to the left and display '+' */
?>
