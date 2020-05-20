#ifndef LINNUX_MAIN_H_
#define LINNUX_MAIN_H_

#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <unistd.h>
#include <vector>
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "system.h"

#include "linnux_testbench_constants.h"
#include "register_keeper_api.h"
#include "chan_fatfs/fatfs_linnux_api.h"
#include "fifo_access_container.h"
#include "eyed_fifo_access_container.h"
#include "linnux_utils.h"
#include "chan_fatfs/terasic_linnux_driver.h"
#include "dual_port_ram_container.h"
#include "linnux_menu.h"
#include "correlation_fifo_class.h"
//#include "seven_segment_encapsulator.h"
#include "gp_fifo_encapsulator.h"
#include "chan_fatfs/terasic_linnux_driver_c.h"
#include "log_file_encapsulator.h"
#include "matlab_curve_linetype_generator.h"
#include "memory_comm_encapsulator.h"

extern matlab_curve_linetype_generator matlab_curve_linetype_generator_for_tcl;
extern std::string tcl_script_file_to_load_before_BER_func_in_SJTOL;
extern std::string tcl_proc_name_run_before_BER_func_in_SJTOL;
extern int tcl_script_registered_as_before_BER_func;

extern std::string tcl_proc_name_for_DUT_diag;
extern std::string tcl_script_file_to_load_for_DUT_diag_proc;
extern int tcl_script_registered_DUT_diag_func;
extern int we_are_in_control_verbose_mode;

class bedrock_linnux_main_context_class {
protected:
	mem_comm_ucos_class_vector_type* mem_comm_ucos_vector_ptr;
public:
	bedrock_linnux_main_context_class() {
		mem_comm_ucos_vector_ptr = NULL;
	}
	mem_comm_ucos_class_vector_type* get_mem_comm_ucos_vector_ptr() { return mem_comm_ucos_vector_ptr; };
	set_mem_comm_ucos_vector_ptr(mem_comm_ucos_class_vector_type* the_mem_comm_ucos_vector_ptr) {
		mem_comm_ucos_vector_ptr = the_mem_comm_ucos_vector_ptr;
	}
};

void bedrock_linnux_main(void *pd);
void bedrock_linnux_control_main(void *);
void bedrock_dut_processor_control_main(void *);

std::string bedrock_exec_linnux_command_from_picol(std::string);
std::string bedrock_exec_linnux_control_command_from_tcl(std::string);
void update_json_motherboard_object();
void update_total_json_object();
void update_json_fmc_object(unsigned long);
void update_json_board_mgmt_object();
std::string do_linnux_command(std::string& input_str_from_external_func, int is_called_from_tcl_script, LINNUX_COMAND_TYPES calling_command_type, int* command_found = NULL);
void print_memory_usage();
extern std::string system_h_str;
#endif
