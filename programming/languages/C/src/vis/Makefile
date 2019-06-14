CC=gcc
CFLAGS=-Wall -I.

main: main.o anchor.o crstat.o ec_malloc.o ftl.o
	$(CC) -o main main.o crstat.o ec_malloc.o ftl.o

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

anchor.o: anchor.o
	$(CC) $(CFLAGS) -c anchor.c

crstat.o: crstat.c
	$(CC) $(CFLAGS) -c crstat.c

ec_malloc.o: ec_malloc.c
	$(CC) $(CFLAGS) -c ec_malloc.c

ftl.o: ftl.c
	$(CC) $(CFLAGS) -c ftl_e.c
