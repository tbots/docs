/* 

	int sstr(char *s,int i);
		
	 Print string pointed to by s. If i is not zero,
	 print character indexes. 

*/
#include <stdio.h>

int sstr(char *s,int i) {
	int m;
	for(m=0; s[m] != '\0'; m++) {
		printf("%c ",s[m]);
		if(i)		/* print indexes */
			printf("\033[2m[%d]\033[0m  ",m);
	}
	if(s[m-1] != '\n')
		printf("\n");
	return i;
}
