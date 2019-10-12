/* Seeks current till the beginning of the new line. */
int seek_nl(int fd) {
	int ret,i;
	char c;
	for(i=0;(ret = read(fd,&c,1)) > 0; i++)
		if(c == '\n')
			break;
	if(ret == -1)
		ftl("read");
	return i;
}
