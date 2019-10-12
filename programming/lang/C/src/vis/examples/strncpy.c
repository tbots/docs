#include <stdio.h>
#include <string.h>
int main() {
	char dest[10] = {0};
	char src[10] = {'h', 'e','l','l','o'};
	printf("%s  %d\n",src,(int)strlen(src));
	printf("%s [%p]\n",src,(void*)strncpy(dest,src,strlen(src)));

	//dest[0] = '\0';		// same as dest I suppose
	src [0] = '\0';		// same as dest I suppose
	//printf("'%s'\n",(char*)strncpy(dest,src,strlen(src)));
	if(*((char*)strncpy(dest,src,strlen(src))))
		puts("true");
	else
		puts("false");
	return 0;
}
