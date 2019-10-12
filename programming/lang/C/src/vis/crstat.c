/* Library for the index visualisation rutines. */
#include <stdio.h>
#include <sys/types.h>		/* for lseek() */
#include <ctype.h>				/* for isspace() */
#include <unistd.h>				/* for lseek(), read() */
#include <stdlib.h>
#include "defs.h"

/*
 *	redraw(char *rw);
 *	
 *  Redraw partial match.
 */
void redraw(int fd,char *word, int non_prt) {
	
	int i;		// index in string to be redrawn
	int cur;	// cursor index within file, pointed by fd
	int ot;
	
	cur= lseek(fd,0,SEEK_CUR);		/* remember current cursor position */
	for(i=0; word[i] != '\0'; i++) 
	{
		if(( ot = lst_or(fd,(cur-i))) == 0 ) // first character on line
		{
			// catch the character and check how much it holds, than delete %d
			// accordingly
			printf("\033[1A");	/* delete current line of output */
			printf("\033[%dC",(lst_or(fd,(cur-i)-1)));
		}
		printf("\e[1D\e[K");
	}

	for(i=0; word[i] != '\0'; i++)		/* print word contents */
		printable_e(word[i],non_prt);
}

/* 
 * eol(int fd);
 * 
 * Return index of the end of the line on which cursor is positioned at
 * the moment of the function call.
 */
int eol(int fd) {
	int cur_ini;
	int step;
	int ret;
	char 	c;

	cur_ini	= lseek(fd,0,SEEK_CUR);	/* remember current offset */

	/* obviously do{}while(); */
	for(step=cur_ini; (ret = read(fd,&c,1)) > 0; step++ )
		if(c == '\n')	
			break;
	return step;	// return end of line offset
}

/* 
 * eof(int fd);
 *
 * Returns end of file offset index. File simply seeked till the end, offset learned and then
 * cursor is restored.
 */
int eof(int fd) {
	int c = lseek(fd,0,SEEK_CUR);		/* remember current cursor offset */
	int e = lseek(fd,0,SEEK_END);		/* seek file to the end and learn last index */
	lseek(fd,c,SEEK_SET);			/* restore initial offset */
	return e;
}


/* 
 * int lst(int fd);
 *
 * Returns index within file of the first character on the line on which cursor 
 * is currently positioned. 
 */
int lst(int fd) {
	int ret; 			/* read() return value, line start index returned in ret as well */
	int cur_ini;	/* cursor offset at the moment of the function call */
	char  c;			/* buffer for the read call */

	cur_ini = lseek(fd,0,SEEK_CUR);	/* store current cursor position */

	/*
		 Seek file one character back each iteration. That will allow to examine previous character relative to the 
		 current. When offset is on the first character in a file, lseek() will return 0 (no character can be seeked).
		 Cursor index always remains at the first character of line where it was initialy positioned at the end of the loop.
	*/
	while((ret = lseek(fd,-1,SEEK_CUR) > 0)) {

		/* Read and examine character on the current cursor index. */
		if(read(fd,&c,1) == -1) ftl("read");		
		/* reached new line character, no need for further reading, read offset to the first
			 character on the next line */
		if(c == '\n') break;	
		/* set up next read(), return read cursor to the current character read after examination */
		lseek(fd,-1,SEEK_CUR);
	}

	//int crstat(int fd,int start,int end,int np,int idx) {
	//crstat(fd,0,8,0,0);
	/* Here can be debug. */
	ret = lseek(fd,0,SEEK_CUR);			/* store line start index */
	lseek(fd,cur_ini,SEEK_SET);			/* restore cursor as it was at the moment of the function call */

	return ret;			/* return line start index */
}



/*
 * int lst_o(int fd);
 *
 *	Return cursor offset from the start of the line on which cursor is positioned at the
 *  moment of the function call. Cursor offset is the distinction between current offset
 *  line start index.
 *
 */
int lst_o(int fd) {
	return lseek(fd,0,SEEK_CUR) - lst(fd);
}


/*
 * int lst_ro(int fd, int ro);
 *
 *	Return offset between cursor index and line start it is positioned at.
 *  First cursor position is set to relative offset (ro) and then lst_o
 *	line start is calculated. Calculated value is the return value of the function.
 */
int lst_or(int fd,int ro) {		// lst_ro
	int cur_ini;
	int line_start;
	
	cur_ini = lseek(fd,0,SEEK_CUR);		/* remember current cursor position */
	lseek(fd,ro,SEEK_SET);	/* seek file to the relative offset */
	line_start = lst_o(fd);	/* calculate relative offset from the line to which cursor was seeked */
	
	lseek(fd,cur_ini,SEEK_SET);		/* restore file offset as it was at the 
															 moment of the function call */
	return line_start;				/* return calculated value */
}



/*
 * print_e(char c, int non_prt);
 *
 * Print character c. If non_prt is in effect print escapce sequences visualized.
 *
 */
void printable_e(char c, int np) {

	if( ! isgraph(c) ) {
	/* Whitespace character. */

		if(np) { 			/* non-printable flag was passed */
			if (c == '\t' )		
				printf("\\t"); 
			else 
			if ( c == '\n')		
				printf("\\n");
			else
			if ( c == '\0' )
				printf("\\0");
			else	
				printf(" ");	// doesn't matter which white space will be printed only once
											// maybe change later on to %d
		}
	}
	else 	
		printf("%c",c);	/* print it; do not output a new line as index will be handled there after */
 /* spaces handled by indexes */
}

/* 
   crstat - visualise read offset
 
  ! CREATE MAN PAGE !
 
  int crstat(int fd, int start, int end, int np, int idx);
 
   Prints characters from the offset of start till the offset of end from the file pointed by the file descriptor fd. Printing can
   be controlled using two constants: LINE_START(-1) and LINE_END(-1). If LINE_START is in effect printing will start from the line
   on which cursor is posistioned on, cursor offset is calculated using lst() function. If LINE_END is in effect reading will stop when end of the line is reached.
   np variable can be set to non-zero value to allow visualisation of the whitespace characters. Offset index for the each printed character can be displayed
   if dpi is set to non-zero value.
  
 */

int crstat(int fd,int start,int end,int np,int idx) {
	int ret ;								
	int step;
	int c; 

	char ch	;

	/* think about how to catch or wrong value for the line borders */
	if(start == LINE_START) 	start = lst(fd);			// defined in defs.h (-1)
	if(end 	 == 	LINE_END) 	end 	= eol(fd);
 	
	c 	 = lseek(fd,0,SEEK_CUR);					/* remember current cursor position */
	step = lseek(fd,start,SEEK_SET);			/* seek cursor to the requested start */

	/* probably substitute by for loop */
	while((ret = read(fd,&ch,1) > 0)) {		/* read character in turn */

		if(ret == -1)
			ftl("in crstat()");		/* fatal on error in read(2) */
	
		if(step == c)
			printf("\033[0m\033[7m");		/* cursor position reached; reset color; <- create a function */
		else
		if(step > c)
			printf("\033[0m");
		else
			printf("\033[90m");
		
		/*
				PRINT CHARACTER 
		*/
		printable_e(ch,np);		/* depends on the np value tab and new line characters will be visualized */
		
		if(idx) {
			if(step!= c)	// print in dim
				printf("\033[90m[%d]\033[0m ",step);
			else
				printf("[%d]\033[0m ",step);
		}
		if(ch=='\n')
			printf("\n");

		if(step == end ) 
			break;			/* end offset reached - stop reading */

		step++;			/* next step */
	}

	if(ch != '\n')
		printf("\n");

	return lseek(fd,c,SEEK_SET);		/* restore cursor position to the one before function was called */
}
