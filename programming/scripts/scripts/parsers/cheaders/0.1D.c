/* matches.c			
 *
 * Visualise matching algorithm.
 */
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
	int repeat_p;			/* repeat pattern  */
	int ai;						/* atom index */
	char anch;				/* one of the '>' or '$' */
	char r_ch;				/* repeatition character */
};

/* stores previous current and following character read */
struct char_st { 
	char 	p;		/* previous */
	char 	c;		/* current */
	char 	f;		/* following */
};

/* holds values that specifies output formatting */
struct scheme {
	int  partial;
	int  non_printable;
	int  brackets;
};

/* Stores atomic parts of expression (backreferences). */
struct atoms {
	int atom_index;
	int atom_new;
	int atom_complete;
	int wi[100];						/* write indexies */
	int li;									/* last index in wi */
};

/*
 * GLOBALS
*/
struct mtchfl fl 	= {0};				/* fl structure created here */
struct char_st cs = {0};
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
		Print cs structure contents. 
*/
void vscs(struct char_st cs) {
	printf("[DEBUG] cs.p:    '%c'\n",cs.p);
	printf("[DEBUG] cs.c:    '%c'\n",cs.c);
	printf("[DEBUG] cs.f:    '%c'\n",cs.f);
}

/*********************************************************************************************
 * int rcs(int fd);                                                                          *
 *                                                                                           *
 *	Populate char_st structure. Reading step 1.                                              *
 ********************************************************************************************/
int rcs(int fd) {
	int ret;
	cs.p = cs.c;				/* store current character from the previous read; becomes a previous character */
	if((ret = read(fd,&cs.c,2)) == -1) 
		ftl("error");	/* read two characters in place of current */

	/* If read occured (one or two characters were read) return cursor one character back only in case of two characters
	 * were read setting up the cursor to next character in file to be read, if only one character was read cursor will
	 * be keep the position of the end of file and next call to rcs() will return 0 but character will be processed as ret
	 * still holds the value of 1.
	 */
	if(ret) 
		lseek(fd,(ret-1)*-1,SEEK_CUR);
	return ret;
}


/************************************************************************************************************
 * int fiw();																																																*
 *																																																					*
 * Return 1 if character read (cs.c) is first in word, 0 otherwise.																					*
 ***********************************************************************************************************/
int fiw() {
	if(cs.p) {
		if(isspace(cs.c))
			return 0;		/* white space never at the beginning of the word */
		else
		if(isalpha(cs.c)){
			if(isalpha(cs.p))
				return 0;
		}
		else
		if(isgraph(cs.c)){ 
			if(isgraph(cs.p))
				return 0;
		}
	}
	return 1;
}
	
/************************************************************************************************************
 * int liw();																																																*
 *																																																					*
 * Return 1 if character read (cs.c) is last in word, 0 otherwise.																					*
 ***********************************************************************************************************/
int liw() {
	
	if(cs.f) 	/* current character is not the last character read */
	{ 		
		if(isspace(cs.c))
		{
			if(isspace(cs.f)) 
				return DOES_NOT_MATCHED;	
		}
		else	// not a whitespace
		{
			if(!isspace(cs.f))
				return DOES_NOT_MATCHED;
		}
	}
	return MATCHED;
}

/* Return MATCHED if character read is at the end of a line or end of a word, DOES_NOT_MATCH 
 * otherwise. */
int anch() {

	switch(fl.anch) 
	{
		case '>':
			return liw();

		case '$':
			if(cs.f == '' || cs.f == '\n') /* following character is empty or a new line */
				return MATCHED;
	}
	return DOES_NOT_MATCH;
}
	
/************************************************************************************************************
 * int match(char *e);																																											*
 *																																																					*
 * match() will apply all the necessary tests on the pattern in expression e on the index of ps, against		*
 * a character. ps is index in expression of the start position of pattern to be examined next. If 		*
 * character is matched pattern, ps will be set to the start index of the next pattern, otherwise DOES_NOT_MATCH *
 * constant(-1) will be returned and ps will be reset to the value of 0, thus search will be restarted from *
 * the beginning of the expression.
 ***********************************************************************************************************/
int match(char *exp,int ps)
{
	int temp_t;							/* help offset */
	int fiwc=0;							/* character requested to be first in word flag; default no (0) */
	int be_at_the_end;			/* DOES_NOT_REQUESTED|REQUESTED_BUT_DOES_NOT_MATCH|DOES_NOT_REQUESTED */
	int matched_in_word;
	int repeat_c=0;	

	/* range */
	int nb;									/* next bracket in range case offset */
	char c;									/* holds character in range */
	int negotiate_match;		/* if match return zero */

	do {

		if(ps < 0) 	/* reset pattern start */
			 ps = 0;		/* when it will be -1 */

		matched_in_word	= 0;	/* set match flag to 0 */
		negotiate_match = 0;
		anchor        	= 0;	/* does not anchored by default */
		be_at_the_end	= DOES_NOT_REQUESTED;			// -1
		temp_t	= 0;

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
			 Information collected in the following block is unique for the current pattern. If 
			 repetition is the case match will be performed against the same pattern the information
			 will not be learned twice.

		*/
		if(!fl.repeat_p) 
		{
			/* 
			 * Debug 
			 */
			if(debug)
				fprintf(stdout,"[DEBUG] learning new pattern\n");

			/*
			 * Zero fl structure.
			 */
			bzero(&fl,sizeof(fl));

			fl.np=ps

			/*
			 * Test 1.
			 *
			 * Handle all the possible cases at the pattern start.
			 */

			/*
			 *  Search for the '^' character.
			 */

			if((exp[ps]) == '^' )
			{
				/* previous character is empty or a new line */
				if(cs.p == '' || cs.p == '\n')
					fl.np = ++ps;
				else
					return DOES_NOT_MATCH;
			}
			
			/*
			 * Handle all the cases where pattern start points to '\'.
			 */

			if(exp[fl.np] == '\\') 
			{
				do 
				{
					switch (exp[++fl.np]) 
					{
						case '(':
	
							a.atom_new++;		/* new atom will be written */
						break;
						
	
						case '<':
	
							if(anch(exp[fl.np] == REQUESTED_BUT_DOES_NOT_MATCH))
							{		
								if(debug) 
									fprintf(stdout,"[DEBUG] character requested to be first in word but does not match\n");
	
								return DOES_NOT_MATCH;			// -1
							}
						break;
	
						default:
	
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

							fl.np++;
						
						break;
					}

					if((fl.np-1) > ps)
						break;

					ps = ++fl.np;
				}
				while(exp[fl.np] == '\\');
			}
			else
			 fl.np++;

			if(debug)
				vsexp(exp,ps,temp_t,"TEST 1 FINISHED\n");

			/*
			 * TEST 2: PATTERN END
			 *
			 */

			temp_t = fl.np;
			while(1)
			{
				switch(exp[temp_t]) 
				{
					/*
					 * Handle \+ and \> cases 
					 */
					case '\\':			
						
						temp_t++;

						if(exp[temp_t] == '+' || exp[temp_t] == '?') 
							fl.r_ch = exp[temp_t];			/* store repetition character */

						else if(exp[temp_t] == '>' ) 
							fl.anch = exp[temp_t];

						else if(exp[temp_t] == ')')
							a.atom_complete++;

						else
							temp_t = DOES_NOT_MATCH;

					break;

					case '$':

					  fl.anch = exp[temp_t];
	
					case '*':

						fl.r_ch = exp[temp_t];

					break;

					default:
						temp_t = DOES_NOT_MATCH;

				}

				if(temp_t != DOES_NOT_MATCH)
					fl.np = ++temp_t;
				else
					break;
			}

			fl.np = temp_t;		// point to the next pattern
		}

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

			if((be_at_the_end  = anch()) == REQUESTED_BUT_DOES_NOT_MATCH) 
			{			
			/*
			 * abb$     <-->   b*
			 * [a]a b   <-->   [a]*\>
			 * a[ ]b		<-->	 b*\>   check if previous character is last in word
			 */
																																								
				if(!fl.r_ch) 
					return DOES_NOT_MATCH;
			}
			/* Debug */
			if(debug)
			//  DOES_NOT_REQUESTED							 -1
			//	REQUESTED_BUT_DOES_NOT_MATCH			0
			//	REQUESTED_AND_MATCHED							1
				fprintf(stdout,"[DEBUG] be_at_the_end: %d\n",be_at_the_end);

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
		 * TEST 4: Handle match result and repetition case
		 */
		if(matched_in_word) {	

			/* Character read matched. */

			if(fl.r_ch) 				/* Repetition character was found */
			{	
				/* Debug */
				if(debug) {
					fprintf(stdout,"[DEBUG] found repetition character\n");
				}

				if(be_at_the_end != REQUESTED_AND_MATCHED) {
					/* Debug */
					if(debug) {
						fprintf(stdout,"[DEBUG] repeating same pattern\n");
					}
					fl.repeat_p = 1;
				}
				else {
					/* Debug */
					if(debug) {
						fprintf(stdout,"[DEBUG] character requested to be last in word and it is last,\n"
												"[DEBUG] no need to perform the repetition, proceed to the next pattern\n");
					}

					fl.repeat_p = 0;	/* do not repeat pattern; end of repetition case */
				}
			}
			
			if(fl.repeat_p == 0) /* go to the next pattern */
				ps = fl.np;
		}
		else {
			
			/* Character read doesn't match. */
			/* Debug */
			if(debug) {
				fprintf(stdout,"[DEBUG] character doesn't match\n");
			}

			if(fl.r_ch) {

				if(debug) 
					fprintf(stdout,"[DEBUG] repetition character `%c' was found\n",fl.r_ch);	

				if(fl.r_ch == '+') 
				{
					if(!fl.repeat_p) {			/* Pattern was not previously repeated and first attempt to match was not satisfied. */
						/* Debug */
						if(debug)
							fprintf(stdout,"[DEBUG] character doesn't match previously\n");
						return DOES_NOT_MATCH;
					}

				}
				fl.repeat_p = 0;				/* current character read will be compared with the next pattern */

				if(be_at_the_end != DOES_NOT_REQUESTED)
					
					// remember start matching offset */
					/* a[ ]b -> a[b]*\>  */
					if(!fiw()) {		/* check if previous character is last in word */

						/* Debug */
						if(debug)
							fprintf(stdout,"[DEBUG] Previous character read is not the last in word\n.");

						return DOES_NOT_MATCH;
					}
				
				if(debug) 
					fprintf(stdout,"[DEBUG] character read will be matched again against next pattern\n");

				ps 			 = fl.np; 
				fl.r_ch  = -1;
				repeat_c =  1;
			}
			else
				return DOES_NOT_MATCH;
		}	
			
		if(debug) 
			vsexp(exp,ps,temp_t,"at the end of the algorithm");

		/* End of expression == Full match */
		if(exp[fl.np] == '\0')
			break;

	} while (repeat_c);			/* repeat match against the same character read */

	return ps;
}



/*
 *	Print word contents.
 */
void print_word(int fd,char *word,struct scheme fmt) {
	
	printf("In print_word()\n");
	exit(1);

	int i= strlen(word);				/* i is the index of the last element in word */
	int line_start_ot,cur;
	
	cur= lseek(fd,0,SEEK_CUR);		/* remember current cursor position */
	if((line_start_ot= lst_o(fd)) == 1)	/* offset from the beginning of the printed line is one */
		line_start_ot = lst_or(fd,cur-2);	/* have no idea */


	/* Handle scheme. */

	if(!(fmt.brackets == 0))		/* '{' and '}' should be deleted as well */
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

/* Visualise reading step.
 *
 * \033[4D		delete 4 character back
 */
void step(int fd,char *word,struct scheme fmt,int match) {

	/* Debug */
	if(debug) {
		printf("[DEBUG] in step()\n");
		vscs(cs);
	}

	/* 
	 * Handle previous character.
	 */
	if(cs.p == '\n') {				
		if(fmt.non_printable) {
			printf("\033[4D");
		}
		else {
			printf("\033[1D");
		}
	}
	else if(cs.p == ' ') {
		if(fmt.non_printable) {
			printf("\033[3D");		
		}
		else {
			printf("\033[1D");
		}
	}
	else {		/* regular character; just delete it */
		printf("\033[1D");
	}

	printf("\033[0m");		/* reset color */

	/*
	 * Handle brackets
	 */
	if(!(fmt.brackets == 0))
	{
		if(match >= 0) { 	/* match found */
			if(strlen(word) > 1 )			/* delete '}' only if it was already printed :) */
				printf("\033[1D");		/* delete '}' */
		}
		else {	/* previn_wrdus character does not match */
			if(strlen(word) > 0)		/* '}' already was printed */
				printf("\033[1D");	/* delete '}' */
		}
	}


	/* 
	 * Decide color and print previous character.
	 */

	/* 
	 * Brackets enclosure was requested. 
	 */
	if(!(fmt.brackets == 0)) {
		if(match >= 0) {			/* matched */
			printf("\033[0m\033[31m\033[1m");		/* set color */
			if(strlen(word) == 1)		/* the first character matched */
					printf("{");		/* open a bracket */
		}
		else {		/* not matched */
			if(*word != 0) 		/* matched characters buffer */
				print_word(fd,word,fmt);	/* restore word */
		}
	}

	/*
	 * Brackets enclosure was not requested.
	 */
	else 
	{		
		/* Debug */
		if(debug) {
			fprintf(stdout,"in step(): deciding on previous character color match: %d\n",match);
			puts("AAA");
		}

		if(match >= 0) {
			printf("\033[41m\033[97m");		/* B: Red; F: White */
		}
		else {		/* no match; restore the word in case of full match */
			if(*word != 0 && fmt.partial == FULL_MATCH)
					print_word(fd,word,fmt);
		}
		/* othewise word is already empty; and character color is not set */
	}

	/* Print previous character here */
	printable_e(cs.p,fmt.non_printable);
	if(cs.p == '\n')
		printf("\n");

	/* reset color */
	printf("\033[0m");		

	if(cs.c) {			/* will be reset to '\0' in last iteration */
		printf("\033[7m");		/* set color for the current character read */
	
		/* Print current character here */
		//puts("BBB");
		printable_e(cs.c,fmt.non_printable);
	}
	else 
		printf("\n");

	if(!(fmt.brackets == 0))
		if(match >= 0)
			printf("}");		/* print closing bracket */

}


/* 
	int re_fdb(int fd,char*exp,struct scheme);
*/
int re_fdb(int fd,char *pattern,struct scheme fmt,int ms) {
	int p;			/* pattern offset */
	int o;			/* new/returned offset */
	int ret;		/* read return value */
	int st;	/* start read offset */

	char *atom[ATOM_MAX] = {0};			/* array of char pointers */
	struct timespec req = {0};			/* timespec */

	atom[a.li] = ec_malloc(1000);		/* all the matched goes to atom[0] */

	o = p = 0;		
	ret = 0;

	req.tv_sec = 0;
	req.tv_nsec = ms;		/* default time wait - 10 ms */

	printf("\033[?25l");		/* hide cursor */

	st=lseek(fd,0,SEEK_CUR);		/* remember cursor offset */
	while((ret = rcs(fd)) > 1) {

		if(ret == -1) 
			ftl("error");
			
		//printf("ret: %d\n",ret);

		/* CONTINUE HERE */
		//exch(fd);		/* print line with the highlighted examined character */
		//crstat(fd,LINE_START,LINE_END,1,1);

		step(fd,atom[0],fmt,o);				/* show step */

		/* Run matching algorithm. 
		 * p is the index in pattern to be examined
		 * o is the match result
		 */
		o = match(pattern,p);	

		/* Debug */
		if(debug)
			printf("[DEBUG] match returned: %d\n",o);

		/* Possible return values:
		 *
		 * MATCH (1) 
		 * DOES_NOT_MATCH (-1)
		 */
		if (o == DOES_NOT_MATCH) 
		{
			/* Debug */
			if(debug)
				printf("[DEBUG] character doesn't match!!!\n");

			if(p > 0) {			/* pattern offset was advanced previously */

				/* Restore word when full match is requested */
				//print_word(fd,atom[0],fmt);
				atom_z(atom);
		 		o = match(pattern,p = 0);		
			}
		}
		

		/* Why 0 is accepted? */
		if(o >= 0)
		{
			/* Debug */
			if(debug) 
				printf("[DEBUG] Match found\n");

			p = o;	/* store next pattern offset */

			if(fl.r_ch != -1) 
				atom_wr(atom);
			else 
			{
				o = -1;
				/* Debug */
				if(debug) 
					fprintf(stdout,"[DEBUG] Repetition failed, do not store character read\n");
			}

		}

		if(strlen(pattern) == p) {
			/* Debug */
			if(debug) 
				printf("[DEBUG] Full match; restart search\n");

			//replace_char(char *atoms[], int fd, int st);

			/* Clean atoms */
			atom_z(atom);
			p = 0;			/* repeat pattern from the beginning */
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
	int fd;				/* file descriptor */
	int ms;				/* milli-seconds */
	int next_option;
	char *filename;	
	char *e;			/* expression */

	struct scheme fmt;				/* formatting structure */
	program_name = argv[0];		/* program name */

	/*
		DEF(AULT)S
	*/
	e = ec_malloc(100);				/* initialize memory for the expression */
	filename = ec_malloc(40);	/* initialize memory to store a filename */

	/*
	 * Output format
	 */
	fmt.brackets = 0;					/* no bracket enclosure */
	fmt.non_printable = 0;		/* do not visualise non-printable characters */
	fmt.partial = PARTIAL_MATCH;	/* highlight any character matched */
	ms = 100;

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

	while(
		(next_option = getopt_long(argc,argv,short_options,long_options,NULL)) != -1) {
		
		switch(next_option)
		{
			case 'h':
				usage(stdout,EXIT_SUCCESS);

			/* Specify a search pattern. */
			case 'e':
				strncpy(e,optarg,strlen(optarg));
				break;

			/* Specify in_wrdlliseconds value to wait between each read step. */
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
				printf("next_option: %d\n",next_option);
				fprintf(stderr,"Try `%s --help' for more information.\n",program_name);
				exit(EXIT_FAILURE);
		}
	}

	if(*filename == 0)		/* filename was not specified */
	{
		fprintf(stderr,"no file name specified\n");
		usage(stderr,EXIT_FAILURE);
	}
	
	if(*e == 0) { 			/* do not run without search pattern */
		puts("falling here");
		usage(stderr,EXIT_FAILURE);
	}

	if((fd = open(filename,O_RDONLY)) == -1)
		ftl("open");

	/* magic here */
	re_fdb(fd,e,fmt,ms);

	/* Debug */
	//printf("Index after re_fdb(): %d\n", re_fdb(fd,e,fmt,ms));
	/* crstat(fd,0,0); */
	close(fd);
	free(filename);
	free(e);
	return 0;
}
