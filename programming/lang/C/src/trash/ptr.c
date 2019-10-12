#include <stdio.h>

int main() {
	int a = 5;
	int *int_ptr;

	int_ptr = &a;

	printf("int_ptr: %p\n",int_ptr);
	printf("int_ptr: 0x%016llx\n",(long long unsigned int)int_ptr);
	return 0;
}
