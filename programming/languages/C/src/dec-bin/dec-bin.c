/* 
 * Display binary representation of the number.
 */
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include "bin.h"
#include "edit.h"

/* Process all the arguments in loop. */
int main(int argc,char *argv[]) {
	int i;
	for(i=1; i < argc; i++) {
		indent(argv[i],30);
		printf(": ");
		binary_print(atoi(argv[i]));
	}
	return 0;
}
