/* Return the value corresponding to the flag name. Well, the thoughts
	 are totally crazy. It can be possible to compare against each flag stored
	 in the array populated from the file. */
char *errnonm_r(char *buf,int value) {
	switch(value) {
		case EMFILE:
			strncpy(buf,"EMPFILE",strlen("EMPFILE")); break;
	}
	return buf;
}
