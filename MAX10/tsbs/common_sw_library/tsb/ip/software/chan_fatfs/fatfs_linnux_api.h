/*
 * fatfs_linnux_api.h
 *
 *  Created on: Jun 15, 2011
 *      Author: linnyair
 */

#ifndef FATFS_LINNUX_API_H_
#define FATFS_LINNUX_API_H_


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
#include <stdio.h>
#include <unistd.h>
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "system.h"

//#include "linnux_testbench_constants.h"
#include "linnux_utils.h"
#include "terasic_linnux_driver.h"

#include "integer.h"
#include "diskio.h"
#include "ff.h"
#include "cgicc/CgiDefs.h"
#include "cgicc/Cgicc.h"
#define MAX_LINNUX_NUM_OPEN_FILES 50
extern std::vector<FIL*> linnux_global_file_object_vec;

std::string get_directory_html_string( std::string path);
void select_terasic_sd_driver();
void select_altera_sd_driver();
std::string fatfs_showdir();
int fatfs_mount_SD_drive();
int fatfs_unmount_SD_drive();
DSTATUS fatfs_init_SD_drive();
int fatfs_check_init_SD_drive();
void fatfs_print_file_contents(std::string filename);
std::vector<std::string> read_from_sd_card_into_string_vector(std::string filename);
std::string read_from_sd_card_into_string(std::string filename);
int linnux_sd_card_file_open_for_write(std::string);
int linnux_sd_card_file_open_for_overwrite(std::string);

int linnux_sd_card_file_open_for_read(std::string filename);

int linnux_sd_card_write_string_to_file(int, std::string);
int linnux_sd_card_fclose(int);
int linnux_sd_card_file_is_open(int fileindex);
int linnux_sd_card_close_all_files();
FRESULT check_that_disk_is_mounted();
int fatfs_copy_file(std::string src_file, std::string dest_file);
int Fat_Read_SD_File_Into_Long_Array(std::string filename, unsigned long* out_array, unsigned long& out_array_size, unsigned long max_allowed_num_of_values);
std::vector<unsigned long> read_from_sd_card_into_ulong_vector(std::string filename);
std::vector<unsigned char> read_from_sd_card_into_byte_vector(std::string filename);
int read_binary_file_from_sd_card_into_char_array(std::string filename, unsigned char **outbuf, unsigned int& bytes_actually_read);
std::string linnux_sd_card_read_string_from_file(int file_index);


// Map to associate the error strings with the enum values
typedef std::map<FRESULT,std::string> fatfs_error_description_type;
typedef std::map<DRESULT,std::string> diskio_error_description_type;
typedef std::map<DSTATUS,std::string> dstatus_error_description_type;


void init_fatfs_error_descriptions();
void init_diskio_error_descriptions();
void init_dstatus_error_descriptions();
std::string get_fatfs_error_description(FRESULT the_error);
std::string get_diskio_error_description(DRESULT the_error);
std::string get_dstatus_error_description(DSTATUS the_error);




#endif /* FATFS_LINNUX_API_H_ */
