/*
 * ctypes.c				tests
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>

int main(int argc,char **argv) {	
	int i;
	char *cp;
	char *test_str;
	test_str = (char*)malloc(32);

	for(i=1; i < argc; i++) {
	/* 
	 * Read all the arguments into test_str. 
	 */
		strncat(test_str,argv[i],strlen(argv[i]));
		//sstr(test_str,strlen(test_str));
	}
	
	/* DEBUG */
	printf("test_str:%20s\n",test_str);

	for(cp=test_str; *cp != 0; cp++) {
		printf("Comparing `%c'\n",*cp);
		/*
		 * int isalnum(int c);
		 */
		printf("isalnum('%c'):%10d\n",*cp,isalnum(*cp));

		/*
		 * int isalpha(int c);
		 */
		printf("isalpha('%c'):%10d\n",*cp,isalpha(*cp));

		/*
		 * int isascii(int c);
		 */
		printf("isascii('%c'):%10d\n",*cp,isascii(*cp));

		/*
		 * int isupper(int c);
		 */
		printf("isupper('%c'):%10d\n",*cp,isupper(*cp));

		/*
		 * int isgraph(int c);
		 */
		printf("isgraph('%c'):%10d\n",*cp,isgraph(*cp));

		/*
		 * int isdigit(int c);
		 */
		printf("isdigit('%c'):%10d\n",*cp,isdigit(*cp));

		/*
		 * int isspace(int c);
		 */
		printf("isspace('%c'):%10d\n",*cp,isspace(*cp));

	}
	
	free(test_str);
	return 0;
}
