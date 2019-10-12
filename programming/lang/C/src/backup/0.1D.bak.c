/* matches.c			
 *
 * Visualise matching algorithm.
 */
#include <stdio.h>
#include "defs.h"

/*
 * STRUCT
 */

/**********************************************************
* struct mtchfl
*																													*
* Holds flags needed by the matching algorithm.						*
**********************************************************/
struct mtchfl {
	int np;						/* next pattern */
	int  repeat_pattern;			/* repeat pattern  */
	char repetition_modifier;				/* repeatition character */
};

/* 
 * Stores previous current and following character 
 * read.
 */
struct char_st { 
	char 	p;		/* previous */
	char 	c;		/* current */
	char 	f;		/* following */
};

/* holds values that specifies output formatting */
struct scheme {
	int  partial;
	int  non_printable;
};

/* Stores atomic parts of expression (backreferences). */
struct atoms {
	int atom_index;					/* backreference index */
	int atom_new;						/* new open bracket found */
	int atom_complete;			/* closing bracket encountered */
	int wi[100];						/* array of inexes in atoms[] to be written */
	int li;									/* last index in wi */
};

/*
 * GLOBALS
*/
struct mtchfl fl 	= {0};				/* fl structure created here */
struct char_st cs = {0};				/* initialize with 0 */
struct atoms a		= {0};
int debug					=  0;


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
		Highlight p and o positin_wrdns. o if set prints character index.
*/
void vsps(char *e,int ps,int t) {
	
	sstr_h(e,10,ps,1);
	printf("[DEBUG]  pattern start (ps): %d\n",ps);

	sstr_h(e,10,fl.np,1);
	printf("[DEBUG] next pattern start (fl.np): %d\n",fl.np);

	sstr_h(e,10,t,1);
	printf("[DEBUG]   offset (t): %d\n",t);

	printf("\n");
}

/*
		Highlight characters within e on index of p and o.
*/
void vsexp(char *exp,int ps,int t,char *msg) {

	printf("\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
	printf("\n%s\n",msg);
	vsps(exp,ps,t);		
	printf("\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
}

/*
		Dump char_st structure.
*/
void vscs(struct char_st cs) {
	printf("[DEBUG] cs.p:    '%c'\n",cs.p);
	printf("[DEBUG] cs.c:    '%c'\n",cs.c);
	printf("[DEBUG] cs.f:    '%c'\n",cs.f);
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
	int temp_t;							/* help offset */
	int fiwc=0;							/* character requested to be first in word flag; default no (0) */
	int be_at_the_end;			/* DOES_NOT_REQUESTED|REQUESTED_BUT_DOES_NOT_MATCH|REQUESTED_AND_MATCHED */
	int matched_in_word;
	int repeat_match=0;			/* repeat match against the same character read */

	/* range */
	int nb;									/* next bracket in range case offset */
	char c;									/* holds character in range */
	int negotiate_match;		/* if match return zero */

	do {			// while repeat_match is set

		if(ps < 0) 	/* reset pattern start; was set in re_fdb() */
			 ps = 0;		/* when it will be -1 */

		matched_in_word	= 0;	/* set match flag to 0 */
		negotiate_match = 0;
		anchor        	= 0;	/* does not anchored by default */
		be_at_the_end  	=  DOES_NOT_REQUESTED;			// -2
		temp_t	= 0;		/* vsexp() is called with it? */

		/* Debug */
		if(debug)
		{
			vsexp(exp,ps,fl.np,"at the beginning of algorithm\n");
			if(fl.repeat_p)
				fprintf(stdout,"[DEBUG] repeating same pattern\n");
			else if(repeat_c)
				fprintf(stdout,"[DEBUG] repeating match against same character, as previous match on failed repetition \n");
		}

		repeat_c 				= 0;

		/* 
			 At the following code fl.np and ps designed to track index in expression. ps tends to track index at which 
			 recurring match should start. fl.np tries to be set to the index in expression for the next match step.

			 Information collected in the following block is unique for the current pattern. If 
			 repetition is the case match will be performed against the same pattern the information
			 will not be learned twice.

			 Information that is learned in this block:
		*/
		if ( ! fl.repeat_pattern ) 
		{
			/* 
			 * Debug 
			 */
			if(debug)
				fprintf(stdout,"[DEBUG] learning new pattern\n");

			/* Zero fl structure from previous data - learning new pattern properties */
			bzero(&fl,sizeof(fl));

			/* np is the ps */
			fl.np=ps

			/*
			 * Test 1.
			 *
			 * Handle all the possible cases at the pattern start. The goal is that after check
			 * examined index in expression will be set to the actual character.
			 */

			if((exp[ps]) == '^' )
			{
				if(cs.p == '' || cs.p == '\n')		/* examine previous character */
					/* advance ps and fl.np to one character in expression
						 jump over '^' */
					fl.np = ++ps;			
				else
					return DOES_NOT_MATCH;
			}
			
			/*
			 * Handle all the cases where pattern start points to '\'.
			 *
			 * Looks like one more function
			 * Cases:
			 *	\<		Calls to anchor(), 1 if position matched
			 *	\(
			 *	\)
			 *	\wW
			 */

			while( exp[fl.np] == '\\' )
			{
				switch( exp[++fl.np] ) 
				{
					case '(':
						a.atom_new++;			/* new backreference will be learned */
						break;
						
					case '<':			/* word start */

						if(anch(exp[fl.np]) == REQUESTED_BUT_DOES_NOT_MATCH)
						{		
							if(debug) 
								fprintf(stdout,"[DEBUG] character requested to be first in word but does not match\n");
							return DOES_NOT_MATCH;			// -1
						}
						break;

					//case ')':		/* close atom */
						//
						//break;

					default:			/* escape sequence */
						switch(exp[fl.np]) 
						{
							case 'w': 	;		break;
							case 'W': 	;		break;
							case 'd': 	;		break;
							case 'D': 	;		break;
							case 's': 	;		break;
							case 'S': 	;		break;
							case '\\':  ; 	break;
							default: fprintf(stderr,"unknown escape sequence `\\%c'\n",exp[fl.np]);
											 exit(EXIT_FAILURE);
						}
						break;
				}

				ps = ++fl.np;	// next pattern start
			}
			/* end while */
		
		/* At the end of the loop all the escape sequences are processed. fl.np and ps
			 are pointing to the part of the pattern that describes a character read. */
					
		/*
		 * TEST 2: PATTERN END
		 *
		 */

			/* Well.... should work perfect fucking ly */
			do 
			{
				temp_t = ++fl.np;		/* basically set to the start of the new pattern */
				switch(exp[fl.np])
				{
				 /*
				 	* Handle \+ and \> cases 
				 	*/
					case '\\':			
						
						// BE CAREFUL HERE WHERE REPETITION REPEATS
						++fl.np;

						if(exp[fl.np] == '+' || exp[fl.np] == '?') 
							fl.repetition_modifier = exp[fl.np];			/* store repetition character */

						else 
						if(exp[fl.np] == '>' ) 
							fl.anch = exp[fl.np];

						else
						if(exp[fl.np] == ')')
							a.atom_complete++;

						else
							fl.np -= 2;
						
					break;

					case '$':
				  fl.anch = exp[fl.np];
					 	break;
	
					case '*':
						fl.repetition_modifier = exp[fl.np];
						break;

					default:
					 	--fl.np;
					break;
				}
			}
			while(fl.np >= temp_t); 
			fl.np = temp_t;		/* restore after going to less than temp_t; points to the start of the next pattern */

		}
		/* end of the first time pattern learning */

		/* Debug */
		if(debug)
		{
			vsexp(exp,ps,temp_t,"TEST 2 FINISHED\n");
			printf("[DEBUG] Testing anchors...\n");
		}

		/* Handle anchor cases \> or $. */
		if(fl.anch) 
		{	
			/* Debug */
			if(debug)
				fprintf(stdout,"[DEBUG] anchor case of '%c' found.\n", fl.anch);

			/* Positional match requested. */
			if((be_at_the_end  = anch(fl.anch)) == DOES_NOT_MATCH) 
			{
				/* Current character read does not match position. If repetion charactcer found we
					 can continue with the algorithm and consider that following character can be on the
					 requested position. Otherwise match fails.
				*/
				if ( ! fl.repetition_modifier ) 
					return DOES_NOT_MATCH;
				else
					be_at_the_end = REQUESTED_BUT_DOES_NOT_MATCH;		/* GOD SAKE */
			}
			else
				be_at_the_end == REQUESTED_AND_MATCHED;
		}

		/* 
		 * TEST 3: examining character on position
		 */

		switch(exp[(temp_t = ps)]) 
		{			
			case '.':	

				matched_in_word++;
			break;


			case '\\':
			 
			 switch(exp[++temp_t]) 
			 {			
				case 'd':
				
					if( 	isdigit(cs.c) )	
						matched_in_word++;
				break;

				case 'D':
				
					if( ! isdigit(cs.c) ) 
						matched_in_word++;
				break;

				case 'w':
				
					if(   isalpha(cs.c) )	
						matched_in_word++;
				break;

				case 'W':
				
					if( ! isalnum(cs.c) )
						matched_in_word++;
				break;

				case 's':
				
					if(		isspace(cs.c) ) 
						matched_in_word++;
				break;

				case 'S':
				
					if( ! isspace(cs.c) ) 
						matched_in_word++;
				break;

				default:
					
					fprintf(stderr,"invalid escape sequence: '\\%c'\n",exp[temp_t]);
					exit(EXIT_FAILURE);
			 }
		  break;
  

			case '[':	
	

				if(exp[++temp_t] == '^') 
					negotiate_match = ++temp_t;

				nb = temp_t + 1;	/* next bracket pointer */
					
				do {
			
					if(exp[nb] 	 == '-') {		/* range */
						nb++;		/* next character in range */
						if(exp[nb] == ']') {		/* '[abcd-]' */
								fprintf(stderr, "Incompleted range specification in `%s'\n", exp);
								exit(EXIT_FAILURE);
						}
			
						c = exp[temp_t];
						if(c == cs.c)
							matched_in_word++;		
						else {
							do { 
								if(++c == cs.c) {	
									matched_in_word++;
									break;
								}
							} while(c != exp[nb]);	
						}
						
						temp_t = ++nb; ++nb;
					}
					else 
					if(exp[temp_t] == cs.c)	/* exact match */
						matched_in_word++; 	

					temp_t = nb++;
						
					if(matched_in_word) {
						if(negotiate_match)  	matched_in_word = 0;
						break;
					}
				}
				while(exp[temp_t] != ']');

			/* Exact match */
			default:
				if(cs.c == exp[ps]) 
					matched_in_word = MATCHED;
		}		

		/* Debug */
		if(debug) {
			fprintf(stdout,"[DEBUG] TEST 3 finished\n");
			vsexp(exp,ps,temp_t,"after matching character on position");
			if(matched_in_word)
				fprintf(stdout,"[DEBUG] character matched\n");
			else
				fprintf(stdout,"[DEBUG] character does not match\n");
		}

		/* 
		 * Handle match result and repetition case
		 */
		if(matched_in_word) 
		{	

		 /* 
		  * Character read matched character in pattern. 
		  */

			/* Pattern requested to be repeated, set fl.repeat_pattern *  to avoid running positional tests on the
			   same pattern segment. */
			if(fl.repetition_modifier) 				
				fl.repeat_pattern = 1;	/* substitute to constants */

		 /* Character matches positional match even though it is requested to be repeated set next pattern index 
		    in expression. */
			if(be_at_the_end == REQUESTED_AND_MATCHED) 
				fl.repeat_pattern = 0;	/* constant please */

			/* next pattern offset will be set at the end of the match() block */
		}

		else {
		 /*
		  * Character read doesn't match. 
		  */

			/* Debug */
			if(debug) {
				fprintf(stdout,"[DEBUG] character doesn't match\n");
			}

			/* When repetition modifier was found and match didn't occur, next match should run from the next pattern section in expression 
			 	against the same character. To achieve that repeat_character variable will be set.  */
			if(fl.repetition_modifier) {		
				repeat_character = 1;

				/* Repetition modifier is '+', meaning match one or more times. If match was repeated at least once repeat_pattern flag should be set
					 previously, that means at least one repetition of the pattern occured, that satisfies condition. Fail otherwise. Next matching 
					 iteration should start from the pattern and 
				*/
				if(fl.repetition_modifier == '+') 
				{
					
					if( ! fl.repeat_pattern ) {			/* Pattern was not previously repeated and first attempt to match was not satisfied. */
						/* Debug */
						if(debug)
							fprintf(stdout,"[DEBUG] character doesn't match previously\n");
						return DOES_NOT_MATCH;
					}
				}

				/* Positional match was requested. Need to run test on the previous character as far current didn't match
					 and it is ok due to repetition character.

					 exp:  a[b*\>]
					 word: a[]b

					 space character didn't match but positional was requested, so try to match 'a' at the end of the word.
				*/
				if(
					 be_at_the_end == REQUESTED_BUT_DOES_NOT_MATCH ||		// same to REQUESTED :)
					 be_at_the_end == REQUESTED_AND_MATCHED)
				{
					
					if(anch(cs.p) == DOES_NOT_MATCH) 	/* check if previous character is last in word */
						return DOES_NOT_MATCH;		/* apply anchor to the previous characater */
						
				}
			}
			/* Pattern was not requsted to be repeated. Matching failed. */
			else
				return DOES_NOT_MATCH;
		}	
		
		/* Pattern repetition was not requested. Advance to the next pattern in expression. */
		if(fl.repeat_pattern == 0) 
			ps = fl.np;
			
		if(debug) 
			vsexp(exp,ps,temp_t,"at the end of the algorithm");

		/* End of expression == Full match. Hmm... */
		if(exp[fl.np] == '\0')
			break;

	} 
	while (repeat_c);			/* repeat match against the same character read */

	return ps;			/* ALWAYS RETURNED INDEX IN EXPRESSION TO BE EXAMINED NEXT */
}



/*
 *	redraw_part_match(char *rw);
 *	
 *  Redraw partial match.
 */
void print_word(int fd,char *word,struct scheme fmt) {
	
	int i= strlen(word);				/* i is the index of the last element in word */
	int line_start_ot,cur;			// line_start_of   offset from the start of the line
															// cursor index within file
	
	cur= lseek(fd,0,SEEK_CUR);		/* remember current cursor position */
	if((line_start_ot= lst_o(fd)) == 1)	/* offset from the beginning of the printed line is one, that means */
		line_start_ot  = lst_or(fd,cur-2);	/* it is on the second character of the line, scroll two back to */
																				/* reach an upper line and set offset according to line above */


	/* Handle scheme. */

	if(fmt.brackets)		/* '{' and '}' should be deleted as well */
		i++;

	while(i > line_start_ot)  {		/* loop while length of i is greater than o from the */
												/* beginning of the line */
		printf("\033[1A");	/* delete current line of output */
		i =  i - line_start_ot;		/* calculate space for the word */
		cur = cur - line_start_ot - 1;	/* calculate the end of the previous line */
		line_start_ot= lst_or(fd,cur);	/* calculate new line start offset */
	}

	printf("\033[%dD\033[K",i);		/* delete i characters */
	for(i=0; word[i] != '\0'; i++)		/* print word contents */
		printable_e(word[i],fmt.non_printable);
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
	if(cs.p == '\n' || cs.p == '\t' ) {
		if(fmt.non_printable) 
			printf("\033[2D");   // \n or \t
	}
	else
		printf("\033[1D");
	printf("\033[0m");		/* reset color */

	/* 
	   Decide color and print previous character.
	   Previous character gonna be printed on red background if matched  
	    printf("\033[41m\033[97m");	 <- ?
	 */

	/* Debug */
	if(debug) 
		fprintf(stdout,"in step(): deciding on previous character color match: %d\n",match);

	/*
	 * String in file matched partially. Redraw it.
	 */
		if(*rw) print_word(fd,word,fmt);
	/* 
	 * Previously examined character matched. 
	 *
	 */
	if(match >= 0) 	// strlen(atom[0])
			printf("\033[41m\033[97m");		/* Set color before printing. Might be wrapped. */

	/* Print previous character here */
	printable_e(cs.p,fmt.non_printable);
	if(cs.p == '\n')
		printf("\n");

	/* reset color */
	printf("\033[0m");		

	if(cs.c) {			/* will be reset to '\0' in last iteration */
		printf("\033[7m");		/* set color for the current character read */
	
		/* Print current character here */
		prin_char(cs.c,fmt.non_printable);
	}
	else 
		printf("\n");

	if(!(fmt.brackets == 0))
		if(match >= 0)
			printf("}");		/* print closing bracket */
}


/* 
 * int re_fdb(int fd,char*exp,struct scheme);
 * 
 * To track backreferences atom[] character pointers array is used.
 * Expexted formatting scheme.
 *
 * Looks like re_fdb() and step() should be in the same block.
 * Describe...
*/
int re_fdb(int fd,char *pattern,struct scheme fmt,int ms) {
	int index_in_expr;			/* index_in_expression on which examined pattern segment resides */

	int ret;		/* read() return value */

	int st;			/* start read offset */

	char *rw; = ec_malloc(100);		/* rewrite part of the expression that is matched partially,
																	 think how much to allocate */
	char *atom[ATOM_MAX] = {0};			/* array of char pointers */
	struct timespec req  = {0};			/* timespec */

	/* Allocate memory for the first atom (atom[0] default) */
	atom[a.li] = ec_malloc(1000);		

	ret = o = p = 0;	// does ret is necessary? 

	req.tv_sec = 0;
	req.tv_nsec = ms;				/* default time wait - 10 ms */
													// ^^^ how it works 

	printf("\033[?25l");				/* hide cursor; create a function! */
	st=lseek(fd,0,SEEK_CUR);		/* remember cursor offset; for what to remember? */

	/*
		 Call to rcs will populate the cr (char_st) structure. 0 is returned when it is no characters were
	 	 read. 
	*/
	while(ret = rcs(fd)) {	// 0 will result in false

		if(ret == -1) 	// die on read error, why is not checked in rsc() ?
			ftl("error");

		//void step(int fd,char *word,struct scheme fmt,int match,int rw)
		step(fd,strlen(atom[0]),fmt,rw);				/* show step 'c; good that atoms are defined here */
			
		/* Full match. Reset examined index. */
		if(strlen(pattern) == index_in_expr)
			index_in_expr = 0;
	
		/* Partial match was rewritten. */
		if(*rw) rw[0] = '\0';

		/* Run matching algorithm. */
		o = match(pattern,o);	

		/* Debug */
		if(debug)
			printf("[DEBUG] match returned: %d\n",o);

		/* Match against current character read and index in expression failed. If index was advanced,
			 try to match same character against the pattern on the first index. */
		if (o == DOES_NOT_MATCH) 
		{
			/* Debug */
			if(debug)
				printf("[DEBUG] character doesn't match!!!\n");
		
			o = 0;

			/* Copy part to be rewritten to rw. Dereference to true if not empty. Also
				 do not run an algorithm if it was no characters stored previously, so index 
				 was not advanced. */
			if(*((char*)strncpy(rw,atom[0],strlen(src))) 	
				o = match(pattern,o)); /* attempt to match against the first character in expression */

			atoms_clear(atom);	/* Prepare for the new match processing. Clear previous backreferences. */
		}

		/* Match against current character in expression succeed. */
		if(o >= 0)
		{
			/* Debug */
			if(debug) 
				printf("[DEBUG] Match found\n");

			/* Populate atoms. */
			atom_wr(atom);

				/* Clean atoms */
				atom_z(atom);
				p = 0;			/* repeat pattern from the beginning */
			}
		}
		else {	// no match o == -1
			p = 0;
		}
			
	
		fflush(stdout);		/* SLEEP */
		nanosleep(&req, (struct timespec *)NULL);	
	}

	/* Debug */
	if(debug) 
		fprintf(stdout,"[DEBUG] Last call: o %d\n",o);
	cs.c = 0;
	step(fd,atom[0],fmt,o);

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
	fmt.brackets = 0;					/* no bracket enclosure */
	fmt.non_printable = 0;		/* do not visualise non-printable characters */
	fmt.partial = PARTIAL_MATCH;	/* highlight any character matched */
	ms = 100;		/* milli-seconds */

	const char *short_options = "hs:e:o:nD::bm:";
	const struct option long_options[] = {
		{ "open",								required_argument, NULL, 'o' },
		{ "expression",					required_argument, NULL, 'e' },
		{ "brackets",						no_argument, NULL, 'b' },
		{ "match",              required_argument, NULL, 'm' },
		{ "non-printable",			no_argument,			 NULL, 'n' },
		{ "ms",									required_argument, NULL, 's' },
		{ "debug",              optional_argument, NULL, 'D'},
		{ "help",								no_argument, NULL, 'h'},
		{ NULL,									no_argument, NULL, 0}
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
				ms = atoi(optarg)*SUF;		/* calculate timeout (ms) */
				break;

			/* Show non-printable characters. */
			case 'n':
				fmt.non_printable++;
				break;

			/* Specify filename to read */
			case 'o':
				strncpy(filename,optarg,strlen(optarg));
				break;

			case 'b':
					fmt.brackets++;
				break;

			/* Specify to highlight partial or only full match. */
			case 'm':
				fmt.brackets=0;		/* reset brackets; only the last optin_wrdn is in effect */
				if(!(strcmp("full",optarg)) || !(strcmp("f",optarg)))		
					fmt.partial=FULL_MATCH;		/* 1 display only full match */
				else if(!(strcmp("partial",optarg)) || !(strcmp("part",optarg)) || !(strcmp("p",optarg)))		
					fmt.partial=PARTIAL_MATCH;		/* 2 	display any matched character */
				else {
					fprintf(stderr,"invalid match specifier: `%s'\n",optarg);
					exit(EXIT_FAILURE);
				}
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

