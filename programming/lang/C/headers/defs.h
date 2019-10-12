int crstat(int fd,int start,int end,int np,int idx);
int eol(int fd);
int lst(int fd);
void ftl(char *msg);
void printable_e(char c, int np, int idx);
void *ec_malloc(unsigned int);

#define REQUESTED_BUT_DOES_NOT_MATCH		// -1 word border or anchor position match result
#define DOES_NOT_MATCH				-1		// returned by match() 
#define DOES_NOT_REQUESTED		-1		// end of word anchor was not requested 
#define LINE_START -1						
#define LINE_END	 -2

extern int debug;
