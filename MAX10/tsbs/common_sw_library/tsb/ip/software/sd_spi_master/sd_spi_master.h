/****************************************************************************
*  Copyright (C) 2012-2013 by Michael Fischer.
*  All rights reserved.
*
*  Redistribution and use in source and binary forms, with or without 
*  modification, are permitted provided that the following conditions 
*  are met:
*  
*  1. Redistributions of source code must retain the above copyright 
*     notice, this list of conditions and the following disclaimer.
*  2. Redistributions in binary form must reproduce the above copyright
*     notice, this list of conditions and the following disclaimer in the 
*     documentation and/or other materials provided with the distribution.
*  3. Neither the name of the author nor the names of its contributors may 
*     be used to endorse or promote products derived from this software 
*     without specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
*  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
*  THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
*  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
*  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
*  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
*  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
*  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
*  SUCH DAMAGE.
*
****************************************************************************
*  History:
*
*  30.08.2012  mifi  First version, tested with an Altera DE1 board.
*  15.08.2013  mifi  The 16 bit access was replaced by 32 bit.
****************************************************************************/
#ifndef ___FATFS_SD_SPI_MASTER_H____
#define ___FATFS_SD_SPI_MASTER_H____

/*=========================================================================*/
/*  DEFINE: All Structures and Common Constants                            */
/*=========================================================================*/

#include "basedef.h"

/*
 * Simple SPI (pio) defines
 */
#define ADDR_TXDATA     0
#define ADDR_RXDATA     4
#define ADDR_CONTROL    8
#define ADDR_STATUS     12

#define CTRL_SSEL       1
#define CTRL_BIT32      2
#define CTRL_LOOP       4 

#define STATUS_DONE     1  


void SELECT();
void DESELECT();
void INIT_CTRL();


#define SPI_TXR      *((volatile unsigned long*)(FATFS_SD_SPI_MASTER_SPI_BASE + ADDR_TXDATA  ))
#define SPI_RXR      *((volatile unsigned long*)(FATFS_SD_SPI_MASTER_SPI_BASE + ADDR_RXDATA  ))
#define SPI_CTRL     *((volatile unsigned long*)(FATFS_SD_SPI_MASTER_SPI_BASE + ADDR_CONTROL ))
#define SPI_SR       *((volatile unsigned long*)(FATFS_SD_SPI_MASTER_SPI_BASE + ADDR_STATUS  ))
#define SPI_SR_DONE  STATUS_DONE

/*=========================================================================*/
/*  DEFINE: Definition of all local Procedures                             */
/*=========================================================================*/
/***************************************************************************/
/*  SetLowSpeed                                                            */
/*                                                                         */
/*  Set SPI port speed to 200 KHz. Provided that the CPU is                */
/*  running with 100 MHz.                                                  */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: none                                                           */
/***************************************************************************/
inline  void SetLowSpeed(void);

/***************************************************************************/
/*  SetHighSpeed                                                           */
/*                                                                         */
/*  Set SPI port speed to 25 MHz. Provided that the CPU is                 */
/*  running with 100 MHz.                                                  */
/*                                                                         */
/*  Note: 25MHz works only with SD cards, MMC need 20MHz max.              */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: none                                                           */
/***************************************************************************/
inline  void SetHighSpeed(void);

/***************************************************************************/
/*  InitDiskIOHardware                                                     */
/*                                                                         */
/*  Here the diskio interface is initialise, in this case the SPI          */
/*  interface of the SAM7S256.                                             */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: none                                                           */
/***************************************************************************/
void InitDiskIOHardware(void);

/***************************************************************************/
/*  Now here comes some macros to speed up the transfer performance.       */
/*                                                                         */
/*            Be careful if you port this part to an other CPU.            */
/*             !!! This part is high platform dependent. !!!               */
/***************************************************************************/

/*
 * Transmit data only, without to store the receive data.
 * This function will be used normally to send an U8.
 */
#define TRANSMIT_U8(_dat)  SPI_TXR = (unsigned long)(_dat);     \
                           while(!(SPI_SR & SPI_SR_DONE));

/*
 * The next function transmit the data "very fast", becasue
 * we do not need to take care of receive data. This function
 * will be used to transmit data in 16 bit mode.
 */
#define TRANSMIT_FAST(_dat) SPI_TXR = (unsigned long)(_dat);     \
                            while(!(SPI_SR & SPI_SR_DONE));
                            
/*
 * RECEIVE_FAST will be used in ReceiveDatablock only.
 */
#define RECEIVE_FAST(_dest)   SPI_TXR = (unsigned long)0xffffffff;     \
                              while( !( SPI_SR & SPI_SR_DONE ) ); \
                              *_dest++  = SPI_RXR;
                           
/***************************************************************************/
/*  Set8BitTransfer                                                        */
/*                                                                         */
/*  Set Data Size of the SPI bus to 8 bit.                                 */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: none                                                           */
/***************************************************************************/
inline  void Set8BitTransfer(void);

/***************************************************************************/
/*  Set32BitTransfer                                                       */
/*                                                                         */
/*  Set Data Size of the SPI bus to 32 bit.                                */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: none                                                           */
/***************************************************************************/
inline  void Set32BitTransfer(void);

/***************************************************************************/
/*  ReceiveU8                                                              */
/*                                                                         */
/*  Send a dummy value to the SPI bus and wait to receive the data.        */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: Data                                                           */
/***************************************************************************/
inline unsigned char ReceiveU8 (void);
inline void ReceiveU32 (unsigned long* dest);
inline void TransmitU32 (unsigned long dat);
/***************************************************************************/
/*  ReceiveDatablock                                                       */
/*                                                                         */
/*  Receive a data packet from MMC/SD card. Number of "btr" bytes will be  */
/*  store in the given buffer "buff". The byte count "btr" must be         */
/*  a multiple of 8.                                                       */
/*                                                                         */
/*  In    : buff, btr                                                      */
/*  Out   : none                                                           */
/*  Return: In case of an error return FALSE                               */
/***************************************************************************/
int ReceiveDatablock(unsigned char * buff, unsigned long btr);

/***************************************************************************/
/*  TransmitDatablock                                                      */
/*                                                                         */
/*  Send a block of 512 bytes to the MMC/SD card.                          */
/*                                                                         */
/*  In    : buff, token (Data/Stop token)                                  */
/*  Out   : none                                                           */
/*  Return: In case of an error return FALSE                               */
/***************************************************************************/
int TransmitDatablock(const unsigned char * buff, unsigned char token);


/***************************************************************************/
/*  GetCDWP                                                                */
/*                                                                         */
/*  Return the status of the CD and WP socket pin.                         */
/*                                                                         */
/*  In    : none                                                           */
/*  Out   : none                                                           */
/*  Return: Data                                                           */
/***************************************************************************/
unsigned long GetCDWP(void);
#endif
/*** EOF ***/
