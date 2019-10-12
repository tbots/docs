/* AND */
#include <stdlib.h>
#include "dec.h"

int main(int argc,char *argv[]) {
	int value1 = atoi(argv[1]);
	int value2 = atoi(argv[2]);
	binary_print(value1);
	binary_print(value2);
	binary_print(value1 | value2);
	return 0;
}
