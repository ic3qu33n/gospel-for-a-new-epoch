nasm -f elf64 gospel.s -o gospel.o && x86_64-linux-gnu-ld -static gospel.o -o gospel
