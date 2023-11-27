
LINKER=x86_64-linux-gnu-ld
#LINKER=x86_64-linux-gnu-gcc
## Linker to use when assembling on x64 Linux machine
#LINKER=ld
LFLAGS=-fPIE
src_asm=gospel.asm
#gospelpaint_asm=gospel_paint.asm
src_test=test.c

.PHONY: all

all: gospel test

gospel: $(src_asm)
	nasm -f elf64 $(src_asm) -o gospel.o && $(LINKER) gospel.o -o $@
#	nasm -f elf64 $(src_asm) -o gospel.o && $(LINKER) $(LFLAGS) gospel.o -o $@
#gospel: $(src_asm)
#	nasm -f bin $(src_asm) -o $@

#gospelpaint: $(gospelpaint_asm)
#	nasm -f elf64 $(gospelpaint_asm) -o gospelpaint.o && $(LINKER) gospelpaint.o -o $@

test: $(src_test)
	x86_64-linux-gnu-gcc -static -o $@ $(src_test)
