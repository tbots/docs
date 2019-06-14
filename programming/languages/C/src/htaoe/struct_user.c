/* Print struct user fields */
#include <stdio.h>
#include <stdlib.h>
struct user{
	int uid;
	int credits;
	int highscore;
	char name[100];
	int (*current_game) ();
};

void dump_struct(unsigned char *ptr,int n[],char m) {
	for(i=0; n < sizeof(n)/sizeof(int); n++) {
		printf(
		dump_struct((unsigned char *)ptr,el[n],m);


int main(int argc,char **argv) {
	struct user player;
	//int next_option;
	int i;
	int el[] = { sizeof(player.uid),
									 sizeof(player.credits),
									 sizeof(player.highscore),
									 sizeof(player.name),
									 sizeof(player.current_game)};

	unsigned char *ptr;		/* struct pointer */
	ptr = (unsigned char*)&player;


	printf("struct user player:\t%p\n",&player);
	printf("sizeof(struct user):\t%d\n",sizeof(struct user));
	printf("sizeof(player.uid):\t%d\n",sizeof(player.uid));
	printf("sizeof(player.credits):\t%d\n",sizeof(player.credits));
	printf("sizeof(player.highscore):\t%d\n",sizeof(player.highscore));
	printf("sizeof(player.name):\t%d\n",sizeof(player.name));
	printf("sizeof(player.current_game):\t%d\n",sizeof(player.current_game));

	return 0;
}
