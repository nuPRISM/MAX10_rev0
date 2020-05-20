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


#define ECHOMAX 255     /* Longest string to echo */

int udp_echo_server(int echoServPort)
{
    int sock;                        /* Socket */
    struct sockaddr_in echoServAddr; /* Local address */
    struct sockaddr_in echoClntAddr; /* Client address */
    unsigned int cliAddrLen;         /* Length of incoming message */
    char echoBuffer[ECHOMAX];        /* Buffer for echo string */
    int recvMsgSize;                 /* Size of received message */

    /* Create socket for sending/receiving datagrams */
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
    	DieWithSystemMessage("UDPEchoServer: socket() failed");

    /* Construct local address structure */
    memset(&echoServAddr, 0, sizeof(echoServAddr));   /* Zero out structure */
    echoServAddr.sin_family = AF_INET;                /* Internet address family */
    echoServAddr.sin_addr.s_addr = htonl(INADDR_ANY); /* Any incoming interface */
    echoServAddr.sin_port = htons(echoServPort);      /* Local port */

    /* Bind to the local address */
    if (bind(sock, (struct sockaddr *) &echoServAddr, sizeof(echoServAddr)) < 0)
    	DieWithSystemMessage("UDPEchoServer:  bind() failed");
  
    for (;;) /* Run forever */
    {
        /* Set the size of the in-out parameter */
        cliAddrLen = sizeof(echoClntAddr);

        /* Block until receive message from a client */
        if ((recvMsgSize = recvfrom(sock, echoBuffer, ECHOMAX, 0,
            (struct sockaddr *) &echoClntAddr, &cliAddrLen)) < 0)
        	DieWithSystemMessage("UDPEchoServer: recvfrom() failed");

        safe_print(printf("UDP Echo Server: Handling client %s, port = %d\n", inet_ntoa(echoClntAddr.sin_addr), (int) echoClntAddr.sin_port));

        /* Send received datagram back to the client */
        if (sendto(sock, echoBuffer, recvMsgSize, 0, 
             (struct sockaddr *) &echoClntAddr, sizeof(echoClntAddr)) != recvMsgSize)
        {
        	DieWithSystemMessage("UDPEchoServer: sendto() sent a different number of bytes than expected");
        }

    	MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);

    }
    return 0;
    /* NOT REACHED */
}
