#include <stdio.h>

int main(){
	int i;
	int n=10;
	int a[10] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
	for(i=0; i < 10; i++)
		printf("a[%d]: %d\n",i,a[i]);
	for(i=0; i < n; i++)					/* note the exact number of the elements is actually n */
	{
		//printf("n-1: %d\n",n-1);
		printf("%6d%c", a[i], (i%2==1 || i==n-1) ? '\n' : 'x');
	}
	return 0;
}
