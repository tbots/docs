#include <stdio.h>				/* for perror(3) */
#include <stdlib.h>				/* for exit(3) */

/* Calls perror() with the error message msg to be printed before error explained. Exit with error code of EXIT_FAILURE.
   Does not returns. */
void ftl(char *msg) {
	perror(msg);
	exit(EXIT_FAILURE);
}
