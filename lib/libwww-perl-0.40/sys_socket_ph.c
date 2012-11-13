/* $Id$ */
/* This simple program just prints out a sample sys/socket.ph file --  */
/* useful for those people having problems with perl sockets on SVR4   */

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>

int main() {

     printf("sub AF_INET { %d; }\n", AF_INET);
     printf("sub PF_INET { %d; }\n", PF_INET);
     printf("sub SOCK_DGRAM { %d; }\n", SOCK_DGRAM);
     printf("sub SOCK_STREAM { %d; }\n", SOCK_STREAM);
     printf("%d;\n", 1);
     exit(0);
}
