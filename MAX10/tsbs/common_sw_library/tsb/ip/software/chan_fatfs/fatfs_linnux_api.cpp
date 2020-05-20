/*
 * fatfs_linnux_api.cpp
 *
 *  Created on: Jun 15, 2011
 *      Author: linnyair
 */

#include "fatfs_linnux_api.h"
#include "fatfs_linnux_api.h"
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <cstdlib>
#include <time.h>
#include "basedef.h"
#include "global_stream_defs.hpp"
#include <new>
#include <string>
#include <vector>
#include <stdexcept>
#include <iostream>
#include <sstream>
#include <cstdlib>

#include "cgicc/CgiDefs.h"
#include "cgicc/Cgicc.h"
#include "cgicc/HTTPHTMLHeader.h"
#include "cgicc/HTMLClasses.h"
#include "fatfs_linnux_api.h"

extern "C" {
 #include "my_mem_defs.h"
 #include "mem.h"
}


#if HAVE_SYS_UTSNAME_H
#  include <sys/utsname.h>
#endif

#if HAVE_SYS_TIME_H
#  include <sys/time.h>
#endif
//#include "styles.h"
#include "url.h"
using namespace std;
using namespace cgicc;

vector<FIL*> linnux_global_file_object_vec(MAX_LINNUX_NUM_OPEN_FILES,(FIL*)NULL);
static fatfs_error_description_type fatfs_error_descriptions;
static diskio_error_description_type diskio_error_descriptions;
static dstatus_error_description_type dstatus_error_descriptions;

int number_of_open_files = 0;

static FATFS SDCard;
std::string   ShowDirectory( const char *path );
string ShowFatTime( WORD ThisTime );
string ShowFatDate( WORD ThisDate );
std::string Silent_ShowDirectory( const char *path );

std::string get_fatfs_error_description(FRESULT the_error) {
	return fatfs_error_descriptions[the_error];
}
std::string get_diskio_error_description(DRESULT the_error) {
	return diskio_error_descriptions[the_error];
}
std::string get_dstatus_error_description(DSTATUS the_error) {
	return dstatus_error_descriptions[the_error];
}

void init_fatfs_error_descriptions()
{
	fatfs_error_descriptions[FR_OK				    ]=  " (0) Succeeded ";
	fatfs_error_descriptions[FR_DISK_ERR			]=  " (1) A hard error occurred in the low level disk I/O layer ";
	fatfs_error_descriptions[FR_INT_ERR			    ]=  " (2) Assertion failed ";
	fatfs_error_descriptions[FR_NOT_READY			]=  " (3) The physical drive cannot work ";
	fatfs_error_descriptions[FR_NO_FILE			    ]=  " (4) Could not find the file ";
	fatfs_error_descriptions[FR_NO_PATH			    ]=  " (5) Could not find the path ";
	fatfs_error_descriptions[FR_INVALID_NAME		]=  " (6) The path name format is invalid ";
	fatfs_error_descriptions[FR_DENIED			    ]=  " (7) Access denied due to prohibited access or directory full ";
	fatfs_error_descriptions[FR_EXIST				]=  " (8) Access denied due to prohibited access ";
	fatfs_error_descriptions[FR_INVALID_OBJECT		]=  " (9) The file/directory object is invalid  ";
	fatfs_error_descriptions[FR_WRITE_PROTECTED	    ]=  " (10) The physical drive is write protected ";
	fatfs_error_descriptions[FR_INVALID_DRIVE		]=  " (11) The logical drive number is invalid ";
	fatfs_error_descriptions[FR_NOT_ENABLED		    ]=  " (12) The volume has no work area ";
	fatfs_error_descriptions[FR_NO_FILESYSTEM		]=  " (13) There is no valid FAT volume on the physical drive ";
	fatfs_error_descriptions[FR_MKFS_ABORTED		]=  " (14) The f_mkfs() aborted due to any parameter error ";
	fatfs_error_descriptions[FR_TIMEOUT			    ]=  " (15) Could not get a grant to access the volume within defined period ";
	fatfs_error_descriptions[FR_LOCKED				]=  " (16) The operation is rejected according to the file sharing policy  ";
	fatfs_error_descriptions[FR_NOT_ENOUGH_CORE	    ]=  " (17) LFN working buffer could not be allocated  ";
	fatfs_error_descriptions[FR_TOO_MANY_OPEN_FILES	]=  " (18) Number of open files > _FS_SHARE ";
}

void init_diskio_error_descriptions()
{
	diskio_error_descriptions[RES_OK]     =  "  0: Successful ";
	diskio_error_descriptions[RES_ERROR]  =  "  1: R/W Error ";
	diskio_error_descriptions[RES_WRPRT]  =  "  2: Write Protected ";
	diskio_error_descriptions[RES_NOTRDY] =  "  3: Not Ready ";
	diskio_error_descriptions[RES_PARERR] =  "  4: Invalid Parameter ";
}


void init_dstatus_error_descriptions()
{

//#define STA_NOINIT		0x01	/* Drive not initialized */
//#define STA_NODISK		0x02	/* No medium in the drive */
//#define STA_PROTECT		0x04	/* Write protected */

	dstatus_error_descriptions[0]  =  "  0: Successful ";
	dstatus_error_descriptions[1]  =  "  1: Drive not initialized ";
	dstatus_error_descriptions[2]  =  "  2: No medium in the drive ";
	dstatus_error_descriptions[3]  =  "  3: No medium in the drive, Drive not initialized ";
	dstatus_error_descriptions[4]  =  "  4: Write Protected ";
	dstatus_error_descriptions[5]  =  "  5: Write Protected, Drive not initialized ";
    dstatus_error_descriptions[6]  =  "  6: Write protected, No medium in the drive ";
    dstatus_error_descriptions[7]  =  "  7: Write protected, No medium in the drive, Drive not initialized ";
}



int linnux_sd_card_file_open_file(string filename, int is_for_read, int overwrite = 0)
{
	select_terasic_sd_driver();
	FIL* current_file_ptr = new FIL;
	int found_an_unused_file_index = 0;
	UINT current_file_index;

	if (number_of_open_files >= MAX_LINNUX_NUM_OPEN_FILES)
	{
		out_to_all_streams("Error opening file :" << filename <<" max number of simultaneous open files " << MAX_LINNUX_NUM_OPEN_FILES << " reached\n");
		return LINNUX_RETVAL_ERROR;
	}

	FRESULT open_operation_status;
	if (is_for_read)
	{
		open_operation_status = f_open (
				current_file_ptr,       /* Pointer to the blank file object structure */
				filename.c_str(), /* Pointer to the file neme */
				FA_READ        /* Mode flags */
		);
	} else {
		if (overwrite)
		{
		open_operation_status = f_open (
				current_file_ptr,       /* Pointer to the blank file object structure */
				filename.c_str(), /* Pointer to the file neme */
				(FA_WRITE | FA_CREATE_ALWAYS) );       /* Mode flags */
		} else {
			open_operation_status = f_open (
							current_file_ptr,       /* Pointer to the blank file object structure */
							filename.c_str(), /* Pointer to the file neme */
							(FA_WRITE | FA_CREATE_NEW) );       /* Mode flags */
		}

	}
	if (open_operation_status != FR_OK)
	{
		out_to_all_streams("Error opening file " << filename <<": Error is [" << fatfs_error_descriptions[open_operation_status] << "]" << endl);
		return LINNUX_RETVAL_ERROR;
	}
	for (size_t i = 0; i < linnux_global_file_object_vec.size(); i++)
	{
		if 	(linnux_global_file_object_vec.at(i) == (FIL*)NULL)
		{
			current_file_index = i;
			linnux_global_file_object_vec.at(i) = current_file_ptr;
			found_an_unused_file_index = 1;
			number_of_open_files++;
			break;
		}
	}
	if (found_an_unused_file_index)
	{
		out_to_all_streams("Opened file index: " << current_file_index << " for file: " << filename << endl);
		return current_file_index;
	} else
	{
		out_to_all_streams("Error opening file " << filename <<": max number of simultaneous open files, which is " << linnux_global_file_object_vec.size() << " has been reached\n");
		return LINNUX_RETVAL_ERROR;
	}
}

int linnux_sd_card_file_open_for_read(string filename)
{
	return (linnux_sd_card_file_open_file(filename,1,0));
}


int linnux_sd_card_file_open_for_write(string filename)
{
	return (linnux_sd_card_file_open_file(filename,0,0));
}


int linnux_sd_card_file_open_for_overwrite(string filename)
{
	return (linnux_sd_card_file_open_file(filename,0,1));
}


int linnux_sd_card_fclose(int file_index)
{
	select_terasic_sd_driver();
	if ((file_index >= MAX_LINNUX_NUM_OPEN_FILES) || (file_index < 0))
	{
		out_to_all_streams("Error: file index " << file_index << " is not a valid file index\n");
		return (0);
	}
	if (linnux_global_file_object_vec.at(file_index) == (FIL*) NULL)
	{
		out_to_all_streams("Error: file index " << file_index << " does not refer to an open file\n");
		return (0);
	}

	//OK, file index is valid and file name is open, lets close it

	FRESULT operation_result = f_close (linnux_global_file_object_vec.at(file_index)    /* File object */
	                                 );
	if (operation_result != FR_OK)
	{
		out_to_all_streams("Error while closing file file with file index " << file_index << " Error is: [" << fatfs_error_descriptions[operation_result] << "]" << endl);
		linnux_global_file_object_vec.at(file_index) = (FIL*) NULL;
		number_of_open_files--;
		out_to_all_streams("Warning: File index " << file_index <<  " is nonetheless being returned to the free index pool\n");
		return 0;
	}
	else
	{
		delete linnux_global_file_object_vec.at(file_index);
		linnux_global_file_object_vec.at(file_index) = (FIL*) NULL;
		number_of_open_files--;
		return (1);
	}
}

int linnux_sd_card_file_is_open(int fileindex)
{
	return (linnux_global_file_object_vec.at(fileindex) != (FIL*) NULL);
}

int linnux_sd_card_close_all_files()
{
	int closed_file_count = 0;
	for (int file_index = 0; file_index < MAX_LINNUX_NUM_OPEN_FILES; file_index++)
	{
	  	if (linnux_sd_card_file_is_open(file_index))
	  	{
	  		if (linnux_sd_card_fclose(file_index))
	  		{
	  			closed_file_count++;
	  		}
	  	}
	}
	return closed_file_count;
}

int linnux_sd_card_write_string_to_file(int file_index, string the_str)
{
	select_terasic_sd_driver();
	if ((file_index >= MAX_LINNUX_NUM_OPEN_FILES) || (file_index < 0))
	{
		out_to_all_streams_safe("Error: file index " << file_index << " is not a valid file index\n");
		return (0);
	}
	if (linnux_global_file_object_vec.at(file_index) == (FIL*) NULL)
	{
		out_to_all_streams_safe("Error: file index " << file_index << " does not refer to an open file\n");
		return (0);
	}

	//OK, file index is valid and file name is open, put the string

//	int operation_result = f_puts (
//			the_str.c_str(),  /* String */
//			linnux_global_file_object_vec[file_index]    /* File object */
//	);


	for (size_t current_char_index = 0; current_char_index < the_str.length(); current_char_index++)
	{
	    int operation_result = f_putc (
			the_str.at(current_char_index),  /* String */
			linnux_global_file_object_vec.at(file_index)    /* File object */
	    );
	    if (operation_result < 0)
	  	{
	    	out_to_all_streams_safe("Error [" <<  operation_result << "] while writing to file with file index " << file_index << "\n");
	  		return (0);
	  	}
	}

    //	FRESULT operation_result = f_sync(linnux_global_file_object_vec[file_index]);
    //	if (operation_result != FR_OK)
   // {
	//  out_to_all_streams_safe("Error [" << fatfs_error_descriptions[file_result] << "] while syncing write to file with file index " << file_index << ": Error is [" << fatfs_error_descriptions[operation_result] << "]" << endl);
	//  return(0);
	//}
	return (1);
}


string linnux_sd_card_read_string_from_file(int file_index)
{
	string result_str = "";
	char buf [1024];
	const UINT num_bytes_to_read = 1; //must be 1 for this to work correctly
	UINT bytes_actually_read;
    INT8U error_code;

	select_terasic_sd_driver();
	if ((file_index >= MAX_LINNUX_NUM_OPEN_FILES) || (file_index < 0))
	{
		out_to_all_streams_safe("Error: file index " << file_index << " is not a valid file index\n");
		return result_str;
	}
	if (linnux_global_file_object_vec.at(file_index) == (FIL*) NULL)
	{
		out_to_all_streams_safe("Error: file index " << file_index << " does not refer to an open file\n");
		return result_str;
	}

	//OK, file index is valid and file name is open, put the string

	do
	{
		error_code = f_read (  linnux_global_file_object_vec.at(file_index),    /* Pointer to the file object structure */
				buf,       /* Pointer to the buffer to store read data */
				num_bytes_to_read,    /* Number of bytes to read */
				&bytes_actually_read      /* Pointer to the variable to return number of bytes read */
		);
		if ((error_code == FR_OK ) && (bytes_actually_read > 0))
		{
			for (UINT i = 0; i < bytes_actually_read; i++)
			{
				if (buf[i] != '\n')
				{
					result_str.append(1,buf[i]);
				} else
				{
					return result_str;
				}
			}
		} else
		{
			return result_str;
		}
	} while (1);

	return ""; //not reached
}


int fatfs_mount_SD_drive()
{
	select_terasic_sd_driver();
	FRESULT file_result;
	out_to_all_streams_safe("Closing all files on SD Drive before mounting (just to close any open connections - Warning: may not handle other threads correctly)\n");
	linnux_sd_card_close_all_files();
	out_to_all_streams_safe("Unmounting SD Drive before mounting (just to close any open connections - Warning: may not handle other threads correctly)\n");
	fatfs_unmount_SD_drive();
	DSTATUS init_result = fatfs_init_SD_drive();
	if (init_result != RES_OK) {
		out_to_all_streams_safe("Error: Disk Initialize returned with error code " << init_result << "which is ("  << dstatus_error_descriptions[init_result] << ") \n");
		return 0;
	}

	/* 1) mount drive... */
	out_to_all_streams_safe("Now Mounting SD drive....\n")
	if( (file_result = f_mount( 0, &SDCard )) != FR_OK)
	{
		out_to_all_streams_safe("Couldn't mount drive, error is [" << fatfs_error_descriptions[file_result] << "]\r\n");
		return 0;
	}

	DRESULT error_number;
    if((error_number = disk_read(0, SDCard.win, SDCard.dirbase, 1)) != RES_OK)
	{
		out_to_all_streams_safe("\nCouldn't read directory sector, error is: [" << diskio_error_descriptions[error_number] << "]. Perhaps the card is not mounted?\n");
		return 0;
	}

	return 1;
}
DSTATUS fatfs_init_SD_drive()
{
	DSTATUS disk_operation_result;
	//DSTATUS disk_operation_result;
	if ((disk_operation_result = disk_initialize( 0 )) == RES_OK)	{
		return disk_operation_result;
	} else
	{
		out_to_all_streams_safe("Error [" << dstatus_error_descriptions[disk_operation_result] << "] while initializing SD drive control software\n");
		return disk_operation_result;
	}

}

int fatfs_check_init_SD_drive()
{
	char pathname[1026];
	FRESULT file_result = f_getcwd(pathname,1024);
	if (file_result == FR_OK)
	{
		return 1;
	} else
	{
		out_to_all_streams_safe("Error [" << fatfs_error_descriptions[file_result] << "] while initializing SD drive control software\n");
		return 0;
	}
}

int fatfs_unmount_SD_drive()
{
	FRESULT error_code;
	select_terasic_sd_driver();
	/* unmount drive... */
	if( (error_code=f_mount( 0, (FATFS*) NULL )) != FR_OK)
	{
		out_to_all_streams_safe("Couldn't unmount drive, error is: [" << fatfs_error_descriptions[error_code] << "]\n");
		return 0;
	}
	return 1;
}


FRESULT check_that_disk_is_mounted()
{
	char pathname[1026]="0:/";
	FRESULT file_result = f_getcwd(pathname,1024);
	return file_result;
}

std::string fatfs_showdir()
{
	char pathname[1026];
	FRESULT file_result = f_getcwd(pathname,1024);
	if (file_result == FR_OK)
		{
		  return Silent_ShowDirectory(pathname);
		} else
		{
			out_to_all_streams_safe("\nfatfs_showdir: Error getting path, error is [" << fatfs_error_descriptions[file_result] << "]. Perhaps the card is not mounted?\n");
			return "";
		}
}

std::string ShowDirectory( const char *path )
{
	select_terasic_sd_driver();
	FILINFO finfo;
	DIR dirs;
	FATFS *fs;
	char *fn;   /* This function is assuming non-Unicode cfg. */
	DWORD clust;
	ULONG TotalSpace, FreeSpace;
	FRESULT res;
	char VolumeLabel[12] = "Linnux_SD";
	char strbuf[1024];
	std::string total_dir_str = "";
#if _USE_LFN
	char lfn[_MAX_LFN * 2 + 1];
	finfo.lfname = lfn;
	finfo.lfsize = sizeof(lfn);
#endif

	/*
	 DRESULT error_number;

	if((error_number = disk_read(0, SDCard.win, SDCard.dirbase, 1)) != RES_OK)
	{
		out_to_all_streams("\nCouldn't read directory sector, error is: [" << diskio_error_descriptions[error_number] << "]. Perhaps the card is not mounted?\n");
		return;
	}*/


	//strncpy( VolumeLabel, (const char *)&SDCard.win, 11 );
	//VolumeLabel[ 11 ] = 0x00;
	if( f_opendir(&dirs, path) == FR_OK )
	{
		if( VolumeLabel[0] == ' ' )
			{out_to_all_streams("\r\n Volume in Linnux SD Card Drive has no label.\r\n");}
		else
			{out_to_all_streams("\r\n Volume in Linnux SD Card Drive " <<  string(VolumeLabel)  << " \r\n");}

		out_to_all_streams(" Directory of " << path << "\r\n\n");

		while( (f_readdir(&dirs, &finfo) == FR_OK) && finfo.fname[0] )
		{
			total_dir_str.append("[");
			total_dir_str.append(( finfo.fattrib & AM_RDO ) ? "r" : ".");
			total_dir_str.append(( finfo.fattrib & AM_HID ) ? "h" : ".");
			total_dir_str.append(( finfo.fattrib & AM_SYS ) ? "s" : ".");
			total_dir_str.append(( finfo.fattrib & AM_VOL ) ? "v" : ".");
			total_dir_str.append(( finfo.fattrib & AM_LFN ) ? "l" : ".");
			total_dir_str.append(( finfo.fattrib & AM_DIR ) ? "d" : ".");
			total_dir_str.append(( finfo.fattrib & AM_ARC ) ? "a" : ".");
			total_dir_str.append("]");
#if _USE_LFN
			fn = *finfo.lfname ? finfo.lfname : finfo.fname;
#else
			fn = finfo.fname;
#endif
			snprintf(strbuf,512," %s  %s   ",
					ShowFatDate(finfo.fdate).c_str(), ShowFatTime( finfo.ftime ).c_str());
			total_dir_str.append(strbuf);
			snprintf(strbuf,512,"%s %6ld %s\r\n", (finfo.fattrib & AM_DIR)?"<DIR>":"     ",
					finfo.fsize, fn );
			total_dir_str.append(strbuf);
		}
		out_to_all_streams(total_dir_str);
		return total_dir_str;
	}
	else
	{
		out_to_all_streams("The system cannot find the path specified.\r\n");
		return "";
	}

	//printf("%cCalculating disk space...\r", 0x09 );
	// Get free clusters
	//res = f_getfree("", &clust, &fs);
	//if( res )
	// {
	//    printf(" f_getfree() failed...\r\n");
	//    return;
	// }

	// TotalSpace = 1; //(DWORD)(fs->max_clust - 2) * fs->csize / 2;
	//FreeSpace = clust * fs->csize / 2;
	//printf("%c%lu KB total disk space.\r\n", 0x09, TotalSpace );
	//printf("%c%lu KB available on the disk.\r\n", 0x09, FreeSpace );
}



std::string Silent_ShowDirectory( const char *path )
{
	select_terasic_sd_driver();
	FILINFO finfo;
	DIR dirs;
	FATFS *fs;
	char *fn;   /* This function is assuming non-Unicode cfg. */
	DWORD clust;
	ULONG TotalSpace, FreeSpace;
	FRESULT res;
	char VolumeLabel[12] = "Linnux_SD";
	char strbuf[1024];
	std::string total_dir_str = "";
#if _USE_LFN
	char lfn[_MAX_LFN * 2 + 1];
	finfo.lfname = lfn;
	finfo.lfsize = sizeof(lfn);
#endif

	/*
	 DRESULT error_number;

	if((error_number = disk_read(0, SDCard.win, SDCard.dirbase, 1)) != RES_OK)
	{
		out_to_all_streams("\nCouldn't read directory sector, error is: [" << diskio_error_descriptions[error_number] << "]. Perhaps the card is not mounted?\n");
		return;
	}*/


	//strncpy( VolumeLabel, (const char *)&SDCard.win, 11 );
	//VolumeLabel[ 11 ] = 0x00;
	if( f_opendir(&dirs, path) == FR_OK )
	{
		while( (f_readdir(&dirs, &finfo) == FR_OK) && finfo.fname[0] )
		{
			total_dir_str.append("[");
			total_dir_str.append(( finfo.fattrib & AM_RDO ) ? "r" : ".");
			total_dir_str.append(( finfo.fattrib & AM_HID ) ? "h" : ".");
			total_dir_str.append(( finfo.fattrib & AM_SYS ) ? "s" : ".");
			total_dir_str.append(( finfo.fattrib & AM_VOL ) ? "v" : ".");
			total_dir_str.append(( finfo.fattrib & AM_LFN ) ? "l" : ".");
			total_dir_str.append(( finfo.fattrib & AM_DIR ) ? "d" : ".");
			total_dir_str.append(( finfo.fattrib & AM_ARC ) ? "a" : ".");
			total_dir_str.append("]");
#if _USE_LFN
			fn = *finfo.lfname ? finfo.lfname : finfo.fname;
#else
			fn = finfo.fname;
#endif
			snprintf(strbuf,512," %s  %s   ",
					ShowFatDate(finfo.fdate).c_str(), ShowFatTime( finfo.ftime ).c_str());
			total_dir_str.append(strbuf);
			snprintf(strbuf,512,"%s %6ld %s\r\n", (finfo.fattrib & AM_DIR)?"<DIR>":"     ",
					finfo.fsize, fn );
			total_dir_str.append(strbuf);
		}
		return total_dir_str;
	}
	else
	{
		out_to_all_streams("The system cannot find the path specified (" << std::string(path) << ".\r\n");
		return "";
	}

	//printf("%cCalculating disk space...\r", 0x09 );
	// Get free clusters
	//res = f_getfree("", &clust, &fs);
	//if( res )
	// {
	//    printf(" f_getfree() failed...\r\n");
	//    return;
	// }

	// TotalSpace = 1; //(DWORD)(fs->max_clust - 2) * fs->csize / 2;
	//FreeSpace = clust * fs->csize / 2;
	//printf("%c%lu KB total disk space.\r\n", 0x09, TotalSpace );
	//printf("%c%lu KB available on the disk.\r\n", 0x09, FreeSpace );
}






//
//char* ShowDirectory_for_FTP( const char *path, unsigned int long_listing )
//{
//	select_terasic_sd_driver();
//	FILINFO finfo;
//	DIR dirs;
//	FATFS *fs;
//	char *fn;   /* This function is assuming non-Unicode cfg. */
//	DWORD clust;
//	ULONG TotalSpace, FreeSpace;
//	FRESULT res;
//	char VolumeLabel[12];
//	char strbuf[1024];
//	char *retstr;
//	std::string total_dir_str = "";
//#if _USE_LFN
//	char lfn[_MAX_LFN * 2 + 1];
//	finfo.lfname = lfn;
//	finfo.lfsize = sizeof(lfn);
//#endif
//
//	retstr = NULL;
//	DRESULT error_number;
//
//	FRESULT file_result = f_getcwd(path,1024);
//				if (file_result == FR_OK)
//					{
//					   safe_print(std::cout << "\ShowDirectory_for_FTP: Error getting path, error is [" << fatfs_error_descriptions[file_result] << "]. Perhaps the card is not mounted?\n");
// 		               return NULL;
//	                 }
//
//	strncpy( VolumeLabel, (const char *)&SDCard.win, 11 );
//	VolumeLabel[ 11 ] = 0x00;
//	if( f_opendir(&dirs, path) == FR_OK )
//	{
//
//		while( (f_readdir(&dirs, &finfo) == FR_OK) && finfo.fname[0] )
//		{
//			total_dir_str.append("[");
//			total_dir_str.append(( finfo.fattrib & AM_RDO ) ? "r" : ".");
//			total_dir_str.append(( finfo.fattrib & AM_HID ) ? "h" : ".");
//			total_dir_str.append(( finfo.fattrib & AM_SYS ) ? "s" : ".");
//			total_dir_str.append(( finfo.fattrib & AM_VOL ) ? "v" : ".");
//			total_dir_str.append(( finfo.fattrib & AM_LFN ) ? "l" : ".");
//			total_dir_str.append(( finfo.fattrib & AM_DIR ) ? "d" : ".");
//			total_dir_str.append(( finfo.fattrib & AM_ARC ) ? "a" : ".");
//			total_dir_str.append("]");
//#if _USE_LFN
//			fn = *finfo.lfname ? finfo.lfname : finfo.fname;
//#else
//			fn = finfo.fname;
//#endif
//			sprintf(strbuf," %s  %s   ",
//					ShowFatDate(finfo.fdate).c_str(), ShowFatTime( finfo.ftime ).c_str());
//			total_dir_str.append(strbuf);
//			sprintf(strbuf,"%s %6ld %s\r\n", (finfo.fattrib & AM_DIR)?"<DIR>":"     ",
//					finfo.fsize, fn );
//			 //sprintf(strbuf,
//			//			          "%s 0 root root %11ld %s %s %s\r\n",
//			//			          "-rw-rw-rw-",(long) finfo.fsize,ShowFatDate(finfo.fdate).c_str(),ShowFatTime( finfo.ftime ).c_str(),fn);
//			total_dir_str.append(strbuf);
//		}
//	}
//	else
//	{
//		return NULL;
//	}
//	trio_asprintf(&retstr,"%s",total_dir_str.c_str());
//	return retstr;
//}


std::string get_directory_html_string( std::string path)
{
	select_terasic_sd_driver();
	FILINFO finfo;
	DIR dirs;
	FATFS *fs;
	char *fn;   /* This function is assuming non-Unicode cfg. */
	DWORD clust;
	ULONG TotalSpace, FreeSpace;
	FRESULT res;
	char VolumeLabel[12] = "Linnux_SD";
	char strbuf[1024];
	std::string total_dir_str = "";
#if _USE_LFN
	char lfn[_MAX_LFN * 2 + 1];
	finfo.lfname = lfn;
	finfo.lfsize = sizeof(lfn);
#endif
	ostringstream output_file_stream;
	DRESULT error_number;
	//safe_print(std::cout << "here 1\n" << endl);
	output_file_stream << title() << "Directory Listing for path " << path << title() << endl;
	output_file_stream << body();
/*
	if((error_number = disk_read(0, SDCard.win, SDCard.dirbase, 1)) != RES_OK)
	{
		output_file_stream << " Couldn't read directory sector, error is: [" << diskio_error_descriptions[error_number] << "]. Perhaps the card is not mounted?\n" << br();
		return output_file_stream.str();
	}
*/

	FRESULT file_result = check_that_disk_is_mounted();
			if (file_result != FR_OK)
				{
				   ostringstream error_str;
				   error_str << "\nfatfs_showdir: Error getting path, error is [" << fatfs_error_descriptions[file_result] << "]. Perhaps the card is not mounted?\n";
				   output_file_stream << error_str << body();
					//out_to_all_streams(error_str.str()); //cannot call out_to_all_streams here: it is not thread-safe!
					return output_file_stream.str();;
				}

    //safe_print(std::cout << "here 2" << endl);
	//strncpy( VolumeLabel, (const char *)&SDCard.win, 11 );
	//VolumeLabel[ 11 ] = 0x00;
	if( f_opendir(&dirs, path.c_str()) == FR_OK )
	{
		if( VolumeLabel[0] == ' ' )
			{output_file_stream << "\r\n Volume in Linnux SD Card Drive has no label" << br();}
		else
			{output_file_stream << "\r\n Volume in Linnux SD Card Drive " <<  VolumeLabel << br();}

		output_file_stream << " Directory of " << path << br();
		//safe_print(std::cout << "here 3" << endl);
		while( (f_readdir(&dirs, &finfo) == FR_OK) && finfo.fname[0] )
		{
			total_dir_str.append("[");
			total_dir_str.append(( finfo.fattrib & AM_RDO ) ? "r" : ".");
			total_dir_str.append(( finfo.fattrib & AM_HID ) ? "h" : ".");
			total_dir_str.append(( finfo.fattrib & AM_SYS ) ? "s" : ".");
			total_dir_str.append(( finfo.fattrib & AM_VOL ) ? "v" : ".");
			total_dir_str.append(( finfo.fattrib & AM_LFN ) ? "l" : ".");
			total_dir_str.append(( finfo.fattrib & AM_DIR ) ? "d" : ".");
			total_dir_str.append(( finfo.fattrib & AM_ARC ) ? "a" : ".");
			total_dir_str.append("]");
#if _USE_LFN
			fn = *finfo.lfname ? finfo.lfname : finfo.fname;
#else
			fn = finfo.fname;
#endif
			snprintf(strbuf,512," %s  %s   ",
					ShowFatDate(finfo.fdate).c_str(), ShowFatTime( finfo.ftime ).c_str());
			total_dir_str.append(strbuf);
			snprintf(strbuf,512,"%s %6ld  ", (finfo.fattrib & AM_DIR)?" &lt DIR &gt":"        ",
					finfo.fsize );
			total_dir_str.append(strbuf);
			if ( finfo.fattrib & AM_DIR ) {
				ostringstream tmpstr;
				ostringstream tmpstr2;
				string tmppath = path;
				if (tmppath[tmppath.length()-1] == '/')
				{
					tmppath.append(fn);
				} else
				{
					tmppath.append("/").append(fn);
				}
				tmpstr2 << "/cgi-bin/showdirectory?" << form_urlencode(tmppath);
				tmpstr << a(fn).set("href",tmpstr2.str()) << br();
				total_dir_str.append(tmpstr.str());
			} else {
				ostringstream tmpstr;
								ostringstream tmpstr2;
								if (path[path.length()-1] == '/')
								{
									tmpstr2 << path << fn;
								} else
								{
									tmpstr2 << path << "/" << fn;
								}
								tmpstr << a(fn).set("href",tmpstr2.str()) << br();
								total_dir_str.append(tmpstr.str());
			  }
			//safe_print(std::cout << "here 4\n" << "fn = " << fn << endl);
		}

	output_file_stream << total_dir_str;
	return output_file_stream.str();
	}
	else
	{
		output_file_stream << "The system cannot find the path specified" << br();
		return output_file_stream.str();
	}

}

string ShowFatTime( WORD ThisTime )
{
	char msg[15];
	BYTE AM = 1;

	int Hour, Minute, Second;

	Hour = ThisTime >> 11;        // bits 15 through 11 hold Hour...
	Minute = ThisTime & 0x07E0;   // bits 10 through 5 hold Minute... 0000 0111 1110 0000
	Minute = Minute >> 5;
	Second = ThisTime & 0x001F;   //bits 4 through 0 hold Second...   0000 0000 0001 1111

	if( Hour > 11 )
	{
		AM = 0;
		if( Hour > 12 )
			Hour -= 12;
	}

	snprintf( msg,12, "%02d:%02d:%02d %s", Hour, Minute, Second*2,
			(AM)?"AM":"PM");
	return( string(msg) );
}


string ShowFatDate( WORD ThisDate )
{
	char msg[15];

	int Year, Month, Day;

	Year = ThisDate >> 9;         // bits 15 through 9 hold year...
	Month = ThisDate & 0x01E0;    // bits 8 through 5 hold month... 0000 0001 1110 0000
	Month = Month >> 5;
	Day = ThisDate & 0x001F;      //bits 4 through 0 hold day...    0000 0000 0001 1111
	snprintf( msg,10, "%02d/%02d/%02d", Month, Day, Year-20);
	return( string(msg));
}

void fatfs_print_file_contents(string filename)
{

	FIL FileObject;
	FRESULT error_code;
	if (   (
			error_code = f_open (&FileObject,			/* Pointer to the blank file object */
					filename.c_str(),	/* Pointer to the file name */
					FA_READ)
	) != FR_OK )			/* Access mode and file open mode flags */
	{
		out_to_all_streams("Error [" << fatfs_error_descriptions[error_code] << "] in opening file: " << filename << "\n");
		return;
	}

	char buf [1024];
	const UINT num_bytes_to_read = 512;
	UINT bytes_actually_read;

	do
	{
		error_code = f_read (  &FileObject,    /* Pointer to the file object structure */
				buf,       /* Pointer to the buffer to store read data */
				num_bytes_to_read,    /* Number of bytes to read */
				&bytes_actually_read      /* Pointer to the variable to return number of bytes read */
		);
		if ((error_code == FR_OK ) && (bytes_actually_read > 0))
		{
			buf[bytes_actually_read] = '\0'; //terminate string
			out_to_all_streams(buf);
		} else
		{
			f_close(&FileObject);
			return;
		}
	} while (1);

}



vector<string> read_from_sd_card_into_string_vector(string filename)
		{
	vector<string> file_string_vector(0);
	FIL FileObject;
	FRESULT error_code;

	char buf [1024];
	const UINT num_bytes_to_read = 512;
	UINT bytes_actually_read;

	string actual_string = "";

	if ((error_code = f_open (&FileObject,			/* Pointer to the blank file object */
			filename.c_str(),	             /* Pointer to the file name */
			FA_READ)) != FR_OK )			/* Access mode and file open mode flags */
	{
		out_to_all_streams("Error [" << fatfs_error_descriptions[error_code] << "] in opening file: " << filename << "\n");
		return file_string_vector;
	}

	do
	{
		error_code = f_read (  &FileObject,    /* Pointer to the file object structure */
				buf,       /* Pointer to the buffer to store read data */
				num_bytes_to_read,    /* Number of bytes to read */
				&bytes_actually_read      /* Pointer to the variable to return number of bytes read */
		);
		if ((error_code == FR_OK ) && (bytes_actually_read > 0))
		{
			for (UINT i = 0; i < bytes_actually_read; i++)
			{
				if (buf[i] != '\n')
				{
					actual_string.append(1,buf[i]);
				} else
				{
					file_string_vector.push_back(actual_string);
					actual_string = "";
				}
			}
		} else
		{
			if (actual_string != "") file_string_vector.push_back(actual_string); //push in incomplete string if present
			f_close(&FileObject);
			return file_string_vector;
		}
	} while (1);
	return file_string_vector; //not reached
}


std::string read_from_sd_card_into_string(std::string filename)
{
	string total_string;
	vector<string> temp_string_vec_array;
	temp_string_vec_array = read_from_sd_card_into_string_vector(filename);
	for (unsigned int i = 0; i < temp_string_vec_array.size(); i++)
	{
		total_string += temp_string_vec_array.at(i);
		total_string += "\n";
	}
	return (total_string);
}


void select_terasic_sd_driver()
{
	//IOWR_ALTERA_AVALON_PIO_DATA(SD_CARD_SELECT_DRIVER_BASE, 1);
}

void select_altera_sd_driver()
{
	//IOWR_ALTERA_AVALON_PIO_DATA(SD_CARD_SELECT_DRIVER_BASE, 0);
}

int fatfs_copy_file(string src_file, string dest_file)
{
	BYTE buffer[4096];   /* file copy buffer */
	FRESULT res;         /* FatFs function common result code */
	UINT br, bw;         /* File read/write count */
	FIL fsrc, fdst;

	res = f_open(&fsrc, src_file.c_str(), FA_OPEN_EXISTING | FA_READ);
	if (res != FR_OK) {out_to_all_streams("Error: [" << fatfs_error_descriptions[res] << "] while opening source " << src_file << " while copying... " << endl); return(0);}

	/* Create destination file on the drive 0 */
	res = f_open(&fdst, dest_file.c_str(), FA_CREATE_ALWAYS | FA_WRITE);
	if (res != FR_OK) {out_to_all_streams("Error: [" << fatfs_error_descriptions[res] << "] while opening destination  " << dest_file << " while copying... " << endl); return(0);}

	/* Copy source to destination */
	for (;;) {
		res = f_read(&fsrc, buffer, sizeof(buffer), &br);    /* Read a chunk of src file */
		if (res || br == 0) break; /* error or eof */
		res = f_write(&fdst, buffer, br, &bw);               /* Write it to the dst file */
		if (res || bw < br) break; /* error or disk full */
	}
	/* Close open files */
	f_close(&fsrc);
	f_close(&fdst);
	return(1);
}


int read_binary_file_from_sd_card_into_char_array(string filename, unsigned char **outbuf, unsigned int& bytes_actually_read)
		{
	vector<unsigned char> file_byte_vector(0);
	FIL FileObject;
	FRESULT error_code;
	unsigned long current_long_val;

	if ((error_code = f_open (&FileObject,			/* Pointer to the blank file object */
			filename.c_str(),	             /* Pointer to the file name */
			FA_READ)) != FR_OK )			/* Access mode and file open mode flags */
	{
		out_to_all_streams("Error [" << fatfs_error_descriptions[error_code] << "] in opening file: " << filename << " \n");
		return LINNUX_RETVAL_ERROR;
	}
    unsigned int length;
    length = f_size(&FileObject);

	*outbuf = (unsigned char *) my_mem_malloc((length*sizeof(unsigned char))+2);

	error_code = f_read (  &FileObject,    /* Pointer to the file object structure */
				*outbuf,       /* Pointer to the buffer to store read data */
				length,    /* Number of bytes to read */
				&bytes_actually_read      /* Pointer to the variable to return number of bytes read */
		);

	if (error_code == FR_OK )
	{
		out_to_all_streams("Read " << bytes_actually_read << " byte values from file " << filename << " of length " << length << std::endl);
		f_close(&FileObject);
	    return (1);
	} else {
		out_to_all_streams("Error [" << fatfs_error_descriptions[error_code] << "] in reading file: " << filename << " of length " << length << " \n");
		f_close(&FileObject);
        return LINNUX_RETVAL_ERROR;
	}
}



vector<unsigned char> read_from_sd_card_into_byte_vector(string filename)
		{
	vector<unsigned char> file_byte_vector(0);
	FIL FileObject;
	FRESULT error_code;
	unsigned long current_long_val;
	const UINT num_bytes_to_read = 1024;
	char buf [2*num_bytes_to_read];
	UINT bytes_actually_read;

	string actual_string = "";

	if ((error_code = f_open (&FileObject,			/* Pointer to the blank file object */
			filename.c_str(),	             /* Pointer to the file name */
			FA_READ)) != FR_OK )			/* Access mode and file open mode flags */
	{
		out_to_all_streams("Error [" << fatfs_error_descriptions[error_code] << "] in opening file: " << filename << " \n");
		return file_byte_vector;
	}

	int value_counter = 0;
	do
	{

		actual_string = "";
		error_code = f_read (  &FileObject,    /* Pointer to the file object structure */
				buf,       /* Pointer to the buffer to store read data */
				num_bytes_to_read,    /* Number of bytes to read */
				&bytes_actually_read      /* Pointer to the variable to return number of bytes read */
		);
		value_counter+=bytes_actually_read;

		if ((error_code == FR_OK ) && (bytes_actually_read != 0) /*&& (bytes_actually_read == num_bytes_to_read)*/)
		{
			for (UINT i = 0; i < bytes_actually_read-1; i+=2)
			{
				file_byte_vector.push_back(convert_hex_char_to_num(buf[i])*16 + convert_hex_char_to_num(buf[i+1]));
			}

			if ((value_counter % (num_bytes_to_read*100)) == 0) {
								out_to_all_streams("Read " << value_counter << " byte values from file " << filename << std::endl);
			}
		}
		else
		{
			f_close(&FileObject);
			return file_byte_vector;
		}


	} while (1);
	return file_byte_vector; //not reached
}


vector<unsigned long> read_from_sd_card_into_ulong_vector(string filename)
		{
	vector<unsigned long> file_ulong_vector(0);
	FIL FileObject;
	FRESULT error_code;
	unsigned long current_long_val;
	char buf [1024];
	const UINT num_bytes_to_read = 8; //8 hex digits (32 bits) in unsigned long
	UINT bytes_actually_read;

	string actual_string = "";

	if ((error_code = f_open (&FileObject,			/* Pointer to the blank file object */
			filename.c_str(),	             /* Pointer to the file name */
			FA_READ)) != FR_OK )			/* Access mode and file open mode flags */
	{
		out_to_all_streams("Error [" << fatfs_error_descriptions[error_code] << "] in opening file: " << filename << " \n");
		return file_ulong_vector;
	}

	int value_counter = 0;
	do
	{
		value_counter++;
		actual_string = "";
		error_code = f_read (  &FileObject,    /* Pointer to the file object structure */
				buf,       /* Pointer to the buffer to store read data */
				num_bytes_to_read,    /* Number of bytes to read */
				&bytes_actually_read      /* Pointer to the variable to return number of bytes read */
		);
		if ((error_code == FR_OK ) && (bytes_actually_read != 0) /*&& (bytes_actually_read == num_bytes_to_read)*/)
		{
			for (UINT i = 0; i < num_bytes_to_read; i++)
			{
				if (i < bytes_actually_read) {
				     actual_string.append(1,buf[i]);
				} else {
					actual_string.append(1,'f'); //append 1's to any unfilled long. Good for Spartan images and indication of unalignment error for other files
				}
			}
			current_long_val = strtoul(actual_string.c_str(),NULL,16);
			file_ulong_vector.push_back(current_long_val);
		}
		else
		{
			f_close(&FileObject);
			return file_ulong_vector;
		}

		if ((value_counter % 1000) == 0) {
			out_to_all_streams("Read " << value_counter << " long values from file " << filename << std::endl);
		}
	} while (1);
	return file_ulong_vector; //not reached
}

int Fat_Read_SD_File_Into_Long_Array(string filename,
		unsigned long* out_array,
		unsigned long& out_array_size,
		unsigned long max_allowed_num_of_values)
{
	vector<unsigned long> file_ulong_vector = read_from_sd_card_into_ulong_vector(filename);
	size_t actual_upper_limit;

	if (file_ulong_vector.size() > max_allowed_num_of_values)
	{
		actual_upper_limit = max_allowed_num_of_values;
		out_to_all_streams("Warning: File " << filename << " contains more values than max allowed of " << max_allowed_num_of_values << " ; only " <<max_allowed_num_of_values << " values will be used\n" << endl);
	} else {
		actual_upper_limit = file_ulong_vector.size();
	}

	for (size_t i = 0; i < actual_upper_limit; i++ )
	{
		out_array[i] = file_ulong_vector.at(i);
	}

	out_array_size = actual_upper_limit;
	return (file_ulong_vector.size() != 0);
}




