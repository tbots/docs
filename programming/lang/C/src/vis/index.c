#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include "defs.h"

/*
 *	Highlight ps (pattern_start), fl.np (next_pattern) and temp_t (temporary index), within
 *	expression.
*/
void vsps(char *e, int ps) {
	
	str_h(e,ps,1);
	printf("[DEBUG]  pattern start (ps): %d\n",ps);

	str_h(e,fl.np,1);		/* fl.np is not passed - it is global */
	printf("[DEBUG] next pattern start (fl.np): %d\n",fl.np);

	printf("\n");
}

/*
		Highlight characters within e{expression} on indexes of 
		pattern_start (ps), next_pattern (fl.np) and temporary_offset (temp_t).
*/
void vsexp(char *exp,
					 int ps,
					 char *msg) {

	
	//if(debug)  {
		//fprintf(stdout,"in vsepx()");
		//exit(1);
	//}
	printf("\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
	printf("\n%s\n",msg);
	vsps(exp,ps);		
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

/* Highlight character on index. */
void str_h(char *s, int pos, int np) {
	
	int i;
	//if(debug) 
	//{
		//fprintf(stdout,"in step_h()\n");
		//fprintf(stdout,"np: %d\n",np);
		//exit(1);
	//}

	for(i=0; !(i > strlen(s)); i++) 
	{
		if(i == pos)			/* index in string reached */
			printf("\033[0m\033[7m");		/* highlight character */
		else
			printf("\033[90m");	/* set dim */
		printable_e(s[i],np);
		printf(" [%d]\033[m ",i);		/* print index */

		if(s[i]=='\n')
			printf("\n");
	}
	if(s[--i] != '\n')
		printf("\n");
}
