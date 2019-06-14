hello: main.o print.o
			 cc -o hello main.o print.o

main.o:	main.c other_headers.h
				@# default command
				cc -c main.c

print.o:	print.c pr.h
				cc -c print.c

clean:
					rm hello *.o
