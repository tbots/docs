#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* 
 * Memory accepted as void * 
 */
void db(void * variable,int s) {
	int i;
	char *p;

	p = (char*)variable;
	for(i=0; i < s; i++) {
		printf("%p:\t0x%02x",p,*p);
		printf("\t");
		printf("'%c'",*p);
		printf("\n");
		p++;
	}
}

int check_authentication(char *password) {
	int auth_flag = 0;
	char password_buffer[16];
	strcpy(password_buffer,password);
	return auth_flag;
}

int main(int argc,char *argv[]) {
	if(argc < 2) {
		printf("Usage: %s <password>\n",argv[0]);
		exit(0);
	}
	if(check_authentication(argv[1])) {
		printf("\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n");
		printf("         Access Granted.\n");
		printf("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n");
	}
	else {
		printf("\nAccess Denied.\n");
	}
	return 0;
}
