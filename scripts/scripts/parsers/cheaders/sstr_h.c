/**************************************************************
 * int sstr_h(char *s,char term,int ind,int in);							*
 * 																														*
 * Print dimmed string. Highlight character on index of ind. Return string s length. *
 *  in stands for index number; if not zero print character		*
 *	indexes																										*
 *																														*
 *************************************************************/
	 
#include <stdio.h>
#include <ctype.h>

int sstr_h(char *s,char t,int n,int ind) {
	int i;
	printf("\033[2m");	/* set dim */
	for(i=0; s[i] != '\0'; i++) {
	/* 
		Start printing in dim. When index is reached highlight the character.
	*/
		if(i == n)			/* n index reached */
			printf("\033[0m\033[7m");

		if ( isgraph(s[i]) )		/* printable: %c */
			printf("%c ",s[i]);
		else 										/* unprintable: %d */
			printf("%d ",s[i]);

		if(ind)
			printf("\033[2m[%d]\033[0m  ",i);
	}
	printf("\033[0m");
	if(t)	/* print terminating character */
		printf("%c",t);
	return i;
}
