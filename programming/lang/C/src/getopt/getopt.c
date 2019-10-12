#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int
main(int argc, char *argv[])
{
  int flags, opt;
  int nsecs, tfnd;

  nsecs = 0;
  tfnd = 0;
  flags = 0;

  /* int getop(int argc, char * const argv[],
            const char *optstring); 
     extern char *optarg;
     extern int optind, opterr, optopt;
  */
  while((opt = getopt(argc,argv,"nt:")) != -1) {
    switch(opt) {
      printf("optind:\t%d\n,opterr:\t%d\n,optopt:'%c'\n",
        optind:\t%d\n,opterr:\t%d\n,optopt:'%c'\n",
    switch(opt) {
      case 'n':
        flags = 1;
        break;
      
      case 't':
        nsecs = atoi(optarg);
        tfnd = 1;
        break;

      default: /* ? */
        fprintf(stderr, "Usage: %s [-t nsecs] [-n] name\n",
                  argv[0]);
        exit(EXIT_FAILURE);

      }
    }
