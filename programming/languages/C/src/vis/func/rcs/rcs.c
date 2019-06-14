/* rcs.c
 *
 * Populates char_st structure.
 */
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include "defs.h"

struct char_st { 
	char 	p;
	char 	c;		
	char 	f;		
};

struct char_st cs = {0};

int rcs(int fd) {
	int ret;

	cs.p = cs.c;				/* store current character from the previous read; becomes a previous character */
	printf("stored previous character: '%c'\n",cs.p);
	//char *p = (char*)&cs + 1;					/* point to the second character in structure; cast allows 
																			 //proper decrement */
	//*(char*)&cs = *p;									/* copy second element to the first */
	
	if((ret = read(fd,&cs.c,2)) == -1) 		/* read two characters on the place of current */
	//if((ret = read(fd,p,2)) == -1) 		/* read two characters */
		ftl("error");			
	printf("reading two characters\n");
	crstat(fd,0,0,1,1);			/* int crstat(int fd,int s,int e,int n,int i); */
	printf("ret: %d\n\n",ret);

	if(ret != 0) {		/* end of file is not reached */
		printf("rewinding (%d-1)*-1 = %d\n",ret,(ret-1)*-1);
		lseek(fd,(ret-1)*-1,SEEK_CUR);		/* back ret - 1 */
		crstat(fd,0,-1,1,1);
	}
	return ret;
}

int main() {
	int fd = open("file",O_RDONLY);
	printf("at the beginning\n");
	crstat(fd,LINE_START,FILE_END,1,1);
	while(rcs(fd))
		;
	close(fd);
	return 0;
}
