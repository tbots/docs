/* argc.c - example of getting an agrument count */
#include <stdio.h>

int main(int argc, char **argv) {
	printf("program name: %s\n",argv[0]);		/* always at index of 0 */
	printf("argc: %d\n",argc);		/* starts from 1 */
	return 0;
}
