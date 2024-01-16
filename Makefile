

## Linker to use when cross-compiling on aarch64 Linux machine

LINKER=x86_64-linux-gnu-ld
#LINKER=x86_64-linux-gnu-gcc

## Linker to use when assembling on x64 Linux machine
#LINKER=ld

LFLAGS=-fPIE -fpie -pie
src_asm=gospel.asm
src_test=test.c

.PHONY: all

all: gospel test

gospel: $(src_asm)
	nasm -f elf64 $(src_asm) -o gospel.o && $(LINKER) gospel.o -o $@

test: $(src_test)
	$(LINKER) $(LFLAGS) -o $@ $(src_test)
