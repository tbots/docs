#include <stdlib.h>
#include <stdio.h>
#define LSH_RL_BUFSIZE 1024

/* Print error message (msg) following colon (':') whitespace and an perror(3) 
	 generated error message. Does not return. Exit with error code of EXIT_FAILURE. */
void ftl(char *msg) {
	perror(msg);
	exit(EXIT_FAILURE);
}

void *ec_malloc(unsigned int size) {
	void *p;
	if ( (p = malloc(size)) == NULL )
		ftl("malloc");
	return p;
}

char *lsh_read_line(void)
{
	int bufsize = LSH_RL_BUFSIZE;
	int position = 0;
	char *buffer; 
	buffer = ec_malloc(sizeof(char) * bufsize);
	int c;

	while(1) {
		c = getchar();		/* read character */
		if(c == EOF || c == '\n') {			/* if we hit EOF, replace it with a null character and return */
			buffer[position] = '\0';
			return buffer;
		} else {
			buffer[position] = c;
		}
		position++;
		if(position >= bufsize) {
			bufsize += LSH_RL_BUFSIZE;
			buffer = realloc(buffer,bufsize);
			if(!buffer) {
				fprintf(stderr,"lsh: allocation error\n");
				exit(EXIT_FAILURE);
			}
		}
	}
}

int main() {
	lsh_read_line();
	return 0;
}
