//utility that counts white pixels.
//Accepts raw RGBA input on stdin.

//probably pipe `$ convert <your-file-name.png> -depth 8 rgba:- | whitepcount

#define white 0xFFFFFFFF
#define num_ints 256
#define bufsize (sizeof(int) * num_ints)

#include <unistd.h>
#include <stdio.h>


#ifdef __amd64__ && __linux__
#include <syscall.h>
inline static ssize_t optiread(int fd, void *buf, size_t count){
  register long *number asm ("rax") = SYS_read;
  register long *one asm ("edi") = fd;
  register long *two asm ("rsi") =  buf;
  register long *three asm ("rdx") = count;
  asm volatile ("syscall"
    : "=r" (number)
    : "r" (number),"r"(one),"r"(two),"r"(three)
    : "rcx","r8","r9","r11","r10"
  );
  return (ssize_t) number;
}
#define iread optiread
#else
#define iread read
#endif

unsigned int buf[bufsize];
ssize_t bytesRead;
unsigned long counter;
unsigned int i;

void main(){
  bytesRead = iread(STDIN_FILENO,buf,bufsize);
  while (bytesRead > 0){
    for(i = 0; i < num_ints;i++){
      if (buf[i] == white)
        counter++;
    }
    bytesRead = iread(STDIN_FILENO,buf,bufsize);
  }
  printf("%lu",counter);
}