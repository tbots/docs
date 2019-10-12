#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "hacking.h"

#define 	FILENAME			"/var/notes"

char *prog_name;	/* program name */

void usage(char *program_name, char *filename) {
	printf("Usage: %s <data to add to %s>\n",prog_name,filename);
	exit(0);
}

void fatal(char *);							// A function for fatal errors.
void *ec_malloc(unsigned int);	// An error-checked malloc() wrapper.

int main(int argc,char *argv[]) {
	int userid, fd;			// File descripor.
	int next_option;
	int mode,trunc;
	char *buffer, *datafile;

	prog_name = argv[0]+2;

	buffer = (char *) ec_malloc(100);
	datafile = (char *) ec_malloc(20);
	mode = O_CREAT|O_WRONLY;			/* create file by default */
	trunc = 0;

	const char *optstring="o:th";
	const struct option longopts[]={
		{	"open",			required_argument, NULL, 'o'},
		{ "trunc",		no_argument,			 NULL, 't'},
		{ "help",			no_argument,			 NULL, 'h'},
		{ NULL,				no_argument,			 NULL,  0 }
	};

	do {
		next_option = getopt_long(argc,argv,optstring,
												longopts,NULL);

		switch(next_option) {
			case 'h':	
				usage(prog_name,datafile);

			case 'o':
				strncpy(datafile,optarg,strlen(optarg));
				break;

			case 't':
				trunc++;
				break;

			case -1:
				break;

			default:
				fprintf(stderr,"Try `%s --help' for more information.\n",prog_name);
				exit(EXIT_FAILURE);
		}
	} while(next_option != -1);

	if(*datafile == 0)
		strncpy(datafile,FILENAME,strlen(FILENAME));
	
	if(trunc)
		mode |= O_TRUNC;
	else
		mode |= O_APPEND;
		
	strcpy(buffer,argv[optind]);				// Copy into buffer.

	printf("[DEBUG] buffer    @ %p: '%s'\n",buffer,buffer);
	printf("[DEBUG] datafile 	@ %p: '%s'\n",datafile,datafile);

	// Opening the file
	fd = open(datafile, mode, S_IRUSR|S_IWUSR);
	if(fd == -1)
		fatal("in main() while opening file");
	printf("[DEBUG] file descriptor is %d\n",fd);

	userid = getuid();		// Get the real user ID.

	// Writing data
	if(write(fd,&userid,4) == -1) // Write user ID before note data.
		fatal("in main() while writing userid to file");
	write(fd,"\n",1);			// Terminate line.

	if(write(fd,buffer,strlen(buffer)) == -1)		// Write note.
		fatal("in main() while writing buffer to file");
	write(fd,"\n",1);			// Terminate line.

	// Closing file
	if(close(fd) == -1)
		fatal("in main() while closing file");

	printf("Note has been saved.\n");
	free(buffer);
	free(datafile);
	return 0;
}
