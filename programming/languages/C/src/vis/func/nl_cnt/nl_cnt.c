/* nl_cnt()					return new lines count within file */
int nl_cnt(int fd) {
	int line;
	int cur;		/* cursor */

	line = 0;
	cur = lseek(fd,0,SEEK_CUR);
	lseek(fd,0,SEEK_SET);
	fflush(stdout);
	//vs(fd,0,0);
	fflush(stdout);
	pause();
	printf("here?");

	printf("%d\n",seek(fd,'\n'));
	//while(seek(fd,'\n'))	
		line++;
	
	lseek(fd,cur,SEEK_SET);
	return line;
}
