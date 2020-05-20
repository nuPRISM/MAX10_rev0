
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

#include <string>

static const int MAXPENDING = 5; // Maximum outstanding connection requests

#define CHARGENMAX 255     /* Longest string to echo */

const std::string Chargen_ASCIISTR("!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz");
const unsigned int chargen_strlength = 72;

std::string get_next_chargen_str() {

int firsttime = 1;
  static std::string current_str_to_send_full(Chargen_ASCIISTR);
  if (!firsttime) {
	  firsttime = 0;
   current_str_to_send_full.insert(current_str_to_send_full.begin(),current_str_to_send_full.at(current_str_to_send_full.length()-1));
   current_str_to_send_full.erase(current_str_to_send_full.length()-1,current_str_to_send_full.length()-1);
  }
  return current_str_to_send_full;

}
int udp_chargen_server(unsigned int chargenServPort) {

	 int sock;                        /* Socket */
	     struct sockaddr_in chargenServAddr; /* Local address */
	     struct sockaddr_in chargenClntAddr; /* Client address */
	     int cliAddrLen;         /* Length of incoming message */
	     char chargenBuffer[CHARGENMAX];        /* Buffer for echo string */
	     int recvMsgSize;                 /* Size of received message */

	     /* Create socket for sending/receiving datagrams */
	     if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
	     	DieWithSystemMessage("UDPchargenServer: socket() failed");

	     /* Construct local address structure */
	     memset(&chargenServAddr, 0, sizeof(chargenServAddr));   /* Zero out structure */
	     chargenServAddr.sin_family = AF_INET;                /* Internet address family */
	     chargenServAddr.sin_addr.s_addr = htonl(INADDR_ANY); /* Any incoming interface */
	     chargenServAddr.sin_port = htons(chargenServPort);      /* Local port */

	     /* Bind to the local address */
	     if (bind(sock, (struct sockaddr *) &chargenServAddr, sizeof(chargenServAddr)) < 0)
	     	DieWithSystemMessage("UDPchargenServer:  bind() failed");

	     for (;;) /* Run forever */
	     {
	         /* Set the size of the in-out parameter */
	         cliAddrLen = sizeof(chargenClntAddr);

	         /* Block until receive message from a client */
	         if ((recvMsgSize = recvfrom(sock, chargenBuffer, CHARGENMAX, 0,
	             (struct sockaddr *) &chargenClntAddr, &cliAddrLen)) < 0)
	         	DieWithSystemMessage("UDPchargenServer: recvfrom() failed");


             std::string response_str = get_next_chargen_str();
             char buffer[CHARGENMAX];
             snprintf(buffer,CHARGENMAX-1,"%s",response_str.c_str());
			 /* Send received datagram back to the client */
			 if (sendto(sock, buffer, strlen(buffer), 0,
				  (struct sockaddr *) &chargenClntAddr, sizeof(chargenClntAddr)) !=  strlen(buffer))
			 {
				DieWithSystemMessage("UDPchargenServer: sendto() sent a different number of bytes than expected");
			 }

	     	MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);

	     }
	     return 0;
}
