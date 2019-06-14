/* 
 * np.c						print file contents to stdout along with names or escape sequences corresponding to
 *                to the non-printable characters.
 *
 * Colors used:
 *		\e[36m			- light gray
 */
#include "defs.h"

/* 
 * Print usage to the stream and exit with exit_code. Does not return. 
 */
void usage(FILE*stream,int exit_code) {
	fprintf(stream,"Usage: %s [OPTIONS]...\n",program_name);
	fprintf(stream,"Print file contents to stdout. If non-printable character encountered, print it's name\n"
								 "or escape sequence corresponding to that character.\n\n"
								 "Mandatory arguments to long options are mandatory for short options too.\n"
								 "  -o, --open                 file to be opened\n"
								 );
	exit(exit_code);
}

int main(int argc,char **argv) {
	int fd;		/* file descriptor */
	int next_option;
	char c;
	char *filename;
	program_name = argv[0];

	filename = (char*)ec_malloc(20);
	const char *short_options = "ho:";		/* short options */
	const struct option long_options[] = {		/* long options */
		{ "open",		required_argument, NULL, 'o' },
		{ "help",					no_argument, NULL, 'h' },
		{ NULL,											0, NULL,  0  }
	};
	
	if(argc < 2)
		usage(stderr,EXIT_FAILURE);

	do {
		next_option = getopt_long(argc,argv,short_options,
																			long_options,NULL);

		switch (next_option) {
			case 'o':
				strncpy(filename,optarg,strlen(optarg));
				break;
				
			case 'h':
				usage(stdout,EXIT_SUCCESS);
				
			case -1:
				break;

			default:
				fprintf(stderr,"Try `%s --help' for more information.\n",program_name);
				exit(EXIT_FAILURE);
				
		}
	} while ( next_option != -1 );


	/* open file */
	if ( (fd = open(filename,O_RDONLY)) == -1 )
		ftl(filename);

	while(read(fd,&c,1) > 0) {
		if(isprint(c))
			printf("%c",c);
		else if(c == ' ')			/* space */
			printf("\e[37m[ ]\e[0m");
		else if(c == '\n')		/* new line */
			printf("\e[37m\\n\e[0m\n");
		else
			printf("\e[37m?\e[0m");
	}

	close(fd);
	return 0;
}
