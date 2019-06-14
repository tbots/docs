#include <stdlib.h>

/* Print error message (msg) following colon (':') whitespace and an perror(3) 
	 generated error message. Does not return. Exit with error code of EXIT_FAILURE. */
void ftl(char *msg) {
	perror(msg);
	exit(EXIT_FAILURE);
}
