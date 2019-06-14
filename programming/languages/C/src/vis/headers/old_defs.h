//const char *program_name;

int crstat(int fd,int s,int e,int np,int di);		/* print file contents; dim up to offset */
int exch(int fd);														/* print file contents; dim all except of offset-1 */
int sstr_h(char *s,char t,int n,int ind);		/* visualise indexed character in s */
int sstr(char *s,int ai);									/* print character in string along to their indexes */
int lst(int fd);														/* return line start offset */
int lst_o(int fd);													/* return offset from the line start */
int lst_or(int fd,int ro);									/* offset is first reset to relative offset (or), the offset from the start of the line
																							 																																is calculated */
int vsrd(int fd,int start,int bcnt,char brk); 				/* attempts to provide a virtualisation for the read() call */
int null(char *s);													/* fill string pointed to by s with zeroes */
void printable(char c,int vis);							/* print formatted characters */
void ftl(char *msg);											
void *ec_malloc(unsigned int size);
char *errnonm_r(char *buf,int value);
char *errnonm(int value);
