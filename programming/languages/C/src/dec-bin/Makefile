CC  	 = gcc
CFLAGS='-Wall'
SOURCE = dec-bin.c binary_print.c indent.c

dec-bin: $(SOURCE)

$(SOURCE) : 
	ln -s ../binary_print/binary_print.c 
	ln -s ../indent/indent.c 

.PHONY : clean

clean:
	rm binary_print.c
	rm indent.c 
