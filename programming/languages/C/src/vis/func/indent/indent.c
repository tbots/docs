/*                                                      */
/* indent()				print ind spaces 											*/
/*                                                      */
void indent(char *string) {
	int m;
	printf("%s",string);
	for(m=0; m < ind; m++)
		printf(" ");
}
