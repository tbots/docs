/* 
 * Return line start offset on which cursor is positioned at the moment of the 
 * function call.
 */

#include <stdio.h>
#include <sys/types.h>		/* lseek(3) */
#include <unistd.h>				/* read(3) */
#include "defs.h"

/* Returns end of file offset. */
int eof(int fd) {
	int c = lseek(fd,0,SEEK_CUR);
	int e = lseek(fd,0,SEEK_END);
	lseek(fd,c,SEEK_SET);
	return e;
}

int lst(int fd) {
	int ret; 	/* read() return value */
	int cur;	/* cursor offset */
	int end;		/* end of file offset */
	char c;

	cur = lseek(fd,0,SEEK_CUR);	/* store current cursor position */

	if(debug) {
		printf("in lst():\n");
		printf("before calculating start of the line\n");
		end = eof(fd);		/* display all the file contents with crstat() */
		crstat(fd,0,end,1,1);
	}

	while((ret = lseek(fd,-1,SEEK_CUR) > 0)) {		/* seek file character back */
		
		if(debug) {
			printf("seeking cursor one character back\n");
			printf("ret: %d\n",ret);
			crstat(fd,0,end,1,1);
		}

		if(read(fd,&c,1) == -1)		/* read character */
			ftl("read");			/* handle an error */

		if(debug) {
			printf("reading current character\n");
			crstat(fd,0,end,1,1);
		}

		if(c == '\n') {
			if(debug) {
				printf("new line was read\ncursor is on the offset of the start of the line\n");
				crstat(fd,0,end,1,1);
			}

			break;	/* cursor positioned on the first character in line */
		}

		lseek(fd,-1,SEEK_CUR);		/* compensate previous read */
		if(debug) {
			printf("previous read compensated\n");
			crstat(fd,0,end,1,1);
		}
	}

	if(debug) {
		if(ret == 0) {
			printf("start of the file reached cursor is at the beginning of the first line\n");
			crstat(fd,0,end,1,1);
		}
	}

	ret = lseek(fd,0,SEEK_CUR);			/* store line start index */
	lseek(fd,cur,SEEK_SET);					/* restore cursor as it was at the moment of the function call */

	return ret;			/* return line start index */
}
