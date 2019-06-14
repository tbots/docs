#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>

void binary_print(unsigned int value);
int main(int argc,char **argv) {
  char*p=argv[1];
  char octet[3] = {0};

  do
  {
    //printf("octet: %d\n",atoi(octet));
    if(*p=='.' || *p == '\0') 
    {
      binary_print(atoi(octet));
      printf("%c",*p);
      bzero(octet,3);
    }
    else
      strncat(octet,p,1);
  }
  while(*p++ != 0);

  printf("\n");
  return 0;
}
