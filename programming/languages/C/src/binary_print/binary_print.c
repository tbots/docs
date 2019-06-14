/* Print binary representation of the number. */
#include <stdio.h>

/* It is great. */
void binary_print(unsigned int value) 
{
	unsigned int mask  = 0xff000000;		// Start with the mask of the highest byte.
	unsigned int shift = 256*256*256;		// Start with the shift of the highest byte.
	unsigned int byte, byte_iterator, bit_iterator;

	for(byte_iterator=0; byte_iterator < 4; byte_iterator++) {

		byte = (value & mask) / shift;		// Isolate each byte.

		for(bit_iterator=0; bit_iterator < 8; bit_iterator++) 
		{

			if(byte & 0x80) 	// If the highest bite in the byte isn't 0,
				printf("\e[41m1\e[0m");		// print a 1.
			else
				printf("0");		// Otherwise, print a 0.
			byte *=  2;
		}
		mask  /= 256;				// Move the bits in mask right by 8.
		shift /= 256;				// Move the bits in shift right by 8.

		printf(" ");
	}
	//printf("\n");
}
