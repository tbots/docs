#include <stdio.h>
#include <stdlib.h>


/* Return byte count within number. */
int byte_cnt(unsigned int value) {
	int cnt;			// byte count
	int mask = 0xff;	// byte mask

	for(cnt=0; value & mask; cnt++)
		mask*=256;
	return cnt;
}


int main(int argc,char **argv) {
	int i;
	int value;
	for(i=1; argv[i] != 0; i++) {
		value= atoi(argv[i]);
		printf("it is %d bytes in a %d\n", byte_cnt(value),value);
	}
	return 0;
}
