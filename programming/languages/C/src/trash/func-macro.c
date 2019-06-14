#include <stdio.h>

void cool() { printf("cool() is called\n"); }
void foo() { printf("foo() is called\n"); }

int main() {
	void (*fptr)();
	#define foo() cool()
	foo();

	fptr = foo;
	printf("address of the foo() function is 0x%016lx\n",(long unsigned int)foo);
	printf("address of the fptr pointer is 0x%016lx\n",(long unsigned int)fptr);

	fptr();
	return 0;
}
