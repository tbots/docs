#include <stdio.h>
#include <stdlib.h>

// handle the absence of "0x" prefix
int main(int argc,char **argv) {
	/* 
	 * long int strtol(const char *nptr, char **endptr, int base);
	 * 
	 * The strtol() function converts the initial part of the string in nptr to a long integer value according to the given
	 * base, which must be between 2 and 36 inclusive, or be the special value of 0.
	 *
	 * The string may begin with an arbitrary abount of white space followed by a single optional '+' or '-' sign. If base
	 * is 0 or 16, the string may then include a '0x' or '0X' prefix, and the number will be read in base of 16; otherwise
	 * a 0 base is taken in base of 10, unless the first character is '0', in which case it is taken in base of 8.
	 */
	printf("%ld\n", strtol(argv[1],NULL,0));
	return 0;
}
