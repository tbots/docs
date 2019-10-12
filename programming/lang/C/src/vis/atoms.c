#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "defs.h"

	// struct atoms {
	//  int atom_index;		
	// 	int atom_new;
	// 	int atom_complete;
	// 	int wi[100];						/* wrtomis parts.
	//  int li;
void atom_print(char **atom) {
	 	int i;
		for(i=0; atom[i] != 0; i++) 
			printf("atom[%d]: '%s'\n",i,atom[i]);
}															

/* Print only atoms on write indexes. */
void atom_print_wi(char **atom) {
	int i;
	for(i=0; i < a.li; ++i)		// a.li - last write index in wi[]
		printf("atom[%d]:\t'%s`\n",a.wi[i],atom[a.wi[i]]);
}

/*  Free allocated memory. */
void atom_clear(char **atom) {
	for(; a.atom_index; --a.atom_index)
		free(atom[a.atom_index]);
}

/* 
 * atom_wr(char **atom);
 *
 *  Write atomic parts. When the new character matched it should be stored in the all matched 
 *  backreferences. Last index (li) in wr[] determines till when atom[] should be iterated.
 */
void atom_wr(char **atom) {
	int i;

	for(; a.atom_new; --a.atom_new)
	{ 
	  
		if(debug) 
			fprintf(stdout,"[DEBUG] found new atom\n");
		
		/* New backreference index will be added to the a.wi array. Array will 
			 be iterated and each atom on index will be written. */
		a.wi[a.li] = ++a.atom_index;
		/* Each opened bracket will need it's buffer. Allocate
			 memory. */
		atom[a.wi[a.li]] = (char*) ec_malloc(100);
		a.li++;		/* be ready to write new atom */
	}

	for(i=0; i < a.li; i++)			/* copy character to each atom */
	{
		if(debug)
			fprintf(stdout,"[DEBUG] copying to the atom[%d]\n",a.wi[i]);

		strncat(atom[a.wi[i]],&cs.c,1); 
	}

	/* Closing bracket found. Index in atom[] should not be written any more. */
	a.li -= a.atom_complete;	
	a.atom_complete = 0;
}
