/* 
 * crstat - visualise read offset
 *
 * Prints characters from the offset of start till the offset of end from the file pointed by the file descriptor fd. Printing can
 * be controlled using two constants: LINE_START(-1) and LINE_END(-1). If LINE_START is in effect printing will start from the line
 * on which cursor is posistioned on, cursor offset is calculated using lst() function. If LINE_END is in effect reading will stop when end of the line is reached.
 * np variable can be set to non-zero value to allow visualisation of the whitespace characters. Offset index for the each printed character can be displayed
 * if dpi is set to non-zero value.
 *
 * Functions:
 *
 * lst   - retun line start offset
 * eol   - return end of line offset
 */

#include <stdio.h>				/* for printf() */
#include <sys/types.h>		/* for lseek() */
#include <unistd.h>				/* for lseek(), read() */

int crstat(int fd,int start,int end,int np,int idx) {
	int ret ;								
	int step;
	int c; 

	char ch	;

	if(start == LINE_START) 	start = lst(fd);			// defined in defs.h (-1)
	if(end 	 == 	LINE_END) 	end 	= eol(fd);
 	
	c 	 = lseek(fd,0,SEEK_CUR);					/* remember current cursor position */

	/* dim */
	printf("\033[90m");	

	/* probably substitute by for loop */
	for(step = lseek(fd,start,SEEK_SET); (ret = read(fd,&ch,1) > 0); step++)

		if(ret == -1)
			ftl("in crstat()");		/* fatal on error in read(2) */
	
		if(step == c)
			printf("\033[0m");		/* cursor position reached; reset color */
		
		printable_e(ch,np);		/* print character */

		if(idx)				/* print index; (probably create a function */
		{
			if(step >= c)
				printf(" \033[2m[%d]\033[0m ",step);
			else
				printf(" [%d] ",step);
		}

		if(ch 		== '\n') 
			printf("\n");					/* printable_e() function will not output new line and need to be handled manually */

		if(step == end ) 
			break;			/* end offset reached - stop reading */

		step++;			/* next step */
	}

	return lseek(fd,c,SEEK_SET);		/* restore cursor position to the one before function was called */
}
