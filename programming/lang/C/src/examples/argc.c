/* argc.c - example of getting an agrument count */
#include <stdio.h>

int main(int argc, char **argv) {
	printf("argc: %d\n",argc);
	return 0;
}

/* NOTE: argc is 1 by default as program name is the first element in the argv[] array */
