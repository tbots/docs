#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

char *program_name;

/* Print usage to the stream and exit with exit code. */
void usage(FILE *stream, int exit_code) {
	fprintf(stream,"Usage: %s [OPTIONS]... CHARS...\n",program_name);
	fprintf(stream,"Display characters following their hexadecimal representation.\n");
	exit(EXIT_FAILURE);
}

/*
 * MAIN
 */
int main(int argc,char *argv[]) {
	int i;
	char *cp; /* char pointer */

	program_name = argv[0];

	for(i=1; i < argc; i++) {
		for(cp = argv[i]; *cp != '\0'; cp++) {
			printf("0x%02x\n",*cp);
		}
	}

	return 0;
}
