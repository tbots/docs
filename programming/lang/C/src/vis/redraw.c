#include <stdio.h>					/* fprintf(3) */
#include <stdlib.h>					/* exit(3) */
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <getopt.h>
#include <string.h>
#include "defs.h"

int main() {
	int fd;				/* file descriptor */
	int c;
	int mode;			/* read mode */
	char *filename = "file";

	mode  				= O_RDWR;				/* read mode */
	if((fd = open(filename,mode)) == -1) 
		perror("fucking hell");
	
	int i;
	for(i=0; i<5; ++i) 
		if(read(fd,&c,1))
			printf("%c",c);

	fflush(stdout);
	sleep(2);
	redraw(fd,"ab",0);
	printf("\n");
	return 0;
}
