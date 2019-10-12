#include <stdio.h>

void intarr(int x[]){
	int i;
	for(i=0; x[i] != 0; i++)
		printf("x[%i]: %d\n",i,x[i]);
}

void intarr1(int x[],int c){
	int i;
	for(i=0; ! ( i > c ); i++)
		printf("x[%i]: %d\n",i,x[i]);
}
		
void ii(int x[]){
	x[1]=0;
}

int main(int argc,char **argv){
	int x[10] = {0};
	x[0]=1;
	x[1]=5;
	intarr(x);
	ii(x);
	intarr(x);
	return 0;
}
