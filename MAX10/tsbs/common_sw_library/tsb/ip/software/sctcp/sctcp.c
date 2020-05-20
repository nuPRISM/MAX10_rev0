/******************************************************************************
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
*******************************************************************************                                                                             *
* Date - July 30, 2010                                                        *
* Module - sctcp.c                                                            *
*                                                                             *                                                                             *
******************************************************************************/

/******************************************************************************
 * SCTCP example.
 *
 * Please refer to the System Console TCP Application Note documentation for details
 * on this software example.  See the Nichestack Tutorial for details on how to
 * configure the TCP/IP networking stack and MicroC/OS-II Real-Time Operating System.
 * The System Console TCP Application Note and Nichestack Tutorial are
 * published on the Altera web-site.  See:
 * Start Menu -> All Programs -> Altera -> Nios II EDS 10.0 -> Nios II 10.0
 * Documentation.  Where "10.0" represents the installed Altera software
 * version.  This software example requires at least Altera ACDS version 10.0
 * or later, as the system console TCP master service was first released in that version.
  */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "basedef.h"
/*
 * MicroC/OS-II definitions
 */
#include "includes.h"

/*
 * Nichestack definitions
 */
#include "ipport.h"
#include "tcpport.h"

/*
 * SOPC Builder system definitions
 */
#include "system.h"
#include "sys/alt_irq.h"

/*
 * Use alt_log_printf instead
 * of the heavy-weight printf from C runtime library
 * within interrupt service routines.
 */
#include "sys/alt_log_printf.h"

/*
 * SCTCP definitions
 */
#include "sctcp.h"
#include "sctcp_alt_error_handler.h"

/*
 * Static global structure for holding communication socket data
 */
static SCTCPConn sctcp_conn;

/*
 * Handles to our MicroC/OS-II semaphores for ISR communication with mm_to_st output fifo
 * and st_to_mm input fifo.
 */
OS_EVENT *SCTCPMMToSTOutputFIFOAlmostEmptySem;
OS_EVENT *SCTCPSTToMMInputFIFOAlmostFullSem;
OS_EVENT *SCTCPMMToSTOutputFIFOFullSem;
OS_EVENT *SCTCPSTToMMInputFIFOEmptySem;
OS_EVENT *SCTCPConnectionReceiveSem;
OS_EVENT *SCTCPConnectionSendSem;

/*
 * SCTCP_reset_connection()
 *
 * This routine will, when called, reset our SCTCPConn struct's members
 * to a reliable initial state. Note that we set our socket (FD) number to
 * -1 to easily determine whether the connection is in a "reset, ready to go"
 * state.
 */
void SCTCP_reset_connection(void)
{
  memset(&sctcp_conn, 0, sizeof(SCTCPConn));

  sctcp_conn.fd = -1;
  sctcp_conn.state = READY;
  sctcp_conn.rx_index = 0;
  sctcp_conn.tx_index = 0;

  return;
}


/*
 * SCTCPListenTask()
 *
 * SCTCPListenTask listens for connections from System Console TCP.
 * This MicroC/OS-II thread spins forever after first establishing a listening
 * socket for our SCTCP connection, binding it, and listening. Once setup,
 * it perpetually waits for incoming data to either the listening socket, or
 * (if a connection is active), the SCTCP data socket. When data arrives,
 * the appropriate routine is called to either accept/reject a connection
 * request, or process incoming data.
 */

void SCTCPListenTask(void *pd)
{
   int fd_listen, max_socket;
   int client_length;
   struct sockaddr_in addr;
   struct sockaddr_in client_addr;
   fd_set readfds;

   /*
    * Sockets primer...
    * The socket() call creates an endpoint for TCP of UDP communication. It
    * returns a descriptor (similar to a file descriptor) that we call fd_listen,
    * or, "the socket we're listening on for connection requests" in our SCTCP
    * server example.
    *
    * Traditionally, in the Sockets API, PF_INET and AF_INET is used for the
    * protocol and address families respectively. However, there is usually only
    * 1 address per protocol family. Thus PF_INET and AF_INET can be interchanged.
    * In the case of NicheStack, only the use of AF_INET is supported.
    * PF_INET is not supported in NicheStack.
    */
   if ((fd_listen = socket(AF_INET, SOCK_STREAM, 0)) < 0)
   {
     sctcp_alt_NetworkErrorHandler(SCTCP_EXPANDED_DIAGNOSIS_CODE,"[SCTCPListenTask] Socket creation failed");
   }

   /*
    * Sockets primer, continued...
    * Calling bind() associates a socket created with socket() to a particular IP
    * port and incoming address. In this case we're binding to SCTCP_PORT and to
    * INADDR_ANY address (allowing anyone to connect to us. Bind may fail for
    * various reasons, but the most common is that some other socket is bound to
    * the port we're requesting.
    */
   addr.sin_family = AF_INET;
   addr.sin_port = htons(SCTCP_PORT);
   addr.sin_addr.s_addr = INADDR_ANY;

   if ((bind(fd_listen,(struct sockaddr *)&addr,sizeof(addr))) < 0)
   {
      sctcp_alt_NetworkErrorHandler(SCTCP_EXPANDED_DIAGNOSIS_CODE,"[SCTCPListenTask] Bind failed");
   }

   /*
    * Sockets primer, continued...
    * The listen socket is a socket which is waiting for incoming connections.
    * This call to listen will block (i.e. not return) until someone tries to
    * connect to this port.
    */
   if ((listen(fd_listen,1)) < 0)
   {
     sctcp_alt_NetworkErrorHandler(SCTCP_EXPANDED_DIAGNOSIS_CODE,"[SCTCPListenTask] Listen failed");
   }

   /* At this point we have successfully created a socket which is listening
    * on SCTCP_PORT for connection requests from any remote address.
    */
   SCTCP_reset_connection();

#if SCTCP_DEBUG
   printf("[SCTCPListenTask] SCTCP listening on port %d\n", SCTCP_PORT);
#endif

   while(1)
   {
      /*
      * For those not familiar with sockets programming...
      * The select() call below basically tells the TCPIP stack to return
      * from this call when any of the events I have expressed an interest
      * in happen (it blocks until our call to select() is satisfied).
      *
      * In the call below we're only interested in someone trying to
      * connect to us, a read event as far as select is concerned.
      *
      * The sockets we're interested in are passed in in the readfds
      * parameter, the format of the readfds is implementation dependant
      * Hence there are standard MACROs for setting/reading the values:
      *
      *   FD_ZERO  - Zero's out the sockets we're interested in
      *   FD_SET   - Adds a socket to those we're interested in
      *   FD_ISSET - Tests whether the chosen socket is set
      */
      FD_ZERO(&readfds);
      FD_SET(fd_listen, &readfds);
      max_socket = fd_listen+1;

      if (sctcp_conn.fd != -1)
      {
         FD_SET(sctcp_conn.fd, &readfds);
         if (max_socket <= sctcp_conn.fd)
         {
            max_socket = sctcp_conn.fd+1;
         }
      }

      select(max_socket, &readfds, NULL, NULL, NULL);

      /*
       * If fd_listen (the listening socket we originally created in this thread)
       * is "set" in readfs, then we have an incoming client connection request.
       */
      if (FD_ISSET(fd_listen, &readfds))
      {
         client_length = sizeof(client_addr);
         if ((sctcp_conn.fd = accept(fd_listen, (struct sockaddr *) &client_addr,
                                     &client_length)) < 0)
         {
            sctcp_alt_NetworkErrorHandler(SCTCP_EXPANDED_DIAGNOSIS_CODE,"[SCTCPListenTask] Accept failed");
         }

         /* sctcp_conn is connected to a client! */

         printf("Handling client %s\n", inet_ntoa(client_addr.sin_addr));
         
         /*
          * Send Welcome message to System Console (sprintf() returns number of bytes to send.)
          */

         sctcp_conn.tx_index = sprintf(sctcp_conn.tx_buffer,"SystemConsole MASTER\r\n");
	       send(sctcp_conn.fd, sctcp_conn.tx_buffer, sctcp_conn.tx_index , 0);
  	     sctcp_conn.tx_index = 0;

         TCPChannelMaster(sctcp_conn.fd); 
#if SCTCP_DEBUG
    printf("Returning from TCPChannelMaster function.\n");
#endif

      }
  	MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);

   }  /* while(1) */
}

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
