#include <stdio.h>
#include "defs.h"

/* Display constant value. */
void display_flags(char *label,unsigned int value) {
	char buf[100]={0};

	indent(label,30); 
	sprintf(buf,": %d",value);		// necessarily to process int
	indent(buf,20);
	binary_print(value);
}
