/******************************************************************************
* Copyright 2009 Altera Corporation, San Jose, California, USA.             *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
*******************************************************************************
* This is a basic NTP Client example.  The full NTP protocol is not           *
* implemented.  Just enough is done to get the time and set the system clock. *
* The goal of this is to show the basics of a sockets base client.            *
*                                                                             *
* This example uses the sockets interface. A good introduction to sockets     *
* programming is the Unix Network Programming book by Richard Stevens         *
******************************************************************************/

extern "C" {
#include <ctype.h>

/* <stdlib.h>: Contains C "rand()" function. */
#include <stdlib.h>

/* MicroC/OS-II definitions */
#include "includes.h"

/* Simple Socket Server definitions */
#include "simple_socket_server.h"

/* Nichestack definitions */
#include "ipport.h"
#include "tcpport.h"
//#include "smtpfuncs.h"
#include "osport.h"
#include "alt_types.h"
#include "ntp_client.h"

#include "target_clock.h"
#include "ntp_data_gram.h"
	//#include "../../iniche/src/autoip4/upnp.h"
#include "network_utilities.h"
}
#include "basedef.h"
#include <stdio.h>
#include <string>
#include <iostream>
#include <fstream>

/* Error Handler definitions */
#include "alt_error_handler.hpp"

extern "C" {
  #include "my_mem_defs.h"
  #include "mem.h"
}
#include "card_configuration_encapsulator.h"
#include "linnux_utils.h"

extern "C" {
u_long inet_addr(char far * str);

}

/* Define your NTP Server Address */
/* Example: IP Address for time.windows.com is 207.46.197.32 */
/*
#define NTP_IP_ADDR0  207
#define NTP_IP_ADDR1  46
#define NTP_IP_ADDR2  197
#define NTP_IP_ADDR3  32
*/

//here is the address for nist1-lv.ustiming.org
/*
#define NTP_IP_ADDR0  64
#define NTP_IP_ADDR1  250
#define NTP_IP_ADDR2  229
#define NTP_IP_ADDR3  100
*/
/*
#define NTP_IP_ADDR0  128
#define NTP_IP_ADDR1  138
#define NTP_IP_ADDR2  140
#define NTP_IP_ADDR3  44
*/

/*
unsigned int NTP_IP_ADDR0  = 192;
unsigned int NTP_IP_ADDR1  = 168;
unsigned int NTP_IP_ADDR2  = 0;
unsigned int NTP_IP_ADDR3  = 100;
*/


/*
#define NTP_IP_ADDR0  192
#define NTP_IP_ADDR1  168
#define NTP_IP_ADDR2  1
#define NTP_IP_ADDR3  1
*/

extern card_configuration_encapsulator card_configuration;
#define NUM_TICKS 0x1000

#define ntpdebug(x) do { if (NTP_DEBUG) { x; } } while (0)

/* This function is a minimal SNTP Client implementation.  A NTP request
 * is sent and upon receiving a response, the system clock is set.
 */
void NTPTask(void* pd)
{
  int        socket_fd;
  int err;
  struct     sockaddr_in addr;
  ntp_struct ntp_send_data;
  ntp_struct ntp_recv_data;
  alt_u8     *send_buffer;
  alt_u8     *recv_buffer;
  alt_u32    sock_len;
  fd_set     socket_fds;
  int        req_delay = 1; //delay in minutes
  struct timeval timeout = {5, 0}; //timeout in {seconds, microseconds}

  std::string ntp_server_ip_addr	 = card_configuration.Get("network", "ntp_server", DEFAULT_INI_FILE_NTP_SERVER_IP_ADDRESS) ;
  unsigned int NTP_SERVER_ADDR ;
 // unsigned int NTP_IP_ADDR0  = 128;
 // unsigned int NTP_IP_ADDR1  = 138;
 // unsigned int NTP_IP_ADDR2  = 140;
 // unsigned int NTP_IP_ADDR3  = 44;
  struct sockaddr_in sa;

  char* tmpstr = my_mem_strdup(ntp_server_ip_addr.c_str());
  NTP_SERVER_ADDR = inet_addr(tmpstr);
  my_mem_free(tmpstr);


  //unsigned int NTP_SERVER_ADDR   = ((NTP_IP_ADDR0 << 24) | (NTP_IP_ADDR1 << 16) | (NTP_IP_ADDR2 << 8) | (NTP_IP_ADDR3));

  /* The size of addr struct is used several times, so we just get the size once here.*/
  sock_len = sizeof(addr);

  re_init_NTP_server:

  /*Clear all of our data structures*/
  memset (&ntp_send_data, 0, sizeof(ntp_send_data));
  memset (&ntp_recv_data, 0, sizeof(ntp_recv_data));
  memset (&addr, 0, sock_len);

/* NTP has many different data fields, but for the most part a client that is
 * going to request the time from a sever only really needs set two values.  The
 * mode and version number.  We set those values here and then encode the entire
 * ntp_send_data struct to the NTP format.  Because the ntp_send_data_struct
 * has been zero initialized, all other fields will be sent as zeros. To be a
 * full implementation, other values may need to be set.  Functionally this gets
 * us what we want which is simply the time.
 */
  ntp_send_data.version_number = 3;
  ntp_send_data.mode = NTP_CLIENT;

  /* Here we declare our socket. For this example we declare a UDP socket as
   * NTP uses UDP.
   */
  if((socket_fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
  {
  alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[ntp_task] Socket creation failed");
  }

 /* Now we fill information into our sockaddr_in struct about the server we are
   * going to communicate with.  In this case, we are using the AF_INET protocol
   * family.  Port number 123 is used for UDP, and finally we are broadcasting
   * this message to any NTP server.  So the IP address is specified as any.
   */
  addr.sin_family = AF_INET;
  addr.sin_port = htons(NTP_PORT_NUM);
  addr.sin_addr.s_addr = NTP_SERVER_ADDR;

   send_buffer = (alt_u8 *)my_mem_malloc(ACTUAL_NTP_BUFFER_SIZE);
   recv_buffer = (alt_u8 *)my_mem_malloc(ACTUAL_NTP_BUFFER_SIZE);

   memset(send_buffer, 0x0, ACTUAL_NTP_BUFFER_SIZE);
   memset(recv_buffer, 0x0, ACTUAL_NTP_BUFFER_SIZE);


 /* Here we do the communication with the NTP server.  This is a very simple 
   * client architecture.  A request is sent and then a NTP packet is received.
   * The NTP packet received is decoded to the ntp_recv_data structure for easy 
   * access.
   */
  while(1)
  {
    encode_ntp_data(send_buffer, &ntp_send_data);

    FD_ZERO(&socket_fds);

    if(!FD_ISSET(socket_fd, &socket_fds))
    {
      //printf("Sending a NTP packet...\n");
      if((err = sendto(socket_fd, (char *) send_buffer, NTP_BUFFER_SIZE, 0, (struct sockaddr *)&addr, sock_len)) < 0)
      {
      //    alt_NTPErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[ntp_func] Error sending NTP packet:\n");
    	  safe_print(printf("[ntp_func] Error %d sending NTP packet: gonna wait then reinit NTP server, address is (%s)...\n", err, ntp_server_ip_addr.c_str()));
            MyOSTimeDlyHMSM(0,0,LINNUX_NETWORK_RECUPERATION_DELAY_IN_SECONDS,0);
			goto re_init_NTP_server;
      }

      /* set a timeout on the recieve, so we don't lock up on a missed packet */
      FD_SET(socket_fd, &socket_fds);
      select(socket_fd+1, &socket_fds, NULL, NULL, &timeout);
    }

    if(FD_ISSET(socket_fd, &socket_fds))
    {
      if((err = recvfrom(socket_fd, (void *)recv_buffer, ACTUAL_NTP_BUFFER_SIZE, 0, (struct sockaddr *)&addr, (int *) &sock_len)) < 0)
      {

    	  safe_print(printf("[ntp_func] Error %d  receiving NTP packet address is (%s):\n", err, ntp_server_ip_addr.c_str()));
          safe_print(printf("[ntp_func] Error receiving NTP packet: gonna wait then reinit NTP server...\n"));
          MyOSTimeDlyHMSM(0,0,LINNUX_NETWORK_RECUPERATION_DELAY_IN_SECONDS,0);
          goto re_init_NTP_server;
      }

      ntpdebug(printf("[NTP Client] Received a NTP response...\n"););
      decode_ntp_data(recv_buffer, &ntp_recv_data);
      ntpdebug(printf("[NTP Client] Received Timestamp: %lu\n ",ntp_recv_data.recv_timestamp1););
      ntpdebug(printf("[NTP Client] Received UNIX Timestamp: %lu\n ",ntp_recv_data.recv_timestamp1 - NTP_TO_UNIX_TIME););

      setclock(ntp_recv_data.recv_timestamp1);
      ntpdebug(safe_print(std::cout <<"[NTP Client] Current time is: " << get_current_time_and_date_as_string_trimmed() << " " << LINNUX_TIMEZONE_STRING << std::endl;));
    }

    /*
     * For a full implementation of an NTP server, the specification requires that
     * some additional things be done after the first NTP data gram is received.
     * e.g. bind to the server that the NTP data gram came from.  For the sake of
     * simplicity we will not implement those requirements, but set the system clock
     * and request the NTP data "req_delay" minutes from the time we get the first
     * NTP data back.
     */

    ntpdebug(printf("Will send next NTP Request in %d minutes...\n",req_delay););
    OSTimeDlyHMSM(0,req_delay,0,0);


                 if (tcp_ip_services_to_shutdown &  LINNUX_TCPIP_SHUTDOWN_NTP)
   				 {
                	 safe_print(printf("\n\n\nNTP: shutting down NTP socket!\n\n\n"));

   					 t_shutdown(socket_fd,2);//shutdown both read and write
   					 close(socket_fd);//close socket
   					 tcp_ip_services_to_shutdown = (tcp_ip_services_to_shutdown & (~LINNUX_TCPIP_SHUTDOWN_NTP));


   		             MyOSTimeDlyHMSM(0,0,LINNUX_NETWORK_RECUPERATION_DELAY_IN_SECONDS,0);//delay a little bit, give TCP time to recover


   					 if((socket_fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
   					 {
   					    alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[ntp_task] Socket creation failed");
   					 }

   					 /* Now we fill information into our sockaddr_in struct about the server we are
   					   * going to communicate with.  In this case, we are using the AF_INET protocol
   					   * family.  Port number 123 is used for UDP, and finally we are broadcasting
   					   * this message to any NTP server.  So the IP address is specified as any.
   					   */
   					  addr.sin_family = AF_INET;
   					  addr.sin_port = htons(NTP_PORT_NUM);
   					  addr.sin_addr.s_addr = htonl(NTP_SERVER_ADDR);

   					  memset(send_buffer, 0x0, ACTUAL_NTP_BUFFER_SIZE);
   					  memset(recv_buffer, 0x0, ACTUAL_NTP_BUFFER_SIZE);
   				 }

  }
  /* should never get here, but if we do free buffers */
  my_mem_free(send_buffer);
  my_mem_free(recv_buffer);

 return ;

}


/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2009 Altera Corporation, San Jose, California, USA.           *
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




