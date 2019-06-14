/* Test \033[{number}D behaviour */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
	printf("12345");
	fflush(stdout);
	sleep(1);
	printf("\033[%dD",3);
	return 0;
}
