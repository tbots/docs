#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main() {
	int fd = open("vagif",O_RDWR );

	printf("fd: %d\n",fd);
	return 0;
}
