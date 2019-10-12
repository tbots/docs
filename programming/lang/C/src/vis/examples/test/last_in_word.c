int last_in_word(struct char_st cs) {
	
	if( isspace(cs.c) )		/* current character read is a white space */
		return 0;			/* consider it outside word */

	if(cs.f) { 		/* current character read is not the last */
		if(isspace(cs.f) || cs.f == '\n')   	/* following character is a whitespace or new line */
			return 1;		/* consider current character read at the start of the word */
		else				/* following character is not a white space or a new line */
			return 0;		/* consider current character read inside word */
	}
	return 1;
}
