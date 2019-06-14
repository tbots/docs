/*
 * Return 1 if any character in string is in upper case.
 */
int isupper_str(char s[]) {
	char *cp;
	for(cp=s; *cp != 0; cp++)
		if(isupper(*cp))
			return 1;
	return 0;
}
