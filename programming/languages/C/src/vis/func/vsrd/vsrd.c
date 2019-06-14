/*
 *
 *
 *
 *
 * The function highlights text portion from the current offset - bcnt (byte count) till the 
 * current offset. Attempts to visualise previous read call.
 */
#include <stdio.h>
#include <unistd.h>

int vsrd(int fd,int start,int bcnt,char brk) {
	int cur,ret,step;		
	char c;

	cur	= lseek(fd,0,SEEK_CUR);			/* remember current cursor position */
	step = lseek(fd,start,SEEK_SET);	/* set cursor to the index of start */

	for(; (ret = read(fd,&c,1)) > 0; step++) {		/* read till end of the file */
		if ( ret == -1 )	/* check for an error */
			ftl("read");

	 	if (step < cur - bcnt || step >= cur)
			printf("\033[0m\033[2m");		/* dim */
		else 
			printf("\033[0m");	/* read() call affected area */

		printable(c,1);		/* print character (see `man printable' for a details) */
		if(step >= cur) 		/* perform check if character matched brk condition; only after cursor is reached */
			if(c == brk ) 
				break;
	}		

	printf("\033[0m");	/* reset color */
	if(c != '\n')			/* last character read is not a new line */
		printf("\n");	/* print it */
	return lseek(fd,cur,SEEK_SET);				/* restore cursor to the one the function was called with */
}	
