/* max.c - find max value of two numbers */
#include <stdio.h>
#include <stdlib.h>

int max(int a,int b) {
	printf("a: %d\n",a);
	printf("b: %d\n",b);
	return (a > b) ? a : b;
}

int main(int argc,char *argv[]) {
	if(argc != 3)
		exit(1);
	printf("highest number is %d\n",max(atoi(argv[1]),atoi(argv[2])));
	return 0;
}
