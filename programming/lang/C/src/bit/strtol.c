#include <stdio.h>
#include <stdlib.h>

int main(int argc,char **argv) {
	printf("%ld\n", strtol("010",NULL,0));	// 8
	printf("%ld\n", strtol("0xF",NULL,0));	// 15 
	return 0;
}
