#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <dirent.h>
#include <sys/syscall.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>


//Test script for getdents64, used for finding the offset of d_type in dirent struct
//This program is largely based on the sample program on the getdents manpage
// See: https://linux.die.net/man/2/getdents64

#define BUF_SIZE 0x2000

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

//Referencing this StackOverflow answer for this function
// https://stackoverflow.com/a/8465083
char* full_path_file(char* dir, char* file){
	size_t len1 = strlen(dir);
	size_t len2 = strlen(file);
//	printf("Dir: %s", dir);
//	printf("length of pathname dir: %d", len1);
//	printf("filename: %s", file);
	char* fullpath = malloc(len1 + len2 + 1);
	memcpy(fullpath, dir, len1);
	memcpy(fullpath + len1, file, len2 + 1);
	return fullpath;
}


int main(){
	DIR *dir;
	struct linux_dirent *entry;
	int fd, nread, fd_entry, fd_entry_test; //fd for getdents call and number of dirent entries in curr dir
	char buf[BUF_SIZE];
	int entry_pos;
	struct stat sb;
	char* test = "frametest";
	fd_entry_test = open(test, 0x2);
	int fstat_res_test = fstat(fd_entry_test, &sb);
	printf("Stat size: %lld", sb.st_size);
	//mmap();


	close(fd_entry_test);
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
			fd_entry = open(entry->d_name, 0x2);
			//char *dname = "./0";
			//char* filepath = full_path_file(dname, entry->d_name);
			//printf("full filepath %s", filepath);
			//fd_entry = open(filepath, 0x2);
			//int fstatat_res = fstatat(fd_entry, filepath, &sb, 0);
			int fstat_res = fstat(fd_entry, &sb);
			//int stat_res = stat(filepath, &sb);
			//char d_type= *(entry + reclen - 1);
			printf("------------------ \n\n");
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
			printf("Stat size: %lld", sb.st_size);
			entry_pos += reclen;
			close(fd_entry);
		}
	}
	printf("I am the test executable!\n");
	printf("Size of stat struct: %zu\n", sizeof(struct stat));
	printf("Offset of st_size in stat struct: %zu\n", offsetof(struct stat, st_size));
	closedir(dir);
	exit(0);
}
