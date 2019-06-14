#include <stdio.h>
#include <unistd.h>
#include <ctype.h>

int main() {
	printf("AAA\nBBB");
	fflush(stdout);
	sleep(1);
	//printf("\033[2K\033[1A");
	printf("\e[1A");
	fflush(stdout);
	sleep(1);
	printf("\n");
	return 0;
}
