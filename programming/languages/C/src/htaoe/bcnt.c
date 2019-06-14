#include <stdio.h>
#include <stdlib.h>

int main(int argc,char **argv) {
	/*
	 * Calculate byte count within 
	 * decimal number.
	 */

	int n,b;

	n = atoi(argv[1]);
	for(b=0; n > 0; b++) {
		n /= 256;
		printf("[DEBUG]   n:   %d\n",n);
	}

	printf("Bytes altered by the %d is %d\n",n,b);
	return 0;
}
