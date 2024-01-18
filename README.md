# gospel-for-a-new-epoch    
This is the repository for the PoC vx for my tmp.0ut article     
["u used 2 call me on my polymorphic shell phone, pt. 1 - gospel for a new epoch"](https://tmpout.sh/3/12.html)   
published in tmp.0ut, volume 3  
  
My PoC virus gospel implements the text segment padding infection technique, first introduced by silvio Cesare (silvio) in his articles "Unix Viruses"[1] and "UNIX ELF Parasites and virus" [2].   
gospel is written in x86-64 asm and it infects ELF x86-64 PIE executables on a modern Linux host.  
gospel's file search routines will identify valid target ELF binaries in the current working directory; the search routine is non-recursive. After gospel locates a valid target ELF, it will infect it. The infected file will run the virus payload —   
printing an ASCII art skull drawing to stdout — and then ret to the OEP and run   
the host ELF code.   
  
  
  
************************  
How to assemble gospel:  
************************  
The Makefile in this repo can be used to assemble gospel.  
Alternatively, to assemble gospel, you will need`  
i. nasm  
ii. an x86_64 GNU linker   
  
Note: I used x86_64-linux-gnu-ld on an aarch64 Kali vm:   
Debian 6.5.3-1kali1 (2023-09-19) aarch64 GNU/Linux  
This was a good option for me since I needed a cross-compiler   
toolchain for my dev env, but feel free to use your favorite compatible linker  
  
To assemble, use the following command:  
nasm -f elf64 gospel.asm -o gospel.o && ld gospel.o -o gospel  
  
  
****************************  
How to test gospel locally:  
****************************  
Clone this repo:  
``` git clone https://github.com/ic3qu33n/gospel-for-a-new-epoch.git```  
  
A pre-compiled version of gospel is included in the repo.  
If you want to recompile gospel with your own x86-64 GNU linker, then edit the Makefile  
Change the value of the environment variable $LINKER in the Makefile to your x86_64 linker of choice.  
  
Once you have updated the Makefile to target your linker of choice, recompile gospel from source with the following command:  
```make gospel```  
  
Compile the test binary that is located within the repo (test.c) with the command:  
```make test```  
  
Run the test binary in its original state:  
```./test```  
  
./test should print the following string to stdout:   
"I am the test executable!"  
  
Then run gospel:  
```./gospel```  
  
gospel will infect the test binary  
rerun test to see the virus payload that has been inserted into the host ELF.  
  
Demo video:  
  
  
  
  
  
##References  
  
  
[1] “Unix Viruses,” Silvio Cesare, https://web.archive.org/web/20020604060624/http://www.big.net.au/~silvio/unix-viruses.txt   
[2] “UNIX ELF Parasites and virus,” Silvio Cesare, October 1998 https://ivanlef0u.fr/repo/madchat/vxdevl/vdat/tuunix02.htm   
[3 — same as 1, different URL] “UNIX Viruses” Silvio Cesare, October 1998  
https://ivanlef0u.fr/repo/madchat/vxdevl/vdat/tuunix01.htm   
[4] “The VIT(Vit.4096) Virus,” Silvio Cesare, October 1998  
https://web.archive.org/web/20020207080316/http://www.big.net.au/~silvio/vit.html   
[4a]“VIT Virus: VIT description,” Silvio Cesare, October 1998  
https://web.archive.org/web/20020228014729/http://www.big.net.au/~silvio/vit.txt   
[4b]“VIT Virus: VIT source,” Silvio Cesare, October 1998, https://web.archive.org/web/20020207080316/http://www.big.net.au/~silvio/vit.html (navigate to it from this page; I’m not putting the link to the tarball here so that no one accidentally downloads it. yw.)  
[5] “Shared Library Call Redirection via ELF PLT Infection”, Silvio Cesare, Phrack, Volume 0xa Issue 0x38, 05.01.2000, 0x07[0x10], http://phrack.org/issues/56/7.html#article   
[6] “Getdents.old.att," GitHub, sblip  
https://gist.github.com/jamichaels/fd6bca66879da9ec0efe   
[7] "ASM Tutorial for Linux n' ELF file format", BY LiTtLe VxW, 29A issue #8  
[8] “Linux virus writing tutorial” [v1.0 at xx/12/99], by mandragore, from Feathered Serpents, 29A issue #4  
[9] “Half virus: Linux.A.443,” Pavel Pech (aka TheKing1980), 03/02/2002, 29A issue #6  
[10] “Linux Mutation Engine (source code) [LiME] Version: 0.2.0,” written by zhugejin at Taipei, Taiwan; Date: 2000/10/10, Last update: 2001/02/28, 29A issue #6  
[11] “Win32/Linux.Winux”, by Benny/29A, 29A issue #6  
[12] “Metamorphism in practice or How I made MetaPHOR and what I've learnt”, by The Mental Driller/29A, 29A issue #6  
[13] “Skeksi virus,” elfmaster  
https://github.com/elfmaster/skeksi_virus   
[14]   
https://www.guitmz.com/linux-nasty-elf-virus/   
  
  
  
***   
  
##Misc. Resources/Further Reading:  
  
Phrack Inc., Volume 0x0b, Issue 0x3d, Phile #0x08 of 0x0f  
Devhell Labs and Phrack Magazine present  
“The Cerberus ELF Interface,” mayhem, http://phrack.org/issues/61/8.html  
  
"IA32 Advanced Function Hooking,"   
mayhem, December 08th 2001, Phrack Inc. Volume 0x0b, Issue 0x3a, Phile #0x08 of 0x0e  
http://phrack.org/issues/58/8.html#article  
  
The Xcellerator  
Linux Rootkits: Part 2  
https://xcellerator.github.io/posts/linux_rootkits_02/   
  
“Manually Creating an ELF Executable” https://web.archive.org/web/20140130143820/http://robinhoksbergen.com/papers/howto_elf.html   
  
linux-re-101, michalmalik  
https://github.com/michalmalik/linux-re-101/blob/master/README.md   
  
###Misc references on various asm programming techniques  
  
TMZ’s syscall pages:  
“x64,” syscall.sh, TMZ  
https://x64.syscall.sh/  
  
Linux getdents man page:  
https://man7.org/linux/man-pages/man2/getdents.2.html  
  
Reading dir entries  
“readdir() — Read an entry from a directory," IBM,  
https://www.ibm.com/docs/en/zos/2.3.0?topic=functions-readdir-read-entry-from-directory   
  
  
###Misc references on using structs in asm:  
  
“NASM - Chapter 5: Standard macros”  
https://www.nasm.us/xdoc/2.15/html/nasmdoc5.html  
  
“About declaring and initializing a structure in Fasm assembly”  
https://stackoverflow.com/questions/41929091/about-declaring-and-initializing-a-structure-in-fasm-assembly  
  
“Pointer for the first struct member list in nasm assembly”  
https://stackoverflow.com/questions/23299846/pointer-for-the-first-struct-member-list-in-nasm-assembly  
  
“Nasm - access struct elements by value and by address  
https://stackoverflow.com/questions/57540758/nasm-access-struct-elements-by-value-and-by-address  
  
“Accessing struc members NASM Assembly”  
https://stackoverflow.com/questions/70477162/accessing-struc-members-nasm-assembly  
  
“reading file's content and printing it to stdout in assembly x64”  
https://stackoverflow.com/questions/64498923/reading-files-content-and-printing-it-to-stdout-in-assembly-x64   
