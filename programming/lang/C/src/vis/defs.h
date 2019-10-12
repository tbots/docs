#define MATCH														 1		// previously was 0
#define DOES_NOT_MATCH									-1
#define DOES_NOT_REQUESTED						  -2
#define REQUESTED_AND_MATCHED 					-3
#define REQUESTED_BUT_DOES_NOT_MATCH		-5
#define LINE_START 											-6					
#define LINE_END	 											-7
#define PART_MATCH										   0	// full match otherwise, no need to define constant
#define FULL_MATCH											 1
#define ATOM_MAX											  20		// defines maximum number of backreferences

extern int debug;

/* All the structure created and initialized to 0 globally */
struct atoms {
	int atom_index;					/* backreference index */
	int atom_new;						/* new open bracket found */
	int atom_complete;			/* closing bracket encountered */
	int wi[100];						/* array of inexes in atoms[] to be written */
	int li;									/* last index in wi; start from index of 0 */
};

extern struct atoms a;
//
//
struct char_st { 
	char 	p;		/* previous */
	char 	c;		/* current */
	char 	f;		/* following */
};

extern struct char_st cs;


struct mtchfl {
	int np;						/* next pattern */
	int  repeat_pattern_match;			/* repeat pattern  */
	char repetition_modifier;				/* repeatition character */
	char anchor;			/* ^ $ \< \> */
};

extern struct mtchfl fl;
/* holds values that specifies output formatting */
struct scheme {
	int  full_match;
	int  non_prt;
};

int last_on_line();
int fiw();
int liw();
int anch(char c,struct char_st cs);
int crstat(int fd,int start,int end,int np,int idx);
int eol(int fd);
int lst(int fd);
int lst_or(int fd,int idx);
void ftl(char *msg);
void printable_e(char c,int np);
void *ec_malloc(unsigned int);
void str_h(char *s, int index, int np);
void vscs();
void vsexp(char *e,int ps,char*msg);
void vsps(char *e,int ps);
void redraw(int fd,char *part,int non_prt);
void atom_clear(char **atom);
void atom_wr(char **atom);

