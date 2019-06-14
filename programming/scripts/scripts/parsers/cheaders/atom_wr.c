/* 
 * Write atomic parts.
 */
int atom_wr(char **atom) {
	// struct atoms {
	// 	int atom_index;
	// 	int atom_new;
	// 	int atom_complete;
	// 	int wi[100];						/* write indexies */
	// 	int li;									/* last index in wi */
	// };

	int i;
	while (a.atom_new){
		printf("[DEBUG] opening bracket found\n");

		a.wi[a.li++] = ++a.atom_index; 
		atom[a.atom_index] = (char*) ec_malloc(100);		/* allocate new space */
		a.atom_new--;
	}

	for(i=0; ! (i > a.li); i++)			/* copy character to each atom */
	{
		/* Debug */
		if(debug) {
			fprintf(stdout,"[DEBUG] writing to the index of '%d'\n",a.wi[i]);
		}

		strncat(atom[a.wi[i]],&cs.c,1); 
	}

	while(a.atom_complete) {		/* closing bracket found */
		printf("[DEBUG] closing bracket found\n");

		a.wi[--a.li] = 0;					/* remove closed index */
		a.atom_complete--;
	}

	return 0;
}
