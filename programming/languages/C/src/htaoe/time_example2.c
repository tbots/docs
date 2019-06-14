#include <stdio.h>
#include <time.h>

void dump_time_struct_bytes(struct tm *time_ptr, int size) {
    int i;
    unsigned char *raw_ptr;		// points to 1 byte == 8 bits == 2 hex

	raw_ptr = (unsigned char*) time_ptr;	// actually have a size of 8 bytes = 64 bits = 16 hex

   	printf("bytes of struct located at 0x%08lx\n",(long unsigned int)time_ptr);
	for(i=0; i < size; i++) {
		printf("0x%02x ",raw_ptr[i]);	// each step will 1 byte == 8 bits == 2 hex
    	if(i%16 == 15)     // Print a new line every 16 bytes.
        	printf("\n");
	}
	printf("\n");
}

int main() {
    long int seconds_since_epoch;
    struct tm current_time, *time_ptr;
    int hour,minute,second, i, *int_ptr;

    seconds_since_epoch = time(0);  // Pass time a null pointer as argument.
    printf("time() - seconds since epoch: %ld\n", seconds_since_epoch);

    time_ptr = &current_time;       // Set time_ptr to the address of
                                    // the current_time struct.

    localtime_r(&seconds_since_epoch,time_ptr);

	hour   = current_time.tm_hour;
	minute = current_time.tm_min;
	second = current_time.tm_sec;

	dump_time_struct_bytes(time_ptr,sizeof(struct tm));

	minute = hour = 0;
	int_ptr = (int*) time_ptr;

printf("sizeof(int_ptr): %ld\n",sizeof(int_ptr));
	for(i=0; i < 3; i++) 
	{
		printf("int_ptr @ 0x%016lx: %d\n", (unsigned long int)int_ptr, *int_ptr);
		int_ptr++;
	}

	return 0;
}
