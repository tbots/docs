/*
 * crstat() function wrapper
 *
 * Will attempt to visualise file read offset on index set by -c within file specified by -o. File will be displayed 
 * according to the values specified by the -s and -e respectively. If option was passed file will be displayed from the
 * line on which cursor is positioned till it's end.
 *
 * Program designed to test functions in crstat.c.
 */

#include <stdio.h>					/* fprintf(3) */
#include <stdlib.h>					/* exit(3) */
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <getopt.h>
#include <string.h>
#include "defs.h"

const char *program_name;

/* Print usage message to the stream and exit with exit_code. Does not return. */
void usage(FILE *stream,int exit_code) {
	fprintf(stream,"Usage: %s [OPTIONS]... -o FILENAME\n",program_name);
	fprintf(stream,"Wrapper program for the crstat() function. The program designed for the\n"
								 "testing purposes.\n"
								 "\n"
								 "Mandatory arguments to long options are mandatory for short options too.\n"
								 "  -o, --open=file            specify a file\n"
								 "  -c, --cursor=offset        set cursor to offset\n"
								 "  -s, --read-start           set read start index\n"
								 "  -e, --read-end             set read end index\n"
								 "  -n, --show-ws              show non-printable characters\n"
								 "  -i, --show-ix              show indexes of each character\n"
								 "  -m, --mode                 mode in which open the file (the same is in `man read'),"
								 "                             doesn't implemented yet\n"
								 "  -h, --help                 display this help and exit\n"  );
	exit(exit_code);
}


/* 
 * MAIN
 */
int main(int argc,char **argv) {
	int fd;				/* file descriptor */
	int mode;			/* read mode */
	int cur;			/* current read offset */
	int read_start,read_end;
	int sw_ws;		/* show white spaces flag */
	int sw_ix;		/* show index flag */
	int opt;			/* return value of getopt_long */
	char *filename;

	cur	  			  = 0;			
	mode  				= O_RDWR;				/* read mode */
	sw_ws					= 0;
	sw_ix					= 0;
	program_name  = argv[0];	/* program name */
	read_start		= LINE_START;
	read_end			= LINE_END;
	
	/* MALLOC */
	filename = (char*)ec_malloc(20);	

	/* GETOPT_LONG() */
	const char *short_options = "hc:o:nis:e:";
	const struct option long_options[] = {
		{ "open",						required_argument, NULL, 'o' },
		{ "cursor", 				required_argument, NULL, 'c' },
		{ "read-start",			no_argument,   		 NULL, 's' },
		{ "read-end",				no_argument,   		 NULL, 'e' },		// accept EOF
		{ "show-ws",				no_argument,			 NULL, 'n' },
		{ "show-ix",        no_argument,			 NULL, 'i' },
		{ "help",						no_argument, 			 NULL, 'h' },
		{ NULL,															0, NULL,  0  }
	};
	
	do {
		opt = getopt_long(argc,argv,short_options,
																			long_options,NULL);
		switch (opt) {
			case 'o':		/* file name */
				strncpy(filename,optarg,strlen(optarg));
				break;
				
			case 'c':		/* set cursor offset (default 0) */
				cur= atoi(optarg);
				break;

			case 's':		/* set read start (default line start) */
				read_start= atoi(optarg);		/* if not numeric? */
				break;

			case 'e':		/* set read end (defaults to line end */
				read_end= atoi(optarg);
				break;

			case 'n':		/* show non-printable characters */
				sw_ws = 1;
				break;

			case 'i':		/* show indexes */
				sw_ix = 1;
				break;

			case 'h':		/* help */
				usage(stdout,EXIT_SUCCESS);
				
			case -1:
				break;

			default:
				fprintf(stderr,"Try `%s --help' for more information.\n",program_name);
				exit(EXIT_FAILURE);
		}
	} while ( opt != -1 );

	if (*filename == 0)			/* print help to stderr and exit with exit code of 1 if */
		usage(stderr,EXIT_FAILURE);		/* filename was not specified */

	if((fd = open(filename,mode)) == -1) 
		ftl(filename);

	if(cur)		/* seek to the specified index */
		lseek(fd,cur,SEEK_SET);

	/* Call to crstat(). */
	crstat(fd,
				 read_start,
				 read_end,
				 sw_ws,
				 sw_ix);

	close(fd);
	return 0;
}
