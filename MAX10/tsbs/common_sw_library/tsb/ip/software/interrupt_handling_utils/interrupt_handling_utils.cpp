/*
 * interrupt_handling_utils.cpp
 *
 *  Created on: May 24, 2011
 *      Author: linnyair
 */

#include "interrupt_handling_utils.h"
//#include "linnux_testbench_constants.h"
#include "linnux_utils.h"
#include "basedef.h"
#include "altera_avalon_timer_regs.h"
#include "cpp_to_c_header_interface.h"
extern "C" {
	#include "sys/alt_stdio.h"
    #include "ucos_ii.h"
#include "xprintf.h"

}
extern volatile int button_irq_edge_capture;
extern volatile int button_irq_edge_capture_raw;

void reset_interrupt_positions(unsigned long position_mask)
{
	button_irq_edge_capture = button_irq_edge_capture & (~(position_mask));
	button_irq_edge_capture_raw = button_irq_edge_capture_raw & (~(position_mask));
	display_interrupt_reg_on_leds();
}

unsigned long get_interrupt_positions(unsigned long position_mask)
{
	return (button_irq_edge_capture & position_mask);
}

void display_interrupt_reg_on_leds()
{
	write_red_led_pattern(button_irq_edge_capture & 0xFF);
}

void clear_sjtol_stop_request_irq_edge_capture()
{
	reset_interrupt_positions(SJTOL_IRQ_STOP_REQUEST_MASK);
}


void clear_tcl_stop_request_irq_edge_capture()
{
	reset_interrupt_positions(STOP_TCL_SCRIPT_REQUEST_MASK);
}


void print_timer_status()
{
	/*
	unsigned long timer_status =  IORD_ALTERA_AVALON_TIMER_STATUS(SYS_CLK_TIMER_BASE);
	unsigned long control_status =  IORD_ALTERA_AVALON_TIMER_CONTROL(SYS_CLK_TIMER_BASE);
	unsigned long periodl_status =  IORD_ALTERA_AVALON_TIMER_PERIODL(SYS_CLK_TIMER_BASE);
	unsigned long periodh_status =  IORD_ALTERA_AVALON_TIMER_PERIODH(SYS_CLK_TIMER_BASE);
	unsigned long snapl_status =  IORD_ALTERA_AVALON_TIMER_SNAPL(SYS_CLK_TIMER_BASE);
	unsigned long snaph_status =  IORD_ALTERA_AVALON_TIMER_SNAPH(SYS_CLK_TIMER_BASE);
	xprintf("stat=%x,ctrl=%x,perl=%x,perh=%x,snl=%x,snh=%x\n",(unsigned int) timer_status,
			 (unsigned int) control_status, (unsigned int)periodl_status,(unsigned int) periodh_status, (unsigned int) snapl_status,
			 (unsigned int) snaph_status);
			 */
}

void do_interrupt_critical_operations()
{
			static unsigned long printout_var = 0;
			unsigned long sw_val;
			int cpu_sr;
			unsigned long button_val;
//int cpu_sr;

            //OS_ENTER_CRITICAL();
            //OS_EXIT_CRITICAL();
			print_timer_status();

		    alt_irq_context context;

			NIOS2_READ_STATUS (context);
            alt_printf("irq_context = %x",(unsigned int) context);

            button_val = get_interrupt_positions(CRITICAL_INTERRUPT_ROUTINE_MASK);

			sw_val = read_switches();

            alt_printf("Switch Val = %x\n",(int)sw_val);
            //OS_TaskStatStkChk();
            inner_OSTaskStatHook(1);

			if (button_val != 0) {
				if (printout_var == 0) {
					alt_printf("In interrupt routine, printing stats and enabling stats, exiting ethernet quiet mode!\n");
					printout_var = 1;
					//print_pktlog();
					//print_ucosdiag();
					linnux_print_task_statistics = 1;
					print_packet_log = 1;
					linnux_printf_ucos_diag = 1;
					we_are_in_ethernet_quiet_mode = 0;

					if (sw_val != 0) {
									task_to_delete_please = sw_val;
					                req_network_watchdog_to_delete_task = 1;
					                alt_printf("Requesting to delete task %x\n",(int) sw_val);
								}
				} else {
					printout_var = 0;
					alt_printf("In interrupt routine, disabling stats, entering ethernet quiet mode!\n");
					linnux_print_task_statistics = 0;
					print_packet_log = 0;
					linnux_printf_ucos_diag = 0;
					we_are_in_ethernet_quiet_mode = 1;
				}
			}
//			OS_EXIT_CRITICAL();
			reset_interrupt_positions(CRITICAL_INTERRUPT_ROUTINE_MASK);

}
