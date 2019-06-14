#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void exs(char *s[],int n) {
	int m;
	for(m=0; m < n; m++) {
		printf("[DEBUG]   byte[%d]:\t%p\t%p\t0x%08x\n",
													m,&s[m],s[m],*s[m]);
	}
}
	
int main(int argc,char *argv[]) {
	char *byte[10];
	char *t;

	t = argv[0];
	printf("[DEBUG] t:   %p\n",t);
	printf("[DEBUG] argv[0]:   %p\n",argv[0]);

	/* byte[0] holds an memory address, instead of character! */
	byte[0] = t;
	printf("[DEBUG]   byte[0]:   %p\n",byte[0]);
	//memset(byte[0],0,10);
	
	return 0;
}	
