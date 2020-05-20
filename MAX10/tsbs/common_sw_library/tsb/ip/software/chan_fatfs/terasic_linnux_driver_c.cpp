/*
 * terasic_linnux_driver.cpp
 *
 *  Created on: Apr 19, 2011
 *      Author: linnyair
 */

#include "terasic_linnux_driver_c.h"
#include "terasic_linnux_driver.h"
//#include "linnux_testbench_constants.h"
//#include "register_keeper_api.h"
#include "fatfs_linnux_api.h"
#include "fatfs_linnux_api.h"
#include <alt_types.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>
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
#include "send_to_ethernet_stdout.h"

extern "C" {
 #include "my_mem_defs.h"
 #include "mem.h"
}

using namespace std;

#ifdef USE_DE2115_TYPE_SD_CONTROL

int sd_test_command(){
	SD_CMD_IN;
	return (IORD_ALTERA_AVALON_PIO_DATA(SD_CMD_BASE));
}
int sd_test_data(){
	SD_DAT_IN; return (IORD_ALTERA_AVALON_PIO_DATA(SD_DAT_BASE));
}
#endif

int SD_card_init_for_diskio(void)
{
	select_terasic_sd_driver();
	return SD_card_init();
}

int SD_read_block_for_diskio(unsigned long  block_number, alt_u8 *buff)
{
	select_terasic_sd_driver();
	return (SD_read_block(block_number,buff));
}
int SD_write_block_for_diskio(unsigned long  block_number, const alt_u8 *buff)
{
	select_terasic_sd_driver();
	return (SD_write_block(block_number,buff));
}

char* read_from_sd_card_into_c_string(const char* filename)
{
	//*********************************************************************
	//deprecated, let's try to use read_from_sd_card_into_string instead
	//*********************************************************************
	 select_terasic_sd_driver();
	  string str;
	  char *buf;
	  //get file contents into buf
	  str = read_from_sd_card_into_string(string(filename));
	  //
	  buf = new char [str.size()+1];
      strcpy(buf,str.c_str());
	  return (buf);
}


char* read_from_sd_card_into_c_string_for_jim(const char* filename)
{
	 select_terasic_sd_driver();
	  string str;
	  char *buf;
	  //get file contents into buf
	  str = read_from_sd_card_into_string(string(filename));
	  buf = (char *) my_mem_malloc(str.size()+1);
      strcpy(buf,str.c_str());
	  return (buf);
}
