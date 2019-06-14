#include <stdio.h>
#include <time.h>

int main() {
	struct tm cur_time,*time_ptr;
	long int seconds_since_epoch;

	time_ptr = &cur_time;
	seconds_since_epoch = time(0);
	localtime_r(&seconds_since_epoch,time_ptr);

	printf("time_ptr [0x%016lx]:\t0x%08x\t%d\n",
		(unsigned long int)time_ptr,
		*((unsigned int*)time_ptr),
		*((unsigned int*)time_ptr));

	printf("tm_sec: %d\n",cur_time.tm_sec);
	printf("tm_sec: %d\n",time_ptr->tm_sec);
	printf("tm_sec: %d\n",*((int*)time_ptr));

	printf("sizeof(cur_time.tm_sec): %ld\n",sizeof(cur_time.tm_sec));

	int i;
	char *raw_ptr = (char*)time_ptr;
	printf("sizeof(raw_ptr[0]): %ld\n",sizeof(raw_ptr[0]));

	for(i=0; i < sizeof(int); i++)
		printf("raw_ptr[%d] [0x%016lx]:\t0x%02x\n",
				i,(unsigned long int)&raw_ptr[i],raw_ptr[i]);
	return 0;
}
