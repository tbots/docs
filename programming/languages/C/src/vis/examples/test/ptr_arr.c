struct atoms {
	int atom_index;
	int atom_new;
	int atom_complete;
	int wi[100];						/* write indexies */
	int li;								/* last index */
	char ch;
};

struct atoms a;

int atom_wr(char **atom) {
	int i;

	while (a.atom_complete) {		/* closing bracket found */
		printf("[DEBUG] closing bracket found\n");
		a.wi[--a.li] = 0;
		a.atom_complete--;				/* reset counter */
	}

	while (a.atom_new){			/* opening bracket found */
		printf("[DEBUG] opening bracket found\n");
		a.wi[a.li++] = ++a.atom_index;  	/* [trick]; initialize next zero element with atom index (next index in *words[]) */
		atom[a.atom_index] = (char*) ec_malloc(100);		/* allocate new space */
		a.atom_new--;
	}

	for(i=0; ! (i >= a.li); i++)			/* copy character to each atom */
	{
		strncat(atom[a.wi[i]],&a.ch,1); 
	}
	
	return 0;
}
		
void atom_print(char **atom) {
	int i;
	for(i=0; atom[i] != 0; i++)
		printf("atom[%d]: '%s'\n",i,atom[i]);
}
