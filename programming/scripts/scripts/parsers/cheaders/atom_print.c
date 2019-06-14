/* 
 * Debug atomis parts.
 */
#include <stdio.h>

void atom_print(char **atom)
{

	int i;

	/* Debug */
	if(debug)
		fprintf(stdout,"[DEBUG] printg atoms...\n");

	for(i=0; atom[i] != 0; i++) {
		/* Debug */
		if(debug)
			printf("atom[%d]: '%s'\n",i,atom[i]);
	}
}

