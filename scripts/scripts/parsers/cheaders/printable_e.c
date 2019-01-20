#include <stdio.h>
#include <ctype.h>

void printable_e(char c,int np) {

		if(np) { 			/* display non-printable characters */

			printf("[\033[90m");

			switch (c) {
				case '\t': printf("\\t"); break;
				case  ' ': printf(" "); 	break;
			 	case '\n': printf("\\n"); break;
				default  : printf("%d",c);			/* print ascii value by default */
			}
			
			printf("\033[0m]");
		}
		else 	
			if(!isspace(c))
				printf("%c",c);
			else
				printf(" ");
}
