#include <stdio.h>
#include <string.h>

/* Print string and identation - string length spaces. */
void indent(char *string, int identation) {
	int i;
	char buf[100] = {0};
	sprintf(buf,"%s",string);
	for(i=(identation - strlen(string)); i > 0; i--) 
		strncat(buf," ",1);
	printf("%s",buf);
}
		
