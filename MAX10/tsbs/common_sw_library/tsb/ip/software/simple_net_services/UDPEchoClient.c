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

char * UDP_ECHO_CLIENT_SERVER_IP = "192.168.1.50";
char* UDP_ECHO_CLIENT_ECHOSTR = "This is the UDP echo client working";
char* UDP_DAYYIME_CLIENT_ECHOSTR = "This is the UDP daytime client working";


#define ECHOMAX 255     /* Longest string to echo */

int send_udp_message(const char *servIP, const char* echoString, int echoServPort, int check_for_reply)
{
	int sock;                        /* Socket descriptor */
	struct sockaddr_in echoServAddr; /* Echo server address */
	struct sockaddr_in fromAddr;     /* Source address of echo */
	unsigned int fromSize;           /* In-out of address size for recvfrom() */
	char echoBuffer[ECHOMAX+1];      /* Buffer for receiving echoed string */
	int echoStringLen;               /* Length of string to echo */
	int respStringLen;               /* Length of received response */

	if ((echoStringLen = strlen(echoString)) > ECHOMAX)  /* Check input length */
				DieWithSystemMessage("UDPEchoClient: Echo word too long");

			/* Create a datagram/UDP socket */
			if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
				DieWithSystemMessage("UDPEchoClient: socket() failed");

			/* Construct the server address structure */
			memset(&echoServAddr, 0, sizeof(echoServAddr));    /* Zero out structure */
			echoServAddr.sin_family = AF_INET;                 /* Internet addr family */
			echoServAddr.sin_addr.s_addr = inet_addr(servIP);  /* Server IP address */
			echoServAddr.sin_port   = htons(echoServPort);     /* Server port */

			/* Send the string to the server */
			if (sendto(sock, echoString, echoStringLen, 0, (struct sockaddr *)
					&echoServAddr, sizeof(echoServAddr)) != echoStringLen)
				DieWithSystemMessage("UDPEchoClient: sendto() sent a different number of bytes than expected");

             if (check_for_reply)
             {
					/* Recv a response */
					fromSize = sizeof(fromAddr);
					if ((respStringLen = recvfrom(sock, echoBuffer, ECHOMAX, 0,
							(struct sockaddr *) &fromAddr, &fromSize)) < 0)
					{
						DieWithSystemMessage("UDPEchoClient: recvfrom() failed");
					}


					if (echoServAddr.sin_addr.s_addr != fromAddr.sin_addr.s_addr)
					{
						safe_print(printf(stderr,"UDPEchoClient: Error: received a packet from unknown source.\n"));
						exit(1);
					}

					/* null-terminate the received data */
					echoBuffer[respStringLen] = '\0';
					safe_print(printf("UDP client, pid = %d, Received: %s\n", (int) OSTCBCur->OSTCBPrio, echoBuffer));    /* Print the echoed arg */
             }
			close(sock);
			return 0;
}


int udp_echo_client(const char *servIP, const char* echoString, int echoServPort)
{


	while (1) {
		send_udp_message(servIP, echoString, echoServPort,1);
		MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);
        usleep(DEFAULT_UDP_ECHO_CLIENT_SLEEP_IN_usec);
	}
	return 0;
	//NOT Reached
}
