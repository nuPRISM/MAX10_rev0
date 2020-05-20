/*
 * adc_mcs_basedef.h
 *
 *  Created on: Mar 8, 2012
 *      Author: linnyair
 */

#ifndef BOARDMANAGEMENT_0_ADC_MCS_BASEDEF_H_
#define BOARDMANAGEMENT_0_ADC_MCS_BASEDEF_H_
#include "system.h"
#include "sys/alt_stdio.h"
#include "io.h"

//#define USE_UART_FOR_COMMUNICATION_WITH_MAIN_PROCESSOR
#define dual_port_ram_container_DEBUG (0)
//#define USE_SAFE_JTAG_PRINT
#define ABORT_IF_JTAG_FIFO_FULL

#define ADC_MCS_NUM_32BIT_WORDS_IN_DP_MEM      (4096)
#define ADC_MCS_NUM_COEFFS_IN_FIR                (16)
#define ADC_MCS_NUM_32BIT_WORDS_TO_FORM_FIR       (4)
#define BOARD_MGMT_MEMM_COMM_NUM_READBACK_REGS                     (4)

#define ADC_MCS_COMMAND_BUFFER_LENGTH            (200)
#define ADC_MCS_RESPONSE_MAXLENGTH               (20000)

//#define my_printf alt_printf
#define my_printf xprintf
#define my_gets xgets

#define MCS_CLOCK_FREQUENCY_HZ (ALT_CPU_CPU_FREQ)

#define COMPILE_SPI_32BIT
//#define COMPILE_SPI_16BIT
//#define COMPILE_SPI_8BIT

#define BOARDMANAGEMENT_0_SPI_CORE_BASE_ADDRESS 0xC0000000
#define START_OF_IO_REGION    0xC0000000
//#define SPI_CORE_BAUDRATE     5000000
#define SPI_CORE_BAUDRATE     50000
#define SPI_CORE_CTRL_SETTINGS 0x2408 // char_len = 8 go_bsy = 0 tx_nex = 1 rx_neg = 0 lsb = 0 ass = 1

#define STDOUT_TUNNEL_MAGIC_STR "(UARTSTDOUT)"

#define TRUE  1
#define FALSE 0

#define GENERIC_UART_REGFILE (0)


#define  ADC_MCS_DATA_WIDTH            32
#define  ADC_MCS_ADDRESS_WIDTH         16
#define  ADC_MCS_STATUS_ADDRESS_START  4
#define  ADC_MCS_NUM_OF_CONTROL_REGS   4
#define  ADC_MCS_NUM_OF_STATUS_REGS    4
#define  ADC_MCS_VERSION               3
#define  ADC_MCS_USER_TYPE             GENERIC_UART_REGFILE

#define use_internal_mcs_uart 0
extern char MCS_PROCESSOR_NAME[];

#define UART_TYPE_GENERIC_UART_REGFILE           0
#define UART_TYPE_BERC_CTRL_UART_REGFILE         1
#define UART_TYPE_DESERIALIZER_CTRL_UART_REGFILE 2
#define UART_TYPE_SPARTAN_ADC_CTRL_UART_REGFILE  3
#define UART_TYPE_FMC_MCS_UART_REGFILE           4
#define UART_TYPE_BOARD_MGMT_UART_REGFILE        5


#define NUM_EXTERNAL_UARTS 0

extern int enable_debug_printfs;

//#define dp(...) alt_printf (__VA_ARGS__)
#define dp(...) do { if (enable_debug_printfs) { printf(__VA_ARGS__); fflush(stdout);}; } while (0)

typedef unsigned char boolean;

#define I2C_OPENCORES_READ_CONST  (1)
#define I2C_OPENCORES_WRITE_CONST (0)

#define NUM_I2C_PERIPHERALS (4)

#define DEFAULT_I2C_SETUP_DELAY_IN_US (1)

#define SFP_REGS_I2C_3BIT_ADDRESS (6)

#define I2C_SPEED_HZ (10000)

#ifdef BOARDMANAGEMENT_0_DUAL_PORT_MEM_CONTROLLER_QSYS_0_SPAN

#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_TOTAL_SPAN_IN_32_BIT_WORDS       ((BOARDMANAGEMENT_0_DUAL_PORT_MEM_CONTROLLER_QSYS_0_SPAN)/4)
#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_BASE_OFFSET_IN_BYTES             (0)
#define BOARD_MGMT_MEMM_COMM_DEFAULT_STRING_SAFETY_BUFFER_IN_CHARS                   (20)
#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_MAX_STR_LENGTH_IN_CHARS                 (BOARD_MGMT_MEMM_COMM_AUX_MEMORY_COMM_REGION_TOTAL_SPAN_IN_32_BIT_WORDS-BOARD_MGMT_MEMM_COMM_DEFAULT_STRING_SAFETY_BUFFER_IN_CHARS)
#define BOARD_MGMT_MEMM_COMM_AUX_MEMORY_MEMORY_COMM_IS_ALIVE_MAGIC_WORD              (0xA50f1be4)
#define BOARD_MGMT_MEMM_COMM_AUX_COMMAND_BUFFER_LENGTH                               (100)

#endif

#define UART_MEMM_COMM_COMMAND_BUFFER_LENGTH_IN_CHARS            (100)
#define UART_MEMM_COMM_MAX_STR_LENGTH_IN_CHARS                   (125)
#define UART_MEMM_COMM_DEFAULT_STRING_SAFETY_BUFFER_IN_CHARS       (5)

#define BOARDMANAGEMENT_0_GPI_BASE_ADDRESS 0
#define BOARDMANAGEMENT_0_GPO_BASE_ADDRESS 0

#endif /* BOARDMANAGEMENT_0_ADC_MCS_BASEDEF_H_ */
