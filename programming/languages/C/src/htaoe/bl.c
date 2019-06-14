/* Return binary string for the read number. 
 * Accepted formats:   0x and 0octal
 *
 * variable aliases:
 *			bcnt 		- byte count
 */
#include <stdio.h>
#include <stdlib.h>
#include "bin.h"

/* 
 * Print usage to the stream and exit with exit_code. 
 */
void usage(FILE *stream,int exit_code) {
	fprintf(stream,"Usage: %s number\n",program_name);
	fprintf(stream,"Prints binary representation of the number.\n");
	exit(exit_code);
}

/* 
 * Return number of bytes occupated by the number. 
 */
int occup(char *number) {
	int num,bcnt;
	num = strtoll(number,NULL,0);			/* convert the number */
	for(bcnt=0; num > 0; bcnt++)
		num /= 256;
	return bcnt;
}


int main(int argc,char **argv) {
	char bin[32] = {0};				/* binary string buffer */
		
	program_name = argv[0];
	if(argc < 2)
		usage(stderr,EXIT_FAILURE);


	printf("%s",
			ret_bin(bin,strtoll(argv[1],NULL,0),occup(argv[1])));

	printf("\n");

	return 0;
}
