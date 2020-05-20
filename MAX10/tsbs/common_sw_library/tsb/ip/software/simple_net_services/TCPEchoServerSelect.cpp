
#include <unistd.h>
#include <ucos_ii.h>
#include <ctype.h>

	/* <stdlib.h>: Contains C "rand()" function. */
#include <stdlib.h>

extern "C" {
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
}

static const int MAXPENDING = 5; // Maximum outstanding connection requests

#include <string>
#include <vector>

std::vector<unsigned> tcp_mutliple_echo_server_port_list;



void Multiple_Echo_Server_HandleTCPClient(int clntSocket) {
  char buffer[BUFSIZE]; // Buffer for echo string

  // Receive message from client
  ssize_t numBytesRcvd = recv(clntSocket, buffer, BUFSIZE, 0);
  if (numBytesRcvd < 0)
    DieWithSystemMessage("HandleTCPClient: recv() failed");

    // Echo message back to client
    ssize_t numBytesSent = send(clntSocket, buffer, numBytesRcvd, 0);
    if (numBytesSent < 0)
      DieWithSystemMessage("Multiple_Echo_Server_HandleTCPClient: send() failed");
    else if (numBytesSent != numBytesRcvd)
      DieWithUserMessage("Multiple_Echo_Server_HandleTCPClient send()", "sent unexpected number of bytes");

    // See if there is more data to receive
    numBytesRcvd = recv(clntSocket, buffer, BUFSIZE, 0);
   if (numBytesRcvd < 0)
      DieWithSystemMessage("Multiple_Echo_Server_HandleTCPClient: recv() failed");


}
int AcceptTCPConnection(int servSock)
{
    int clntSock;                    /* Socket descriptor for client */
    struct sockaddr_in echoClntAddr; /* Client address */
    unsigned int clntLen;            /* Length of client address data structure */

    /* Set the size of the in-out parameter */
    clntLen = sizeof(echoClntAddr);

    /* Wait for a client to connect */
    if ((clntSock = accept(servSock, (struct sockaddr *) &echoClntAddr,
          (int *) &clntLen)) < 0)
    	DieWithSystemMessage("accept() failed");

    /* clntSock is connected to a client! */

    safe_print(printf("tcp_multiple_echo_server: Handling client %s\n", inet_ntoa(echoClntAddr.sin_addr)));

    return clntSock;
}


int CreateTCPServerSocket(unsigned short port)
{
    int sock;                        /* socket to create */
    struct sockaddr_in echoServAddr; /* Local address */

    /* Create socket for incoming connections */
    if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
    	DieWithSystemMessage("CreateTCPServerSocket: socket() failed");

    /* Construct local address structure */
    memset(&echoServAddr, 0, sizeof(echoServAddr));   /* Zero out structure */
    echoServAddr.sin_family = AF_INET;                /* Internet address family */
    echoServAddr.sin_addr.s_addr = htonl(INADDR_ANY); /* Any incoming interface */
    echoServAddr.sin_port = htons(port);              /* Local port */

    /* Bind to the local address */
    if (bind(sock, (struct sockaddr *) &echoServAddr, sizeof(echoServAddr)) < 0)
    	DieWithSystemMessage("CreateTCPServerSocket: bind() failed");

    /* Mark the socket so it will listen for incoming connections */
    if (listen(sock, MAXPENDING) < 0)
    	DieWithSystemMessage("CreateTCPServerSocket: listen() failed");

    return sock;
}

int tcp_multiple_echo_server(long timeout, std::vector<unsigned> port_list)
{
    int *servSock;                   /* Socket descriptors for server */
    int maxDescriptor;               /* Maximum socket descriptor value */
    fd_set sockSet;                  /* Set of socket descriptors for select() */
    struct timeval selTimeout;       /* Timeout for select() */
    int running = 1;                 /* 1 if server should be running; 0 otherwise */
    int noPorts;                     /* Number of port specified on command-line */
    int port;                        /* Looping variable for ports */
    unsigned short portNo;           /* Actual port number */

    noPorts = port_list.size()  ;           /* Number of ports is argument count minus 2 */

    /* Allocate list of sockets for incoming connections */
    servSock = (int *) malloc(noPorts * sizeof(int));
    /* Initialize maxDescriptor for use by select() */
    maxDescriptor = -1;
  
    /* Create list of ports and sockets to handle ports */
    for (port = 0; port < noPorts; port++)
    {
        /* Add port to port list */
        portNo = port_list.at(port);  /* Skip first two arguments */

        /* Create port socket */
        servSock[port] = CreateTCPServerSocket(portNo);

        /* Determine if new descriptor is the largest */
        if (servSock[port] > maxDescriptor)
            maxDescriptor = servSock[port];
    }

    safe_print(printf("Starting TCP multiple echo server...\n"));
    while (running)
    {
    	 /* Zero socket descriptor vector and set for server sockets */
        /* This must be reset every time select() is called */
        FD_ZERO(&sockSet);
        /* Add keyboard to descriptor vector */
        for (port = 0; port < noPorts; port++)
            FD_SET(servSock[port], &sockSet);

        /* Timeout specification */
        /* This must be reset every time select() is called */
        selTimeout.tv_sec = timeout;       /* timeout (secs.) */
        selTimeout.tv_usec = 0;            /* 0 microseconds */

        /* Suspend program until descriptor is ready or timeout */
        if (select(maxDescriptor + 1, &sockSet, NULL, NULL, &selTimeout) == 0)
        {
           // safe_print(printf("tcp_multiple_echo_server: No echo requests for %ld secs...Server still alive\n", timeout));
        }
        else 
        {
            for (port = 0; port < noPorts; port++)
                if (FD_ISSET(servSock[port], &sockSet))
                {
                	MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);
                    safe_print(printf("\n======================\ntcp_multiple_echo_server: Request on port %d:  \n======================\n", (int) port));
                    Multiple_Echo_Server_HandleTCPClient(AcceptTCPConnection(servSock[port]));
                }
        }
        MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);
    }

    /* Close sockets */
    for (port = 0; port < noPorts; port++)
        close(servSock[port]);

    /* Free list of sockets */
    free(servSock);
    safe_print(printf("tcp_multiple_echo_server exiting....\n"));

    while (1) {
    	MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);
    }

   return 0;
}
