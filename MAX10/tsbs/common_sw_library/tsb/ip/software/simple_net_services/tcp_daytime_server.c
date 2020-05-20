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




void HandleDaytimeTCPClient(int clntSocket) {
  char buffer[BUFSIZE] ; // Buffer for echo string
  snprintf(buffer,BUFSIZE,"Aug 13, 2012 10:22 PM");
     ssize_t numBytesSent = send(clntSocket, buffer, strlen(buffer), 0);
    if (numBytesSent < 0)
    {
      DieWithSystemMessage("send() failed");
    }
    else {
		if (numBytesSent != strlen(buffer))
		{
		  DieWithUserMessage("send()", "sent unexpected number of bytes");
		}
    }

  close(clntSocket); // Close client socket
}
int tcp_daytime_server(unsigned int server_port) {


	unsigned int  servPort = server_port; // First arg:  local port

  // Create socket for incoming connections
  int servSock; // Socket descriptor for server
  if ((servSock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
    DieWithSystemMessage("socket() failed");

  // Construct local address structure
  struct sockaddr_in servAddr;                  // Local address
  memset(&servAddr, 0, sizeof(servAddr));       // Zero out structure
  servAddr.sin_family = AF_INET;                // IPv4 address family
  servAddr.sin_addr.s_addr = htonl(INADDR_ANY); // Any incoming interface
  servAddr.sin_port = htons(servPort);          // Local port

  // Bind to the local address
  if (bind(servSock, (struct sockaddr*) &servAddr, sizeof(servAddr)) < 0)
    DieWithSystemMessage("bind() failed");

  for (;;) { // Run forever

  // Mark the socket so it will listen for incoming connections
  if (listen(servSock, MAXPENDING) < 0)
    DieWithSystemMessage("listen() failed");

    struct sockaddr_in clntAddr; // Client address
    // Set length of client address structure (in-out parameter)
    int clntAddrLen = sizeof(clntAddr);

    // Wait for a client to connect
    int clntSock = accept(servSock, (struct sockaddr *) &clntAddr, &clntAddrLen);
    if (clntSock < 0)
      DieWithSystemMessage("accept() failed");

    // clntSock is connected to a client!

    char clntName[INET_ADDRSTRLEN]; // String to contain client address
    if (inet_ntop(AF_INET, &clntAddr.sin_addr.s_addr, clntName,
        sizeof(clntName)) != NULL)
      safe_print(printf("TCP Daytime Server: Handling client %s/%d\n", clntName, ntohs(clntAddr.sin_port)));
    else
      puts("TCP Daytime Server: Unable to get client address");

    HandleDaytimeTCPClient(clntSock); //close is done here
	MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);

  }
  // NOT REACHED
  return 0;
}
