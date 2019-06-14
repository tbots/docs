/* 
 * fnctl_flags.c
 */

#include <stdio.h>
#include <fcntl.h>
#include "defs.h"


int main(int argc,char *argv[]) {
	display_flags("O_RDONLY", O_RDONLY);
	display_flags("O_WRONLY", O_WRONLY);
	display_flags("O_RDWR", O_RDWR);
	printf("\n");
	display_flags("O_APPEND", O_APPEND);
	display_flags("O_TRUNC", O_TRUNC);
	display_flags("O_CREAT", O_CREAT);
	printf("\n");
	display_flags("O_WRONLY|O_APPEND|O_CREAT", O_WRONLY|O_APPEND|O_CREAT);

	return 0;
}
