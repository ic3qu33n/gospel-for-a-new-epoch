
LINKER=x86_64-linux-gnu-ld
#LINKER=x86_64-linux-gnu-gcc

## Linker to use when assembling on x64 Linux machine
#LINKER=ld

LFLAGS=-fPIE
src_asm=gospel.asm
src_test=test.c

.PHONY: all

all: gospel test

gospel: $(src_asm)
	nasm -f elf64 $(src_asm) -o gospel.o && $(LINKER) gospel.o -o $@

test: $(src_test)
	x86_64-linux-gnu-gcc -o $@ $(src_test)
