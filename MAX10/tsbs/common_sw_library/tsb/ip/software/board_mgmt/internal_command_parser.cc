/*
 * internal_command_parser.c
 *
 *  Created on: Jul 15, 2013
 *      Author: yairlinn
 */
#include <stdio.h>
#include <string>
#include <cstring>

extern "C" {
#include "adc_mcs_basedef.h"
#include <xprintf.h>
#include "rsscanf.h"
#include "misc_str_utils.h"
#include "misc_utils.h"
#include "system.h"
#include "pio_encapsulator.h"
#include <stdlib.h>
#include "drv_spi.h"
#include "per_spi.h"
#include "sfp_i2c.h"
#include "alt_eeprom.h"
#include <drivers/inc/i2c_opencores_regs.h>
#include <drivers/inc/i2c_opencores.h>
#include "mem.h"
#include "my_mem_defs.h"
}
#include "basedef.h"
#include "board_management.h"


#include "jansson.hpp"
#include "json_serializer_class.h"

#include <vector>
#include <iostream>
#include <sstream>
#include "cpp_utils.h"
unsigned long i2c_addr_array[] = {
		BOARDMANAGEMENT_0_FMC_I2C_BASE,
		BOARDMANAGEMENT_0_PMBUS_BASE
};
#include "internal_command_parser.h"

char  last_command[ADC_MCS_COMMAND_BUFFER_LENGTH];

unsigned int func_get_project_name(char* command_params, char* result_str, int max_response_chars) {
//xsprintf(result_str,"%x\n",read_from_gpi_reg(1));
	xsprintf(result_str,"Griffin\n");
  return TRUE;
}

unsigned int func_get_board_mgmt_name(char* command_params, char* result_str, int max_response_chars) {
 //xsprintf(result_str,"%x\n",read_from_gpi_reg(2));
	xsprintf(result_str,"BoardManagement\n");
  return TRUE;
}
unsigned int func_get_board_mgmt_version(char* command_params, char* result_str, int max_response_chars) {
  xsprintf(result_str,"12345678\n");
  return TRUE;
}

unsigned int func_get_num_uarts(char* command_params, char* result_str, int max_response_chars) {
  xsprintf(result_str,"%u\n",NUM_EXTERNAL_UARTS);
  return TRUE;
}


unsigned int func_sw_date_str(char* command_params, char* result_str, int max_response_chars) {
  xsprintf(result_str,"%s %s\n",__DATE__, __TIME__ );
  return TRUE;
}


unsigned int func_json_print(char* command_params, char* result_str, int max_response_chars) {
  std::string json_str = g_board.get_json_string();
  std::cout << "Json String =  " << remove_spaces(json_str) << std::endl;
  xsprintf(result_str,"json printed\n");
  return TRUE;
}

unsigned int func_get_json_status(char* command_params, char* result_str, int max_response_chars) {
  std::string json_str = only_graphable(remove_spaces(g_board.get_json_string())).substr(0,max_response_chars);
  std::cout << "Json String =  " << json_str << std::endl;
  xsprintf(result_str,"%s\n",json_str.c_str());
  return TRUE;
}

unsigned int func_get_devices(char* command_params, char* result_str, int max_response_chars) {
  xsprintf(result_str,"boardmgmt\n");
  return TRUE;
}


unsigned int func_i2c_init (char* command_params, char* result_str, int max_response_chars) {
	  I2C_init(BOARDMANAGEMENT_0_FMC_I2C_BASE,MCS_CLOCK_FREQUENCY_HZ,I2C_SPEED_HZ);
	  xsprintf(result_str,"i2c init executed\n");
	  return TRUE;
	}
unsigned int func_i2c_read (char* command_params, char* result_str, int max_response_chars)  {
	  unsigned long last;
	  unsigned int numargs_received = rsscanf(command_params,"%x",&last);
	  unsigned long res =I2C_read(BOARDMANAGEMENT_0_FMC_I2C_BASE,last);
	  xsprintf(result_str,"I2C Read result = %x\n",res);
	  return TRUE;
	}
unsigned int func_i2c_start (char* command_params, char* result_str, int max_response_chars) {
	unsigned long addr, is_read;
	unsigned int numargs_received = rsscanf(command_params,"%x %x",&addr, &is_read);
	int res =I2C_start(BOARDMANAGEMENT_0_FMC_I2C_BASE,addr,is_read);
	xsprintf(result_str,"i2c start executed addr=(%x) is_read=(%x) res = (%d)\n",addr,is_read,res);
	return TRUE;
}
unsigned int func_i2c_write  (char* command_params, char* result_str, int max_response_chars) {
	unsigned long data, last, res;
	unsigned int numargs_received = rsscanf(command_params,"%x %x",&data, &last);
	res = I2C_write(BOARDMANAGEMENT_0_FMC_I2C_BASE,data,last);
	xsprintf(result_str,"i2c start executed data=(%x) last=(%x) res = (%x)\n",data,last,res);
	return TRUE;
}


unsigned int func_i2c_snapshot(char* command_params, char* result_str, int max_response_chars) {
	int i2c_num;
    unsigned int numargs_received = rsscanf(command_params,"%d",&i2c_num);
     if ((i2c_num > NUM_I2C_PERIPHERALS) || (i2c_num < 1)){
    	 xsprintf(result_str,"Error: i2c num must be between 1 and %d\n",(int)NUM_I2C_PERIPHERALS);
     } else {

  xsprintf(result_str,"PLO(%x) PHI(%x) CTR(%x) RXR(%x) SR(%x) TXR(%x) CR(%x) TST(%x)\n",
		                 IORD(i2c_addr_array[i2c_num-1],0),
		                 IORD(i2c_addr_array[i2c_num-1],1),
		                 IORD(i2c_addr_array[i2c_num-1],2),
		                 IORD(i2c_addr_array[i2c_num-1],3),
		                 IORD(i2c_addr_array[i2c_num-1],4),
		                 IORD(i2c_addr_array[i2c_num-1],5),
		               	 IORD(i2c_addr_array[i2c_num-1],6),
		                 IORD(i2c_addr_array[i2c_num-1],7)
		                 );
     }
  return TRUE;
}
unsigned int func_sfp_read_msa (char* command_params, char* result_str, int max_response_chars) {
	unsigned long addr, res;
	unsigned int numargs_received = rsscanf(command_params,"%x",&addr);
	res = (read_from_sfp_msa(addr) & 0xFFFF);
	xsprintf(result_str,"%u\n",res);
	return TRUE;
}
unsigned int func_sfp_read_reg (char* command_params, char* result_str, int max_response_chars) {
	unsigned long addr, res;
    unsigned int numargs_received = rsscanf(command_params,"%x",&addr);
	res = read_from_sfp_reg(addr);
	//xsprintf(result_str,"%x sfp_read_reg nargs = (%x) addr=(%x) res = (%x)\n",res,numargs_received,addr,res);
	xsprintf(result_str,"%u\n",res);
	return TRUE;
}
unsigned int func_sfp_read_mac_eeprom (char* command_params, char* result_str, int max_response_chars) {
	unsigned long addr, res;
    unsigned int numargs_received = rsscanf(command_params,"%x",&addr);
	res = read_from_mac_eeprom(addr);
	//xsprintf(result_str,"%x sfp_read_reg nargs = (%x) addr=(%x) res = (%x)\n",res,numargs_received,addr,res);
	xsprintf(result_str,"%u\n",res);
	return TRUE;
}


unsigned int func_program_spartan_hex_byte_file(char* command_params, char* result_str, int max_response_chars) {
  unsigned long addr, length, fmc_num;
  unsigned int numargs_received = rsscanf(command_params,"%x %x %x",&addr,&length,&fmc_num);
  if ((numargs_received != 3) || (fmc_num >= NUM_FMC_CARDS))  {
	  printf("Got: %d values\n",length);
	  xsprintf(result_str,"%s nargs = 0x(%x) cmd = (%s) cmd_params = (%s) addr = 0x(%x) length = 0x(%x) fmc_num = 0x(%x)\n\n",STDOUT_TUNNEL_MAGIC_STR,numargs_received, last_command,command_params,addr,length,fmc_num);
	  return TRUE;
  }

  dp("found pointer with address %x\n",addr);
  unsigned char* file_contents_vector;
  file_contents_vector = (unsigned char *) addr;
  unsigned long upper_limit;
  if (length > 100 ) {
	  upper_limit = 100;
  } else {
	  upper_limit = length;
  }
  for (int i = 0; i < upper_limit; i++) {
	  printf("%08d: %02x\n",i,(unsigned) file_contents_vector[i]);
  }
  printf("Got: %d values\n",length);
  fflush(stdout);
  int op_result;
/*
  std::cout << "Erasing Flash\n";
  std::cout.flush();

  op_result = alt_erase_flash_block
		           (
		            g_board.flash[g_board.spartan[fmc_num].flash_idx].device,
		            g_board.spartan[fmc_num].offset,
		            DEFAULT_SPARTAN_FLASH_IMAGE_LENGTH

					);
*/

  std::cout << "Writing Flash\n";
    std::cout.flush();


  op_result = alt_write_flash
		           (
		            g_board.flash[g_board.spartan[fmc_num].flash_idx].device,
		            //g_board.flash[FLASH_IDX_STRATIX].device, //for Stratix
					g_board.spartan[fmc_num].offset,
					//g_board.pfl.page_addr[0].start //for Stratix
					(const void *) addr,
					length
					);
  std::cout << "Finished Writing Flash\n";
  std::cout.flush();

  xsprintf(result_str,"%d\n",op_result);
  return TRUE;
}


unsigned int func_program_stratix_hex_byte_file(char* command_params, char* result_str, int max_response_chars) {
  unsigned long addr, length;
  unsigned int numargs_received = rsscanf(command_params,"%x %x",&addr,&length);
  if (numargs_received != 2)  {
	  printf("Got: %d values\n",length);
	  xsprintf(result_str,"%s nargs = 0x(%x) cmd = (%s) cmd_params = (%s) addr = 0x(%x) length = 0x(%x)\n\n",STDOUT_TUNNEL_MAGIC_STR,numargs_received, last_command,command_params,addr,length);
	  return TRUE;
  }

  dp("found pointer with address %x\n",addr);
  unsigned char* file_contents_vector;
  file_contents_vector = (unsigned char *) addr;
  unsigned long upper_limit;
  if (length > 100 ) {
	  upper_limit = 100;
  } else {
	  upper_limit = length;
  }
  for (int i = 0; i < upper_limit; i++) {
	  printf("%08d: %02x\n",i,(unsigned) file_contents_vector[i]);
  }
  printf("Got: %d values\n",length);

  int op_result;
  std::cout << "Writing Flash\n";
     std::cout.flush();
  fflush(stdout);
  fflush(stderr);
  op_result = alt_write_flash
		           (
		            g_board.flash[FLASH_IDX_STRATIX].device, //for Stratix
					0, //for Stratix
					(const void *) addr,
					length);
  std::cout << "Op Result: "<< op_result <<"\n";
     std::cout.flush();



  xsprintf(result_str,"%d\n",op_result);
  return TRUE;
}



unsigned int func_write_to_spartan_flash(char* command_params, char* result_str, int max_response_chars) {
  unsigned long addr, length, offset;
  unsigned int numargs_received = rsscanf(command_params,"%x %x %x",&addr,&length,&offset);
  if (numargs_received != 3)  {
	  printf("Got: %d values\n",length);
	  xsprintf(result_str,"%s nargs = 0x(%x) cmd = (%s) cmd_params = (%s) addr = 0x(%x) length = 0x(%x) offset = 0x(%x)\n\n",STDOUT_TUNNEL_MAGIC_STR,numargs_received, last_command,command_params,addr,length,offset);
	  return TRUE;
  }

  dp("nargs = 0x(%x) cmd = (%s) cmd_params = (%s) addr = 0x(%x) length = 0x(%x) offset = 0x(%x)\n\n",numargs_received, last_command,command_params,addr,length,offset);
  unsigned char* file_contents_vector;
  file_contents_vector = (unsigned char *) addr;
  unsigned long upper_limit;
  if (length > 100 ) {
	  upper_limit = 100;
  } else {
	  upper_limit = length;
  }
  for (int i = 0; i < upper_limit; i++) {
	  dp("%08d: %02x\n",i,(unsigned) file_contents_vector[i]);
  }
  dp("Got: %d values, writing Flash\n",length);
  fflush(stdout);
  int op_result;


  int cpu_sr;
				         //enter critical mode because write flash is supposedly not thread safe
  op_result = alt_write_flash
		           (
		            g_board.flash[g_board.spartan[0].flash_idx].device,
					offset,
					(const void *) addr,
					length
					);

  dp("Finished Writing Spartan Flash\n");


  xsprintf(result_str,"%d\n",op_result);
  return TRUE;
}


unsigned int func_write_to_stratix_flash(char* command_params, char* result_str, int max_response_chars) {
	 unsigned long addr, length, offset;
	  unsigned int numargs_received = rsscanf(command_params,"%x %x %x",&addr,&length,&offset);
	  if (numargs_received != 3)  {
		  printf("Got: %d values\n",length);
		  xsprintf(result_str,"%s nargs = 0x(%x) cmd = (%s) cmd_params = (%s) addr = 0x(%x) length = 0x(%x) offset = 0x(%x)\n\n",STDOUT_TUNNEL_MAGIC_STR,numargs_received, last_command,command_params,addr,length,offset);
		  return TRUE;
	  }

	  dp("nargs = 0x(%x) cmd = (%s) cmd_params = (%s) addr = 0x(%x) length = 0x(%x) offset = 0x(%x)\n\n",numargs_received, last_command,command_params,addr,length,offset);
	  unsigned char* file_contents_vector;
	  file_contents_vector = (unsigned char *) addr;
	  unsigned long upper_limit;
	  if (length > 100 ) {
		  upper_limit = 100;
	  } else {
		  upper_limit = length;
	  }
	  for (int i = 0; i < upper_limit; i++) {
		  dp("%08d: %02x\n",i,(unsigned) file_contents_vector[i]);
	  }
	  dp("Got: %d values, writing Flash\n",length);
	  fflush(stdout);


  int op_result;
  int cpu_sr;
  //enter critical mode because write flash is supposedly not thread safe

  op_result = alt_write_flash
		           (
		            g_board.flash[FLASH_IDX_STRATIX].device, //for Stratix
					offset, //for Stratix
					(const void *) addr,
					length);

  dp("Finished Writing Stratix Flash\n");

  xsprintf(result_str,"%d\n",op_result);
  return TRUE;
}


unsigned int func_exec_read_devices   (char* command_params, char* result_str, int max_response_chars) {
	ReadDevices();
	xsprintf(result_str,"%s\n",__func__);
	return TRUE;
}

unsigned int func_exec_read_pins      (char* command_params, char* result_str, int max_response_chars) {
	ReadPins();
	xsprintf(result_str,"%s\n",__func__);
	return TRUE;
}

unsigned int func_get_tflash          (char* command_params, char* result_str, int max_response_chars) {
   //xsprintf(result_str,"%s %s\n",g_board.flash[0].name,g_board.flash[1].name);
	xsprintf(result_str,"%s\n",__func__);
   return TRUE;
}

unsigned int func_get_tfmc            (char* command_params, char* result_str, int max_response_chars) {
	//xsprintf(result_str,"%s\n",g_board.fmc[0].ReadByte, g_board.fmc[0].WriteByte, );
	xsprintf(result_str,"%s\n",__func__);
	return TRUE;
}

unsigned int func_get_tpfl            (char* command_params, char* result_str, int max_response_chars) {
	xsprintf(result_str,"%s\n",__func__);
	return TRUE;
}

unsigned int func_get_tpm             (char* command_params, char* result_str, int max_response_chars) {
	xsprintf(result_str,"%s\n",__func__);
	return TRUE;
}

unsigned int func_get_tspartan        (char* command_params, char* result_str, int max_response_chars) {
	xsprintf(result_str,"%s\n",__func__);
	return TRUE;
}

unsigned int func_get_ttemp           (char* command_params, char* result_str, int max_response_chars) {
	xsprintf(result_str,"%s\n",__func__);
	return TRUE;
}

unsigned int func_get_tuser_dip       (char* command_params, char* result_str, int max_response_chars) {
	xsprintf(result_str,"%s\n",__func__);
	return TRUE;
}


//the commands need to be in alphabetical order
struct command {
    char *name;
    unsigned int (*cmd_func)(char *, char *, int);
} board_mgmt_command_tbl[] = {
	{ "board_mgmt_name"    , func_get_board_mgmt_name     },
	{ "exec_read_devices"  , func_exec_read_devices       },
	{ "exec_read_pins"     , func_exec_read_pins          },
	{ "get_devices"        , func_get_devices             },
	{ "get_json_status"    , func_get_json_status         },
	{ "get_tflash" 	       , func_get_tflash              },
	{ "get_tfmc"           , func_get_tfmc                },
	{ "get_tpfl"           , func_get_tpfl                },
	{ "get_tpm"	           , func_get_tpm                 },
	{ "get_tspartan"       , func_get_tspartan            },
	{ "get_ttemp"          , func_get_ttemp               },
	{ "get_tuser_dip"      , func_get_tuser_dip           },
	{ "i2c_init"     , func_i2c_init    },
	{ "i2c_read"     , func_i2c_read    },
	{ "i2c_snapshot" , func_i2c_snapshot    },
	{ "i2c_start"   , func_i2c_start    },
	{ "i2c_write"   , func_i2c_write    },
	{ "json_print_write"   , func_json_print },
	{ "num_uarts"   , func_get_num_uarts     },
	{ "program_spartan_hex",func_program_spartan_hex_byte_file },
	{ "program_stratix_hex",func_program_stratix_hex_byte_file },
    { "project_name", func_get_project_name },
    { "sw_date"     , func_sw_date_str },
    { "version"     , func_get_board_mgmt_version  },
	{ "write_to_spartan_flash", func_write_to_spartan_flash },
	{ "write_to_stratix_flash", func_write_to_stratix_flash }
};

#define N_CMDS (sizeof board_mgmt_command_tbl / sizeof board_mgmt_command_tbl[0])

static int comp_cmd(const void *c1, const void *c2)
{
    const struct command *cmd1 = (const struct command *)c1, *cmd2 = (const struct command *)c2;

    //return memcmp(cmd1->name, cmd2->name, 2); //change this to something better
    return strcmp(cmd1->name, cmd2->name);
}

static struct command *get_cmd(char *name)
{
    struct command target = { name, NULL };

    return (struct command *) bsearch(&target, board_mgmt_command_tbl, N_CMDS, sizeof board_mgmt_command_tbl[0], comp_cmd);
}


unsigned int execute_internal_command (char * the_command, char* result_str, int max_command_chars, int max_response_chars)
{

    char command_name[max_command_chars];
    char *command_params;
    xsprintf(last_command,"%s",the_command);
    get_first_string(the_command, command_name, max_command_chars);
    command_params=get_second_string_pointer(the_command);

	struct command *cmd = get_cmd(command_name);

	if (cmd) {
	    return (cmd->cmd_func(command_params,result_str,max_response_chars));
	} else {
		xsprintf(result_str,"Error: commmand not found (%s)!\n", the_command);
		return FALSE;
	}
	return FALSE;

}


std::string execute_internal_command_subjugate(std::string the_command, void* additional_data) {
	    int result;
	    int max_command_chars = 4096;
	    char command_name[max_command_chars];
	    char result_str[ADC_MCS_RESPONSE_MAXLENGTH];
	    char *command_params;
	    char* the_command_c_str;
	    the_command_c_str = my_mem_strdup(the_command.c_str());
	    char *original_the_command_c_str = the_command_c_str;
	    xsprintf(last_command,"%s",the_command_c_str);
	    get_first_string(the_command_c_str, command_name, max_command_chars);
	    command_params=get_second_string_pointer(the_command_c_str);

		struct command *cmd = get_cmd(command_name);

		if (cmd) {
		    result = (cmd->cmd_func(command_params,result_str,ADC_MCS_RESPONSE_MAXLENGTH));
		} else {
			xsprintf(result_str,"Error: commmand not found (%s)!\n", the_command_c_str);
			result = FALSE;
		}
		std::string result_str_cpp = result_str;
		my_mem_free(original_the_command_c_str);
		//std::cout << "execute_internal_command_subjugate returning: (" << result_str_cpp << " )\n";
		//std::cout.flush();
		return result_str_cpp;
}
