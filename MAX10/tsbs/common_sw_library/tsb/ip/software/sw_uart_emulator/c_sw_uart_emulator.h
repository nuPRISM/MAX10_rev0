
#ifndef C_SW_UART_EMULATOR_H
#define C_SW_UART_EMULATOR_H

typedef enum {
	C_SW_UART_EMULATOR_FAIL = 0,
	C_SW_UART_EMULATOR_SUCCESS = 1
} SW_UART_EMULATOR_RESPONSE_TYPE;



typedef SW_UART_EMULATOR_RESPONSE_TYPE (*execute_internal_command_function_type) (char * the_command, char* result_str, int maxlen);
typedef SW_UART_EMULATOR_RESPONSE_TYPE (*process_secondary_uart_command_function_type) (unsigned int secondary_uart_num, char * the_command, char* result_str, int maxlen);

#define SW_UART_REGFILE_EMULATOR_DISPLAY_NAME_WIDTH (16)
#define SW_UART_REGFILE_EMULATOR_DESCRIPTION_MAX_LENGTH (16)
#define SW_UART_REGFILE_EMULATOR_MAX_RESPONSE_LENGTH (128)



typedef struct uart_register_file_info_struct_s {
	unsigned long
	DATA_WIDTH,
	ADDRESS_WIDTH,
	STATUS_ADDRESS_START,
	NUM_OF_CONTROL_REGS,
	NUM_OF_STATUS_REGS,
	INIT_ALL_CONTROL_REGS_TO_DEFAULT,
	USE_AUTO_RESET,
	VERSION,
	USER_TYPE,
	NUM_SECONDARY_UARTS,
	ADDRESS_OF_THIS_UART,
	IS_SECONDARY_UART,
	IS_ACTUALLY_PRESENT,
	CLOCK_RATE_IN_HZ,
	WATCHDOG_LIMIT_IN_CLOCK_CYCLES,
	WATCHDOG_LIMIT_IN_SYSTEM_TICKS,
	ENABLE_ERROR_MONITORING,
	DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS,
	ENABLE_STATUS_WISHBONE_INTERFACE,
	ENABLE_CONTROL_WISHBONE_INTERFACE,
	STATUS_WISHBONE_NUM_ADDRESS_BITS,
	CONTROL_WISHBONE_NUM_ADDRESS_BITS,
	IGNORE_TIMING_TO_READ_LD,
	USE_GENERIC_ATTRIBUTE_FOR_READ_LD,
	WISHBONE_INTERFACE_IS_PART_OF_BRIDGE,
	WISHBONE_STATUS_BASE_ADDRESS,
	WISHBONE_CONTROL_BASE_ADDRESS;
	char DISPLAY_NAME[SW_UART_REGFILE_EMULATOR_DISPLAY_NAME_WIDTH+1];
	execute_internal_command_function_type       internal_command_function_ptr;
	process_secondary_uart_command_function_type process_secondary_uart_command_function_ptr;
	SW_UART_EMULATOR_RESPONSE_TYPE (*write_to_ctrl_reg_func_ptr          )(struct uart_register_file_info_struct_s* s, unsigned long regnum, unsigned long val);
	SW_UART_EMULATOR_RESPONSE_TYPE (*read_from_ctrl_reg_func_ptr         )(struct uart_register_file_info_struct_s* s, unsigned long regnum, unsigned long* val);
	SW_UART_EMULATOR_RESPONSE_TYPE (*read_from_status_reg_func_ptr       )(struct uart_register_file_info_struct_s* s, unsigned long regnum, unsigned long* val);
	SW_UART_EMULATOR_RESPONSE_TYPE (*get_status_reg_description_func_ptr )(struct uart_register_file_info_struct_s* s, unsigned long regnum, char* desc, int maxlen);
	SW_UART_EMULATOR_RESPONSE_TYPE (*get_ctrl_reg_description_func_ptr   )(struct uart_register_file_info_struct_s* s, unsigned long regnum, char* desc, int maxlen);
} uart_register_file_info_struct;

SW_UART_EMULATOR_RESPONSE_TYPE process_sw_uart_emulator_command(uart_register_file_info_struct* s, char *cmd_str, char* result_str, int maxlen);


#endif
