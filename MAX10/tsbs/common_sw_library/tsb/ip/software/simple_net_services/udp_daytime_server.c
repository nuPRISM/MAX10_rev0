#include <unistd.h>
#include <string.h>
#include <ucos_ii.h>
#include <ctype.h>
	/* <stdlib.h>: Contains C "rand()" function. */
#include <stdlib.h>

	/* MicroC/OS-II definitions */
#include "includes.h"

	/* Simple Socket Server definitions */
#include "basedef.h"

	/* Nichestack definitions */
#include "ipport.h"
#include "tcpport.h"
//#include "smtpfuncs.h"
	//#include "../../iniche/src/autoip4/upnp.h"
#include "my_mem_defs.h"
#include "mem.h"
#include "Practical.h"

static const int MAXPENDING = 5; // Maximum outstanding connection requests

#define DAYTIMEMAX 255     /* Longest string to echo */


int udp_daytime_server(unsigned int daytimeServPort) {

      int sock;                        /* Socket */
     struct sockaddr_in daytimeServAddr; /* Local address */
     struct sockaddr_in daytimeClntAddr; /* Client address */
     unsigned int cliAddrLen;         /* Length of incoming message */
     char daytimeBuffer[DAYTIMEMAX];        /* Buffer for echo string */
     int recvMsgSize;                 /* Size of received message */

     /* Create socket for sending/receiving datagrams */
     if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
     	DieWithSystemMessage("UDPdaytimeServer: socket() failed");

     /* Construct local address structure */
     memset(&daytimeServAddr, 0, sizeof(daytimeServAddr));   /* Zero out structure */
     daytimeServAddr.sin_family = AF_INET;                /* Internet address family */
     daytimeServAddr.sin_addr.s_addr = htonl(INADDR_ANY); /* Any incoming interface */
     daytimeServAddr.sin_port = htons(daytimeServPort);      /* Local port */

     /* Bind to the local address */
     if (bind(sock, (struct sockaddr *) &daytimeServAddr, sizeof(daytimeServAddr)) < 0)
     	DieWithSystemMessage("UDPdaytimeServer:  bind() failed");

     for (;;) /* Run forever */
     {
         /* Set the size of the in-out parameter */
         cliAddrLen = sizeof(daytimeClntAddr);

         /* Block until receive message from a client */
         if ((recvMsgSize = recvfrom(sock, daytimeBuffer, DAYTIMEMAX, 0,
             (struct sockaddr *) &daytimeClntAddr, &cliAddrLen)) < 0)
         	DieWithSystemMessage("UDPdaytimeServer: recvfrom() failed");
         safe_print(printf("UDP Daytime Server: Handling client %s, port = %d\n", inet_ntoa(daytimeClntAddr.sin_addr), (int) daytimeClntAddr.sin_port));

         char buffer[BUFSIZE] ; // Buffer for daytime string
         snprintf(buffer,BUFSIZE-1,"Aug 13, 2012 10:22 PM");
		 /* Send received datagram back to the client */
		 if (sendto(sock, buffer, strlen(buffer), 0,
			  (struct sockaddr *) &daytimeClntAddr, sizeof(daytimeClntAddr)) !=  strlen(buffer))
		 {
			DieWithSystemMessage("UDPdaytimeServer: sendto() sent a different number of bytes than expected");
		 }

     	MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);

     }
     return 0;
  // NOT REACHED
}
