/*
 *
 *
 *
 *	Return offset between current cursor position and line start. 
 *  First cursor position is set to n, then offset between new cursor index and
 *	line start is calculated. Calculated value is the return value of the function.
 */
#include <sys/types.h>
#include <unistd.h>
#include "defs.h"

int lst_or(int fd,int ro) {			/* line start offset relative */
	int cur,ls;
	
	cur = lseek(fd,0,SEEK_CUR);		/* remember current cursor position */
	ls = lseek(fd,ro,SEEK_SET) - lst(fd);		/* calculate offset from the line start */
	
	lseek(fd,cur,SEEK_SET);		/* restore file offset as it was at the function call */
	return ls;				/* return calculated value */
}
