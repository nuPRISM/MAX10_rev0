/*
 * internal_command_parser.h
 *
 *  Created on: Jul 15, 2013
 *      Author: yairlinn
 */

#ifndef INTERNAL_COMMAND_PARSER_H_
#define INTERNAL_COMMAND_PARSER_H_

#include "simple_debug.h"

typedef struct internal_parser_command_s {
    char *name;
    unsigned int (*cmd_func)(char *, char *, struct internal_parser_command_s *);
    void* additional_info;
    const char* help_str;
} internal_parser_command;

unsigned int func_do_tcl_command(char* command_params, char* result_str, struct internal_parser_command_s *);

unsigned int execute_internal_command (
		internal_parser_command command_tbl[],
		unsigned int num_of_commands,
		char * the_command,
		char* result_str);

unsigned int init_command_parser(internal_parser_command command_tbl[],
		unsigned int num_of_commands);

typedef enum {
	DEBUG_PRINTOUT_TYPE_DO_NOT_PRINT_IMMEDIATELY = 0,
	DEBUG_PRINTOUT_TYPE_PRINT_IMMEDIATELY = 1,
	DEBUG_PRINTOUT_TYPE_PRINT_IMMEDIATELY_NOT_INTO_RESULT_STR = 2,
} debug_printout_type;

int print_received_params (char* result_str, unsigned int* the_params, int numargs, int print_to_output);
int print_out_of_range_error_message (char* result_str, unsigned int* the_params, int numargs, int print_to_output);
int parse_unsigned_int_params (char *command_params, int** the_params, unsigned int is_hex);
int debug_print_params_to_uart(char* result_str, unsigned int* the_params, int numargs, char* func, int print_to_output);

#endif /* INTERNAL_COMMAND_PARSER_H_ */
