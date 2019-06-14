/* Zero a string. */
void null(char *s) {
	int i;
	for(i=0; s[i] != '\0'; i++)
		s[i] = 0;
}


/* Display characters till index in dim and from the index till the end in 
	 normal color. Return string length. */
int visual(char *s,int index) 
{
	int i;
	for(i=0; s[i] != '\0'; i++) 
	{
		printf("\033[2m");
		if(i >= index)
			printf("\033[0m");
		//printf("%c%d",s[i],i);
		printf("%c",s[i]);
		//if(s[i] == '\n')
			//break;
	}
	return i;				/* restore cursor */
}	

