/*
 * terasic_linnux_driver.cpp
 *
 *  Created on: Apr 19, 2011
 *      Author: linnyair
 */

#include "terasic_linnux_driver.h"
//#include "linnux_testbench_constants.h"
#include "fatfs_linnux_api.h"
#include <alt_types.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>
#include <sys/alt_alarm.h>
#include <system.h>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <time.h>
#include "basedef.h"
#include "cpp_to_c_header_interface.h"
extern "C" {
   #include "my_mem_defs.h"
   #include "mem.h"
#include <xprintf.h>

}

using namespace std;
#ifdef DEBUG_SDCARD
//    #define SDCARD_DEBUG(x)    {DEBUG(("[SD]")); DEBUG(x);}
#define SDCARD_DEBUG(x)    do { xprintf x; } while(0)
#else
    #define SDCARD_DEBUG(x)
#endif


#define DEBUG_SDCARD_HEX //DEBUG_HEX_PRINTF


alt_u8 gszCSD[17];
alt_u8 gszCID[17];
terasic_bool gbActive = FALSE;

//-------------------------------------------------------------------------
void Ncr(void);
void Ncc(void);
alt_u8 send_cmd(alt_u8 *in);
alt_u8 send_cmd(alt_u8 *);
alt_u8 response_R(alt_u8 s);
//-------------------------------------------------------------------------
alt_u8 read_status;
alt_u8 response_buffer[20];
alt_u8 RCA[2];
alt_u8 cmd_buffer[5];
const alt_u8 cmd0[5]   = {0x40,0x00,0x00,0x00,0x00};
const alt_u8 cmd55[5]  = {0x77,0x00,0x00,0x00,0x00};
const alt_u8 cmd2[5]   = {0x42,0x00,0x00,0x00,0x00};
const alt_u8 cmd3[5]   = {0x43,0x00,0x00,0x00,0x00};
const alt_u8 cmd7[5]   = {0x47,0x00,0x00,0x00,0x00};
const alt_u8 cmd9[5]   = {0x49,0x00,0x00,0x00,0x00};
const alt_u8 cmd10[5]  = {0x4a,0x00,0x00,0x00,0x00};  // richard add
const alt_u8 cmd16[5]  = {0x50,0x00,0x00,0x02,0x00}; // block length = 512 byte
const alt_u8 cmd17[5]  = {0x51,0x00,0x00,0x00,0x00};
const alt_u8 cmd24[5]  = {0x58,0x00,0x00,0x00,0x00};  // Nadav add - Write block
const alt_u8 acmd6[5]  = {0x46,0x00,0x00,0x00,0x02};  // bus width, 4-bits
const alt_u8 acmd41[5] = {0x69,0x0f,0xf0,0x00,0x00};  // 0x76 = 41 + 0x40
const alt_u8 acmd42[5] = {0x6A,0x00,0x00,0x00,0x00};  // richard add, SET_CLR_CARD_DETECT
const alt_u8 acmd51[5] = {0x73,0x00,0x00,0x00,0x00};
//-------------------------------------------------------------------------
void Ncr(void)
{
  SD_CMD_IN;
  SD_CLK_LOW;
  SD_CLK_HIGH;
  SD_CLK_LOW;
  SD_CLK_HIGH;
}
//-------------------------------------------------------------------------
void Ncc(void)
{
  int i;
  for(i=0;i<8;i++)
  {
    SD_CLK_LOW;
    SD_CLK_HIGH;
  }
}




void dump_CSD(alt_u8 szCSD[]){
   SDCARD_DEBUG(("SD-CARD CSD:...\r\n"));

}

void dump_CID(alt_u8 szCID[]){
    int i = 1;
   SDCARD_DEBUG(("SD-CARD CID:\r\n"));
   SDCARD_DEBUG(("  Manufacturer ID(MID):%02Xh\r\n", szCID[i+0]));
   SDCARD_DEBUG(("  OEM/Application ID(OLD):%02X%02Xh\r\n", szCID[i+2], szCID[i+1]));
   SDCARD_DEBUG(("  Product Name(PNM):%C%C%C%C%C\r\n", szCID[i+3], szCID[i+4], szCID[i+5], szCID[i+6], szCID[i+7]));
   SDCARD_DEBUG(("  Product Revision:%02Xh\r\n", szCID[i+8]));
   SDCARD_DEBUG(("  Serail Number(PSN):%02X%02X%02X%02Xh\r\n", szCID[i+9], szCID[i+10], szCID[i+11], szCID[i+12]));
   SDCARD_DEBUG(("  Manufacturere Date Code(MDT):%01X%02Xh\r\n", szCID[i+13] & 0x0F, szCID[i+14]));
   SDCARD_DEBUG(("  CRC-7 Checksum(CRC7):%02Xh\r\n", szCID[i+15] >> 1));

}

terasic_bool SD_GetCSD(alt_u8 szCSD[], alt_u8 len){
    if (!gbActive)
        return FALSE;
    if (len > 16)
        len = 16;
    memmove(szCSD, &gszCSD[1], len);
    return TRUE;
}

terasic_bool SD_GetCID(alt_u8 szCID[], alt_u8 len){
    if (!gbActive)
        return FALSE;
    if (len > 16)
        len = 16;
    memmove(szCID, &gszCID[1], len);
    return TRUE;
}





//-------------------------------------------------------------------------
terasic_bool SD_card_init(void)
{
    alt_u8 x,y;

    // richard add:  pull-high DAT3 to enter SD mode?
#ifndef SD_4BIT_MODE
  //  SD_DAT3_OUT;
   // SD_DAT3_HIGH;
#endif
    SDCARD_DEBUG(("--- Power On, Card Identification Mode, Idle State\r\n"));
    SDCARD_DEBUG(("default 1-bit mode\r\n"));

    c_low_level_system_usleep(74*10);

    SD_CMD_OUT;
    SD_DAT_IN;
    SD_CLK_HIGH;
    SD_CMD_HIGH;
    SD_DAT_LOW;

    gbActive = FALSE;
    read_status=0;
    for(x=0;x<40;x++)
        Ncr();
    for(x=0;x<5;x++)
        cmd_buffer[x]=cmd0[x];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("CMD0[GO_IDLE_STATE]\r\n"));
    do
    {

    	   SD_DAT_OUT;
    	      SD_DAT_LOW;
    	      SD_DAT_OUT;
    	      SD_DAT_HIGH;
    	      SD_DAT_OUT;
        // issue cmd55 & wait response
      for(x=0;x<40;x++);
        Ncc();
      for(x=0;x<5;x++)
        cmd_buffer[x]=cmd55[x];
      y = send_cmd(cmd_buffer);

      SDCARD_DEBUG(("CMD55[APP_CMD]\r\n"));
      Ncr();
      if(response_R(1)>1){ //response too long or crc error
        SDCARD_DEBUG(("response error for CMD55\r\n"));
        return FALSE;
      }
      Ncc();

        // issue acmd41 & wait response
      for(x=0;x<5;x++)
        cmd_buffer[x]=acmd41[x];
      y = send_cmd(cmd_buffer);
      SDCARD_DEBUG(("ACMD41[SD_APP_OP_COND]\r\n"));
        Ncr();
    } while(response_R(3)==1);


    // issue cmd2 & wait response
    Ncc();
    for(x=0;x<5;x++)
        cmd_buffer[x]=cmd2[x];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("CMD2[ALL_SEND_CID]\r\n"));
    Ncr();
    if(response_R(2)>1){
        SDCARD_DEBUG(("CMD2 fail\r\n"));
        return FALSE;
    }

    SDCARD_DEBUG(("--- Power On, Card Identification Mode, Identification State\r\n"));

    // issue cmd3 & wait response, finally get RCA
    Ncc();
    for(x=0;x<5;x++)
        cmd_buffer[x]=cmd3[x];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("CMD3[SEND_RELATIVE_ADDR]\r\n"));
    Ncr();
    if(response_R(6)>1){
        SDCARD_DEBUG(("CMD3 fail\r\n"));
        return FALSE;
    }

    RCA[0]=response_buffer[1];
    RCA[1]=response_buffer[2];



    // above is Card Identification Mode
    //*************** now, wer are in Data Transfer Mode ********************************/
    //### Standby-by state in Data-transfer mode

    SDCARD_DEBUG(("--- enter data-transfer mode, Standy-by stater\n"));
    // issue cmd9 with given RCA & wait response
    Ncc();
    for(x=0;x<5;x++)
        cmd_buffer[x]=cmd9[x];
    cmd_buffer[1] = RCA[0];
    cmd_buffer[2] = RCA[1];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("CMD9[SEND_CSD]\r\n"));
    Ncr();
    if(response_R(2)>1){
        SDCARD_DEBUG(("CMD9 fail\r\n"));
        return FALSE;
    }
    memmove(gszCSD,&response_buffer[0] , sizeof(gszCSD));    // richard add
    //DEBUG_SDCARD("\r\nCSD Hex:\r\n");
    //DEBUG_SDCARD_HEX(gszCSD, sizeof(gszCSD));
    //dump_CSD(gszCSD);

    // richard add  (query card identification)
    Ncc();
    for(x=0;x<5;x++)
        cmd_buffer[x]=cmd10[x];
    cmd_buffer[1] = RCA[0];
    cmd_buffer[2] = RCA[1];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("CMD10[SEND_CID]\r\n"));
    Ncr();
    if(response_R(2)>1){
        SDCARD_DEBUG(("CMD10 fail\r\n"));
        return FALSE;
    }
    memmove(gszCID,&response_buffer[0] , sizeof(gszCID));    // richard add
    //DEBUG_SDCARD("\r\nCID Hex:\r\n");
    //DEBUG_SDCARD_HEX(gszCID, sizeof(gszCID));
    dump_CID(gszCID);

    // can issue cmd 4, 9, 10, in (stdandby state)

    // issue cmd9 with given RCA & wait response





    // richard: issue cmd7 to enter transfer state
    // cmd7: toggle between Standy-by and Trasfer State
    Ncc();
    for(x=0;x<5;x++)
        cmd_buffer[x]=cmd7[x];
    cmd_buffer[1] = RCA[0];
    cmd_buffer[2] = RCA[1];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("CMD7[SELECT/DESELECT_CARD], select card\r\n"));
    Ncr();
    if(response_R(1)>1){
        SDCARD_DEBUG(("CMD7 fail\r\n"));
        return FALSE;
    }

    //### Transfer state in Data-transfer mode
    SDCARD_DEBUG(("--- enter data-transfer mode, Transfer state\r\n"));






    // issue cmd16 (select a block length) & wait response
    Ncc();
    for(x=0;x<5;x++)
        cmd_buffer[x]=cmd16[x];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("CMD16[SET_BLOCK_LENGTH], 512 bytes\r\n"));
    Ncr();
    if(response_R(1)>1){
        SDCARD_DEBUG(("CMD16 fail\r\n"));
        return FALSE;
    }

#ifdef SD_4BIT_MODE
    // richard add: set bus width
    // Note. This command is valid only in "transfer state", i.e. after CMD7 is issued


    Ncc();
    for(x=0;x<5;x++)
        cmd_buffer[x]=cmd55[x];
    cmd_buffer[1] = RCA[0]; // note. remember to fill RCA
    cmd_buffer[2] = RCA[1];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("ACM55[APP_CMD]\r\n"));
    Ncr();
    if(response_R(1)>1){
        SDCARD_DEBUG(("CMD55 fail\r\n"));
        return FALSE;
    }


    Ncc();
    for(x=0;x<5;x++)
        cmd_buffer[x]=acmd6[x];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("ACMD6[SET_BUS_WIDTH], 4-bit\r\n"));
    Ncr();
    if(response_R(1)>1){
        SDCARD_DEBUG(("ACMD6 fail\r\n"));
        return FALSE;
    }


    //
    Ncc();
    for(x=0;x<5;x++)
        cmd_buffer[x]=cmd55[x];
    cmd_buffer[1] = RCA[0]; // note. remember to fill RCA
    cmd_buffer[2] = RCA[1];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("ACM55[APP_CMD]\r\n"));
    Ncr();
    if(response_R(1)>1){
        SDCARD_DEBUG(("CMD55 fail\r\n"));
        return FALSE;
    }


    Ncc();
    for(x=0;x<5;x++)
        cmd_buffer[x]=acmd42[x];
    y = send_cmd(cmd_buffer);
    SDCARD_DEBUG(("ACMD42[SET_CLR_CARD_DETECT], 4-bit\r\n"));
    Ncr();
    if(response_R(1)>1){
        SDCARD_DEBUG(("ACMD42 fail\r\n"));
        return FALSE;
    }



#endif

    SDCARD_DEBUG(("SD_card_init success\r\n"));
    read_status =1; //sd card ready
    gbActive = TRUE;
    return TRUE;
}


terasic_bool SD_read_block(alt_u32 block_number, alt_u8 *buff)
{
  // buffer size muse be 512 byte
  alt_u8 c=0;
  alt_u32  i,addr; //j,addr;
  int terasic_try = 0;
  const int max_try = 20000;
  unsigned long long end_time, start_time;
  unsigned long long total_runtime;
  double double_total_runtime;

  char start_TS[50],end_TS[50],total_TS[50];

    // issue cmd17 for 'Single Block Read'. parameter: block address
    {
      Ncc();
      addr = block_number * 512;
      cmd_buffer[0] = cmd17[0]; // CMD17: Read Single Block
      cmd_buffer[1] = (addr >> 24 ) & 0xFF; // MSB
      cmd_buffer[2] = (addr >> 16 ) & 0xFF;
      cmd_buffer[3] = (addr >> 8 ) & 0xFF;
      cmd_buffer[4] = addr & 0xFF; // LSB
      send_cmd(cmd_buffer);
      Ncr();
    }


    start_time=low_level_system_timestamp();

    // get response
    while(1)
    {
      SD_CLK_LOW;
      SD_CLK_HIGH;
//      if(!(SD_TEST_DAT))
      if((SD_TEST_DAT & 0x01) == 0x00) // check bit0
        break;
      if (terasic_try++ > max_try)
        return FALSE;

      end_time=low_level_system_timestamp(); if (start_time > end_time) { /* in case of some weird timer wrap */ start_time = end_time; }
      total_runtime = (end_time - start_time);
      if (total_runtime > WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS)
      {
    	  convert_ull_to_string(start_time,start_TS);
    	  convert_ull_to_string(end_time,end_TS);
    	  convert_ull_to_string(total_runtime,total_TS);
          printf("\n[TERASIC_LINNUX_DRIVER][TS_Sec=%lu] SD_read_block: Timed out! start=%s end = %s total=%s\n",low_level_system_timestamp_in_secs(),start_TS,end_TS,total_TS);
          double_total_runtime = ((double) end_time) - ((double) start_time);
          printf("double_total_runtime = %lf  (double) total_runtime = %lf  total_h = %lu total_l = %lu\n",double_total_runtime, (double) total_runtime, (unsigned long) (total_runtime >> 32), (unsigned long) (total_runtime % (1ULL<<32)));
          if (((double)total_runtime) > ((double)WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS))
          {
            return FALSE;
          } else {
        	  printf("Double results are not bigger than watchdog of %lf, continuing!\n",(double)WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS);
          }
      }

    }

    // read data (512byte = 1 block)
    for(i=0;i<512;i++)
    {
      alt_u8 j;
      c = 0; // richard add
#ifdef SD_4BIT_MODE
      for(j=0;j<2;j++)
      {
        SD_CLK_LOW;
        SD_CLK_HIGH;
        c <<= 4;
        c |= (SD_TEST_DAT & 0x0F);
      }
#else
      for(j=0;j<8;j++)
      {
        SD_CLK_LOW;
        SD_CLK_HIGH;
        c <<= 1;
        if(SD_TEST_DAT & 0x01)  // check bit0
        c |= 0x01;
      }
#endif


      *buff=c;
       buff++;
    }

    //
    for(i=0; i<16; i++)
    {
        SD_CLK_LOW;
        SD_CLK_HIGH;
    }
  read_status = 1;  //SD data next in
  return TRUE;
}


//-------------------------------------------------------------------------
alt_u8 response_R(alt_u8 s)
{
  unsigned long long end_time, start_time;
  unsigned long long total_runtime;
  double double_total_runtime;

  char start_TS[50],end_TS[50],total_TS[50];

  start_time=low_level_system_timestamp();
  alt_u8 a=0,b=0,c=0,r=0,crc=0;
  alt_u8 i,j=6,k;
  while(1)
  {
	SD_CMD_IN;
    SD_CLK_LOW;
    SD_CLK_HIGH;
    if(!(SD_TEST_CMD))
        break;
    if(crc++ >100)
        return 2;

    end_time=low_level_system_timestamp(); if (start_time > end_time) { /* in case of some weird timer wrap */ start_time = end_time; }
    total_runtime = (end_time - start_time);
    if (total_runtime > WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS)
    {
    	convert_ull_to_string(start_time,start_TS);
    	    	  convert_ull_to_string(end_time,end_TS);
    	    	  convert_ull_to_string(total_runtime,total_TS);
    	          printf("\n[TERASIC_LINNUX_DRIVER][TS_Sec=%lu] response_R: Timed out!  start=%s end = %s total=%s\n",low_level_system_timestamp_in_secs(),start_TS,end_TS,total_TS);
    	          double_total_runtime = ((double) end_time) - ((double) start_time);
    	                    printf("double_total_runtime = %lf  (double) total_runtime = %lf  total_h = %lu total_l = %lu\n",double_total_runtime, (double) total_runtime, (unsigned long) (total_runtime >> 32), (unsigned long) (total_runtime % (1ULL<<32)));
    	                    if (((double)total_runtime) > ((double)WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS))
    	                    {
    	                      return 2;
    	                    } else {
    	                  	  printf("Double results are not bigger than watchdog of %lf, continuing!\n",(double)WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS);
    	                    }
    }
  }
  crc =0;
  if(s == 2)
    j = 17;

  for(k=0; k<j; k++)
  {
    c = 0;
    if(k > 0)                      //for crc culcar
        b = response_buffer[k-1];
    for(i=0; i<8; i++)
    {
      SD_CLK_LOW;
      if(a > 0)
      c <<= 1;
      else
      i++;
      a++;
      SD_CLK_HIGH;
      if(SD_TEST_CMD)
      c |= 0x01;
      if(k > 0)
      {
        crc <<= 1;
        if((crc ^ b) & 0x80)
        crc ^= 0x09;
        b <<= 1;
        crc &= 0x7f;
      }
    }
    if(s==3)
    {
      if( k==1 &&(!(c&0x80)))
      r=1;
    }
    response_buffer[k] = c;
  }
  if(s==1 || s==6)
  {
    if(c != ((crc<<1)+1))
    r=2;
  }
  return r;
}
//-------------------------------------------------------------------------
alt_u8 send_cmd(alt_u8 *in)
{

  int i,j;
  alt_u8 b,crc=0;
  SD_CMD_OUT;
  for(i=0; i < 5; i++)
  {
    b = in[i];
    for(j=0; j<8; j++)
    {
      SD_CLK_LOW;
      if(b&0x80)
      {SD_CMD_HIGH;}
      else
      {SD_CMD_LOW;}
      crc <<= 1;
      SD_CLK_HIGH;
      if((crc ^ b) & 0x80)
      crc ^= 0x09;
      b<<=1;
    }
    crc &= 0x7f;
  }
  crc =((crc<<1)|0x01);
  b = crc;
  for(j=0; j<8; j++)
  {
    SD_CLK_LOW;
    if(crc&0x80)
    {SD_CMD_HIGH;}
    else
    {SD_CMD_LOW;}
    SD_CLK_HIGH;
    crc<<=1;
  }
  return b;
}


#ifdef SUPPORT_SD_CARD
    #include "terasic_sdcard/SDCardDriver.h"
#endif //SUPPORT_USB_DISK

#ifdef SUPPORT_USB_DISK
    #include "terasic_usb_isp1761\class\usb_disk\usb_disk.h"
    #include "terasic_usb_isp1761\usb_host\usb_hub.h"
#endif //SUPPORT_USB_DISK

#ifdef DEBUG_FAT
    #define FAT_DEBUG(x)    {DEBUG(("[FAT]")); DEBUG(x);}
#else
    #define FAT_DEBUG(x)
#endif

//extern VOLUME_INFO gVolumeInfo;




// For FAT16 only
CLUSTER_TYPE fatClusterType(unsigned short Fat){
    CLUSTER_TYPE Type;

    if (Fat > 0 && Fat < 0xFFF0)
        Type = CLUSTER_NEXT_INFILE;
    else if (Fat >= 0xFFF8) // && Fat <= (unsigned short)0xFFFF)
        Type = CLUSTER_LAST_INFILE;
    else if (Fat == (unsigned short)0x00)
        Type = CLUSTER_UNUSED;
    else if (Fat >= 0xFFF0 && Fat <= 0xFFF6)
        Type = CLUSTER_RESERVED;
    else if (Fat == 0xFFF7)
        Type = CLUSTER_BAD;

    return Type;

}

unsigned int fatNextCluster(VOLUME_INFO *pVol, unsigned short ThisCluster){
    CLUSTER_TYPE ClusterType;
    unsigned int NextCluster;
#ifdef FAT_READONLY
//    const int nFatEntrySize = 2; // 2 byte for FAT16

//    NextCluster =  *(unsigned short *)(gVolumeInfo.szFatTable + ThisCluster*nFatEntrySize);
    NextCluster =  *(unsigned short *)(pVol->szFatTable + (ThisCluster << 1));

    ClusterType = fatClusterType(NextCluster);
    if (ClusterType != CLUSTER_NEXT_INFILE && ClusterType != CLUSTER_LAST_INFILE){
        NextCluster = 0;  // invalid cluster
    }
#else
    int nFatEntryPerSecter;
    const int nFatEntrySize = 2; // 2 byte for FAT16
    unsigned int Secter;
    char szBlock[512];
    nFatEntryPerSecter = pVol->BPB_BytsPerSec/nFatEntrySize;
    Secter = pVol->FatEntrySecter + (ThisCluster*nFatEntrySize)/pVol->BPB_BytsPerSec;
    if (pVol->ReadBlock512(pVol->DiskHandle, Secter,(alt_u8 *) szBlock)){
        NextCluster = *(unsigned short *)(szBlock + (ThisCluster%nFatEntryPerSecter)*nFatEntrySize);
        ClusterType = fatClusterType(NextCluster);
        if (ClusterType != CLUSTER_NEXT_INFILE && ClusterType != CLUSTER_LAST_INFILE)
            NextCluster = 0;  // invalid cluster
    }


    return NextCluster;

#endif

    return NextCluster;
}

void fatDumpDate(unsigned short Date){
    int Year, Month, Day;
    Year = ((Date >> 9) & 0x1F) + 1980;
    Month = ((Date >> 5) & 0xF);
    Day = ((Date >> 0) & 0x1F);
    FAT_DEBUG(("%d,%d,%d", Year, Month, Day));
}

void fatDumpTime(unsigned short Date){
    int H,M,S;
    H = ((Date >> 9) & 0x1F);
    M = ((Date >> 5) & 0x3F);
    S = ((Date >> 0) & 0x1F)*2;
    FAT_DEBUG(("%d:%d:%d", H, M, S));
}

terasic_bool fatIsLast(FAT_DIRECTORY *pDir){
    if (pDir->Name[0] == 0x00)
        return TRUE;
    return FALSE;
}


terasic_bool fatIsValid(FAT_DIRECTORY *pDir){
    char szTest[] = {0x00, 0xE5, 0x22, 0x2A, 0x2B, 0x2C, 0x2E, 0x2F, 0x3A, 0x3B, 0x3C, 0x3E, 0x3F, 0x5B, 0x5C, 0x5D, 0x7C};
    int i;

    for(i=0;i<sizeof(szTest)/sizeof(szTest[0]);i++){
        if (pDir->Name[0] == szTest[i]){
            return FALSE;
        }
    }
    return TRUE;

}

// debug
void fatDump(FAT_DIRECTORY *pDir){
    char szInvalidName[] = {0x22, 0x2A, 0x2B, 0x2C, 0x2E, 0x2F, 0x3A, 0x3B, 0x3C, 0x3E, 0x3F, 0x5B, 0x5C, 0x5D, 0x7C};
    int i;
    if (pDir->Name[0] == (char)0xE5){
        FAT_DEBUG(("the directory entry is free.\n"));
        return;
    }
    if (pDir->Name[0] == 0x00){
        FAT_DEBUG(("the directory entry is free, and there are no allocated directory entries after tis one.\n"));
        return;
    }

    if (pDir->Name[0] <= 0x20 && pDir->Name[0] != 0x05){
        FAT_DEBUG(("Invalid file name.\n"));
        return;
    }

    for(i=0;i<sizeof(szInvalidName)/sizeof(szInvalidName[0]);i++){
        if (pDir->Name[0] == szInvalidName[i]){
            FAT_DEBUG(("Invalid file name.\n"));
            return;
        }
    }

    //printf("sizeof(FAT_TABLE):%d\n", (int)sizeof(FAT_TABLE));
    if (pDir->Name[0] == 0x05){
        FAT_DEBUG(("Name:%c%c%c%c%c%c%c%c\n", 0xE5,pDir->Name[1],pDir->Name[2],pDir->Name[3],pDir->Name[4],pDir->Name[5],pDir->Name[6],pDir->Name[6]));
    }else{
        FAT_DEBUG(("Name:%c%c%c%c%c%c%c%c\n", pDir->Name[0],pDir->Name[1],pDir->Name[2],pDir->Name[3],pDir->Name[4],pDir->Name[5],pDir->Name[6],pDir->Name[6]));
    }
    FAT_DEBUG(("Extention:%c%c%c\n", pDir->Extension[0],pDir->Extension[1],pDir->Extension[2]));
    FAT_DEBUG(("Attribute:%02Xh\n", pDir->Attribute));
    if (pDir->Attribute & ATTR_READ_ONLY)
        FAT_DEBUG(("  Read-Only\n"));
    if (pDir->Attribute & ATTR_HIDDEN)
        FAT_DEBUG(("  Hidden\n"));
    if (pDir->Attribute & ATTR_SYSTEM)
        FAT_DEBUG(("  System\n"));
    if (pDir->Attribute & ATTR_VOLUME_ID)
        FAT_DEBUG(("  Volume\n"));
    if (pDir->Attribute & ATTR_DIRECTORY)
        FAT_DEBUG(("  Directory\n"));
    if (pDir->Attribute & ATTR_ARCHIVE)
        FAT_DEBUG(("  Archive\n"));
    if (pDir->Attribute & ATTR_LONG_NAME)
        FAT_DEBUG(("  Long Name\n"));
    FAT_DEBUG(("CreateTime:")); fatDumpTime(pDir->CreateTime);FAT_DEBUG(("\n"));
    FAT_DEBUG(("CreateDate:")); fatDumpDate(pDir->LastAccessDate);FAT_DEBUG(("\n"));
    FAT_DEBUG(("ClusterHi:%04Xh\n", pDir->FirstLogicalClusterHi));
    FAT_DEBUG(("LastWriteTime:")); fatDumpTime(pDir->LastWriteTime);FAT_DEBUG(("\n"));
    FAT_DEBUG(("LastWriteDate:")); fatDumpDate(pDir->LastWriteDate);FAT_DEBUG(("\n"));
    FAT_DEBUG(("Cluster:%04Xh(%d)\n", pDir->FirstLogicalCluster,pDir->FirstLogicalCluster));
    FAT_DEBUG(("File Size:%08Xh(%ld)\n", pDir->FileSize, (long)pDir->FileSize));
}


unsigned int fatArray2Value(unsigned char *pValue, unsigned int nNum){
    unsigned char *pMSB = (pValue + nNum - 1);
    unsigned int nValue;
    int i;
    for(i=0;i<nNum;i++){
        nValue <<= 8;
        nValue |= *pMSB--;

    }

    return nValue;
}

//

terasic_bool fatMount(VOLUME_INFO *pVol){
    terasic_bool bSuccess = TRUE;
    int FirstPartitionEntry,PartitionType,FirstSectionInVolume1;
    int nFatTableSize,nFatTableSecterNum;//, i;
    unsigned char szBlock[512];

    // parsing Boot Sector system
    // Read the Master Boot Record(MBR) of FAT file system (Locate the section 0)
    // Offset:
    // 000h(446 bytes): Executable Code (Boots Computer)
    // 1BEh( 16 bytes): 1st Partition Entry
    // 1CEh( 16 bytes): 2nd Partition Entry
    // 1DEh( 16 bytes): 3nd Partition Entry
    // 1EEh( 16 bytes): 4nd Partition Entry
    // 1FEh(  2 bytes): Executable Maker (55h AAh)

    // read first block (secotor 0), BPB(BIOS Parameter Block) or called as boot sector or reserved sector
    if (!pVol->ReadBlock512(pVol->DiskHandle, 0, szBlock)){
        FAT_DEBUG(("Read section 0 error.\n"));
        return FALSE;
    }
    /*
    if (szBlock[510] != 0x55 || szBlock[511] != 0x55){
        FAT_DEBUG(("Invalid 0xAA55 signature\n"));
        return FALSE;
    }
    */

    // check file system
    FirstPartitionEntry = 0x1BE;
    PartitionType = szBlock[FirstPartitionEntry + 4];
    if (PartitionType == PARTITION_FAT16){
        FAT_DEBUG(("FAT16\n"));
    }else if (PartitionType == PARTITION_FAT32){
        FAT_DEBUG(("FAT32\n"));
    }else{
        FAT_DEBUG(("the partition type(%d) is not supported.\n", PartitionType));
        return FALSE; // only support FAT16 in this example
    }
    pVol->Partition_Type = PartitionType;
    // 2.2 Find the first section of partition 1
    FirstSectionInVolume1 = fatArray2Value(&szBlock[FirstPartitionEntry + 8],4);
                            //szBlock[FirstPartitionEntry + 8 + 3]*256*256*256 +
                            //szBlock[FirstPartitionEntry + 8 + 2]*256*256 +
                            //szBlock[FirstPartitionEntry + 8 + 1]*256 +
                            //szBlock[FirstPartitionEntry + 8];

    //3 Parsing the Volume Boot Record(BR)
    //3.1  Read the Volume Boot Record(BR)
    if (!pVol->ReadBlock512(pVol->DiskHandle, FirstSectionInVolume1, szBlock)){
        FAT_DEBUG(("Read first sector in volume one fail.\n"));
        return FALSE;
    }
    pVol->PartitionStartSecter = FirstSectionInVolume1;
    pVol->BPB_BytsPerSec = szBlock[0x0B+1]*256 + szBlock[0x0B];
    pVol->BPB_SecPerCluster = szBlock[0x0D];
    pVol->BPB_RsvdSecCnt = szBlock[0x0E + 1]*256 + szBlock[0x0E];
    pVol->BPB_NumFATs = szBlock[0x10];
    pVol->BPB_RootEntCnt = szBlock[0x11+1]*256 + szBlock[0x11];
    pVol->BPB_FATSz = szBlock[0x16+1]*256 + szBlock[0x16];

    if (pVol->Partition_Type == PARTITION_FAT32){
        pVol->BPB_FATSz = fatArray2Value(&szBlock[0x24], 4);  // BPB_FATSz32
        //pVol->BPB_RootEntCnt = fatArray2Value(&szBlock[0x2C], 4);  // BPB_RootClus
    }

    if (pVol->BPB_BytsPerSec != 512){
        FAT_DEBUG(("This program only supports FAT BPB_BytsPerSec == 512\n"));
        return FALSE; // only support FAT16 in this example
    }
#ifdef DUMP_DEBUG
    FAT_DEBUG(("First section in partition 1: %04Xh(%d)\n", gVolumeInfo.PartitionStartSecter, gVolumeInfo.PartitionStartSecter));
    FAT_DEBUG(("Byte Per Sector: %04Xh(%d)\n", gVolumeInfo.BPB_BytsPerSec, gVolumeInfo.BPB_BytsPerSec));
    FAT_DEBUG(("Sector Per Clusoter: %02Xh(%d)\n", gVolumeInfo.BPB_SecPerCluster, gVolumeInfo.BPB_SecPerCluster));
    FAT_DEBUG(("Reserved Sectors: %04Xh(%d)\n", gVolumeInfo.BPB_RsvdSecCnt, gVolumeInfo.BPB_RsvdSecCnt));
    FAT_DEBUG(("Number of Copyies of FAT: %02Xh(%d)\n", gVolumeInfo.BPB_NumFATs, gVolumeInfo.BPB_NumFATs));
    FAT_DEBUG(("Maxmun Root Directory Entries: %04Xh(%d)\n", gVolumeInfo.BPB_RootEntCnt, gVolumeInfo.BPB_RootEntCnt));
    FAT_DEBUG(("Sectors Per FAT: %04Xh(%d)\n", gVolumeInfo.BPB_FATSz, gVolumeInfo.BPB_FATSz));
#endif
    //
    pVol->FatEntrySecter = pVol->PartitionStartSecter + pVol->BPB_RsvdSecCnt;
    pVol->RootDirectoryEntrySecter = pVol->FatEntrySecter + pVol->BPB_NumFATs * pVol->BPB_FATSz;
    pVol->DataEntrySecter = pVol->RootDirectoryEntrySecter + ((pVol->BPB_RootEntCnt*32)+(pVol->BPB_BytsPerSec-1))/pVol->BPB_BytsPerSec;

    // read FAT table into memory
    pVol->nBytesPerCluster = pVol->BPB_BytsPerSec * pVol->BPB_SecPerCluster;
    nFatTableSecterNum = pVol->BPB_NumFATs * pVol->BPB_FATSz;
    nFatTableSize = nFatTableSecterNum * pVol->BPB_BytsPerSec;
#ifdef FAT_READONLY
    pVol->szFatTable = malloc(nFatTableSize);
    if (!pVol->szFatTable){
        FAT_DEBUG(("fat malloc(%d) fail!", nFatTableSize));
        return FALSE;
    }
    for(i=0;i<nFatTableSecterNum && bSuccess; i++ ){
        if (!pVol->ReadBlock512(pVol->DiskHandle, pVol->FatEntrySecter+i, pVol->szFatTable + i*pVol->BPB_BytsPerSec)){
            FAT_DEBUG(("Read first sector in volume one fail.\n"));
            bSuccess = FALSE;
        }
    }


    if (!bSuccess && pVol->szFatTable){
        free(pVol->szFatTable);
        pVol->szFatTable = 0;
    }
#endif


    if (bSuccess){
        FAT_DEBUG(("Fat_Mount success\n"));
    }else{
        FAT_DEBUG(("Fat_Mount fail\n"));
    }
    pVol->bMount = bSuccess;
    return bSuccess;


}

//===================== SUPPORT_SD_CARD =================================================
#ifdef SUPPORT_SD_CARD

terasic_bool SD_ReadBlock512(DISK_HANDLE DiskHandle, alt_u32 PysicalSelector, alt_u8 szBuf[512]){
    return SD_read_block(PysicalSelector, szBuf);
}

FAT_HANDLE fatMountSdcard(void){
    FAT_HANDLE hFat = 0;
    VOLUME_INFO *pVol;
    const int nMaxTry=10;
    terasic_bool bFind = FALSE;
    int nTry=0;
    terasic_bool bSuccess = TRUE;


    //1. chek whether SD Card existed. Init SD card if it is present.
    while(!bFind && nTry++ < nMaxTry){
        bFind = SD_card_init();
        if (!bFind)
        	c_low_level_system_usleep(100*1000);
    }
    if (!bFind){
        FAT_DEBUG(("Cannot find SD card.\n"));
        return hFat;
    }

    hFat = my_mem_malloc(sizeof(VOLUME_INFO));
    pVol = (VOLUME_INFO *)hFat;
    pVol->ReadBlock512 = SD_ReadBlock512;
    bSuccess = fatMount(pVol);



    if (bSuccess){
        FAT_DEBUG(("Fat_Mount success\n"));
        pVol->bMount = TRUE;
    }else{
        FAT_DEBUG(("Fat_Mount fail\n"));
        my_mem_free((void *)hFat);
        hFat = 0;
    }

    return hFat;
}

#endif ////===================== SUPPORT_SD_CARD =================================================


//===================== SUPPORT_USB_DISK =================================================
#ifdef SUPPORT_USB_DISK

FAT_HANDLE fatMountUsbDisk(DEVICE_HANDLE hDevice){
    FAT_HANDLE hFat = 0;
    terasic_bool bSuccess = FALSE;
    USBDISK_HANDLE hUsbDisk;
    alt_u8 Port, PortStart=1;
    USB_DEVICE *pHub = (USB_DEVICE *)hDevice;
    //int i;

    if (!pHub)
        return 0;

#ifdef PORT1_CONFIG_AS_DEVICE
    PortStart = 2;
#endif // PORT1_CONFIG_AS_DEVICE
    // check whether usb driver is ready
    for(Port=PortStart;Port<=3 && !bSuccess;Port++){
        if (Hub_IsDeviceAttached(pHub, Port)){
            FAT_DEBUG(("Port %d is attached\n", Port));
            hUsbDisk = USBDISK_Open(pHub, Port);
            if (hUsbDisk)
                bSuccess = TRUE;
        }
    }



    if (bSuccess){
        VOLUME_INFO *pVol;
        hFat = malloc(sizeof(VOLUME_INFO));
        pVol = (VOLUME_INFO *)hFat;
        pVol->DiskHandle = hUsbDisk;
        pVol->ReadBlock512 = USBDISK_ReadBlock512;
        if (!fatMount(pVol)){
            free((void *)hFat);
            hFat = 0;
        }
    }


    return hFat;
}

#endif ////===================== SUPPORT_USB_DISK =================================================


#ifdef DEBUG_FAT
    #define FAT_DEBUG(x)    DEBUG(x)
#else
    #define FAT_DEBUG(x)
#endif



//VOLUME_INFO gVolumeInfo;
void fatComposeShortFilename(FAT_DIRECTORY *pDir, char *szFilename);
terasic_bool fatSameLongFilename(alt_u16 *p1, alt_u16 *p2);




FAT_HANDLE Fat_Mount(FAT_DEVICE FatDevice, DEVICE_HANDLE hDevice){

    //Fat_Unmount();
    FAT_HANDLE hFat = 0;

    if (FatDevice == FAT_SD_CARD){
        #ifdef SUPPORT_SD_CARD
        hFat = fatMountSdcard();
        #endif //SUPPORT_SD_CARD
    }else if (FatDevice == FAT_USB_DISK){
        #ifdef SUPPORT_USB_DISK
        hFat = fatMountUsbDisk(hDevice);
        #endif
    }
    return hFat;

}

void Fat_Unmount(FAT_HANDLE Fat){
    VOLUME_INFO *pVol = (VOLUME_INFO *)Fat;
    if (!pVol)
        return;
#ifdef FAT_READONLY
    if (pVol->szFatTable){
        free(pVol->szFatTable);
        pVol->szFatTable = 0;
    }
#endif //#ifdef FAT_READONLY
    pVol->bMount = FALSE;

    my_mem_free(pVol);
}

terasic_bool Fat_FileBrowseBegin(FAT_HANDLE hFat, FAT_BROWSE_HANDLE *pFatBrowseHandle){
    VOLUME_INFO *pVol = (VOLUME_INFO *)hFat;
    if (!pVol)
        return FALSE;
    if (!pVol->bMount)
        return FALSE;
    pFatBrowseHandle->DirectoryIndex = 0;
    pFatBrowseHandle->hFat = hFat;
    return TRUE;
}

terasic_bool Fat_FileBrowseNext(FAT_BROWSE_HANDLE *pFatBrowseHandle, FILE_CONTEXT *pFileContext){
    terasic_bool bFind = FALSE, bVlaid, bError=FALSE, bLongFilename = FALSE;
    int OrderValue = 0;
    FAT_DIRECTORY *pDir;
    unsigned int nSecter, nOffset;
    char szBlock[512];
    VOLUME_INFO *pVol = (VOLUME_INFO *)pFatBrowseHandle->hFat;

    if (!pVol)
        return FALSE;

    if (!pVol->bMount)
        return FALSE;


    do{
        nOffset = (sizeof(FAT_DIRECTORY)*pFatBrowseHandle->DirectoryIndex)/pVol->BPB_BytsPerSec;
        nSecter = pVol->RootDirectoryEntrySecter + nOffset;
        if (!pVol->ReadBlock512( pVol->DiskHandle,  nSecter, (alt_u8*) szBlock)){
            bError = TRUE;
        }else{
            nOffset = (sizeof(FAT_DIRECTORY)*pFatBrowseHandle->DirectoryIndex)%pVol->BPB_BytsPerSec;
            pDir = (FAT_DIRECTORY *)(szBlock + nOffset);
            pFatBrowseHandle->DirectoryIndex++;
            bVlaid = fatIsValid(pDir);
            if (bVlaid){
                if ((pDir->Attribute & ATTR_LONG_NAME) == ATTR_LONG_NAME){
                    FAT_LONG_DIRECTORY *pLDIR = (FAT_LONG_DIRECTORY *)pDir;
                    // check attribute
                    if ((pLDIR->LDIR_Attr & ATTR_LONG_NAME) != ATTR_LONG_NAME){
                        bError = TRUE;
                    }else{
                        // check order
                        if (OrderValue == 0){
                            if (bLongFilename)
                                bError = TRUE;
                            else
                                OrderValue = pLDIR->LDIR_Ord & 0x3F;
                            memset(pFileContext->szName, 0, sizeof(pFileContext->szName));
                        }else{
                            if ((pLDIR->LDIR_Ord & 0x3F) != OrderValue)
                                bError = TRUE;
                        }
                    }

                    //
                    if (!bError){
                        int BaseOffset;
                        bLongFilename = TRUE;
                        OrderValue--;
                        BaseOffset = OrderValue * 26;
                        // cast filename
                        memmove(pFileContext->szName+BaseOffset, pLDIR->LDIR_Name1, 10);
                        memmove(pFileContext->szName+BaseOffset+10, pLDIR->LDIR_Name2, 12);
                        memmove(pFileContext->szName+BaseOffset+22, pLDIR->LDIR_Name3, 4);
                    }
                }else{
                    if (bLongFilename){
                        pFileContext->Attribute = ATTR_LONG_NAME;
                        if ((pDir->Attribute & (ATTR_ARCHIVE | ATTR_DIRECTORY)) == 0)
                            bError = TRUE;
                        else
                            bFind = TRUE;
                    }else{
                        fatComposeShortFilename(pDir, pFileContext->szName);
                        bFind = TRUE;
                    }

                    if (bFind){
                        // my ext
                        pFileContext->bLongFilename = bLongFilename;
                        pFileContext->bFile = (pDir->Attribute & ATTR_ARCHIVE)?TRUE:FALSE;
                        pFileContext->bDirectory = (pDir->Attribute & ATTR_DIRECTORY)?TRUE:FALSE;
                        pFileContext->bVolume = (pDir->Attribute & ATTR_VOLUME_ID)?TRUE:FALSE;

                        //
                        pFileContext->Attribute = pDir->Attribute;
                        pFileContext->CreateTime = pDir->CreateTime;
                        pFileContext->LastAccessDate = pDir->LastAccessDate;
                        pFileContext->FirstLogicalClusterHi = pDir->FirstLogicalClusterHi;
                        pFileContext->LastWriteTime = pDir->LastWriteTime;
                        pFileContext->LastWriteDate = pDir->LastWriteDate;
                        pFileContext->FirstLogicalCluster = pDir->FirstLogicalCluster;
                        pFileContext->FileSize = pDir->FileSize;
                    }
                }
            }
        }
    }while (!bFind && !fatIsLast(pDir) && !bError);

    return bFind;

}

/*
terasic_bool Fat_FileBrowseNext(FAT_BROWSE_HANDLE *pFatBrowseHandle, FAT_DIRECTORY *pDirectory){
    terasic_bool bFind = FALSE, bError=FALSE;
    FAT_DIRECTORY *pDir;
    unsigned int nSecter, nOffset;
    char szBlock[512];
    VOLUME_INFO *pVol = (VOLUME_INFO *)pFatBrowseHandle->hFat;

    if (!pVol)
        return FALSE;

    if (!pVol->bMount)
        return FALSE;


    do{
        nOffset = (sizeof(FAT_DIRECTORY)*pFatBrowseHandle->DirectoryIndex)/pVol->BPB_BytsPerSec;
        nSecter = pVol->RootDirectoryEntrySecter + nOffset;
//        if (!SD_read_block(nSecter, szBlock)){
        if (!pVol->ReadBlock512(pVol->DiskHandle, nSecter, szBlock)){
            bError = TRUE;
        }else{
            nOffset = (sizeof(FAT_DIRECTORY)*pFatBrowseHandle->DirectoryIndex)%pVol->BPB_BytsPerSec;
            pDir = (FAT_DIRECTORY *)(szBlock + nOffset);
            printf("[%d]=%02Xh\n", pFatBrowseHandle->DirectoryIndex, pDir->Name[0]);
            pFatBrowseHandle->DirectoryIndex++;
            bFind = fatIsValid(pDir);
            if (bFind){
                *pDirectory = *pDir;
                printf("find....\n");
            }
        }
    }while (!bFind && !fatIsLast(pDir) && !bError);

    return bFind;

}
*/

unsigned int Fat_FileCount(FAT_HANDLE Fat){
    unsigned int nCount = 0;
    FAT_BROWSE_HANDLE hBrowse;
    FILE_CONTEXT FileContext;

    if (Fat_FileBrowseBegin(Fat, &hBrowse)){
        while(Fat_FileBrowseNext(&hBrowse, &FileContext))
            nCount++;
    }

    return nCount;
}

terasic_bool fatSameLongFilename(alt_u16 *p1, alt_u16 *p2){
    terasic_bool bSame = TRUE;

    while(bSame && ((*p1 != 0) || (*p2 != 0))){
        if (*p1 != *p2){
            bSame = FALSE;
        }
        p1++;
        p2++;

    }

    return bSame;
}


void fatComposeShortFilename(FAT_DIRECTORY *pDir, char *szFilename){
    int i,nPos=0;

    i=0;
    while(i < 8 && pDir->Name[i] != 0 && pDir->Name[i] != ' ')
        szFilename[nPos++] = pDir->Name[i++];

    if (pDir->Attribute & (ATTR_ARCHIVE | ATTR_DIRECTORY)){
        if (pDir->Attribute & (ATTR_ARCHIVE | ATTR_DIRECTORY))
            szFilename[nPos++] = '.';
        i=0;
        while(i < 3 && pDir->Extension[i] != 0 && pDir->Extension[i] != ' ')
            szFilename[nPos++] = pDir->Extension[i++];
    }
    szFilename[nPos++] = 0;
}


// File Access
FAT_FILE_HANDLE Fat_FileOpen(FAT_HANDLE Fat, const char *pFilename){
    terasic_bool bFind = FALSE;
    FAT_BROWSE_HANDLE hBrowse;
    FILE_CONTEXT FileContext;
    FAT_FILE_INFO *pFile = 0;

    if (Fat_FileBrowseBegin(Fat, &hBrowse)){
        while (!bFind && Fat_FileBrowseNext(&hBrowse, &FileContext)){
            if (FileContext.bLongFilename){
                bFind = fatSameLongFilename((alt_u16 *)FileContext.szName, (alt_u16 *)pFilename);
            }else{
                if (strcmpi(FileContext.szName, pFilename) == 0)
                    bFind = TRUE;
            }

            if (bFind){
                pFile = (FAT_FILE_INFO *) my_mem_malloc(sizeof(FAT_FILE_INFO));
                if (pFile){
                    pFile->SeekPos = 0;
                    pFile->Directory = FileContext;
                    pFile->IsOpened = TRUE;
                    pFile->Cluster = FileContext.FirstLogicalCluster;
                    pFile->ClusterSeq = 0;
                    pFile->Fat = Fat;
                }
            }

        }
    }
    return (FAT_FILE_HANDLE)pFile;
}

unsigned int Fat_FileSize(FAT_FILE_HANDLE hFileHandle){
    FAT_FILE_INFO *f = (FAT_FILE_INFO *)hFileHandle;
    if (f->IsOpened)
        return f->Directory.FileSize;
    return 0;
}


terasic_bool Fat_FileRead(FAT_FILE_HANDLE hFileHandle, void *pBuffer, const int nBufferSize){
    FAT_FILE_INFO *f = (FAT_FILE_INFO *)hFileHandle;
    VOLUME_INFO *pVol;
    unsigned int Pos, PhysicalSecter, NextCluster, Cluster;
    unsigned int BytesPerCluster, nReadCount=0, nClusterSeq;
    int s;
    terasic_bool bSuccess= TRUE;
    char szBlock[512];

    if (!f || !f->Fat)
        return FALSE;
    pVol = (VOLUME_INFO *)f->Fat;

    if (!f->IsOpened){
        FAT_DEBUG(("[FAT] Fat_FileRead, file not opened\r\n"));
        return bSuccess;
    }

    BytesPerCluster = pVol->nBytesPerCluster; //gVolumeInfo.BPB_BytsPerSec * gVolumeInfo.BPB_SecPerCluster;
    Pos = f->SeekPos;
    if (BytesPerCluster == 32768){
        nClusterSeq = Pos >> 15;
        Pos -= (f->ClusterSeq << 15);
    }else if (BytesPerCluster == 16384){
        nClusterSeq = Pos >> 14;
        Pos -= (f->ClusterSeq << 14);
    }else if (BytesPerCluster == 2048){
        nClusterSeq = Pos >> 11;
        Pos -= (f->ClusterSeq << 11);
    }else{
        nClusterSeq = Pos/BytesPerCluster;
        Pos -= f->ClusterSeq*BytesPerCluster;
    }


    Cluster = f->Cluster;
    if (nClusterSeq != f->ClusterSeq){
        Cluster = f->Cluster;  //11/20/2007, richard
        // move to first clustor for reading
        while (Pos >= BytesPerCluster && bSuccess){
            // go to next cluster
            NextCluster = fatNextCluster(pVol, Cluster);
            if (NextCluster == 0){
                bSuccess = FALSE;
                FAT_DEBUG(("[FAT] Fat_FileRead, not next Cluster, current Cluster=%d\r\n", Cluster));
            }else{
                Cluster = NextCluster;
            }
            Pos -= BytesPerCluster;
            f->Cluster = Cluster;
            f->ClusterSeq++;
        }
    }

    // reading
    while(nReadCount < nBufferSize && bSuccess){
        if (pVol->BPB_SecPerCluster == 32)
            PhysicalSecter = ((Cluster-2) << 5) + pVol->DataEntrySecter; // -2: FAT0 & FAT1 are reserved
        else if (pVol->BPB_SecPerCluster == 64)
            PhysicalSecter = ((Cluster-2) << 6) + pVol->DataEntrySecter; // -2: FAT0 & FAT1 are reserved
        else
            PhysicalSecter = (Cluster-2)*pVol->BPB_SecPerCluster + pVol->DataEntrySecter; // -2: FAT0 & FAT1 are reserved
        for(s=0;s<pVol->BPB_SecPerCluster && nReadCount < nBufferSize;s++){
            if (Pos >= pVol->BPB_BytsPerSec){
                Pos -= pVol->BPB_BytsPerSec;
            }else{
                int nCopyCount;
                nCopyCount = pVol->BPB_BytsPerSec;
                if (Pos)
                    nCopyCount -= Pos;
                if (nCopyCount > (nBufferSize-nReadCount))
                    nCopyCount = nBufferSize-nReadCount;
                if (nCopyCount == 512){
                    //if (PhysicalSecter == 262749)
                    //    FAT_DEBUG(("[FAT] here, 262749"));
                    if (!pVol->ReadBlock512(pVol->DiskHandle, PhysicalSecter, (alt_u8 *) ((char *)pBuffer+nReadCount))){
                        bSuccess = FALSE; // fail
                        FAT_DEBUG(("[FAT] Fat_FileRead, SD_read_block fail, PhysicalSecter=%d (512)\r\n", PhysicalSecter));
                    }else{
                        //FAT_DEBUG(("[FAT] Fat_FileRead Success, PhysicalSecter=%d (512)\r\n", PhysicalSecter));
                        nReadCount += nCopyCount;
                        if (Pos > 0)
                            Pos = 0;
                    }
                }else{
                    if (!pVol->ReadBlock512(pVol->DiskHandle, PhysicalSecter,(alt_u8*)  szBlock)){
                        bSuccess = FALSE; // fail
                        FAT_DEBUG(("[FAT] Fat_FileRead, SD_read_block fail\r\n"));
                    }else{
                        memmove((void *)((char *)pBuffer+nReadCount), szBlock+Pos,nCopyCount);
                        nReadCount += nCopyCount;
                        if (Pos > 0)
                            Pos = 0;
                    }
                }

            }
            PhysicalSecter++;
        }

        // next cluster
        if (nReadCount < nBufferSize){
            NextCluster = fatNextCluster(pVol, Cluster);
            if (NextCluster == 0){
                bSuccess = FALSE;
                FAT_DEBUG(("[FAT] Fat_FileRead, no next cluster\r\n"));
            }else{
                Cluster = NextCluster;
            }
            //
            f->ClusterSeq++;
            f->Cluster = Cluster;
        }
    }

    if (bSuccess){
        f->SeekPos += nBufferSize;
    }


    return bSuccess;
}

terasic_bool Fat_FileSeek(FAT_FILE_HANDLE hFileHandle, const FAT_SEEK_POS SeekPos, const int nOffset){
    FAT_FILE_INFO *f = (FAT_FILE_INFO *)hFileHandle;
    VOLUME_INFO *pVol;
    terasic_bool bSuccess= TRUE;

    if (!f || !f->Fat)
        return FALSE;
    pVol = (VOLUME_INFO *)f->Fat;

    if (!f->IsOpened)
        return FALSE;

    switch(SeekPos){
        case FILE_SEEK_BEGIN:
            f->SeekPos = nOffset;
            break;
        case FILE_SEEK_CURRENT:
            f->SeekPos += nOffset;
            break;
        case FILE_SEEK_END:
            f->SeekPos = f->Directory.FileSize+nOffset;
            break;
        default:
            bSuccess = FALSE;
            break;

    }
    f->Cluster = f->Directory.FirstLogicalCluster;
    f->ClusterSeq = 0;

    return bSuccess;

}

void Fat_FileClose(FAT_FILE_HANDLE hFileHandle){
    FAT_FILE_INFO *f = (FAT_FILE_INFO *)hFileHandle;
    if (!f)
        return;

    free(f);
}

terasic_bool Fat_FileIsOpened(FAT_FILE_HANDLE hFileHandle){
    FAT_FILE_INFO *f = (FAT_FILE_INFO *)hFileHandle;
    if (!f)
        return FALSE;
    return f->IsOpened;
}

float Fat_SpeedTest(FAT_HANDLE hFat, alt_u32 TestDurInMs){
    terasic_bool bSuccess = TRUE;
    alt_u32 time_start, time_finish, time_elapsed, TotalReadBytes=0;
    int nSecter = 0;
    float fMegaBytePerSec = 0;
    char szBlock[512];
    VOLUME_INFO *pVol = (VOLUME_INFO *)hFat;
    if (!pVol)
        return 0;
    time_start = low_level_system_timestamp();
    time_finish = low_level_system_timestamp() + TestDurInMs * 1000 / alt_ticks_per_second();
    while(low_level_system_timestamp() < time_finish && bSuccess){
        bSuccess = pVol->ReadBlock512(pVol->DiskHandle, nSecter, (alt_u8*) szBlock);
        nSecter++;
        TotalReadBytes += sizeof(szBlock);

    }
    if (bSuccess){
        time_elapsed = low_level_system_timestamp() - time_start;
        fMegaBytePerSec = (float)TotalReadBytes * (float)alt_ticks_per_second() / (float)time_elapsed / 1024.0 / 1024.0;
    }
    return fMegaBytePerSec;


}



terasic_bool Fat_Test(FAT_HANDLE hFat, char *pDumpFile){
    terasic_bool bSuccess;
    int nCount = 0;
    FAT_BROWSE_HANDLE hBrowse;
    FILE_CONTEXT FileContext;

    bSuccess = Fat_FileBrowseBegin(hFat, &hBrowse);
    if (bSuccess){
        while(Fat_FileBrowseNext(&hBrowse, &FileContext)){
            if (FileContext.bLongFilename){
                alt_u16 *pData16;
                alt_u8 *pData8;
                pData16 = (alt_u16 *)FileContext.szName;
                pData8 = (alt_u8 *) FileContext.szName;
                printf("[%d]", nCount);
                while(*pData16){
                    if (*pData8)
                        printf("%c", *pData8);
                    pData8++;
                    if (*pData8)
                        printf("%c", *pData8);
                    pData8++;
                    //
                    pData16++;
                }
                printf("\n");

            }else{
                printf("[%d]%s\n", nCount, FileContext.szName);
            }
            nCount++;
        }
    }
    if (bSuccess && pDumpFile && strlen(pDumpFile)){
        FAT_FILE_HANDLE hFile;
        hFile =  Fat_FileOpen(hFat, pDumpFile);
        if (hFile){
            char szRead[256];
            int nReadSize, nFileSize, nTotalReadSize=0;
            nFileSize = Fat_FileSize(hFile);
            if (nReadSize > sizeof(szRead))
                nReadSize = sizeof(szRead);
            printf("%s dump:\n", pDumpFile);
            while(bSuccess && nTotalReadSize < nFileSize){
                nReadSize = sizeof(szRead);
                if (nReadSize > (nFileSize - nTotalReadSize))
                    nReadSize = (nFileSize - nTotalReadSize);
                //
                if (Fat_FileRead(hFile, szRead, nReadSize)){
                    int i;
                    for(i=0;i<nReadSize;i++){
                        printf("%c", szRead[i]);
                    }
                    nTotalReadSize += nReadSize;
                }else{
                    bSuccess = FALSE;
                    printf("\nFaied to read the file \"%s\"\n", pDumpFile);
                }
            } // while
            if (bSuccess)
            printf("\n");
            Fat_FileClose(hFile);
        }else{
            bSuccess = FALSE;
            printf("Cannot find the file \"%s\"\n", pDumpFile);
        }
    }
    return bSuccess;
}

terasic_bool print_file_contents(FAT_HANDLE hFat, char *pDumpFile){
    terasic_bool bSuccess;
    int nCount = 0;
    FAT_BROWSE_HANDLE hBrowse;
    FILE_CONTEXT FileContext;

    bSuccess = Fat_FileBrowseBegin(hFat, &hBrowse);
    if (bSuccess){
        while(Fat_FileBrowseNext(&hBrowse, &FileContext)){
            if (FileContext.bLongFilename){
                alt_u16 *pData16;
                alt_u8 *pData8;
                pData16 = (alt_u16 *)FileContext.szName;
                pData8 = (alt_u8 *) FileContext.szName;
                while(*pData16){
                    if (*pData8)
                    pData8++;
                    if (*pData8)
                    pData8++;
                    //
                    pData16++;
                }
            }else{
            }
            nCount++;
        }
    }
    if (bSuccess && pDumpFile && strlen(pDumpFile)){
        FAT_FILE_HANDLE hFile;
        hFile =  Fat_FileOpen(hFat, pDumpFile);
        if (hFile){
            char szRead[256];
            int nReadSize, nFileSize, nTotalReadSize=0;
            nFileSize = Fat_FileSize(hFile);
            if (nReadSize > sizeof(szRead))
                nReadSize = sizeof(szRead);
            printf("%s File Contents:\n", pDumpFile);
            printf("=================\n");
            while(bSuccess && nTotalReadSize < nFileSize){
                nReadSize = sizeof(szRead);
                if (nReadSize > (nFileSize - nTotalReadSize))
                    nReadSize = (nFileSize - nTotalReadSize);
                //
                if (Fat_FileRead(hFile, szRead, nReadSize)){
                    int i;
                    for(i=0;i<nReadSize;i++){
                        safe_print(printf("%c", szRead[i]));
                    }
                    nTotalReadSize += nReadSize;
                }else{
                    bSuccess = FALSE;
                    safe_print(printf("\nFaied to read the file \"%s\"\n", pDumpFile));
                }
            } // while
            if (bSuccess)
            safe_print(printf("\n"));
            Fat_FileClose(hFile);
        }else{
            bSuccess = FALSE;
            printf("Cannot find the file \"%s\"\n", pDumpFile);
        }
    }
    return bSuccess;
}

//terasic_bool Fat_Read_SD_File_Into_Long_Array(FAT_HANDLE hFat, char *pDumpFile, unsigned long* out_array,
// unsigned long& out_array_size, unsigned long max_allowed_num_of_values){
//    terasic_bool bSuccess;
//    int nCount = 0;
//    FAT_BROWSE_HANDLE hBrowse;
//    FILE_CONTEXT FileContext;
//
//    bSuccess = Fat_FileBrowseBegin(hFat, &hBrowse);
//    if (bSuccess){
//        while(Fat_FileBrowseNext(&hBrowse, &FileContext)){
//            if (FileContext.bLongFilename){
//                alt_u16 *pData16;
//                alt_u8 *pData8;
//                pData16 = (alt_u16 *)FileContext.szName;
//                pData8 = (alt_u8 *) FileContext.szName;
//               // safe_print(printf("[%d]", nCount));
//                while(*pData16){
//                    if (*pData8)
//                        {
//                    	//safe_print(printf("%c", *pData8));
//                        }
//                    pData8++;
//                    if (*pData8)
//                    {
//                        //safe_print(printf("%c", *pData8));
//                    }
//                    pData8++;
//                    //
//                    pData16++;
//                }
//                //safe_print(printf("\n"));
//
//            }else{
//                //safe_print(printf("[%d]%s\n", nCount, FileContext.szName));
//            }
//            nCount++;
//        }
//    }
//
//    out_array_size = 0;
//
//    if (bSuccess && pDumpFile && strlen(pDumpFile)){
//        FAT_FILE_HANDLE hFile;
//        hFile =  Fat_FileOpen(hFat, pDumpFile);
//        if (hFile){
//            char szRead[256];
//            int nReadSize, nFileSize, nTotalReadSize=0;
//            nFileSize = Fat_FileSize(hFile);
//            if (nReadSize > sizeof(szRead))
//                nReadSize = sizeof(szRead);
//            safe_print(printf("Reading %s  into array of long\n", pDumpFile));
//            while(bSuccess && nTotalReadSize < nFileSize){
//                nReadSize = sizeof(szRead);
//                if (nReadSize > (nFileSize - nTotalReadSize))
//                    nReadSize = (nFileSize - nTotalReadSize);
//                //
//                if (Fat_FileRead(hFile, szRead, nReadSize)){
//                    int i;
//                    char current_long_str[9];
//                    unsigned long current_long_val;
//                    current_long_str[8]='\0';
//                    for(i=0;((i<nReadSize) && (i+7<nReadSize));i=i+8)//+8 because 8 hex chars per long
//                    {
//                        //safe_print(printf("%c%c%c%c%c%c%c%c\n", szRead[i],szRead[i+1], szRead[i+2],szRead[i+3],szRead[i+4],szRead[i+5], szRead[i+6],szRead[i+7]));
//                        sprintf(current_long_str,"%c%c%c%c%c%c%c%c", szRead[i],szRead[i+1], szRead[i+2],szRead[i+3],szRead[i+4],szRead[i+5], szRead[i+6],szRead[i+7]);
//                        current_long_val = strtoul(current_long_str,NULL,16); //convert from hex str
//                        out_array[out_array_size]=current_long_val;
//                        //cout << current_long_str << " <= Current_long_str" << dec << out_array_size << " " << hex << " " << out_array[out_array_size] << " "<< current_long_val << dec << "\n";
//                        out_array_size++;
//						if (out_array_size >= max_allowed_num_of_values)
//						{
//						  cout << "Max allowed number of values: " << max_allowed_num_of_values << " reached. Ending file read\n";
//						}
//                    }
//                    nTotalReadSize += nReadSize;
//                }else{
//                    bSuccess = FALSE;
//                    safe_print(printf("\nFaied to read the file \"%s\"\n", pDumpFile));
//                }
//            } // while
//            if (bSuccess)
//            safe_print(printf("\n"));
//            Fat_FileClose(hFile);
//        }else{
//            bSuccess = FALSE;
//            safe_print(printf("Cannot find the file \"%s\"\n", pDumpFile));
//        }
//    }
//    return bSuccess;
//}


terasic_bool Fat_Read_SD_File_Into_Vector_of_string(FAT_HANDLE hFat, char *pDumpFile, vector<string>& file_string_vector)
{
    terasic_bool bSuccess;
    int nCount = 0;
    FAT_BROWSE_HANDLE hBrowse;
    FILE_CONTEXT FileContext;

    bSuccess = Fat_FileBrowseBegin(hFat, &hBrowse);
    if (bSuccess){
        while(Fat_FileBrowseNext(&hBrowse, &FileContext)){
            if (FileContext.bLongFilename){
                alt_u16 *pData16;
                alt_u8 *pData8;
                pData16 = (alt_u16 *)FileContext.szName;
                pData8 = (alt_u8 *) FileContext.szName;
               // safe_print(printf("[%d]", nCount));
                while(*pData16){
                    if (*pData8)
                        {
                    	//safe_print(printf("%c", *pData8));
                        }
                    pData8++;
                    if (*pData8)
                    {
                        //safe_print(printf("%c", *pData8));
                    }
                    pData8++;
                    //
                    pData16++;
                }
                //safe_print(printf("\n"));

            }else{
                //safe_print(printf("[%d]%s\n", nCount, FileContext.szName));
            }
            nCount++;
        }
    }

    file_string_vector.clear();
    string actual_string;
    actual_string = "";

    if (bSuccess && pDumpFile && strlen(pDumpFile)){
        FAT_FILE_HANDLE hFile;
        hFile =  Fat_FileOpen(hFat, pDumpFile);
        if (hFile){
            char szRead[256];
            int nReadSize, nFileSize, nTotalReadSize=0;
            nFileSize = Fat_FileSize(hFile);
            if (nReadSize > sizeof(szRead))
                nReadSize = sizeof(szRead);
            safe_print(printf("Reading %s into vector of string\n", pDumpFile));
            while(bSuccess && nTotalReadSize < nFileSize){
                nReadSize = sizeof(szRead);
                if (nReadSize > (nFileSize - nTotalReadSize))
                    nReadSize = (nFileSize - nTotalReadSize);
                //
                if (Fat_FileRead(hFile, szRead, nReadSize)){
                    for (int i=0; i<nReadSize; i++)
                    {
                        //safe_print(printf("%c%c%c%c%c%c%c%c\n", szRead[i],szRead[i+1], szRead[i+2],szRead[i+3],szRead[i+4],szRead[i+5], szRead[i+6],szRead[i+7]));
                        if (szRead[i] != '\n')
                        	{
                        	  actual_string.append(1,szRead[i]);
                        	} else
                        	{
                        	  file_string_vector.push_back(actual_string);
                        	  actual_string = "";
                        	}
                    }
                    nTotalReadSize += nReadSize;
                }else{
                    bSuccess = FALSE;
                    safe_print(printf("\nFaied to read the file \"%s\"\n", pDumpFile));
                }
            } // while
            if (bSuccess)
            safe_print(printf("\n"));
            Fat_FileClose(hFile);
        }else{
            bSuccess = FALSE;
            safe_print(printf("Cannot find the file \"%s\"\n", pDumpFile));
        }
    }
    return bSuccess;
}

//vector<string> read_from_sd_card_into_string_vector(string filename)
//{
//	vector<string> temp_string_vec_array;
//	select_terasic_sd_driver();
//	FAT_HANDLE hFat;
//	char filename_str[256];
//	sprintf(filename_str, "%s", filename.c_str());
//	hFat = Fat_Mount(FAT_SD_CARD, 0);
//	safe_print(printf("Mounting SD Card.....\n"));
//	if (hFat)
//	{
//		safe_print(printf("sdcard mount success!\n"));
//		safe_print(printf("Root Directory Item Count:%d\n", Fat_FileCount(hFat)));
//		Fat_Read_SD_File_Into_Vector_of_string(hFat, filename_str, temp_string_vec_array);
//	}
//	else
//	{
//			safe_print(printf("Failed to mount the SDCARD!\nPlease insert the SDCARD into DE3 board and press BUTTON3.\n"));
//	}
//	return temp_string_vec_array;
//}
//===============================================================================================

//std::string read_from_sd_card_into_string(std::string filename)
//{
//	string total_string;
//	vector<string> temp_string_vec_array;
//	temp_string_vec_array = read_from_sd_card_into_string_vector(filename);
//	for (unsigned int i = 0; i < temp_string_vec_array.size(); i++)
//	{
//  	 total_string += temp_string_vec_array[i];
//  	 total_string += "\n";
//	}
//	return (total_string);
//}

int test_SD_card()
{
	//select_terasic_sd_driver();
    //
	//FAT_HANDLE hFat;
	//unsigned long test_array[20000];
	//unsigned long test_array_length;
	//safe_print(printf("========== DE3 SDCARD Test ================"));
    //
	//hFat = Fat_Mount(FAT_SD_CARD, 0);
	//if (hFat){
	//	safe_print(printf("sdcard mount success!\n"));
	//	safe_print(printf("Root Directory Item Count:%d\n", Fat_FileCount(hFat)));
	//	Fat_Test(hFat, "test.txt");
	//	Fat_Read_SD_File_Into_Long_Array(hFat, "test.txt", test_array,test_array_length, MAX_NUM_OF_32BIT_VALUES_IN_PATTERN_RAM);
	//	cout << "Read " << test_array_length << " unsigned long values from SD card:\n";
	//	for (unsigned long i = 0; i<test_array_length; i++ )
	//	{
	//		cout << hex << test_array[i] << dec << "\n";
	//	}
	//	Fat_Unmount(hFat);
	//}else{
	//	safe_print(printf("Failed to mount the SDCARD!\nPlease insert the SDCARD into DE3 board and press BUTTON3.\n"));
	//}
	return 0;
}


int cat_file_from_SD_card(char* filename)
{
	select_terasic_sd_driver();

	FAT_HANDLE hFat;
	unsigned long test_array[20000];
	unsigned long test_array_length;

	safe_print(printf("Mounting SD Card.....\n"));
	hFat = Fat_Mount(FAT_SD_CARD, 0);
	if (hFat){
		safe_print(printf("sdcard mount success!\n"));
		safe_print(printf("Root Directory Item Count:%d\n", Fat_FileCount(hFat)));
		print_file_contents(hFat, filename);
		Fat_Unmount(hFat);
	}else{
		safe_print(printf("Failed to mount the SDCARD!\nPlease insert the SDCARD into DE3 board and press BUTTON3.\n"));
	}
	return 0;
}


void ls_SD_card()
{
	select_terasic_sd_driver();

	FAT_HANDLE hFat;
	safe_print(printf("========== DE3 SD Card Directory Listing =============\n"));

	//IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, LED_BLUE_PATTERN);
	hFat = Fat_Mount(FAT_SD_CARD, 0);
	if (hFat){
		safe_print(printf("sdcard mount success!\n"));
		safe_print(printf("Root Directory Item Count:%d\n", Fat_FileCount(hFat)));
	//	IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, LED_GREEN_PATTERN);
	}else{
		safe_print(printf("Failed to mount the SDCARD!\nPlease insert the SDCARD into DE3 board and press BUTTON3.\n"));
	//	IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, LED_RED_PATTERN);
	}
	terasic_bool bSuccess;
	int nCount = 0;
	FAT_BROWSE_HANDLE hBrowse;
	FILE_CONTEXT FileContext;

	bSuccess = Fat_FileBrowseBegin(hFat, &hBrowse);
	if (bSuccess){
		while(Fat_FileBrowseNext(&hBrowse, &FileContext)){
			if (FileContext.bLongFilename){
				alt_u16 *pData16;
				alt_u8 *pData8;
				pData16 = (alt_u16 *)FileContext.szName;
				pData8 = (alt_u8 *) FileContext.szName;
				safe_print(printf("[%d]", nCount));
				while(*pData16){
					if (*pData8)
						safe_print(printf("%c", *pData8));
					pData8++;
					if (*pData8)
						safe_print(printf("%c", *pData8));
					pData8++;
					//
					pData16++;
				}
				safe_print(printf("\n"));

			}else{
				safe_print(printf("[%d]%s\n", nCount, FileContext.szName));
			}
			nCount++;
		}
	}
	Fat_Unmount(hFat);
}



/*****************************************************************************
*  Function: calc_crc16
*
*  Purpose: Calculates a CRC16 value from a block of data.
*
*  Returns: CRC16 value
*
*****************************************************************************/
alt_u16 calc_crc16( const alt_u8* data, alt_u32 length )
{
  alt_u8 xor_flag;
  alt_u16 crc = 0;
  alt_u16 data_byte;
  int bit_index, byte_index;

  for( byte_index = 0; byte_index < length; byte_index++ )
  {
    data_byte = (alt_u16)data[byte_index];
    data_byte <<= 8;
    for ( bit_index = 0; bit_index < 8; bit_index++ )
    {
      if ((crc ^ data_byte) & 0x8000)
      {
        xor_flag = 1;
      }
      else
      {
        xor_flag = 0;
      }
      crc = crc << 1;
      if (xor_flag)
      {
        crc = crc ^ 0x1021;
      }
      data_byte = data_byte << 1;
    }
  }
  return( crc );
}


// Added - Nadav 06/05/10
terasic_bool SD_write_block(alt_u32 block_number, const alt_u8 *buff)
{
  // buffer size must be 512 byte
  alt_u8 c=0;
  alt_u32  i,addr,j; //j,addr;
  alt_u16 crc;
  unsigned long long end_time, start_time;
  unsigned long long total_runtime;
 double double_total_runtime;

  char start_TS[50],end_TS[50],total_TS[50];
    crc = calc_crc16( buff, 512 );

    // issue cmd24 for 'Single Block Write'. parameter: block address
    {
      Ncc();
      addr = block_number * 512;
      cmd_buffer[0] = cmd24[0]; // CMD24: Write Single Block
      cmd_buffer[1] = (addr >> 24 ) & 0xFF; // MSB
      cmd_buffer[2] = (addr >> 16 ) & 0xFF;
      cmd_buffer[3] = (addr >> 8 ) & 0xFF;
      cmd_buffer[4] = addr & 0xFF; // LSB
      send_cmd(cmd_buffer);
      SDCARD_DEBUG(("CMD24[WR_BLK_CMD]\r\n"));
      Ncr();

      if(response_R(1)>1){ //response too long or crc error
        SDCARD_DEBUG(("response error for CMD24\r\n"));
        return FALSE;
      }

    }
      SD_CMD_HIGH;
      SD_DAT_OUT;

      // Data Write Token 1111111
      SD_DAT_HIGH;
      for(i=0;i<7;i++)
      {
        SD_CLK_LOW;
        SD_CLK_HIGH;
      }

     // Data Token Start Bit (0)
      SD_CLK_LOW;
      SD_DAT_LOW;
      SD_CLK_HIGH;

    // write data (512byte = 1 block)
    for(i=0;i<512;i++)
    {
      alt_u8 b;
      c = 0; // richard add
      b = buff[i];


        for(j=0; j<8; j++)
        {
          SD_CLK_LOW;
          if(b&0x80)
          SD_DAT_HIGH;
          else
          SD_DAT_LOW;
          SD_CLK_HIGH;
          b<<=1;
        }
     }

    // Adding the 16bit CRC
    for(j=0; j<16; j++)
    {
          SD_CLK_LOW;
          if(crc&0x8000)
          SD_DAT_HIGH;
          else
          SD_DAT_LOW;
          SD_CLK_HIGH;
          crc<<=1;
     }

    // End bit
    SD_CLK_LOW;
    SD_DAT_HIGH;
    SD_CLK_HIGH;
    SD_DAT_IN;
    start_time=low_level_system_timestamp();
    // Wait for Status
    while(1)
    {
        SD_CLK_LOW;
        SD_CLK_HIGH;
        if((SD_TEST_DAT & 0x01) == 0x00)
            break;

        end_time=low_level_system_timestamp(); if (start_time > end_time) { /* in case of some weird timer wrap */ start_time = end_time; }
        total_runtime = (end_time - start_time);
        if (total_runtime > WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS)
        {
        	 convert_ull_to_string(start_time,start_TS);
        	 convert_ull_to_string(end_time,end_TS);
        	 convert_ull_to_string(total_runtime,total_TS);
        	 safe_print(printf("\n[TERASIC_LINNUX_DRIVER][TS_sec=%lu] SD_write_block checkpoint 1: Timed out!start=%s end = %s total=%s\n",low_level_system_timestamp_in_secs(),start_TS,end_TS,total_TS));
        	 double_total_runtime = ((double) end_time) - ((double) start_time);
        	           safe_print(printf("double_total_runtime = %lf  (double) total_runtime = %lf  total_h = %lu total_l = %lu\n",double_total_runtime, (double) total_runtime, (unsigned long) (total_runtime >> 32), (unsigned long) (total_runtime % (1ULL<<32))));
        	           if (((double)total_runtime) > ((double)WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS))
        	           {
        	             return FALSE;
        	           } else {
        	         	  safe_print(printf("Double results are not bigger than watchdog of %lf, continuing!\n",(double)WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS));
        	           }
        }
     }

     // Read Transfer status
     c = 0;
     for(j=0;j<3;j++)
      {
        SD_CLK_LOW;
        SD_CLK_HIGH;
        c <<= 1;
        if(SD_TEST_DAT & 0x01)  // check bit0
        c |= 0x01;
      }

    //safe_print(printf("response = %d \n",c));
     start_time=low_level_system_timestamp();
    // Wait for transfer to finish
    while(1)
    {
        SD_CLK_LOW;
        SD_CLK_HIGH;
        if((SD_TEST_DAT & 0x01) == 0x01)
            break;
        end_time=low_level_system_timestamp(); if (start_time > end_time) { /* in case of some weird timer wrap */ start_time = end_time; }
        total_runtime = (end_time - start_time);
        if (total_runtime > WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS)
        {
        	convert_ull_to_string(start_time,start_TS);
        	convert_ull_to_string(end_time,end_TS);
        	convert_ull_to_string(total_runtime,total_TS);
        	safe_print(printf("\n[TERASIC_LINNUX_DRIVER][TS_Sec=%lu] SD_write_block checkpoint 2: Timed out! start=%s end = %s total=%s\n",low_level_system_timestamp_in_secs(),start_TS,end_TS,total_TS));
        	double_total_runtime = ((double) end_time) - ((double) start_time);
        	          safe_print(printf("double_total_runtime = %lf  (double) total_runtime = %lf  total_h = %lu total_l = %lu\n",double_total_runtime, (double) total_runtime, (unsigned long) (total_runtime >> 32), (unsigned long) (total_runtime % (1ULL<<32))));
        	          if (((double)total_runtime) > ((double)WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS))
        	          {
        	            return FALSE;
        	          } else {
        	        	  safe_print(printf("Double results are not bigger than watchdog of %lf, continuing!\n",(double)WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS));
        	          }
        }
     }

    SD_CMD_HIGH;
    Ncc();

    start_time=low_level_system_timestamp();
    while(1)
    {
        SD_CLK_LOW;
        SD_CLK_HIGH;
        if((SD_TEST_DAT & 0x01) == 0x01)
            break;
        end_time=low_level_system_timestamp(); if (start_time > end_time) { /* in case of some weird timer wrap */ start_time = end_time; }
        total_runtime = (end_time - start_time);
        if (total_runtime > WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS)
        {
        	convert_ull_to_string(start_time,start_TS);
        	convert_ull_to_string(end_time,end_TS);
        	convert_ull_to_string(total_runtime,total_TS);
        	safe_print(printf("\n[TERASIC_LINNUX_DRIVER][TS_Sec=%lu] SD_write_block checkpoint 3: Timed out! start=%s end = %s total=%s\n",low_level_system_timestamp_in_secs(),start_TS,end_TS,total_TS));
        	double_total_runtime = ((double) end_time) - ((double) start_time);
        	          safe_print(printf("double_total_runtime = %lf  (double) total_runtime = %lf  total_h = %lu total_l = %lu\n",double_total_runtime, (double) total_runtime, (unsigned long) (total_runtime >> 32), (unsigned long) (total_runtime % (1ULL<<32))));
        	          if (((double)total_runtime) > ((double)WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS))
        	          {
        	            return FALSE;
        	          } else {
        	        	  safe_print(printf("Double results are not bigger than watchdog of %lf, continuing!\n",(double)WATCHDOG_TIME_FOR_FOR_SD_CARD_IN_64_BIT_COUNTER_TICKS));
        	          }
        }
     }


  return TRUE;
}
