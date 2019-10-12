/* rcs.c
 *
 * Populates char_st structure.
 */
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include "defs.h"

struct char_st { 
	char 	p;
	char 	c;		
	char 	f;		
};

struct char_st cs = {0};

int main() {
	cs.p = 'a';
	printf("cs.p: '%c' located at %p\n",cs.p,(char*)&cs.p);
	printf("structure cs located at %p\n",&cs);
	return 0;
}
