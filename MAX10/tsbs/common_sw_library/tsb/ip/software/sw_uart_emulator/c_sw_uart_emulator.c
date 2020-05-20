

#include "c_sw_uart_emulator.h"
#include "xprintf.h"
#include "rsscanf.h"
#include "misc_str_utils.h"
#include "strlen.h"
#include "misc_utils.h"

#ifndef NULL
#define NULL (0)
#endif

#define check_arguments(numargs,desired_numargs) \
							{ \
								if (numargs != desired_numargs) \
								{ \
									xsprintf(actual_result_str_ptr,"Error: got %d args, expected %d args\n",numargs,desired_numargs); \
									op_was_success = 0; \
									break; \
								}\
                            }
							


SW_UART_EMULATOR_RESPONSE_TYPE process_uart_protocol_command(uart_register_file_info_struct* s, char *cmd_str, char* result_str, int maxlen) {
	
	char command_char;

	unsigned long arg1;
	unsigned long arg2;
	unsigned long result1;
	int      numargs_received;
    SW_UART_EMULATOR_RESPONSE_TYPE op_was_success = C_SW_UART_EMULATOR_FAIL;
    char *actual_result_str_ptr;

    char aux_response[SW_UART_REGFILE_EMULATOR_MAX_RESPONSE_LENGTH];
    char aux_response2[SW_UART_REGFILE_EMULATOR_MAX_RESPONSE_LENGTH];

    make_string_lowercase(cmd_str);
	numargs_received = rsscanf(cmd_str,"%c %x %x",&command_char, &arg1, &arg2);

	actual_result_str_ptr  = result_str;
  
    switch (command_char) {
							case 'i' : check_arguments(numargs_received,2);
									   switch (arg1) {
									   case 0 : result1 = extract_bit_range(s->DATA_WIDTH           ,0,7); break;
									   case 1 : result1 = extract_bit_range(s->DATA_WIDTH           ,8,15); break;
									   case 2 : result1 = extract_bit_range(s->ADDRESS_WIDTH        ,0,7); break;
									   case 3 : result1 = extract_bit_range(s->ADDRESS_WIDTH        ,8,15); break;
									   case 4 : result1 = extract_bit_range(s->STATUS_ADDRESS_START ,0,7); break;
									   case 5 : result1 = extract_bit_range(s->STATUS_ADDRESS_START ,8,15); break;
									   case 6 : result1 = extract_bit_range(s->NUM_OF_CONTROL_REGS  ,0,7); break;
									   case 7 : result1 = extract_bit_range(s->NUM_OF_CONTROL_REGS  ,8,15); break;
									   case 8 : result1 = extract_bit_range(s->NUM_OF_STATUS_REGS   ,0,7); break;
									   case 9 : result1 = extract_bit_range(s->NUM_OF_STATUS_REGS   ,8,15); break;
									   case 10: result1 = 0; break; //error reporting - ignore for now
									   case 11: result1 = 0; break; //error reporting - ignore for now
									   case 12: result1 = 0; break; //error reporting - ignore for now
									   case 13: result1 = 0; break; //error reporting - ignore for now
									   case 14: result1 = 0; break; //error reporting - ignore for now
									   case 15: result1 = 3; break; //version
									   case 16: result1 = convert_char_to_number(s->DISPLAY_NAME[15]);  break;
									   case 17: result1 = convert_char_to_number(s->DISPLAY_NAME[14]);  break;
									   case 18: result1 = convert_char_to_number(s->DISPLAY_NAME[13]);  break;
									   case 19: result1 = convert_char_to_number(s->DISPLAY_NAME[12]);  break;
									   case 20: result1 = convert_char_to_number(s->DISPLAY_NAME[11]);  break;
									   case 21: result1 = convert_char_to_number(s->DISPLAY_NAME[10]);  break;
									   case 22: result1 = convert_char_to_number(s->DISPLAY_NAME[9] );  break;
									   case 23: result1 = convert_char_to_number(s->DISPLAY_NAME[8] );  break;
									   case 24: result1 = convert_char_to_number(s->DISPLAY_NAME[7] );  break;
									   case 25: result1 = convert_char_to_number(s->DISPLAY_NAME[6] );  break;
									   case 26: result1 = convert_char_to_number(s->DISPLAY_NAME[5] );  break;
									   case 27: result1 = convert_char_to_number(s->DISPLAY_NAME[4] );  break;
									   case 28: result1 = convert_char_to_number(s->DISPLAY_NAME[3] );  break;
									   case 29: result1 = convert_char_to_number(s->DISPLAY_NAME[2] );  break;
									   case 30: result1 = convert_char_to_number(s->DISPLAY_NAME[1] );  break;
									   case 31: result1 = convert_char_to_number(s->DISPLAY_NAME[0] );  break;
									   case 32: result1 = s->USER_TYPE                               ; break; //user_type
									   case 33: result1 = s->ADDRESS_OF_THIS_UART                    ; break; //ADDRESS_OF_THIS_UART
									   case 34: result1 = s->IS_SECONDARY_UART                       ; break; //IS_SECONDARY_UART
									   case 35: result1 = s->NUM_SECONDARY_UARTS                     ; break; //NUM_SECONDARY_UARTS
									   default:
										   result1 = 0;
									   }
									   xsprintf(actual_result_str_ptr,"%02x",result1);
									   op_was_success = C_SW_UART_EMULATOR_SUCCESS;
									   break;

							case 'r' : check_arguments(numargs_received,2);
							           op_was_success = s->read_from_ctrl_reg_func_ptr(s,arg1,&result1);
									   xsprintf(actual_result_str_ptr,"%x",result1);
									   break;

							case 's' : check_arguments(numargs_received,2);
							           op_was_success = s->read_from_status_reg_func_ptr(s,arg1,&result1);
									   xsprintf(actual_result_str_ptr,"%x",result1);
									   break;

							case 'w' : check_arguments(numargs_received,3);
							           op_was_success = s->write_to_ctrl_reg_func_ptr(s, arg2,arg1);
									   //xsprintf(actual_result_str_ptr,"\n");
									   break;

							case 'n'  : check_arguments(numargs_received,2);
							            s->get_ctrl_reg_description_func_ptr(s,arg1,aux_response,SW_UART_REGFILE_EMULATOR_MAX_RESPONSE_LENGTH);
										convert_string_to_list_of_hex_numbers(aux_response,aux_response2,SW_UART_REGFILE_EMULATOR_MAX_RESPONSE_LENGTH);
										xsprintf(actual_result_str_ptr,"%s",aux_response2);
										op_was_success = C_SW_UART_EMULATOR_SUCCESS;
										break;

							case 'm' :  check_arguments(numargs_received,2);
							            s->get_status_reg_description_func_ptr(s,arg1,aux_response,SW_UART_REGFILE_EMULATOR_MAX_RESPONSE_LENGTH);
										convert_string_to_list_of_hex_numbers(aux_response,aux_response2,SW_UART_REGFILE_EMULATOR_MAX_RESPONSE_LENGTH);
										xsprintf(actual_result_str_ptr,"%s",aux_response2);
										op_was_success = C_SW_UART_EMULATOR_SUCCESS;
										break;

							case 't' : {
										char* internal_command;
										internal_command = get_second_string_pointer(cmd_str);
										op_was_success = s->internal_command_function_ptr(internal_command,aux_response, maxlen);
										convert_string_to_list_of_hex_numbers(aux_response,actual_result_str_ptr,maxlen);
										//xprintf(";abcdefghijklmnopqrstuvwxyz1234567890qwaeszrdxtfcygvuhbijnokmpl\n");
										break;
										 }

							default:   xsprintf(actual_result_str_ptr,"Unrecognized");
									   op_was_success = C_SW_UART_EMULATOR_FAIL;
									   break;
	      }		  
			
   return op_was_success;

}

SW_UART_EMULATOR_RESPONSE_TYPE process_sw_uart_emulator_command(uart_register_file_info_struct* s, char *cmd_str, char* result_str, int maxlen)
{
	//Note that result_str conforms to TCL specs


	char command_char;

	unsigned long arg1;
	unsigned long arg2;
	int      numargs_received;
    SW_UART_EMULATOR_RESPONSE_TYPE op_was_success = C_SW_UART_EMULATOR_FAIL;
    char *actual_result_str_ptr;

    make_string_lowercase(cmd_str);
	numargs_received = rsscanf(cmd_str,"%c %x %x",&command_char, &arg1, &arg2);

	actual_result_str_ptr  = result_str;

	if (numargs_received == 0) {
		    xsprintf(actual_result_str_ptr,"Error - no command detected!\n");
		    op_was_success = 0;
	        return op_was_success;
     }
		
		
	if (command_char == 'u') { 
									char* secondary_uart_address;
									secondary_uart_address = get_second_string_pointer(cmd_str);
									char* actual_command_to_secondary_uart;
									actual_command_to_secondary_uart = get_second_string_pointer(secondary_uart_address);										
									unsigned secondary_uart;
									rsscanf(secondary_uart_address,"%d",&secondary_uart);
									if (!s->IS_SECONDARY_UART) {
										if (secondary_uart == 0) {
											op_was_success = process_uart_protocol_command(s, actual_command_to_secondary_uart, actual_result_str_ptr, maxlen);
										} else {
											op_was_success = s->process_secondary_uart_command_function_ptr(secondary_uart,actual_command_to_secondary_uart,actual_result_str_ptr,maxlen);										
										}
										
									} else {
										if (secondary_uart == s->ADDRESS_OF_THIS_UART) {
											op_was_success = process_uart_protocol_command(s, actual_command_to_secondary_uart, actual_result_str_ptr, maxlen);
										} else {												
											op_was_success = C_SW_UART_EMULATOR_FAIL;
										}												
									}
							} else {
		if (!s->IS_SECONDARY_UART) {				
			op_was_success = process_uart_protocol_command(s, cmd_str, actual_result_str_ptr, maxlen);
		}
	}
	return op_was_success;
}


