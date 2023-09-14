#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <fcntl.h>


//Test script for getdents64, used for finding the offset of d_type in dirent struct
//This program is largely based on the sample program on the getdents manpage
// See: https://linux.die.net/man/2/getdents64

#define BUF_SIZE 1024

#define handle_error(msg) do { perror(msg); exit(EXIT_FAILURE); } while(0);
//struct linux_dirent {
struct linux_dirent {
    unsigned long  d_ino;     /* Inode number */
    unsigned long  d_off;     /* Offset to next linux_dirent */
    unsigned short d_reclen;  /* Length of this linux_dirent */
    char           d_name[];  /* Filename (null-terminated) */
                        /* length is actually (d_reclen - 2 -
                           offsetof(struct linux_dirent, d_name) */
    /*
    char           pad;       // Zero padding byte
    char           d_type;    // File type (only since Linux 2.6.4;
                              // offset is (d_reclen - 1))
    */

};	
//};

int main(){
	DIR *dir;
	struct linux_dirent *entry;
	int fd, nread; //fd for getdents call and number of dirent entries in curr dir
	char buf[BUF_SIZE];
	int entry_pos;
	/*dir=opendir(".");
	if (dir == NULL){
		puts("error opening directory");
	}*/
	//fd = syscall(open, ".", 0x0 | 0x2);
	fd = open(".", 0x0 | O_DIRECTORY);
	//fd=opendir(".");
	nread=syscall(SYS_getdents64, fd, buf, BUF_SIZE);
	if (fd == -1){
		handle_error("getdents");
		
	} else {
		if (nread == 0){
			exit(0);
		}
		printf("---------nread=%d--------- \n\n", nread);
		while (entry_pos>=0 && entry_pos < nread){
		//while ((entry = readdir(dir)) != NULL) {
			entry= (struct linux_dirent *) (buf + entry_pos);
			long offset = entry->d_off;
			char d_type = *(buf + entry_pos + entry->d_reclen - 1);
			int reclen = entry->d_reclen;
			//char d_type= *(entry + reclen - 1);
			printf(" %s", entry->d_name);
			printf(" %x", d_type);
			printf(" %-10s", (d_type == DT_REG) ? "regular" :
							 (d_type == DT_DIR) ? "directory" :
							 (d_type == DT_FIFO) ? "FIFO" :
							 (d_type == DT_SOCK) ? "socket" : "???"
				);
			//printf(" %1011d", (long long)entry->d_off);
			printf(" %d", entry->d_reclen);
			printf("------------------ \n\n");
			entry_pos += reclen;
		}
	}
	printf("I am the test executable!\n");
	closedir(dir);
	exit(0);
}
