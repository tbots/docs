/*
 * All the functions should be inside this file.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <getopt.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "vis1.h"
#include "err.h"

#define DATA_FILE		"col.c"

int main(int argc,char **argv) {
	int i;
	int fd;
	int line_number,line_stop;
	int visible;
	char c;
	char *line,*line_ptr;
	char *filename;
	line = ec_malloc(1000);
	filename = ec_malloc(24);
	line_stop = line_number = 0;
	line_ptr = line;

	visible = 0;
	strncpy(filename,DATA_FILE,strlen(DATA_FILE));
	fd = open(filename,O_RDONLY);
	for(i=0;read(fd,&c,1) > 0;i++)
	{
		if((*line_ptr = c) == '\n')
			if(++visible == 1)
				line_stop = i;
		line_ptr++;
	}
	printf("line_stop: %d\n",line_stop);
	visual(line,line_stop);
	line_ptr = line;
	printf("%d:   ",line_number);
	do 
	{  
		printf("%c",*line_ptr);
		if(*line_ptr == '\n') 
			printf("%d:   ",++line_number);
		line_ptr++;
	}
	while(*line_ptr != '\0');

	close(fd);
	free(line);
	free(filename);
	return 0;
}
