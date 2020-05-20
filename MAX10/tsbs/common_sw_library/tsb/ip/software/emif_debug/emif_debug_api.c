// Example program for using the Altera EMIF On-Chip Debug Port
// Quartus Version: 17.0std
#include "emif_export.h"
#include <system.h>
global_param_t* glob_param;
mem_param_t* mem_param;

// Sends a command to the EMIF
alt_32 send_command(volatile debug_data_t* debug_data_ptr, alt_32 command, alt_32 args[], alt_32 num_args)
{
	volatile alt_32 i, response;

	// Wait until command_status is ready
	do {
		response = IORD_32DIRECT(&(debug_data_ptr->command_status), 0);
	} while(response != TCLDBG_TX_STATUS_CMD_READY);

	// Load arguments
	if(num_args > COMMAND_PARAM_WORDS)
	{
		// Too many arguments
		return 0;
	}
	for(i = 0; i < num_args; i++)
	{
		IOWR_32DIRECT(&(debug_data_ptr->command_parameters[i]), 0, args[i]);
	}

	// Send command code
	IOWR_32DIRECT(&(debug_data_ptr->requested_command), 0, command);

	// Wait for acknowledgment
	do {
		response = IORD_32DIRECT(&(debug_data_ptr->command_status), 0);
	} while(response != TCLDBG_TX_STATUS_RESPONSE_READY && response != TCLDBG_TX_STATUS_ILLEGAL_CMD);

	// Acknowledge response
	IOWR_32DIRECT(&(debug_data_ptr->requested_command), 0, TCLDBG_CMD_RESPONSE_ACK);

	// Return 1 on success, 0 on illegal command
	return (response != TCLDBG_TX_STATUS_ILLEGAL_CMD);
}

int emif_complete_status_report()
{
    // Replace these with the desired interface, pin, etc.
    const alt_32 interface_id = 0;
    const alt_u32 lane = 0;
    const alt_u32 dq = 0;
    const alt_u32 dqs = 0;
    const alt_u32 ca = 0;
    const alt_u32 dm = 0;
    alt_32 value = 0;
    alt_32 args[COMMAND_PARAM_WORDS];

    // Read and print the global parameter table
    glob_param = (global_param_t*)DDR4_ARCH_BASE + G_HEAP_STARTING_ADDR;
    print_global_param(glob_param);

    // Read and print the memory parameter table
    init_parameter_table(interface_id);
    print_mem_param(mem_param);

    // Read and print the debug data reports
    volatile debug_data_t* debug_data = (debug_data_t*)(DDR4_ARCH_BASE + G_HEAP_STARTING_ADDR + mem_param->pt_DEBUG_DATA_PTR);

    // Recalibrate
    args[0] = interface_id;
    args[1] = INIT_MODE_DYNAMIC_FULL_RECAL;
    send_command(debug_data, TCLDBG_RUN_MEM_CALIBRATE, args, 2);

    // Wait for report to be ready
    volatile alt_u32* flags = &(debug_data->mem_summary_report->report_flags);
    while (!(*flags & DEBUG_REPORT_STATUS_REPORT_READY));
    print_debug_data((debug_data_t*)debug_data);
    print_summary_report(debug_data->mem_summary_report);
    print_cal_report(debug_data->mem_cal_report);

    // Test access to PHY settings
    // init_parameter_table(interface_id) must be called prior to using these functions
    // g_rank_shadow must be set prior to using these functions
    g_rank_shadow = 0;

    value = get_dq_in_delay(dq);
    uart_printf("get_dq_in_delay(%d) = %d\n", dq, value);
    set_dq_in_delay(dq, value);

    value = get_dqs_in_delay(dqs);
    uart_printf("get_dqs_in_delay(%d) = %d\n", dqs, value);
    set_dqs_in_delay(dqs, value);

    value = get_dqs_lane_in_delay(dqs, lane);
    uart_printf("get_dqs_lane_in_delay(%d, %d) = %d\n", dqs, lane, value);
    set_dqs_lane_in_a_delay(dqs, lane, value);

    value = get_dqs_lane_in_b_delay(dqs, lane);
    uart_printf("get_dqs_lane_in_b_delay(%d, %d) = %d\n", dqs, lane, value);
    set_dqs_lane_in_b_delay(dqs, lane, value);

    value = get_dqs_en_delay(dqs);
    uart_printf("get_dqs_en_delay(%d) = %d\n", dqs, value);
    set_dqs_en_delay(dqs, value);

    value = get_final_dq_out_delay(dq);
    uart_printf("get_final_dq_out_delay(%d) = %d\n", dq, value);
    set_dq_out_delay(dq, value);

    value = get_final_dqs_out_delay(dqs);
    uart_printf("get_final_dqs_out_delay(%d) = %d\n", dqs, value);
    set_dqs_out_delay(dqs, value);

    if (mem_param->pt_NUM_DM > 0) {
      value = get_dbi_in_delay(dm);
      uart_printf("get_dbi_in_delay(%d) = %d\n", dm, value);
      set_dbi_in_delay(dqs, value);

      value = get_final_dm_dbi_out_delay(dm);
      uart_printf("get_final_dm_dbi_out_delay(%d) = %d\n", dm, value);
      set_dm_dbi_out_delay(dm, value);
    }

    value = get_vfifo_latency(dqs);
    uart_printf("get_vfifo_latency(%d) = %d\n", dqs, value);
    set_vfifo_latency(dqs, value);

    value = get_lfifo_latency(dqs);
    uart_printf("get_lfifo_latency(%d) = %d\n", dqs, value);
    set_lfifo_latency(dqs, value);

    value = get_ca_delay(ca);
    uart_printf("get_ca_delay(%d) = %d\n", ca, value);
    set_ca_delay(ca, value);

    // End transmission
    alt_putchar(4);

    return 0;
}
