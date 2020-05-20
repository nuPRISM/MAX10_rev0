/*
 * process_command.c
 *
 *  Created on: Apr 4, 2012
 *      Author: linnyair
 */

extern "C" {
#include "process_command.h"
#include "adc_mcs_basedef.h"
#include "system.h"
#include <xprintf.h>
#include "rsscanf.h"
#include "misc_str_utils.h"
#include <string.h>
#include "misc_utils.h"
#include "pio_encapsulator.h"
}

#include "internal_command_parser.h"

//#define NULL (0)
extern int allow_stdout_printf;
char* print_diagnostics(char* outstr) {

	char* currptr = outstr;
	if (outstr == (char*) NULL) {
		alt_printf("Error: print_diagnostics: received NULL argument!\n");
		return ((char *)NULL);
	}
    currptr += xsprintf(outstr, " { Diagnostic 1 } ");
	currptr += xsprintf(currptr," { Diagnostic 2 } ");

	return currptr;
}


boolean process_command(char *cmd_str, char* result_str, int max_command_length, int maxlen)
{
	//Note that result_str conforms to TCL specs
#define check_arguments(numargs,desired_numargs) \
							{ \
								if (numargs != desired_numargs) \
								{ \
									xsprintf(actual_result_str_ptr,"Error: got %d args, expected %d args\n",numargs,desired_numargs); \
									op_was_success = FALSE; \
									break; \
								}\
                            }

	char command_char;

	unsigned long arg1;
	unsigned long arg2;
	unsigned long result1;
	int      numargs_received;
    boolean op_was_success = FALSE;
    char *actual_result_str_ptr;


    char aux_response[ADC_MCS_RESPONSE_MAXLENGTH];
    char aux_response2[ADC_MCS_RESPONSE_MAXLENGTH];

	to_lower(cmd_str);
	numargs_received = rsscanf(cmd_str,"%c %x %x",&command_char, &arg1, &arg2);

	actual_result_str_ptr  = result_str;

	if (numargs_received == 0) {
		    xsprintf(actual_result_str_ptr,"Error - no command detected!\n");
		    op_was_success = FALSE;
		    goto return_the_response;
		}

	switch (command_char) {
	case 'i' : check_arguments(numargs_received,2);
	           switch (arg1) {
	           case 0 : result1 = extract_bit_range(ADC_MCS_DATA_WIDTH,0,7); break;
	           case 1 : result1 = extract_bit_range(ADC_MCS_DATA_WIDTH,8,15); break;
	           case 2 : result1 = extract_bit_range(ADC_MCS_ADDRESS_WIDTH,0,7); break;
	           case 3 : result1 = extract_bit_range(ADC_MCS_ADDRESS_WIDTH,8,15); break;
	           case 4 : result1 = extract_bit_range(ADC_MCS_STATUS_ADDRESS_START,0,7); break;
	           case 5 : result1 = extract_bit_range(ADC_MCS_STATUS_ADDRESS_START,8,15); break;
	           case 6 : result1 = extract_bit_range(ADC_MCS_NUM_OF_CONTROL_REGS,0,7); break;
	           case 7 : result1 = extract_bit_range(ADC_MCS_NUM_OF_CONTROL_REGS,8,15); break;
	           case 8 : result1 = extract_bit_range(ADC_MCS_NUM_OF_STATUS_REGS,0,7); break;
	           case 9 : result1 = extract_bit_range(ADC_MCS_NUM_OF_STATUS_REGS,8,15); break;
	           case 10: result1 = 0; break; //error reporting - ignore for now
	           case 11: result1 = 0; break; //error reporting - ignore for now
	           case 12: result1 = 0; break; //error reporting - ignore for now
	           case 13: result1 = 0; break; //error reporting - ignore for now
	           case 14: result1 = 0; break; //error reporting - ignore for now
	           case 15: result1 = 3; break; //version
	           case 16: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[15]);  break;
	           case 17: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[14]);  break;
	           case 18: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[13]);  break;
	           case 19: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[12]);  break;
	           case 20: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[11]);  break;
	           case 21: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[10]);  break;
	           case 22: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[9]);  break;
	           case 23: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[8]);  break;
	           case 24: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[7]);  break;
	           case 25: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[6]);  break;
	           case 26: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[5]);  break;
	           case 27: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[4]);  break;
	           case 28: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[3]);  break;
	           case 29: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[2]);  break;
	           case 30: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[1]);  break;
	           case 31: result1 = convert_char_to_number(MCS_PROCESSOR_NAME[0]);  break;
	           case 32: result1 = UART_TYPE_BOARD_MGMT_UART_REGFILE; break; //user_type
	           default:
	        	   result1 = 0;
	           }
	           xsprintf(actual_result_str_ptr,"%x\n",result1);
               op_was_success = TRUE;
               break;

	case 'r' : check_arguments(numargs_received,2);
	           result1 = read_from_gpo_reg(arg1+1);
	           xsprintf(actual_result_str_ptr,"%x\n",result1);
	           op_was_success = TRUE;
	           break;

	case 's' : check_arguments(numargs_received,2);
	           result1 = read_from_gpi_reg(arg1+1);
	           xsprintf(actual_result_str_ptr,"%x\n",result1);
	           op_was_success = TRUE;
	           break;

	case 'w' : check_arguments(numargs_received,3);
	           write_to_gpo_reg(arg2+1,arg1);
	           xsprintf(actual_result_str_ptr,"\n");
	           op_was_success = TRUE;
	           break;

	case 'n'  : check_arguments(numargs_received,2);
	            xsprintf(aux_response,"GPO%d",arg1+1);
	            convert_string_to_list_of_hex_numbers(aux_response,aux_response2,ADC_MCS_RESPONSE_MAXLENGTH);
	            xsprintf(actual_result_str_ptr,"%s\n",aux_response2);
	            op_was_success = TRUE;
	            break;

	case 'm' :  check_arguments(numargs_received,2);
	            xsprintf(aux_response,"GPI%d",arg1+1);
		        convert_string_to_list_of_hex_numbers(aux_response,aux_response2,ADC_MCS_RESPONSE_MAXLENGTH);
		        xsprintf(actual_result_str_ptr,"%s\n",aux_response2);
		        op_was_success = TRUE;
				break;

	case 't' : {
		        char* internal_command;
		        internal_command = get_second_string_pointer(cmd_str);
		        op_was_success = execute_internal_command(internal_command,actual_result_str_ptr,max_command_length,maxlen);
		        break;
	             }


	default:   xsprintf(actual_result_str_ptr,"Unrecognized\n");
	           op_was_success = FALSE;
	           break;
	}

    return_the_response:

	    return op_was_success;
}
