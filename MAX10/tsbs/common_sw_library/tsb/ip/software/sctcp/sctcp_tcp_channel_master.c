/*
 * tcp_master_channel.c
 *
 * Implements TCPChannelMaster and its sub functions.
 *
 * Created: July 30, 2010
 */

#include <stdio.h>
#include "includes.h"
#include "io.h"
#include "ipport.h"
#include "tcpport.h"
#include "libport.h"
#include "basedef.h"
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
 * TCPChannelMaster()
 *
 * TCPChannelMaster handles receipt of a System Console command over an 
 * Ethernet socket that conforms to the Avalon Streaming Packet Protocol.
 * It is essentially a state machine, with various states handled in case 
 * statements.
 *
 * Altera Avalon switch fabric cannot handled unaligned accesses.  
 * The syntax for System Console does not prevent the user from specifying
 * a start address that is not aligned on a 4 byte boundary.  Therefore,
 * the data writes are broken up to handle writes that straddle alignment 
 * boundaries, handled by the following 3 states:
 * (ST_WRITE_BYTE, ST_WRITE_HW, and ST_WRITE_BYTE).
 */
 
void TCPChannelMaster(int socket)
{
   char recvBuffer[RCVBUFSIZE];
   int recvMsgSize;
   int i;
   unsigned char current = 0;
   unsigned char command = 0;
   int counter = 0;
   int state = ST_SOP;
   int address = 0;
   int word = 0;
   int orig_counter = 0;
   int loop = 0;
   int eop_received = 0;

   /*
    *  Receive command from System Console over a socket.
    */
   if ((recvMsgSize = recv(socket, recvBuffer, RCVBUFSIZE, 0 )) < 0)
   {
      sctcp_alt_NetworkErrorHandler(SCTCP_EXPANDED_DIAGNOSIS_CODE,"Error receiving from client.\n");
   }

   /*
    * Process received string char by char in a state machine style, 
    * following Altera Avalon Streaming Packet Protocol.
    */
   while (recvMsgSize >0 )
   {
      for (i=0; i<recvMsgSize; i++) 
      {
         current = recvBuffer[i];
         /*
          * Drop end of packets here.  Note it in a variable name eop_received.
          */
         if ( current == AV_ST_PP_EOP ) 
         {
            eop_received = 1;
            continue;
         }

         /*
          * Need to deal with escape over receive buffer boundary
          */
         if ( current == AV_ST_PP_ESC ) 
         {
#if SCTCP_DEBUG
            printf("[TCPChannelMaster] Escape received!\n");
#endif
            current = recvBuffer[++i] ^ 0x20;
         }
         
         switch ( state )
         {
            case ST_SOP:
               eop_received = 0;
               counter = 0;
               command = 0;
               address = 0;
               
               /*
                * Wait for start of packet here
                * If not, just drop
                */
               if (current == AV_ST_PP_SOP ) 
               {
                  state = ST_CHN0;
               }
			   /*Additional checking because 12.0 system console protocol sends CHN ID and CH NO before SOP*/
			   if (current == AV_ST_PP_CHN ) 
               {
                  state = ST_CHN0;
               }
               break;
               
            case ST_CHN0:
               /*
                * Expect AV_ST_PP_CHN here (skip check for speed)
                */
               state = ST_CHN1;
               break;
               
            case ST_CHN1:
				/*
                * Can decipher channel if we want to multiplex.
                * Only a single channel supported in this implementation.
                */
               state = ST_GET_COMMAND;			   
			   break;
               
            case ST_GET_COMMAND:
               command = current;
               state = ST_GET_EXTRA;
               break;
               
            case ST_GET_EXTRA:
               state = ST_GET_COUNTER;
               loop = 1;
               break;
               
            case ST_GET_COUNTER:
               counter = (counter << 8) + current;
               if (loop-- == 0) 
               {
                  state = ST_GET_ADDRESS;
                  loop = 3;
               }
               break;
               
            case ST_GET_ADDRESS:
               address = (address << 8) + current;
               if (loop-- == 0) 
               {
                  if (command == AV_ST_PP_NOT) 
                  {
                     /* 
                      * got a no transaction code - respond accordingly
                      */
                     sendResponse(socket, command, 0);
                     state = ST_SOP;
                  }
                  /*
                   * Execute the read
                   */
                  if ((command == AV_ST_READ_NON_INCREMENTING) ||
							        (command == AV_ST_READ_INCREMENTING) )
                  {
                     doRead(socket, command, address, counter);
                     state = ST_SOP;
                  }
                  /*
                   * For writes, proceed to getting data.
                   */
                  if ((command == AV_ST_WRITE_NON_INCREMENTING) ||
                      (command == AV_ST_WRITE_INCREMENTING) ) 
                  {
                     orig_counter = counter;
                     /*
                      * Depending on the address, or number of bytes
                      * remaining, go to the correct write state
                      */
                     if (counter == 0) 
                     {
                        sendResponse(socket, command, counter);
                        state = ST_SOP;
                     }
                     else if ( (counter == 1) ||
                               ((address % 4) == 1) ||
                               ((address % 4) == 3)) 
                     {
                        state = ST_WRITE_BYTE;
                     }
                     else if ( (counter == 2) || 
                     	         (counter == 3) || 
                     	         ((address %4) == 2)) 
                     {
                        loop = 1;
                        state = ST_WRITE_HW;
                     }
                     /*
                      * Write 4 bytes
                      */
                     else 
                     {
                        loop = 3;
                        state = ST_WRITE_WORD;
                     }
                  }
               }
               break;
               
            /*
             * These three write states (ST_WRITE_BYTE, ST_WRITE_HW, and ST_WRITE_BYTE)
             * get whatever data they need
             * if the buffer runs out, it will block until more data.
             */
            case ST_WRITE_BYTE:
#if SCTCP_DEBUG
               printf("[TCPChannelMaster] writing 1 byte to %x.\n", address);
               printf("[TCPChannelMaster] Byte is %x.\n", current);
               printf("[TCPChannelMaster] Counter is %d.\n", counter);

#endif
               IOWR_8DIRECT(address,0,current);
               if (command == AV_ST_WRITE_INCREMENTING)
               {
                  address++;
               }
               /*
                * if done
                */
               if (--counter == 0) 
               {
               /*
                * number bytes written = orig_counter
                */
                  sendResponse(socket, command, orig_counter );
                  state = ST_SOP;
               }
               /*
                * address should now be even
                * only stay here if there is only 1 byte to write
                */
               else if (counter == 1) 
               {
                  state = ST_WRITE_BYTE;
               }
               else if (counter == 2 || counter == 3 || ((address % 4 ) == 2)) 
               {
                  loop = 1;
                  state = ST_WRITE_HW;
               }
               else 
               {
                  loop = 3;
                  state = ST_WRITE_WORD;
               }
               break;
               
            case ST_WRITE_HW:
               word = (word << 8) + current;
               if (loop-- == 0) 
               {
#if SCTCP_DEBUG
                  printf("[TCPChannelMaster] Writing 2 bytes to %x.\n",address);
                  printf("[TCPChannelMaster] Bytes are %x.\n", word & 0x0000FFFF);
#endif
                  IOWR_16DIRECT(address,0,word & 0x0000FFFF);
                  if (command == AV_ST_WRITE_INCREMENTING)
                  {
                     address = address + 2;
                  }
                  counter = counter - 2;
                  if (counter == 0) 
                  {
                     /*
                      * number bytes written = orig_counter
                      */
                     sendResponse(socket, command, orig_counter  );
                     state = ST_SOP;
                  }
                  /*
                   * address should now be even
                   * only stay here if there is only 1 byte to write
                   */
                  else if (counter == 1) 
                  {
                     state = ST_WRITE_BYTE;
                  }
                  else if (counter == 2 || counter == 3 || 
                 	        ((address % 4 ) == 2)) 
                  {
                     loop = 1;
                     state = ST_WRITE_HW;
                  }
                  else
                  {
                     loop = 3;
                     state = ST_WRITE_WORD;
                  }
               }
               break;
                    
            case ST_WRITE_WORD:
               word = (word << 8) + current;
               if (loop-- == 0)
               {
#if SCTCP_DEBUG
                  printf("[TCPChannelMaster] Writing 4 bytes to %x.\n", address);
                  printf("[TCPChannelMaster] Bytes are %x.\n", word);
#endif
                  IOWR_32DIRECT(address,0,word);
                  if (command == AV_ST_WRITE_INCREMENTING)
                  {
                        address = address + 4;
                  }
                  counter = counter - 4;
                  if (counter == 0) 
                  {
                     /*
                      * number bytes written = orig_counter
                      */
                     sendResponse(socket, command, orig_counter );
                     state = ST_SOP;
                  }
                  /*
                   * address should now be even
                   * only stay here if there is only 1 byte to write
                   */
                  else if (counter == 1) 
                  {
                     state = ST_WRITE_BYTE;
                  }
                  else if (counter == 2 || counter == 3 || ((address % 4 ) == 2)) 
                  {
                     loop = 1;
                     state = ST_WRITE_HW;
                  }
                  else
                  {
                     loop = 3;
                     state = ST_WRITE_WORD;
                  }
               }
               break;
                    
            default:
               state = ST_SOP;
               break;
         }
      }

      MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);

      if ((recvMsgSize = recv(socket, recvBuffer, RCVBUFSIZE, 0)) < 0 )
      {
         printf("Connection lost");
         break;
      }
   }
   close(socket);
}

/*
 * putDataInBuffer()
 *
 * putDataInBuffer() handles loading data into a buffer,
 * escaping any data as needed.
 *
 * This function does not check for memory constraints.
 * Returns the number of bytes put in the buffer: 
 * 1 byte if data is 'normal', 2 bytes if it required escaping.
 */
int putDataInBuffer(char buff[], char data) 
{
	
	/*
	 * If data requires escaping, add escape byte,
	 * and XOR data with 0x20, per Avalon Streaming Packet Protocol.
	 * Data requiring escape: (0x7A (AV_ST_PP_SOP), 0x7B (AV_ST_PP_EOP),
	 *  0x7C (AV_ST_PP_CHN), or 0x7D (AV_ST_PP_ESC))
	 */
	if ((data >= AV_ST_PP_SOP) && (data <= AV_ST_PP_ESC))
    {
		buff[0] = AV_ST_PP_ESC;
		buff[1] = 0x20 ^ data;
		return 2;
	}
	buff[0] = data;
	return 1;
}

/*
 * putHeader()
 *
 * putHeader() simply handles adding the Altera Avalon Packet 
 * Protocol header into the buffer, consisting of start of packet and channel info.
 */

int putHeader(char buff[], char channel) 
{
	buff[0] = AV_ST_PP_SOP;
	buff[1] = AV_ST_PP_CHN;
	return ( 2 + putDataInBuffer(&buff[2], channel));
}

/*
 * putEOP()
 *
 * putEOP() simply adds end of packet into the buffer.
 */
int putEOP (char buff[]) 
{
	buff[0] = AV_ST_PP_EOP;
	return 1;
}

/*
 * sendResponse()
 *
 * sendResponse() handles responses for write and nop commands.
 */
void sendResponse(int socket, unsigned char command, int counter ) 
{
	 /*
	  * Response packet has 3 header bytes + 4 data bytes+ 1 eop byte,
	  * + at most 3 bytes that requires escaping, for a total of 11
	  * maximum bytes, therefore declare sendBuffer with 11 elements.
	  */
    char sendBuffer[11];
    int i=0;

#if SCTCP_DEBUG
    printf("[sendResponse] Called with command %x.\n", command);
#endif

    /*
     * Header
     */
    i += putHeader(&sendBuffer[i], 0);
    i += putDataInBuffer(&sendBuffer[i], command | 0x80);
    i += putDataInBuffer(&sendBuffer[i], 0);
    i += putDataInBuffer(&sendBuffer[i], (counter >> 8 ) & 0x000000FF);
    i += putEOP(&sendBuffer[i]);
    i += putDataInBuffer(&sendBuffer[i], counter & 0x000000FF);
    
    /*
     * Send the complete response packet back to System Console.
     */
    if (send(socket, sendBuffer, i, 0) != i)
    {
        sctcp_alt_NetworkErrorHandler(SCTCP_EXPANDED_DIAGNOSIS_CODE,"[sendResponse] error sending response.");
    }
    
#if SCTCP_DEBUG
    printf("[sendResponse] Done sending response for command %x.\n", command);
#endif
}

/*
 * doRead()
 *
 * doRead() handles responses for read commands.
 * Altera Avalon switch fabric cannot handled unaligned accesses.  
 * The syntax for System Console does not prevent the user from specifying
 * a start address that is not aligned on a 4 byte boundary.  Therefore,
 * the data reads are broken up to handle reads that straddle alignment 
 * boundaries.
 */
void doRead(int socket, unsigned char command, int address, int counter) 
{
   char sendBuffer[SNDBUFSIZE];
   int sendBuffer_index=0;
   unsigned int wordBuf;


   /*
    * Header
    */
   sendBuffer_index += putHeader(&sendBuffer[sendBuffer_index], 0);

   /*
    * Execute read and call putDataInBuffer with read data.
    */
    
   while (counter != 0) 
   {
      /* At most, we're going to put 9 bytes into the
       * sendBuffer at a time.  So we should always check if sendBuffer is close to the limit,
       * and send off the buffer then (and block)
       */
    	if (SNDBUFSIZE - sendBuffer_index < 10) 
    	{
    	   if (send(socket, sendBuffer, sendBuffer_index, 0) != sendBuffer_index)
    	   {
    	      sctcp_alt_NetworkErrorHandler(SCTCP_EXPANDED_DIAGNOSIS_CODE,"[doRead] Error sending from read.");
    	   }
#if SCTCP_DEBUG
         printf("[doRead] Sent %d bytes!\n", sendBuffer_index);
#endif
    	   sendBuffer_index = 0;
    	}
		  if (counter == 1 || (address %4) == 1 || (address %4) ==3) 
		  {
         wordBuf = IORD_8DIRECT(address, 0);
         if (counter == 1) 
         {
             sendBuffer_index += putEOP(&sendBuffer[sendBuffer_index]);
         }
         sendBuffer_index += putDataInBuffer(&sendBuffer[sendBuffer_index], wordBuf & 0x000000FF);
         if (command == AV_ST_READ_INCREMENTING)
         {
            address++;
         }
         counter--;
      }
      else if (counter == 2 || counter == 3 || (address %4) ==  2) 
      {
         wordBuf = IORD_16DIRECT(address, 0);
         sendBuffer_index += putDataInBuffer(&sendBuffer[sendBuffer_index], (wordBuf >> 8) & 0x000000FF);
         if (counter == 2) 
         {
            sendBuffer_index += putEOP(&sendBuffer[sendBuffer_index]);
         }
         sendBuffer_index += putDataInBuffer(&sendBuffer[sendBuffer_index], wordBuf & 0x000000FF);
         if (command == AV_ST_READ_INCREMENTING)
         {
            address = address + 2;
         }
         counter = counter - 2;
      }
      else 
      {
         wordBuf = IORD_32DIRECT(address,0);
         sendBuffer_index += putDataInBuffer(&sendBuffer[sendBuffer_index], (wordBuf >> 24) & 0x000000FF);
         sendBuffer_index += putDataInBuffer(&sendBuffer[sendBuffer_index], (wordBuf >> 16) & 0x000000FF);
         sendBuffer_index += putDataInBuffer(&sendBuffer[sendBuffer_index], (wordBuf >> 8) & 0x000000FF);
         if (counter == 4) {
            sendBuffer_index += putEOP(&sendBuffer[sendBuffer_index]);
         }
         sendBuffer_index += putDataInBuffer(&sendBuffer[sendBuffer_index], wordBuf & 0x000000FF);
         if (command == AV_ST_READ_INCREMENTING)
         {
            address = address + 4;
         }
         counter = counter - 4;
      }
   }

   if (send(socket, sendBuffer, sendBuffer_index, 0) != sendBuffer_index)
   {
      sctcp_alt_NetworkErrorHandler(SCTCP_EXPANDED_DIAGNOSIS_CODE,"[doRead] error sending from read.");
   }
}

