#include <stdio.h>

int main() {
	/* char */
	printf("sizeof(char): %ld\n", sizeof(char));
	printf("sizeof(char*): %ld\n", sizeof(char*));

	/* int */
	printf("sizeof(int): %ld\n", 	  sizeof(int));
	printf("sizeof(unsigned int): %ld\n", sizeof(unsigned int));

	printf("sizeof(short int): %ld\n", 	  sizeof(short int));
	printf("sizeof(unsigned short int): %ld\n", sizeof(unsigned short int));

	printf("sizeof(long int): %ld\n", 	  sizeof(long int));
	printf("sizeof(unsigned long int): %ld\n", 	  sizeof(unsigned long int));

	printf("sizeof(int*): %ld\n",sizeof(int*));
	printf("sizeof(unsigned int*): %ld\n", sizeof(unsigned int*));
	printf("sizeof(long int*): %ld\n", 	  sizeof(long int*));
	printf("sizeof(unsigned long int*): %ld\n", 	  sizeof(unsigned long int*));

	return 0;
}
