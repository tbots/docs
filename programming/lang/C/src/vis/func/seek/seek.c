/* seek()				seek till brk encountered */
int seek(int fd,char brk) {
	int i;
	int ret;
	char c;

	for(i=0; (ret = read(fd,&c,1)) > 0; i++) 
		if(c == brk) break;
	if(ret == -1)
		ftl("read");
	return i;
}
