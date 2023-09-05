#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>



int main(){
	DIR *dir;
	struct dirent *entry;
	dir=opendir(".");
	if (dir == NULL){
		puts("error opening directory");
	} else {
		while ((entry = readdir(dir)) != NULL) {
			printf(" %s", entry->d_name);
		}
	}
	printf("I am the test executable!\n");
	closedir(dir);
	exit(0);
}
