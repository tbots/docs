void usage(FILE* stream,int exit_code);
void vsps(char *e,int ps,int t);
void vsexp(char *exp,int ps,int t,char *msg);
void vscs(struct char_st cs);
int rcs(int fd);
int fiw();
int liw();
int anch();
void print_word(int fd,char *word,struct scheme fmt);
void step(int fd,char *word,struct scheme fmt,int match);
int re_fdb(int fd,char *pattern,struct scheme fmt,int ms);
