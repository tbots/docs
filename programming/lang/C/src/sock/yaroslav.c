	/* How is it at all valid? */
	strncpy(adr_unix.sun_path, pth_unix, sizeof(adr_unix)) [sizeof adr_unix.sun_path-1] = 0;	
