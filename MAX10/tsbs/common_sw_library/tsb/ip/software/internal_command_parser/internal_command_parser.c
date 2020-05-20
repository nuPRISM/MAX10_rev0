/*
 * internal_command_parser.c
 *
 *  Created on: Jul 15, 2013
 *      Author: yairlinn
 */


#include "basedef.h"
#include "xprintf.h"
#include "rsscanf.h"
#include "system.h"
#include "io.h"
#include "strlen.h"
#include "misc_str_utils.h"
#include "internal_command_parser.h"
#include "misc_utils.h"
#include "string.h"
#include "sys/alt_timestamp.h"

extern ldb_debug_level_type current_debug_level;
extern int in_benchmarking_mode;
#if LDB_COMPILE_PICOL
/* Picol */

#define PICOL_CONFIGURATION
/* A minimal Picol configuration: no arrays, no I/O, no [interp] or [glob]
command. */
#define PICOL_FEATURE_ARRAYS  0
#define PICOL_FEATURE_GLOB    0
#define PICOL_FEATURE_INTERP  0
#define PICOL_FEATURE_PUTS    1

#define PICOL_MAX_FILE_LENGTH (4096)

#if COMMAND_SERVER_ENABLE_PETIT_FILE_SYSTEM
#define PICOL_FEATURE_FILE_SUPPORT 1
#define PICOL_FEATURE_IO      0
#else
#define PICOL_FEATURE_FILE_SUPPORT 0
#define PICOL_FEATURE_IO           0
#endif

#define PICOL_FEATURE_TIME_SUPPORT 0


#if COMMAND_SERVER_ENABLE_PETIT_FILE_SYSTEM
#include "pff.h"
#include "petit_fatfs_macro_definitions.h"
#endif

#define PICOL_IMPLEMENTATION
#include "picol_command_disable_list.h"
#include "picol.h"

static picolInterp* picol_interpreter;
static internal_parser_command *saved_command_tbl;
static unsigned int saved_num_of_commands;

#endif

#if PRINT_DEBUG_COMMENTS_TO_UART

#define debug_print_params_to_uart_macro(result_str,the_params,numargs) \
	  do { result_str+=xsprintf(result_str,"%sIn func: %s\n%sGot %d parameters:",COMMENT_STR, __func__, COMMENT_STR, numargs); \
	  result_str+=print_received_params (result_str, the_params, numargs); \
	  result_str+=xsprintf(result_str,"\n"); } while (0)
#else
      #define debug_print_params_to_uart_macro(result_str,the_params,numargs)  do {} while(0)
#endif

 int debug_print_params_to_uart(char* result_str, unsigned int* the_params, int numargs, char* func, int print_to_output)
 {
	 if (current_debug_level == LDB_DEBUG_LEVEL_DONT_SHOW_ANY_MESSAGES) {
		 return 0;
	 }
#if PRINT_DEBUG_COMMENTS_TO_UART
	 if (print_to_output == DEBUG_PRINTOUT_TYPE_PRINT_IMMEDIATELY_NOT_INTO_RESULT_STR) {
		 char temp_response_str[INTERNAL_COMMAND_RESPONSE_MAXLENGTH];
		 xprintf("%sIn func: %s\n%sGot %d parameters:",COMMENT_STR, func, COMMENT_STR, numargs);
	     print_received_params (temp_response_str, the_params, numargs,1);
		 xprintf("\n");
		 return 0;
	 } else {
	  char* initial_result_str = result_str;
	  result_str+= xsprintf(result_str,"%sIn func: %s\n%sGot %d parameters:",COMMENT_STR, func, COMMENT_STR, numargs);
	  result_str+=print_received_params (result_str, the_params, numargs,0);
	  result_str+=xsprintf(result_str,"\n");
	  if (print_to_output) { xprintf(initial_result_str); };
	  return (result_str - initial_result_str);
	 }
#else
	  return 0;
#endif
 }


 int parse_unsigned_int_params (char *command_params, int** the_params, unsigned int is_hex) {
	 char fmt_string[MAX_PARAMS_FOR_COMMANDS*10];
	 xsprintf(fmt_string,"%%%c %%%c %%%c %%%c %%%c %%%c %%%c %%%c %%%c %%%c %%%c %%%c %%%c %%%c %%%c %%%c",
			 (is_hex & 0x1) ? 'x' :'d',
			 (is_hex & 0x2) ? 'x' :'d',
			 (is_hex & 0x4) ? 'x' :'d',
			 (is_hex & 0x8) ? 'x' :'d',
			 (is_hex & 0x10) ? 'x' :'d',
			 (is_hex & 0x20) ? 'x' :'d',
			 (is_hex & 0x40) ? 'x' :'d',
			 (is_hex & 0x80) ? 'x' :'d',
			 (is_hex & 0x100) ? 'x' :'d',
			 (is_hex & 0x200) ? 'x' :'d',
			 (is_hex & 0x400) ? 'x' :'d',
			 (is_hex & 0x800) ? 'x' :'d',
			 (is_hex & 0x1000) ? 'x' :'d',
			 (is_hex & 0x2000) ? 'x' :'d',
			 (is_hex & 0x4000) ? 'x' :'d',
			 (is_hex & 0x8000) ? 'x' :'d');
	 int numargs_received = rsscanf(command_params,fmt_string,
			 &the_params[0],
			 &the_params[1],
			 &the_params[2],
			 &the_params[3],
			 &the_params[4],
			 &the_params[5],
			 &the_params[6],
			 &the_params[7],
			 &the_params[8],
			 &the_params[9],
			 &the_params[10],
			 &the_params[11],
			 &the_params[12],
			 &the_params[13],
			 &the_params[14],
			 &the_params[15]);
	 return numargs_received;
 }




int print_received_params (char* result_str, unsigned int* the_params, int numargs, int print_to_output) {
    int charcnt = 0;
    int current_charcnt = 0;
    char * original_result_str_point = result_str;
    for (int i = 0; i < numargs; i++) {
    	if (i ==0) {
    		if (numargs == 1) {
    		    charcnt += (current_charcnt = xsprintf(result_str,"(%u=0x%x",the_params[i],the_params[i] ));
    		} else {
        		charcnt += (current_charcnt = xsprintf(result_str,"(%u=0x%x ",the_params[i],the_params[i]));
    		}
    		result_str += current_charcnt;
    	} else {
    		if (i==(numargs-1)) {
    			charcnt += (current_charcnt = xsprintf(result_str,"%u=0x%x)",the_params[i],the_params[i]));
    			result_str += current_charcnt;
    		} else {
    			charcnt += (current_charcnt = xsprintf(result_str,"%u=0x%x ",the_params[i],the_params[i]));
    			result_str += current_charcnt;
    		}
    	}
    }

    if (numargs == 0) {
       charcnt += (current_charcnt = xsprintf(result_str,"()"));
       result_str += current_charcnt;
    } else {
    	if (numargs == 1) {
    		charcnt += (current_charcnt = xsprintf(result_str,")"));
    		result_str += current_charcnt;
    	}
    }
    if (print_to_output) {xprintf(original_result_str_point); };
    //xprintf("result_str addition = (%s)\n",original_result_str_point);
    return charcnt;
}

int print_out_of_range_error_message (char* result_str, unsigned int* the_params, int numargs, int print_to_output) {
     int current_charcnt = 0;
     int charcnt = 0;
     if (print_to_output == DEBUG_PRINTOUT_TYPE_PRINT_IMMEDIATELY_NOT_INTO_RESULT_STR) {
		 char temp_response_str[INTERNAL_COMMAND_RESPONSE_MAXLENGTH];
    	 xprintf("%sParameters out of range ",COMMENT_STR);
    	 print_received_params (temp_response_str, the_params, numargs,1);
         xprintf("\n");
     } else  {
     char* original_str = result_str;
	 charcnt += (current_charcnt = xsprintf(result_str,"%sParameters out of range ",COMMENT_STR));
 	 result_str+= current_charcnt;
 	 charcnt += (current_charcnt = print_received_params (result_str, the_params, numargs,0));
	 result_str+= current_charcnt;
	 charcnt += (current_charcnt = xsprintf(result_str,"\n"));
	 result_str+= current_charcnt;
	 if (print_to_output) {xprintf(original_str);};
     }
     return charcnt;
}


#if LDB_COMPILE_PICOL
COMMAND(ylcmd) {
    ARITY2(argc == 2, "execute internal command");
    int n;
    char tmp_result_str[INTERNAL_COMMAND_RESPONSE_MAXLENGTH];
    unsigned int command_result = execute_internal_command(saved_command_tbl,saved_num_of_commands,argv[1],tmp_result_str);
    picolSetResult(picol_interpreter, tmp_result_str);
    return (command_result == TRUE) ? PICOL_OK : PICOL_ERR;
}


unsigned int func_do_tcl_command(char* command_params, char* result_str, internal_parser_command *self_ptr) {
  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
  unsigned int retval;
  int rc = 0;
  rc = picolEval(picol_interpreter, command_params); /* Wrong usage. */
  report_error(picol_interpreter, rc);
  return (rc==PICOL_OK) ? TRUE : FALSE;
}
#endif

static int comp_cmd(const void *c1, const void *c2)
{
    const internal_parser_command *cmd1 = c1, *cmd2 = c2;

    return my_strcmp(cmd1->name, cmd2->name);
}

static internal_parser_command *get_cmd(
		internal_parser_command command_tbl[],
		unsigned int num_of_commands,
		char *name)
{
    internal_parser_command target = { name, NULL, NULL };

    return ((internal_parser_command *) bsearch(&target, command_tbl, num_of_commands, sizeof (internal_parser_command), comp_cmd));
}


unsigned int execute_internal_command (
		internal_parser_command command_tbl[],
		unsigned int num_of_commands,
		char * the_command,
		char* result_str)
{
    static int command_counter = 0;
#if LDB_COMPILE_PICOL
    if (command_counter == 0) {
    	init_command_parser(command_tbl,
    			 num_of_commands
    			);
    }
#endif

    char command_name[INTERNAL_COMMAND_BUFFER_LENGTH];
    char *command_params;
    int charcnt;
    if (!the_command) {
		xprintf("%sNull command string pointer\n", COMMENT_STR);
		return FALSE;
    }

    if (!my_strlen(the_command)) {
    		xprintf("%sEmpty command\n", COMMENT_STR);
    		return FALSE;
    }

    make_string_lowercase(the_command);
    //xsprintf(last_command,"%s",the_command);
    get_first_string(the_command, command_name, INTERNAL_COMMAND_BUFFER_LENGTH);
    command_params=get_second_string_pointer(the_command);

    internal_parser_command *cmd = get_cmd(command_tbl,num_of_commands,command_name);
	command_counter++;

	debug_xprintf(LDB_DEBUG_LEVEL_SHOW_ALL_INFO_MESSAGES,"%sCommand #(%d) Got Command: (%s) Command name: (%s)\n",COMMENT_STR,command_counter,the_command,command_name);

	if (cmd) {
		if (in_benchmarking_mode) {
			unsigned int result;
			alt_timestamp_start();
			alt_timestamp_type start_time = alt_timestamp();
			result = cmd->cmd_func(command_params,result_str,cmd);
			alt_timestamp_type end_time = alt_timestamp();
			xprintf("%sCommand ticks: start: %u end: %u delta: %u ticks_per_second: %u\n",COMMENT_STR,start_time,end_time,end_time-start_time,alt_timestamp_freq());
			return result;
	    } else {
	    return (cmd->cmd_func(command_params,result_str,cmd));
		}
	} else {
		xprintf("%sCommmand not found (%s)\n", COMMENT_STR, the_command);
		return FALSE;
	}
	return FALSE;

}

#if LDB_COMPILE_PICOL
unsigned int init_command_parser(internal_parser_command command_tbl[],
		unsigned int num_of_commands) {
	picol_interpreter = picolCreateInterp();
	saved_command_tbl = command_tbl;
	saved_num_of_commands = num_of_commands;
    picolRegisterCmd(picol_interpreter, "ylcmd", picol_ylcmd, NULL);
    return TRUE;
}

void report_error(picolInterp* i, int rc) {
    if (rc != PICOL_OK) {
        xprintf("%sPicol Error:[%d] %s\n", COMMENT_STR,rc, i->result);
    }
}
#endif



