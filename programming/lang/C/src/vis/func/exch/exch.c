/* 
 *
 *
 *		Highlight current character read.
 *
 */
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int exch(int fd) {
	char c;
	int step,ret;
	int pos = lseek(fd,0,SEEK_CUR)-1;

	step=lst(fd);		/* set step to the line start index */
	lseek(fd,step,SEEK_SET);		/* set file offset to the start of the line */

	for(; (ret = read(fd,&c,1)) > 0; step++) {		/* read till end of the file */
		printf("\033[0m\033[2m");			/* print in dim by default */
		if(step==pos)			/* highlight character when position index reached */
			printf("\033[0m\033[7m");
		printable(c,1);		/* print character (see `man printable' for more information) */
		if(c == '\n')		/* stop at new line */
			break;
	}
	return lseek(fd,++pos,SEEK_SET);	/* set file offset as it was on function
											call and return it's value */
}
