/* matches.c			
 *
 * Visualise matching algorithm.
 */
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <ctype.h>
#include "defs.h"
#include <time.h>
/*
 * GLOBALS - INITIALIZATION
*/
struct mtchfl fl 	= {0};				/* fl structure created here */
struct char_st cs = {0};				/* initialize with 0 */
struct atoms   a	= {0};			/* atoms */
int debug					=  0;

/* Program name placeholder. */
const char *program_name;

/* Print usage to the stream and exit with exit_code. Does not 
	 return. */
void usage(FILE* stream,int exit_code) {
	fprintf(stream, "Usage: %s [OPTIONS]... -e EXP -o FILE\n",program_name);
	fprintf(stream, "Attempts to provide a visualisation of search alghoritm steps within file.\n"
									"\n"
									"Mandatory arguments for long options are mandatory for short options too.\n"
									"  -o, --open FILE             file to be read\n"
									"  -e, --exp=regexp            search pattern\n"
									"  -b, --brackets=<delimiter>  enclose matched text portin_wrdn in brackets\n"
									"  -m, --match=[full|partial]  highlighting scheme\n"
									"  -n, --non-printable         visualise non-printable characters\n"
									"  -s, --ms                    set time interval for the steps\n"
									"  -D, --debug                 print debugging information\n"
									"  -h, --help                  print this message and exit\n");
	exit(exit_code);
}

/*
 * int rcs(int fd);                                                                          
 *                                                                                          
 *	Populate char_st structure. Reading step 1. 
 *  Need to hack it properly.
 */
int rcs(int fd) {
	int ret;
	cs.p = cs.c;				/* store current character from the previous read; becomes a previous character */
	if((ret = read(fd,&cs.c,2)) == -1) /* read two characters in place of current */
		ftl("error");	

	/* If read occured (one or two characters were read) return cursor one character back only in case of two characters
	 * were read setting up the cursor to next character in file to be read, if only one character was read cursor will
	 * keep the position of the end of file and next call to rcs() will return 0 but character will be processed as ret
	 * still holds the value of 1.
	 */
	if(ret) 
		lseek(fd,(ret-1)*-1,SEEK_CUR);
	return ret;
}

/*
 * int match(char *e);																																											
 *																																																					
 *  match() will apply all the necessary tests on the pattern in expression exp on the index of ps, against
 * a currently read character. If examined character matched pattern, ps will be set to the next index within
 * pattern to be examined. otherwise DOES_NOT_MATCH constant(-1) is returned and ps will be reset to the value of 0,
 * thus search will be restarted from the beginning of the expression testing it against the same character.
 *
 * Return value is the index in expression to be examined next. 
 *
 * Uses matchfl structure
 * Matching alghorithm phases:
 *
 *	
 ***********************************************************************************************************/
int match(char *exp,int ps)
{
	//int temp_t;												/* help offset */
	int matched_position;							/* DOES_NOT_REQUESTED|REQUESTED_BUT_DOES_NOT_MATCH|REQUESTED_AND_MATCHED */
	int matched_in_word = DOES_NOT_MATCH;			/* -1 */
	int repeat_character_match=0;			/* repeat match against the same character read */
	char esc =0;											/* modifier of the escape sequence */

	/* range */
	//int nb;									/* next bracket in range case offset */
	//char c;									/* holds character in range */
	//int negotiate_match;		/* if match return zero */

	do {			// while repeat_character_match is set

		if(ps < 0) 	/* reset pattern start; was set in re_fdb() */
			 ps = 0;		/* when it will be -1 */

		matched_in_word	= 0;	/* set match flag to 0 */
		//negotiate_match = 0;
		//matched_position  	=  DOES_NOT_REQUESTED;			// -2
		//temp_t	= 0;		/* vsexp() is called with it? */

		if(debug)
			vsexp(exp,ps,"[DEBUG] at the beginning of algorithm\n");

		if(fl.repeat_pattern_match)
			fprintf(stdout,"[DEBUG] repeating same pattern\n");
		else
		if(repeat_character_match)
				fprintf(stdout,"[DEBUG] repeating match against same character, as previous match on failed repetition \n");
		/* ENDDEBUG */

		repeat_character_match 				= 0;		/* reest before new match */
		/* 
			 At the following code fl.np and ps designed to track index in expression. ps tends to track index at which 
			 recurring match should start. fl.np tries to be set to the index in expression for the next match step.

			 Information collected in the following block is unique for the current pattern. If 
			 repetition is the case match will be performed against the same pattern the information
			 will not be learned twice.

			 Information that is learned in this block:
		*/
		if ( ! fl.repeat_pattern_match ) 	/* information about pattern learned first time */
		{
			/* Zero fl structure from previous data - learning new pattern properties */
			bzero(&fl,sizeof(fl));

			fl.np=ps;

			/*
			 * Test 1.
			 *
			 * Handle all the possible cases at the pattern start. The goal is that after check
			 * examined index in expression will be set to the actual character to be matched.
			 *
			 * Special cases to be considered:
			 *	->		^
			 *	->		
			 */

			if(exp[ps] == '^')
			{
				if(debug)
					fprintf(stdout,"[DEBUG] processing '^'\n");
			
				if(anch(exp[ps],cs) == REQUESTED_BUT_DOES_NOT_MATCH) {
					if(debug)
						fprintf(stdout,"[DEBUG] character read is not first in the word\n");

				return DOES_NOT_MATCH;
				}
				else
					fl.np = ++ps;			/* advance ps and fl.np to one character in expression
						 									 jump over '^' */
			}
			
			/*
			 * Handle all the cases where pattern start points to '\' in loop.
			 *
			 * Cases:
			 *	\<		Calls to anch(), 1 if position matched
			 *	\(
			 *	\)
			 *	\wW
			 */

			while( exp[fl.np] == '\\' )	
			{
				switch( exp[++fl.np] ) 	/* examine following metacharacter */
				{
					case '(':
						if(debug)
							vsexp(exp,ps,"[DEBUG] Opening bracket found\n");

						a.atom_new++;			/* new backreference will be learned */		
						break;
						
					case '<':			/* word start; fail immediately */
						if(debug) 
						{
							vsexp(exp,ps,"[DEBUG] '<' found; testing for positional match\n");
							fprintf(stdout,"[DEBUG] returned: %d\n",anch(exp[fl.np],cs));
						}
						if(anch(exp[fl.np],cs) != REQUESTED_AND_MATCHED)
							return DOES_NOT_MATCH;			// -1
						break;

					case ')':		/* close atom */
						fprintf(stderr,"[FATAL ERROR]	UNMATCHED BRACKET\n");
						exit(1);		/* Handle error codes */
						break;

					default:			/* escape sequence */
						switch(esc = exp[++fl.np]) 
						{
							case 'w':
							case 'W':
							case 'd':
							case 'D':
							case 's':
							case 'S':
							case '.':
							case '\\':
								if(debug)
									fprintf(stdout,"[DEBUG] escape sequence found: `%c\'\n",esc);
								break;

							default:
								fprintf(stdout,"[DEBUG] unknown escape sequence `%c\'\n",esc);
								exit(EXIT_FAILURE);
						}
						break;
				}

				if(esc) 	/* fl.np points to the end of the pattern */
					break;
				ps = ++fl.np;	// next pattern start
			}
			fl.np++;

			if(debug)
				vsexp(exp,ps,"[DEBUG] after processing all the special cases at the beginning of the pattern\n");

			while(exp[fl.np] != '\0') 
			{
				if(debug)
					vsexp(exp,ps,"processing end of the pattern\n");		// no need for temp_t

				if(exp[fl.np]=='\\')
				{
					// BE CAREFUL HERE WHERE REPETITION REPEATS
					++fl.np;

					if(exp[fl.np] == '+' || exp[fl.np] == '?') 
						fl.repetition_modifier = exp[fl.np];			/* store repetition character */
	
					else 
					if(exp[fl.np] == '>' ) 
						fl.anchor = exp[fl.np];
	
					else
					if(exp[fl.np] == ')')
						a.atom_complete++;		// do not complete on pattern repetition
					else
					{		/* HERE new escape character of the next pattern */
						--fl.np;
						break;		/* out of infinite loop */
					}
				}
												/* $ and > accepted in one expression */
				else if('$') 
			  	fl.anchor = exp[fl.np];		

				else if('*')
					fl.repetition_modifier = exp[fl.np];

				else 
					break;		/* no special character; break before advancing */


				fl.np++;
				fprintf(stdout,"[DEBUG] fl.np: '%c' %d\n",exp[fl.np],exp[fl.np]);
		}
	}
	/* end of the first time pattern learning */

	/* Handle anchor cases \> or $. Decided to match position before literal match. */
	if(fl.anchor) 
	{	
		/* Debug */
		if(debug)
			fprintf(stdout,"[DEBUG] anchor case of '%c' found.\n", fl.anchor);

		/* Positional match requested. */
		if((matched_position  = anch(fl.anchor,cs)) == REQUESTED_BUT_DOES_NOT_MATCH) 
		{
				/* Current character read does not match position. If repetion charactcer found we
					 can continue with the algorithm and consider that following character can be on the
					 requested position. Otherwise match fails.
				*/
				if ( ! fl.repetition_modifier ) 
					return DOES_NOT_MATCH;
		}
	}

	/* 
	 * TEST 3: Literal match
	 */

		
	if(esc)
	{ 
		switch(esc)
		{
			case 'd':
				if( 	isdigit(cs.c) )	matched_in_word++;
																			 break;
			case 'D':
				if( ! isdigit(cs.c) ) matched_in_word++;
	  																	 break;
			case 'w':
				if(   isalpha(cs.c) )	matched_in_word++;
																			 break;
			case 'W':
				if( ! isalnum(cs.c) ) matched_in_word++;
																			 break;
			case 's':
				if(		isspace(cs.c) ) matched_in_word++;
				 															 break;
			case 'S': 
				if( ! isspace(cs.c) ) matched_in_word++;
																			 break;
			case '.' :		/* Literal match */
			case '\\':
				if(cs.c == exp[ps]) 
					matched_in_word = MATCH;
				 break; 
		}
	}
	else 
	{	// not a metacharacter
		if((exp[ps] == '.') || (cs.c == exp[ps]))
				matched_in_word = MATCH;

		/* DEBUG */
		if(debug)
		{
			vsexp(exp,ps,"after matching character on position");
			if(matched_in_word)
				fprintf(stdout,"[DEBUG] character matched\n");
			else
				fprintf(stdout,"[DEBUG] character does not match\n");
		}
	}

	/* 
	 * Handle match result and repetition case
	 */
	if(matched_in_word) 
	{	
		if(fl.repetition_modifier) 				
		/* Pattern requested to be repeated, set fl.repeat_pattern_match flag. Pattern in expression will be
			   repeated */
			fl.repeat_pattern_match = 1;	/* substitute to constants */

		 /* Character matches positional match even though it is requested to be repeated set next pattern index 
		    in expression. 'a\> \<b' 'aa b' */
		if(matched_position == REQUESTED_AND_MATCHED) 
			fl.repeat_pattern_match = 0;	/* constant please */
	}
	else 
	{ /* Character read doesn't match pattern in expression  */

		/* When repetition modifier was found and match didn't occur, next match should run from the next pattern section in expression 
			 	against the same character. To achieve that repeat_character_match variable will be set.  */
		if(fl.repetition_modifier) 
		{

			if(debug)
				fprintf(stderr,"[DEBUG] Repetition modifier found: '%c'\n",
								fl.repetition_modifier);

			repeat_character_match = 1;

			/* Repetition modifier is '+', meaning match one or more times. If match was repeated at least once repeat_pattern_match flag should be set
					 	previously, that means at least one repetition of the pattern occured, that satisfies condition. Fail otherwise. Next matching 
					 	iteration should start from the next pattern.  */
			if(fl.repetition_modifier == '+')
				if( ! fl.repeat_pattern_match ) 			/* Pattern was not previously repeated and first attempt to match was not satisfied. */
							return DOES_NOT_MATCH;

			/* Positional match was requested. Need to run test on the previous character as far current didn't match
			 	and it is ok due to repetition character.

					 exp:  a[b*\>]
					 word: a[]b

					 space character didn't match but positional was requested, so try to match 'a' at the end of the word.
			*/
			if(
			 	matched_position == REQUESTED_BUT_DOES_NOT_MATCH ||		// same to REQUESTED :)
			 	matched_position == REQUESTED_AND_MATCHED		// DOES NOT
				)
			{
					
				if(anch(fl.anchor,cs) == DOES_NOT_MATCH) 	/* check if previous character is last in word */
				return DOES_NOT_MATCH;		/* apply anchor to the previous characater */
			}
			/* Pattern was not requsted to be repeated. Matching failed. */
			else
				return DOES_NOT_MATCH;
		}	
		
		/* Pattern repetition was not requested. Advance to the next pattern in expression. */
		if(fl.repeat_pattern_match == 0) 
			ps = fl.np;
			
		if(debug) {
			vsexp(exp,ps,"at the end of the algorithm");
			fprintf(stderr,"[DEBUG] fl.repeat_pattern_match: %d\n",fl.repeat_pattern_match);
		}

		/* End of expression == Full match. Hmm... */
		if(exp[fl.np] == '\0')
			break;
	}
}
while(repeat_character_match);			/* repeat match against the same character read */

	return ps;			/* ALWAYS RETURNED INDEX IN EXPRESSION TO BE EXAMINED NEXT */
}


/*
 * void step(int fd, struct scheme fmt, int match, char *part); 
 *
 * Visualise reading step.
 */
void step(int fd, struct scheme fmt, int match, char *part)
{	

	//clear(char *code);
	/* Clear previous character. */
	if(fmt.non_prt) 
	{
		if(cs.p == '\n' || cs.p == '\t' ) 
			printf("\033[2D");   // \n or \t	:		are they dispalyed this way?
	}
	else
		printf("\033[1D");

	printf("\033[K\033[0m");		/* reset color */

	/* 
	   Decide color and print previous character.
	   Previous character gonna be printed on red background if matched  
	 */

	/* String in file matched partially if full_match in fl structure is set. Controlled by the two constants:
	 * PART_MATCH and FULL_MATCH
	 */
	if(fmt.full_match)				// 0 by default (PART_MATCH)
		if(*part) redraw(fd,part,fmt.non_prt);	// maybe zero part in redraw?

	/* Previously examined character matched */
	if(match) 	// strlen(atom[0])
		printf("\033[41m\033[97m");		/* Set color before printing. Might be wrapped. */

	/* Print previous character here
	  if non_prt flag was passed \n, \t, \0 will be visualized */
	printable_e(cs.p,fmt.non_prt);
	if(cs.p == '\n')
		printf("\n");

	// function print_c() print_p() 
	printf("\033[0m\033[7m");		/* set color for the current character read */
	printable_e(cs.c,fmt.non_prt);
	printf("\033[0m");
}


/* 
 * int re_fdb(int fd,char*exp,struct scheme);
 * 
 * To track backreferences atom[] character pointers array is used.
 * Expexted formatting scheme.
 *
 * Looks like re_fdb() and step() should be in the same block. Not really
 * Describe...
*/
int re_fdb(int fd,char *pattern,struct scheme fmt,int ms) {
	int index_in_expr;			/* index_in_expression on which examined pattern segment resides */
	int ret;		/* read() return value */

	char *rw = ec_malloc(100);		/* rewrite part of the expression that is matched partially,
																	 think how much to allocate; maybe to use atom[0] instead? */
	char *atom[ATOM_MAX] = {0};			/* array of char pointers to store a backtricks */
	struct timespec req  = {0};			/* timespec */

	/* Allocate memory for the first atom (atom[0] default). Last index in the atom[] is 1. */
	atom[a.li++] = ec_malloc(1000);				

	ret = 0;		/* read() return value */
	index_in_expr = 0;

	req.tv_sec = 0;
	req.tv_nsec = ms;				/* default time wait - 10 ms */
													// ^^^ how it works 

	printf("\033[?25l");				/* hide cursor; create a function! */

	/*
		 Call to rcs will populate the cr (char_st) structure. 0 is returned when it is no characters were
	 	 read. 
	*/
	while( (ret = rcs(fd)) ) {	// 0 will result in false

		if(ret == -1) 	// die on read error, why is not checked in rsc() ?
			ftl("error");

		if (!debug) 	/* do not mess characters with debug */
			step(fd,fmt,strlen(atom[0]),rw);
			
		/* Full match. Reset examined index. */
		if(strlen(pattern) == index_in_expr)
			index_in_expr = 0;
	
		/* Partial match was rewritten.	!! STOP HERE !! */
		if(fmt.full_match)
			if(*rw) rw[0] = '\0';		// maybe put it in redraw() itself?

		/* Run matching algorithm. */
		index_in_expr = match(pattern,index_in_expr);	

		if(debug)
			vsexp(pattern,index_in_expr,"[DEBUG] Returned from the match() call\n");
		
		exit(15);

		/* Match against current character read and index in expression failed. If index was advanced,
			 try to match same character against the pattern on the first index. */
		if (index_in_expr == DOES_NOT_MATCH) 
		{
		
			/* Copy part to be rewritten to rw. Dereference to true if not empty. Also
				 do not run an algorithm if it was no characters stored previously, so index 
				 was not advanced. */
			if( *( (char*) strncpy(rw,atom[0],strlen(atom[0])) ) ) 	
			{
				if(debug)
					fprintf(stdout,"[DEBUG] Match failed; cursor was advanced - trying to rematch on index of 0\n");
				index_in_expr = match(pattern,(index_in_expr=0)); /* NOTE: index_in_expr reset here, otherwise remains DOES_NOT_MATCH */
			}
			atom_clear(atom);	/* Prepare for the new match processing. Clear previous backreferences. */
			
			//fprintf(stdout,"[DEBUG] rw[%p]:\t'%s'\n",rw,rw);
		}

		if(index_in_expr >= 0)
			atom_wr(atom);
	
		fflush(stdout);		/* SLEEP */
		nanosleep(&req, (struct timespec *)NULL);	

		if(debug++ == 2)
			break;
	}

	//cs.c = 0;
	//step(fd,atom[0],fmt,o);

	printf("\033[0m\033[?25h");			/* unhide cursor */
	return lseek(fd,0,SEEK_CUR);		/* return current file offset */
}


/*
 * MAIN
 */

int main(int argc,char *argv[]) {

	int   fd;						/* file descriptor */
	char *filename;			/* file name */

	int   next_option;		/* next option to be processed by getops_long() */
	int ms;								/* milli-seconds */

	char *e;							/* expression */

	struct scheme fmt;				/* formatting structure */
	program_name = argv[0];		/* program name */

	e = ec_malloc(100);				/* initialize memory for the expression */
	filename = ec_malloc(40);	/* initialize memory to store a filename */

	/* Output formatting */
	fmt.non_prt = 0;		/* do not visualise non-printable characters */
	fmt.full_match = PART_MATCH;	/* highlight any character matched; 0 by default */
	ms = 100;		/* milli-seconds */

	const char *short_options = "hs:e:o:nD::f";
	const struct option long_options[] = {
		{ "open",								required_argument, NULL, 'o' },
		{ "expression",					required_argument, NULL, 'e' },
		{ "full-match",					no_argument,			 NULL, 'f' },
		{ "non-printable",			no_argument,			 NULL, 'n' },
		{ "ms",									required_argument, NULL, 's' }, { "debug",              optional_argument, NULL, 'D'},
		{ "help",								no_argument,			 NULL, 'h'},
		{ NULL,									no_argument,			 NULL, 0}
	};

	while((next_option = getopt_long(argc,argv,short_options,long_options,NULL)) != -1)
	{
		switch(next_option) 	{
			case 'h':
				usage(stdout,EXIT_SUCCESS);

			/* Specify a search pattern. */
			case 'e':
				strncpy(e,optarg,strlen(optarg));
				break;

			/* Specify milliseconds value to wait between each read step. */
			case 's':
				ms = atoi(optarg)*1000000;		/* last try 100 */
				break;

			/* Show non-printable characters. */
			case 'n':
				++fmt.non_prt;
				break;

			/* Display only full match. */
			case 'f':
				++fmt.full_match;
				break;

			/* Specify filename to read */
			case 'o':
				strncpy(filename,optarg,strlen(optarg));
				break;

			case 'D':					/* turn on debug */
				if(optarg)
					debug=atoi(optarg);
				else
					debug=1;
				 break;

			default:
				//printf("next_option: %d\n",next_option);
				fprintf(stderr,"Try `%s --help' for more information.\n",program_name);
				exit(EXIT_FAILURE);
		}
	}

	if(*filename == 0)	/* filename was not specified */
	{
		fprintf(stderr,"no file name specified\n");		// wrap to a function
		usage(stderr,EXIT_FAILURE);
	}
	
	if(*e == 0) { 			/* do not run without search pattern */
		fprintf(stderr,"no expression specified\n");
		usage(stderr,EXIT_FAILURE);
	}

	if((fd = open(filename,O_RDONLY)) == -1) ftl("open");	/* open a filename */
	re_fdb(fd,e,fmt,ms);		/* maybe pass a filename instead of descriptor? */

	/* Debug */
	//printf("Index after re_fdb(): %d\n", re_fdb(fd,e,fmt,ms));
	/* crstat(fd,0,0); */
	close(fd);
	free(filename);
	free(e);
	return 0;
}
