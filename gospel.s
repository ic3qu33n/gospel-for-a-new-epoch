[bits 64]

section .data

;x64 syscall reference

SYS_READ 		dd 0x0
SYS_WRITE 		db 0x1
SYS_OPEN 		db 0x2
SYS_CLOSE 		db 0x3
SYS_GETDENTS64	db 0x4e


;;
STDOUT			db 0x1

;open() syscall parameter reference 
OPEN_RW			db 0x2
O_RDONLY		db 0x0

struc linux_dirent
	.d_ino			resq 1
	.d_off			resq 1
	.d_reclen		resw 1
	.d_nameq		resb 1
endstruc

;MAX_RDENT_BUF:	db 0x200 dup (?)
MAX_RDENT_BUF	dw 0x200

;;file pointed to by fstat is fd
struc file_stat
	.st_de			resq 1	;ID of dev containing file
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

section .text
global _start
; getdents64 - syscall 0x4e
;; getdents(unsigned int fd, struct linux_dirent *dirent, unsigned int count);
;;rdi == fd
;;rsi == *dirent
;rdx == count
_start:
	push rbp
	mov rsp, rbp
	sub rsp, 600
	mov r14, rsp

_getdirents:
; open - syscall 0x2
;;open(filename, flags, mode);
;;rdi == filename
;;rsi == flags
;rdx == mode
;; returns: fd (in rax, obv)
	push "."
	pop rdi
	xor rsi, rsi 		;no flags
	mov rdx, O_RDONLY	;open read-only
	mov rax, SYS_OPEN
	syscall
	
	mov r9, rax
	
	push r9
	pop rdi
	lea rsi, [r14 + 200] ;r14 + 200 is location on the stack where we'll save our dirent struct
	mov rdx, MAX_RDENT_BUF
	mov rax, SYS_GETDENTS64
	syscall


	mov r8, rax
; close - syscall 0x3
;;close(fd);
;;rdi == fd (file descriptor)
;; returns: 0 on success (-1 on error)

	push r9
	pop rdi
	mov rax, SYS_CLOSE
	syscall

; close - syscall 0x3
;;close(fd);
;;rdi == fd (file descriptor)
;;rsi == const char* buf
;rdx == count (# of bytes to write)
;; returns: 0 on success (-1 on error)
	
	push r8
	pop rsi
	mov rdi, STDOUT
	mov rax, SYS_WRITE
;	mov rdx, MAX_RDENT_BUF
	mov rdx, 10
	syscall

	


;;restore stack to original state
_restore:
	add rsp, 200
	pop rbp
	
;exit
_end:
	xor rdi, rdi
	mov rax, 0x3c ;exit() syscall on x64
	syscall	
