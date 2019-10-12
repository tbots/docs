#include <stdio.h>
#include <time.h>

int main(int argc, char *argv[]) {
    time_t seconds_since_epoch;     // 1970-01-01 00:00:00 +0000 (UTC)

    seconds_since_epoch = time(NULL);
    printf("Seconds since epoch: %ld\n",seconds_since_epoch);

    return 0;
}
