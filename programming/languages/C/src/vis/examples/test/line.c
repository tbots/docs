#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void sec(){
	fflush(stdout);
	sleep(1);
}
	
int main() {
	printf("hello\nworld");
	sec();
	printf("\033[1D");						// move one character back
	sec();
	//printf("\033[K");						// clear screen till the beginning of the line
	//sec();
	//printf("|w|");
	//printf("\033[1A\033[1K");
	return 0;
}
