#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

void int_array_dump(int fd[]) {
		printf("fd[0]: %d\n",fd[0]);
		printf("fd[1]: %d\n",fd[1]);
}

int unbuf_wr(char *string) {
	return write(1,string,strlen(string));

}


int main() {
	int fd[2];
	char string[]="c\nb\na\n";
	char readbuffer[100] = {0};
	pid_t	childpid;
	int reason = NULL;

	if(pipe(fd) == -1) {
		perror("pipe");
		exit(1);
	}

	if((childpid = fork()) == -1) {
		perror("fork");
		exit(1);
	}
	
	if(childpid == 0) {
		close(fd[1]);		// close pipe write end
		close(0);
		dup(*fd);
		//dup2(0, fd[0]);
		execlp("sort","sort",NULL);
	}
	else {
		close(fd[0]);
		write(fd[1],string,strlen(string));
	}
	return 0;
}
