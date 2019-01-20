#include <sys/types.h>
#include <unistd.h>

/* Return index of the end of the line on which cursor is positioned. */
int eol(int fd) {
	int i;
	int cur;
	char c;

	cur = lseek(fd,0,SEEK_CUR);		/* remember cursor position */
	for(i=cur; read(fd,&c,1) > 0; i++)
		if(c == '\n') 
			break;

	lseek(fd,cur,SEEK_SET);

	return i;
}

