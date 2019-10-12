#include <stdio.h>

int main(){
	int ps=0;
	char word[10];
	word[ps]= 'a';
	word[ps+1]= 'b';
	while (word[ps++] == '\\') puts("A");
	printf("word: %c\n",word[ps]);
	return 0;
}
