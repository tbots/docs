int replace_char(char *atoms[],int fd,int st) {
	atom_print(atoms);
	crstat(fd,st,eol(fd),1,0);
	crstat(fd,lseek(fd,0,SEEK_CUR),
	return 0;
}
