
LINKER=x86_64-linux-gnu-ld
LFLAGS=-static
src_asm=gospel.asm
gospelpaint_asm=gospel_paint.asm
src_test=test.c

.PHONY: all

all: gospel gospelpaint

gospel: $(src_asm)
	nasm -f elf64 $(src_asm) -o gospel.o && $(LINKER) gospel.o -o $@

gospelpaint: $(gospelpaint_asm)
	nasm -f elf64 $(gospelpaint_asm) -o gospelpaint.o && $(LINKER) gospelpaint.o -o $@

test: $(src_test)
	x86_64-linux-gnu-gcc -static -o $@ $(src_test)
