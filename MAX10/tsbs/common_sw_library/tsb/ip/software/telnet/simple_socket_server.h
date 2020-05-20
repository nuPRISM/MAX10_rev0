/******************************************************************************
* Copyright 2006 Altera Corporation, San Jose, California, USA.             *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
*******************************************************************************                                                                             *
* Date - October 24, 2006                                                     *
* Module - simple_socket_server.h                                             *
*                                                                             *                                                                             *
******************************************************************************/

/* 
 * Simple Socket Server (SSS) example. 
 * 
 * Please refer to the Altera Nichestack Tutorial documentation for details on this 
 * software example, as well as details on how to configure the TCP/IP 
 * networking stack and MicroC/OS-II Real-Time Operating System.  The Altera
 * Nichestack Tutorial, along with the rest of the Nios II documentation is published 
 * on the Altera web-site.  See: 
 * Start Menu -> Programs -> Nios II Development Kit -> Nios II Documentation.
 * In particular, chapter 9 of the Nios II Software Developer's Handbook 
 * describes Ethernet & Network stack.
 * 
 * Software Design Methodology Note:
 * 
 * The naming convention used in the Simple Socket Server Tutorial employs
 * capitalized software module references as prefixes to variables to identify
 * public resources for each software module, while lower-case 
 * variables with underscores indicate a private resource used strictly 
 * internally to a software module.
 * 
 * The software modules are named and have capitalized variable identifiers as
 * follows:
 * 
 * SSS      Simple Socket Server software module  
 * LED      Light Emitting Diode Management software module
 * NETUTILS Network Utilities software module
 * 
 * OS       Micrium MicroC/OS-II Real-Time Operating System software component
 */
 
 /* Validate supported Software components specified on system library properties page.
  */
#ifndef __SIMPLE_SOCKET_SERVER_H__
#define __SIMPLE_SOCKET_SERVER_H__

#include "basedef.h"

#if !defined (ALT_INICHE)
  #error The Simple Socket Server example requires the 
  #error NicheStack TCP/IP Stack Software Component. Please see the Nichestack
  #error Tutorial for details on Nichestack TCP/IP Stack - Nios II Edition,
  #error including notes on migrating applications from lwIP to NicheStack.
#endif

#ifndef __ucosii__
  #error This Simple Socket Server example requires 
  #error the MicroC/OS-II Intellectual Property Software Component.
#endif

#if defined (ALT_LWIP)
  #error The Simple Socket Server example requires the 
  #error NicheStack TCP/IP Stack Software Component, and no longer works
  #error with the lwIP networking stack.  Please see the Altera Nichstack
  #error Tutorial for details on Nichestack TCP/IP Stack - Nios II Edition,
  #error including notes on migrating applications from lwIP to NicheStack.
#endif

/*
 * Task Prototypes:
 * 
 */

void CIN_MONITOR_Task(void *);
void DEVICE_MONITOR_Task(void *);

void SSSCreateTasks();


/* Definition of Task Stacks for tasks not using networking. */



/* 
 *
 *
 *
 * The IP, gateway, and subnet mask address below are used as a last resort
 * if no network settings can be found, and DHCP (if enabled) fails. You can
 * edit these as a quick-and-dirty way of changing network settings if desired.
 * 
 * Default IP addresses are set to all zeros so that DHCP server packets will
 * penetrate secure routers. They are NOT intended to be valid static IPs, 
 * these values are only a valid default on networks with DHCP server. 
 * 
 * If DHCP will not be used, select valid static IP addresses here, for example:
 *           IP: 192.168.1.234
 *      Gateway: 192.168.1.1
 *  Subnet Mask: 255.255.255.0
 */

/* 
 * TX & RX buffer sizes for all socket sends & receives in our sss app
 */
#define SSS_RX_BUF_SIZE  1460
#define SSS_TX_BUF_SIZE  1460

#define MAX_ETHERNET_BUF_MESSAGE_TX_LENGTH_PER_PACKET (SSS_TX_BUF_SIZE-2)
enum SOCKET_STATE_ENUM {READY, IN_PROCESS, COMPLETE, CLOSE};
typedef enum SOCKET_STATE_ENUM SOCKET_STATE;


/*
 * Handles to our MicroC/OS-II resources. All of the resources beginning with 
 * "SSS" are declared in file "simple_socket_server.c".
 */

/*
 * Handle to our MicroC/OS-II Command Queue for sending commands received 
 * on the TCP-IP socket from the SSSSimpleSocketServerTask to the LEDTask.
 */
extern OS_EVENT *SSSLINNUXCINCommandQ;
extern OS_EVENT *SSSLINNUX_TELNET_CIN_CommandQ;
extern OS_EVENT *SSSLINNUX_TELNET_SYSCON_CommandQ;
extern OS_EVENT *SSSLINNUX_TELNET_SYSCON_COUTCommandQ;
extern OS_EVENT *SSSLINNUXCOUTCommandQ;
extern OS_EVENT *SSSLINNUXCommandFeedbackQ;
extern OS_EVENT *SSSLINNUXMemCommCommandQ;
extern OS_EVENT *SSSLINNUXVMEMemCommCommandQ;
extern OS_EVENT *c_SSSLINNUX_TELNET_CIN_CommandQ;
extern OS_EVENT *c_SSSLINNUXCOUTCommandQ;
extern OS_EVENT *c_SSSLINNUXCommandFeedbackQ;

extern OS_EVENT *SSSLINNUXErasedCommandQ;

extern OS_EVENT *LINNUX_DUT_PROCESSOR_CommandFeedbackQ;
extern OS_EVENT *LINNUX_DUT_PROCESSOR_CIN_CommandQ;
extern OS_EVENT *LINNUX_DUT_PROCESSOR_COUT_CommandQ;

extern OS_EVENT *MONITOR_ALL_TELNET_CommandFeedbackQ;
extern OS_EVENT *MONITOR_ALL_TELNET_COUT_CommandQ;

//some semaphores

extern OS_EVENT *LINNUX_Job_Completed_Queue_Semaphore;
extern OS_EVENT *LINNUX_TCL_Job_Queue_Semaphore;
extern OS_EVENT *LINNUX_Strtk_Semaphore;
extern OS_EVENT *DUT_PROC_MEM_COMM_Semaphore;
extern OS_EVENT *DUT_PROC_UART_COMM_Semaphore;

#endif /* __SIMPLE_SOCKET_SERVER_H__ */

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
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
