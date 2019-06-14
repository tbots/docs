/*
 *	Return cursor offset from the start of the line on which cursor is positioned.
 */
#include <sys/types.h>
#include <unistd.h>
#include "defs.h"

int lst_o(int fd) { return lseek(fd,0,SEEK_CUR) - lst(fd); }
