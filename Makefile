
LINKER=x86_64-linux-gnu-ld
LFLAGS=-static
src_asm=gospel.asm


.PHONY: all

all: gospel

gospel: $(src_asm)
	nasm -f elf64 $(src_asm) -o gospel.o && $(LINKER) -static gospel.o -o $@
