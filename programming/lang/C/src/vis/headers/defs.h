/*
 * int lst(char);
 *
 * ftl
 * ec_malloc
 * lst
 * printable_e
 *
 */
#define LINE_START -1						
#define LINE_END	 -1						

extern int debug;

/* Functions */
void atom_print(char**);
int  eol(int fd);
void ftl(char *msg);
int lst(int fd);
int lst_o(int fd);
int lst_or(int fd,int ro);			/* line start offset relative */
void printable_e(char,int);
void *ec_malloc(unsigned int);
int crstat(int fd,int start,int end,int np,int idx);
