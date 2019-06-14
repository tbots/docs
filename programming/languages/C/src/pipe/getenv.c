#include <stdlib.h>
#include <stdio.h>

int main(int argc,char **argv) {	
	int i;

	for(i=1; i < argc; i++)
		printf("%s:\t%s\n",argv[i],getenv(argv[i]));
	return 0;
}
