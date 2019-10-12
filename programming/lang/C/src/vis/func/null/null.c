/* Fills all the string with the zeroes. Returns zero. */
int null(char *s) {
	int i;
	for(i=0; s[i] != '\0'; i++)
		s[i] = 0;
	return 0;
}

