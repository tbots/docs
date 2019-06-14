/*
 * int eof(int fd);
 * 
 * Returns end of file offset index. 
 */
int eof(int fd) {
	int c = lseek(fd,0,SEEK_CUR);		/* remember current cursor offset */
	int e = lseek(fd,0,SEEK_END);		/* seek file to the end and learn last index */
	lseek(fd,c,SEEK_SET);			/* restore initial offset */
	return e;
}
