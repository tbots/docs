#include <stdlib.h>
#include "defs.h"

/* Returns pointer to the allocated memory location or NULL on error. ftl() function handles the warning. */
void *ec_malloc(unsigned int size) {
	void *p;
	if ( (p = malloc(size)) == NULL )
		ftl("malloc");
	return p;
}
