all: disasm

clean:
	rm -f *.o
	rm -f *.a

disasm: disasm.c
	gcc -c -std=c99  -o disasm.o disasm.c
	ar rcs libdisasm.a disasm.o
	#-g --gstabs+
