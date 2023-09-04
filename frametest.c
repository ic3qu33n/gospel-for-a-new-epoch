#include <stdio.h>
#include <stdlib.h>


int main(){
	FILE* fd=fopen("/dev/fb0", "rw+");
	FILE* drand=fopen("/dev/urandom", "r");
	char rand_bytes[64];
	fread(rand_bytes, 64, 1, drand);
	fwrite(drand, 64, 1, fd);
	//;fclose(fd);
	fclose(drand);
	printf("I am the test executable!\n");
	exit(0);
}
