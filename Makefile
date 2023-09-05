
LINKER=x86_64-linux-gnu-ld
LFLAGS=-static
src_asm=gospel.asm
src_test=test.c

.PHONY: all

all: gospel

gospel: $(src_asm)
	nasm -f elf64 $(src_asm) -o gospel.o && $(LINKER) gospel.o -o $@

test: $(src_test)
	x86_64-linux-gnu-gcc -static -o $@ $(src_test)
