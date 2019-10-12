/* Functions to examine positional match. Returns REQUESTED_AND_MATCHED if character read matched position,
 * REQUESTED_BUT_DOES_NOT_MATCH otherwise.
 */

#include <ctype.h>
#include "defs.h"

/*
 * int first_on_line(struct char_st cs);
 *
 * Return 1 (REQUESTED_AND_MATCHED) if current character read is first on the line. 
 */
int first_on_line() {
	if( ( ! cs.p ) || cs.p == '\n' )
		return REQUESTED_AND_MATCHED;
	return REQUESTED_BUT_DOES_NOT_MATCH;
}

/*
 * int last_on_line();
 *
 * Return 1 (REQUESTED_AND_MATCHED) if current character read is last on the line. Check cases
 * when new line preceded with a whitespace(s).
 */
int last_on_line() {
	if( ( ! cs.f ) || cs.f == '\n' )		/* if the next character is empty (end of file) or a new line 
																	consider current character read last on line */
		return REQUESTED_AND_MATCHED;
	return REQUESTED_BUT_DOES_NOT_MATCH;
}

/*
 * int fiw();
 *		
 * Return 1 if character read (cs.c) is first in word, 0 otherwise.
 */
int first_in_word() {
	if( ( ! cs.p ) || isspace(cs.p) )	/* if previous character read is empty (beginning of the file) or is 
																	a whitespace, consider current character read as first in word */
		return REQUESTED_AND_MATCHED;
	return REQUESTED_BUT_DOES_NOT_MATCH;
}
	
/*
 * int liw();
 *					
 * Return 1 if character read (cs.c) is last in word, 0 otherwise.
 */
int last_in_word() {
	if ( ( ! cs.f ) || isspace(cs.f) )		/* if following character is empty (end of file) or is a whitespace,
																			consider current character read at the end of the word */
		return REQUESTED_AND_MATCHED;
	return REQUESTED_BUT_DOES_NOT_MATCH;
}

/* Check if the character read matched position. */
int anch(char c,struct char_st cs) {

	switch(c) 
	{
		case '^': 
			return first_on_line();

		case '<':
			return first_in_word();

		case '>':
			return last_in_word();

		case '$':
			return last_on_line();

		default:
			return DOES_NOT_REQUESTED;
			break;
	}
}
