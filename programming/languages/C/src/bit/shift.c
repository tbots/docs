#include "bin.h"

int main() {
	int n = 0b00001111;
	char bin[20]={0};
	ret_bin(bin,(long long int)n,1);
	printf("%s\n",bin);
	n <<= 2;
	ret_bin(bin,(long long int)n,1);
	printf("%s\n",bin);
	return 0;
}
