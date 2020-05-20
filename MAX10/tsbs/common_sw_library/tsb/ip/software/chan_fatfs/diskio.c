/*-----------------------------------------------------------------------*/
/* Low level disk I/O module skeleton for FatFs     (C)ChaN, 2007        */
/*-----------------------------------------------------------------------*/
/* This is a stub disk I/O module that acts as front end of the existing */
/* disk I/O modules and attach it to FatFs module with common interface. */
/*-----------------------------------------------------------------------*/

#include "diskio.h"
#include "includes.h"
#include "terasic_linnux_driver_c.h"
#include "cpp_to_c_header_interface.h"
#include "basedef.h"
#include <xprintf.h>
#include <stdio.h>

/*-----------------------------------------------------------------------*/
/* Inidialize a Drive                                                    */
/*-----------------------------------------------------------------------*/

DSTATUS disk_initialize (
		BYTE drv				/* Physical drive nmuber (0..) */
)
{
	int cpu_sr;
#ifdef USE_SD_1BIT_MODE
	//	DSTATUS stat;
	int result;
	OS_ENTER_CRITICAL();
	result = SD_card_init_for_diskio();
	OS_EXIT_CRITICAL();

	if(result)
		return RES_OK;
	else
		return RES_NOTRDY;
#else
	int sd_card_is_present = SD_card_is_detected();
	if (!sd_card_is_present) {
#if WARN_ONLY_IF_SD_CARD_NOT_DETECTED
		safe_print(printf("Warning: File: %s Line %d Function:%s SD card not present!\n",__FILE__,__LINE__,__func__));
#else
		safe_print(printf("Error: File: %s Line %d Function:%s SD card not present!\n",__FILE__,__LINE__,__func__));
		return STA_NODISK;
#endif
	}
	DSTATUS result;
	OS_ENTER_CRITICAL();
	result = SD_SPI_disk_initialize(drv);
	OS_EXIT_CRITICAL();
	return result;
#endif
}



/*-----------------------------------------------------------------------*/
/* Return Disk Status                                                    */
/*-----------------------------------------------------------------------*/

DSTATUS disk_status (
		BYTE drv		/* Physical drive nmuber (0..) */
)
{
	int cpu_sr;
#ifdef USE_SD_1BIT_MODE
	return RES_OK;
#else

	DSTATUS result;
#if !DO_NOT_USE_OS_CRITICAL_WRAP_FOR_SD_CARD
	OS_ENTER_CRITICAL();
#endif
	result = SD_SPI_disk_status(drv);
#if !DO_NOT_USE_OS_CRITICAL_WRAP_FOR_SD_CARD
	OS_EXIT_CRITICAL();
#endif
	return result;

	//return RES_OK;
#endif
}



/*-----------------------------------------------------------------------*/
/* Read Sector(s)                                                        */
/*-----------------------------------------------------------------------*/

DRESULT disk_read (
		BYTE drv,		/* Physical drive nmuber (0..) */
		BYTE *buff,		/* Data buffer to store read data */
		DWORD sector,	/* Sector address (LBA) */
		BYTE count		/* Number of sectors to read (1..255) */
)
{

	int cpu_sr;

#ifdef USE_SD_1BIT_MODE
	DRESULT res;
	int i;
	int result=RES_ERROR;


	//	result = MMC_disk_read(buff, sector, count);
	for(i=0;i<count;i++)
	{
		// SD-NN
		OS_ENTER_CRITICAL();
		result = SD_read_block_for_diskio(sector+i, buff+i*512);
		if (!result) {
			printf("[diskio.c][TS_sec=%lu]Error in disk read, Sector = %X, i = %d, trying again!\n",c_low_level_system_timestamp_in_secs(),(unsigned int)sector,i);
			c_low_level_system_usleep(LINNUX_TIME_TO_WAIT_AFTER_DISK_ERROR_IN_US);
			result = SD_read_block_for_diskio(sector+i, buff+i*512);
			if (!result) {
				c_low_level_system_usleep(LINNUX_TIME_TO_WAIT_AFTER_DISK_ERROR_IN_US);
				printf("[diskio.c][TS_sec=%lu]Error in disk read, initializing SD card and trying again\n",c_low_level_system_timestamp_in_secs());
				result = SD_card_init_for_diskio();
				printf("[diskio.c][TS_sec=%lu]Result of SD_card_init is: %d\n",c_low_level_system_timestamp_in_secs(),result);
				c_low_level_system_usleep(LINNUX_TIME_TO_WAIT_AFTER_DISK_ERROR_IN_US);
				result = SD_read_block_for_diskio(sector+i, buff+i*512);
				printf("[diskio.c][TS_sec=%lu]Result of Second read is: %d\n",c_low_level_system_timestamp_in_secs(),result);
			} else {
				printf("[diskio.c][TS_sec=%lu]Retry #1 of read is successful!",c_low_level_system_timestamp_in_secs());
			}
		}
		OS_EXIT_CRITICAL();

		if (result == 0) {
			break;
		}

	}
	// translate the result code here
	//res = 1-result;
	if (result) {
		res=RES_OK;
	} else {
		res=RES_ERROR;
		printf("[diskio.c][TS_sec=%lu] Error in disk_read!\n",c_low_level_system_timestamp_in_secs());
	}

	return res;
#else
	DSTATUS result;
	int i;
	for (i = 0; i < NUM_RETRIES_FOR_SD_CARD; i++)
	{
#if !DO_NOT_USE_OS_CRITICAL_WRAP_FOR_SD_CARD
		OS_ENTER_CRITICAL();
#endif
		result = SD_SPI_disk_read (drv,buff, sector,count);
#if !DO_NOT_USE_OS_CRITICAL_WRAP_FOR_SD_CARD
		OS_EXIT_CRITICAL();
#endif
		if (result == RES_OK) {
			break;
		} else {
			c_low_level_system_usleep(LINNUX_TIME_TO_WAIT_AFTER_DISK_ERROR_IN_US);
			safe_print(xprintf("[diskio.c][TS_sec=%lu]Error in disk read, retrying try %d of %d\n",c_low_level_system_timestamp_in_secs(),i,NUM_RETRIES_FOR_SD_CARD));
		}
	}
	return result;
#endif
}

/*-----------------------------------------------------------------------*/
/* Write Sector(s)                                                       */
/*-----------------------------------------------------------------------*/
/* The FatFs module will issue multiple sector transfer request
/  (count > 1) to the disk I/O layer. The disk function should process
/  the multiple sector transfer properly Do. not translate it into
/  multiple single sector transfers to the media, or the data read/write
/  performance may be drasticaly decreased. */

#if _READONLY == 0
DRESULT disk_write (
		BYTE drv,			/* Physical drive nmuber (0..) */
		const BYTE *buff,	/* Data to be written */
		DWORD sector,		/* Sector address (LBA) */
		BYTE count 		/* Number of sectors to write (1..255) */
)
{
	int cpu_sr;

#ifdef USE_SD_1BIT_MODE

	DRESULT res;
	int result=RES_ERROR;
	int i;

	for(i=0;i<count;i++)
	{
		// SD-NN
		OS_ENTER_CRITICAL();
		result = SD_write_block_for_diskio(sector+i, buff+i*512);

		if (!result) {
			printf("[diskio.c][TS_sec=%lu]Error in disk write, Sector = %X, i = %d, trying again!\n",c_low_level_system_timestamp_in_secs(),(unsigned int)sector,i);
			c_low_level_system_usleep(LINNUX_TIME_TO_WAIT_AFTER_DISK_ERROR_IN_US);
			result = SD_write_block_for_diskio(sector+i, buff+i*512);
			if (!result) {
				c_low_level_system_usleep(LINNUX_TIME_TO_WAIT_AFTER_DISK_ERROR_IN_US);
				printf("[diskio.c][TS_sec=%lu]Error in disk write, initializing SD card and trying again\n",c_low_level_system_timestamp_in_secs());
				result = SD_card_init_for_diskio();
				printf("[diskio.c][TS_sec=%lu]Result of SD_card_init is: %d\n",c_low_level_system_timestamp_in_secs(),result);
				c_low_level_system_usleep(LINNUX_TIME_TO_WAIT_AFTER_DISK_ERROR_IN_US);
				result = SD_write_block_for_diskio(sector+i, buff+i*512);
				printf("[diskio.c][TS_sec=%lu]Result of Second rewrite is: %d\n",c_low_level_system_timestamp_in_secs(),result);
			} else {
				printf("[diskio.c][TS_sec=%lu]Retry #1 of write successful!",c_low_level_system_timestamp_in_secs());
			}
		}
		OS_EXIT_CRITICAL();

		if (result == 0) {
			break;
		}
	}

	// translate the result code here
	//res = 1-result;
	if (result) {
		res=RES_OK;
	} else {
		res=RES_ERROR;
		printf("[diskio.c][TS_sec=%lu] Error in disk_write!\n",c_low_level_system_timestamp_in_secs());
	}

	//	result = MMC_disk_write(buff, sector, count);
	// translate the reslut code here

	return res;
#else
	DSTATUS result;
	int i;
	for (i = 0; i < NUM_RETRIES_FOR_SD_CARD; i++)
	{
#if !DO_NOT_USE_OS_CRITICAL_WRAP_FOR_SD_CARD
		OS_ENTER_CRITICAL();
#endif
		result = SD_SPI_disk_write (drv,buff, sector,count);
#if !DO_NOT_USE_OS_CRITICAL_WRAP_FOR_SD_CARD
		OS_EXIT_CRITICAL();
#endif
		if (result == RES_OK) {
			break;
		} else {
			c_low_level_system_usleep(LINNUX_TIME_TO_WAIT_AFTER_DISK_ERROR_IN_US);
			safe_print(xprintf("[diskio.c][TS_sec=%lu]Error in disk write, retrying try %d of %d\n",c_low_level_system_timestamp_in_secs(),i,NUM_RETRIES_FOR_SD_CARD));

		}
	}
	return result;

#endif
}
#endif /* _READONLY */



/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */
/*-----------------------------------------------------------------------*/

DRESULT disk_ioctl (
		BYTE drv,		/* Physical drive nmuber (0..) */
		BYTE ctrl,		/* Control code */
		void *buff		/* Buffer to send/receive control data */
)
{
	int cpu_sr;

#ifdef USE_SD_1BIT_MODE
	/*If disk_iotcl gets called, this is to ensure write coherency. So instead of
	 *actually implementing it, we  do a  low level sleep to allow time for the card to
	 *finish any pending writes*/
	/* OS_ENTER_CRITICAL();
	 c_low_level_system_usleep(LINNUX_TIME_TO_SLEEP_IN_IOCTL_IN_US);
	 OS_EXIT_CRITICAL();
	 */
	return RES_OK;
#else
	DSTATUS result;
#if !DO_NOT_USE_OS_CRITICAL_WRAP_FOR_SD_CARD
	OS_ENTER_CRITICAL();
#endif
	result = SD_SPI_disk_ioctl (drv,ctrl,buff);
#if !DO_NOT_USE_OS_CRITICAL_WRAP_FOR_SD_CARD
	OS_EXIT_CRITICAL();
#endif
	return result;

	//return RES_OK;

#endif
}


