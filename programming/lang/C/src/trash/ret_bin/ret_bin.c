/*
 * Return character string with each character corresponding to the bit
 * value of the conversion result. 
 *
 * s specifies the size of the variable in bytes
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

char *program_name;					/* name of the program */

/* 
 * Return binary string. 
 */
char *ret_bin(char *bin,long long int num,int s) {

	int i,m;
	char *tmp;

	s = s * 8;		/* bits */
	tmp = (char*)ec_malloc(s);	

	m =  0;		/* index in tmp */

	do { 

		if ( num % 2 )
			tmp[m] = '1'; 
		else
			tmp[m] = '0'; 
		m++;

	} while ( num /= 2);

	while ( m < s )
		tmp[m++] = '0';

	i = 0;
	do { bin[i++] = tmp[--m]; } while ( m );
		
	free(tmp);
	return bin;
}
