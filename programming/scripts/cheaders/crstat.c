/* 
 * crstat - visualise read offset
 *
 */

#include <stdio.h>	
#include <sys/types.h>		
#include <unistd.h>	

int crstat(int fd,int start,int end,int np,int idx) {
	int step;
	int  ret;								
	int  cur; 		/* cursor position */
	char  ch;

	if(start ==	LINE_START)
		start  = lst(fd);

	if(end 	 == LINE_END) 
		end    = eol(fd);
 	
	cur = lseek(fd,0,SEEK_CUR);					/* remember current cursor position */

	/* dim */
	printf("\033[90m");	

	for(step = lseek(fd,start,SEEK_SET); (ret = read(fd,&ch,1) > 0); step++)

		if(ret == -1)
			ftl("in crstat()");		/* fatal on error in read(2) */
	
		if(step == cur)
			printf("\033[0m");		/* cursor position reached; reset color */
		
		printable_e(ch,np);		/* print character */

		if(idx)				/* print index */
		{
			if(step >= cur)
				printf(" \033[2m[%d]\033[0m ",step);
			else
				printf(" [%d] ",step);
		}

		if(ch 		== '\n') 
			printf("\n");					/* printable_e() function will not output new line and need to be handled manually */

		if(step == end ) 
			break;			/* end offset reached - stop reading */
	}

	return lseek(fd,c,SEEK_SET);		/* restore cursor position to the one before function was called */
}
