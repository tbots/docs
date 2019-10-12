#include <stdio.h>

int main() {
	#define BUFSIZE   1024
	#define TABLESIZE BUFSIZE

	printf("TABLESIZE: %d\n",TABLESIZE);

	#undef  BUFSIZE
	#define BUFSIZE 37
	printf("TABLESIZE: %d\n",TABLESIZE);
	return 0;
}
