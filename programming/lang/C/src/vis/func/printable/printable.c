/* printable.c
 *
 * Print character c to the screen, if non_prnt is not a zero, attempts to provide a visual representation for the non-printable characters
 * by printining their symbolic representation (i.e. '\n','\t' etc.), in case when character has no corresponding representation it's decimal value is 
 * print instead.
 *
 * When non_prnt is not specified, non-printable characters always will be printed as '[ ]'.
 */
void printable(char c,int non_prnt) {
	if(isspace(c)) 
	{
		printf("non_prnt: %d\n",non_prnt);
		if(non_prnt) 
		{
			if(c == '\t')
				printf("\\t");
			else if(c == ' ')
				printf("[ ]");
			else if ( c == '\n')
				printf("\\n");
			else
				printf("%d",c);
		}
		else
			printf("[ ]");
	}
	else {
			printf("%c",c);						/* printable character */
}
