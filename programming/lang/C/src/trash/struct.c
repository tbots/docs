#include <stdio.h>
#include <string.h>

struct test {
	char name[20];
};

int main() {
	struct test real_name;
	char *raw_ptr;
	int i;

	//strncpy(real_name.name,"Oleg Sergiyuk",13);
	raw_ptr = (char*) &real_name;
	for(i=0; i < sizeof (real_name); i++)
		printf("raw_ptr [0x%016lx]\t0x%02x\n",
			(unsigned long int)&raw_ptr[i], (unsigned short int)(unsigned char)raw_ptr[i]);
	return 0;
}
