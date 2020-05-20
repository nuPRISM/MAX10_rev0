/*
 * terasic_linnux_driver.h
 *
 *  Created on: Apr 19, 2011
 *      Author: linnyair
 */

#ifndef TERASIC_LINNUX_DRIVER_H_
#define TERASIC_LINNUX_DRIVER_H_
#include "terasic_lib/terasic_includes.h"
#include "terasic_fat/FatFileSystem.h"
#include "terasic_fat/FatInternal.h"
#include "terasic_sdcard/SDCardDriver.h"
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

//terasic_bool Fat_Read_SD_File_Into_Long_Array(FAT_HANDLE hFat, char *pDumpFile, unsigned long* out_array, unsigned long& out_array_size, unsigned long max_allowed_num_of_values);
void ls_SD_card();
int test_SD_card();
int cat_file_from_SD_card(char*);
terasic_bool SD_card_init(void);
terasic_bool SD_read_block(alt_u32 block_number, alt_u8 *buff);
terasic_bool SD_write_block(alt_u32 block_number, const alt_u8 *buff);


terasic_bool Fat_Read_SD_File_Into_Vector_of_string(FAT_HANDLE hFat, char *pDumpFile, std::vector<std::string>& file_string_vector);
//std::vector<std::string> read_from_sd_card_into_string_vector(std::string filename);
//std::string read_from_sd_card_into_string(std::string filename);


#endif /* TERASIC_LINNUX_DRIVER_H_ */
