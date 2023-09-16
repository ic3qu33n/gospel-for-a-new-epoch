#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <linux/fb.h>

/*******************************************************************************
*	
*	Test program to write directly to the Linux framebuffer using fb device
* 	Code adapted from the tutorials at: http://betteros.org/tut/graphics1.php
*
*******************************************************************************/

uint32_t pixel_color(uint8_t r, uint8_t g, uint8_t b, struct fb_var_screeninfo *vinfo){
	return (r<<vinfo->red.offset) | (g<<vinfo->green.offset) | (b<<vinfo->blue.offset);
}


int main(){

//	struct timespec remaining, request = {1, 60};
	useconds_t delay=100000;

	struct fb_fix_screeninfo finfo;
	struct fb_var_screeninfo vinfo;
	//FILE* fd=fopen("/dev/fb0", "rw+");
	
	//open frame buffer device
	int fd_fb0 = open("/dev/fb0", O_RDWR);
	if (fd_fb0 == -1){
		printf("Error opening framebuffer device.. rip");	
	}
	printf("Framebuffer device successfully opened!");	
	
	ioctl(fd_fb0, FBIOGET_VSCREENINFO, &vinfo);
	
	vinfo.grayscale=0;
	vinfo.bits_per_pixel=32;

	ioctl(fd_fb0, FBIOPUT_VSCREENINFO, &vinfo);
	ioctl(fd_fb0, FBIOGET_VSCREENINFO, &vinfo);
	
	ioctl(fd_fb0, FBIOGET_FSCREENINFO, &finfo);
	

	long screensize = vinfo.yres_virtual * finfo.line_length;
	
	int *fbp = mmap(0, screensize, PROT_READ | PROT_WRITE, MAP_SHARED, fd_fb0, 0);
	int x,y;	

	for (x=0; x<vinfo.xres;x++){
		for (y=0; y<vinfo.yres; y++) {
			long location = (x + vinfo.xoffset) * (vinfo.bits_per_pixel/8) + (y+vinfo.yoffset) * finfo.line_length;
			*((uint32_t*)(fbp + location)) = pixel_color(0xFF, 0x0, 0xFF, &vinfo);
		}
		//usleep(delay);
	}
	//FILE* drand=fopen("/dev/urandom", "r");
	//char rand_bytes[64];
	//fread(rand_bytes, 64, 1, drand);
	//fwrite(drand, 64, 1, fd);
	//;fclose(fd);
	//fclose(drand);
	

	//printf("I am the test executable!\n");
	
	//nanosleep(&remaining, &request);
	usleep(delay);
	return 0;
}
