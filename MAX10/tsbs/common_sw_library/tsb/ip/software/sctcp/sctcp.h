/******************************************************************************
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
*******************************************************************************
* Date - July 30, 2010                                                        *
* Module - sctcp.h                                                            *
*                                                                             *
******************************************************************************/

/*
 * SCTCP  example.
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
 *
 * Software Design Methodology Note:
 *
 * The naming convention used in the System Console TCP Application Note employs
 * capitalized software module references as prefixes to variables to identify
 * public resources for each software module.
 *
 * The software modules are named and have capitalized variable identifiers as
 * follows:
 *
 * SCTCP    System Console TCP software module
 * OS       Micrium MicroC/OS-II Real-Time Operating System software component
 */

 /* Validate supported Software components specified on system library properties
  * page.
  */
#ifndef __SCTCP_H__
#define __SCTCP_H__

#if !defined (ALT_INICHE)
  #error The Nios II System Console TCP example requires the
  #error NicheStack TCP/IP Stack Software Component. Please see the Nichestack
  #error Tutorial for details on Nichestack TCP/IP Stack - Nios II Edition.
#endif

#ifndef __ucosii__
  #error This Nios II System Console TCP example requires
  #error the MicroC/OS-II Software Component.
#endif

#include "basedef.h"
/*
 * Function Prototypes for TCP Master Channel server.
 */
void TCPChannelMaster( int socket);
int putDataInBuffer(char buff[], char data);
int putHeader(char buff[], char channel);
int putEOF (char  buff[]);
void sendResponse(int socket, unsigned char command, int counter );
void doRead(int socket, unsigned char command, int address, int counter);


/*
 * Task Prototypes:
 *
 * SCTCPListenTask()  - Manages the listen socket connection and processes the System Console commands.
 *
 * SCTCPInitialTask() Initializes Nichestack, and creates network tasks.
 *
 */

void SCTCPListenTask(void *pd);


/*
 * TX & RX buffer sizes for all socket sends & receives in our
 * SCTCP application.
 */
#define SCTCP_RX_BUF_SIZE  1500
#define SCTCP_TX_BUF_SIZE  1500

/*
 * The maximum time that an Ethernet cable can be "down" before sending
 * a disconnect message.
 */
#define   SCTCP_MAX_CABLE_DOWN        	1

/*
 * Handles to our MicroC/OS-II resources. All of the resources beginning with
 * "SCTCP" are declared in file "sctcp.c".
 */

/*
 * Here we declare a structure to manage SCTCP communication for a
 * single connection.
 */
typedef struct SCTCP_SOCKET {
	enum { READY, COMPLETE, CLOSE } state; 
	int fd; 
	int       close; 
	char      rx_buffer[SCTCP_RX_BUF_SIZE];
	INT16U 	  rx_index; /* position we've read up to */
	char      tx_buffer[SCTCP_TX_BUF_SIZE];
	INT16U 	  tx_index; /* position we've written up to */

} SCTCPConn;

#define RCVBUFSIZE 1024
#define SNDBUFSIZE 1024

/*
 * System Console command processing state machine values.
 */
#define ST_SOP 0
#define ST_CHN0 1
#define ST_CHN1 2
#define ST_GET_COMMAND 3
#define ST_GET_EXTRA 4
#define ST_GET_COUNTER 5
#define ST_GET_ADDRESS 6
#define ST_WRITE_BYTE 7
#define ST_WRITE_HW 8
#define ST_WRITE_WORD 9

/*
 * Avalon Streaming Packet Protocol constant defines.  These definitions include descriptions
 * of what the Avalon-ST Bytes to Packets Converter Core does in response to various control byte values.
 */

/*
 * Avalon Streaming Packet Protocol - Start of Packet
 * Drop this byte.  Mark the next payload byte as start of packet by asserting startofpacket signal.
 */
#define AV_ST_PP_SOP	0x7A

/*
 * Avalon Streaming Packet Protocol - End of Packet
 * Drop this byte.  Mark the next payload byte as end of packet by asserting endofpacket signal.
 */
#define AV_ST_PP_EOP	0x7B

/*
 * Avalon Streaming Packet Protocol - Channel Number Indicator
 * Drop this byte.  Take the next non-special character byte as channel number.
 *
 */
#define AV_ST_PP_CHN	0x7C

/*
 * Avalon Streaming Packet Protocol - Escape
 * Drop this escape byte.  Next byte is XORed with 0x20.
 */
#define AV_ST_PP_ESC	0x7D

/*
 * Avalon Streaming Packet Protocol - Command transaction codes
 */

/*
 * Avalon Streaming Packet Protocol - Write, not incrementing address
 */

#define AV_ST_WRITE_NON_INCREMENTING	0x00

/*
 * Avalon Streaming Packet Protocol - Write, incrementing address
 */
#define AV_ST_WRITE_INCREMENTING		0x04

/*
 * Avalon Streaming Packet Protocol - Read, not incrementing address
 */

#define AV_ST_READ_NON_INCREMENTING		0x10

/*
 * Avalon Streaming Packet Protocol - Read, incrementing address
 */
#define AV_ST_READ_INCREMENTING			0x14


/*
 * No Transaction (or invalid transaction)
 */
#define AV_ST_PP_NOT	0x7F


#endif /* __SCTCP_H__ */

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
