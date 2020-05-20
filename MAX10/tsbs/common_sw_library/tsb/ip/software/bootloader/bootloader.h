


#ifndef ___BOOTLOADER_H_
#define ___BOOTLOADER_H_
#include "alt_types.h"
#include "c_pio_encapsulator.h"

/*
 * Some CRC error codes for readability.
 */
#define BOOTLOADER_CRCS_VALID 0
#define BOOTLOADER_SIGNATURE_INVALID 1
#define BOOTLOADER_HEADER_CRC_INVALID 2
#define BOOTLOADER_DATA_CRC_INVALID 3
/*
 * Size of buffer for processing flash contents
 */
#define BOOTLOADER_FLASH_BUFFER_LENGTH 256

/*
 * The boot images stored in flash memory, have a specific header
 * attached to them.  This is the structure of that header.  The 
 * perl script "make_header.pl", included with this example is 
 *  used to add this header to your boot image.
 */
typedef struct {
  alt_u32 signature;
  alt_u32 version;
  alt_u32 timestamp;
  alt_u32 data_length;
  alt_u32 data_crc;
  alt_u32 res1;
  alt_u32 res2;
  alt_u32 header_crc;
} my_flash_header_type;

typedef enum {
	BOOTLOADER_BOOT_SW_FROM_FLASH              = 0,
	BOOTLOADER_BOOT_SW_FROM_SD_CARD             = 1,
	BOOTLOADER_BOOT_SW_FROM_USER_DEFINED_SOURCE0 = 2,
	BOOTLOADER_BOOT_SW_FROM_USER_DEFINED_SOURCE1 = 3
} bootloader_boot_source_type;

extern pio_encapsulator_struct      bootloader_reset_control_pio;
extern pio_encapsulator_struct      bootloader_gpio_out_pio;
extern pio_encapsulator_struct      bootloader_enable_and_params_pio;
extern pio_encapsulator_struct      bootloader_reset_and_bootloader_request_pio;
extern bootloader_boot_source_type  bootloader_nios_sw_source;
bootloader_boot_source_type get_bootloader_nios_sw_source();
int get_bootloader_image_index();
alt_u32 FlashCalcCRC32(alt_u8 *flash_addr, int bytes);
int ValidateFlashImage(void *image_ptr);
unsigned char bootloader_chan_getc();
void bootloader_chan_putc(unsigned char c);
unsigned long read_main_nios_pc();
int ddr_pll_is_locked() ;
int ddr_calibration_has_failed() ;
int ddr_calibration_has_succeeded();
void bootloader_do_ddr_reset() ;
void bootloader_print_all_pio_statuses();


typedef enum {
BOOTLOADER_INDEX_OF_MAIN_PROCESSOR = 0,
BOOTLOADER_INDEX_OF_DUT_PROCESSOR = 1,
} bootloader_index_of_processors_t;

#endif
