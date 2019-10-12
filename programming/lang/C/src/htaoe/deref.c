#include <stdio.h>

int main() {
	void *p;
	int i;
	int a = 5;

	p = &a;
	printf("&a : %p\n",&a);
	printf("p : %p\n",p);

	for(i=0; i < sizeof(int); i++) {
		printf("%p: %d\n",p,(*(char*)p));
		(char*)p++;
	}

	return 0;
}
