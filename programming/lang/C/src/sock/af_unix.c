/* af_unix.c
 *
 * AF_UNIX socket example.
 */
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>

/* This function reports the error and exits back to the shell: */
static void
bail (const char *on_what) {
	perror(on_what);
	exit(1);
}

int
main(int argc,char **argv,char **envp) {

	struct sockaddr_un adr_unix;	/* AF_UNIX */

	int z;			/* status return code */
	int sck_unix;	/* scoket */
	int len_unix;	/* length */

	const char pth_unix[] = "/tmp/sock"; /* pathname */
	
	/*
	 * Create a AF_UNIX (aka AF_LOCAL) socket:
	 */
	sck_unix = socket(AF_UNIX,SOCK_STREAM,0);	
		/* 
		 * int socket(int domain, int type, int protocol); 
		 *   creates an endpoint for communication and returns a file descriptor that refers to that endpoint; The domain argument specifies a communication domain, 
		 * 	 this selects the protocol family which will be used for communication
		*/

	if(sck_unix == -1)
		bail("socket()");
	
	/* 
	 * Here we remove the pathname for the socket,
	 * in case it existed from a prior run. Ignore errors (it might not exist).
	 */
	unlink(pth_unix);

	/*
	 * Form an AF_UNIX address.
	 */
	memset(&adr_unix,0,sizeof(adr_unix));		/* void *memset(void *s,int c, size_t n); */

	adr_unix.sun_family = AF_UNIX; 

	/* How is it at all valid? */
	strncpy(adr_unix.sun_path, pth_unix, sizeof(adr_unix)); // [sizeof adr_unix.sun_path-1] = 0;	

	len_unix = SUN_LEN(&adr_unix);

	/* 
	 * Bind the address to the socket:
	 */
	z = bind(sck_unix, (struct sockaddr *) &adr_unix, len_unix);
		/* 
		 * int bind(int sockfd,const struct sockaddr *addr,socklen_t addrlen);
		 *	When a socket is created with socket(2), it exists in a name space (address
		 *  family) but has no address asigned to it. bind() assigns the address
		 *  specified by addr to the socket referred to by the file descriptor sockfd.
		 *  addrlen specifies the size, in bytes, of the address structure pointed to by
		 *  addr.
		 */	
	
	if ( z == -1) 
		bail("bind()");
	
	/* 
	 * Display all of our bound sockets:
	 */
	system("netstat -pa -- unix 2> /dev/null | sed -n '/^Active UNIX/,/^Proto/p; /af_unix/p'");

	/*
	 * Close and unink socket path:
	 */
	close(sck_unix);
	unlink(pth_unix);

	return 0;
}
