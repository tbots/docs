/* fgetc(3) wrapper */
#include <stdio.h>

int main() {
	char s[100];
	/* int fgetc(FILE *stream); */
	//while((c = fgetc(stdin)) != '\n')
	fgets(s,sizeof(s),stdin);
	printf("s: \"%s\"\n",s);
	return 0;
}
