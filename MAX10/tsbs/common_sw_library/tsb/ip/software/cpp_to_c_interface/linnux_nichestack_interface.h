/*
 * linnux_nichestack_interface.h
 *
 *  Created on: Sep 28, 2011
 *      Author: linnyair
 */

#ifndef LINNUX_NICHESTACK_INTERFACE_H_
#define LINNUX_NICHESTACK_INTERFACE_H_
#ifdef __cplusplus
extern "C" {
#endif

#if defined(__STDC__) || defined(__cplusplus)
	/* ANSI C prototypes */
	extern void linnux_main(void *pd);
	extern void linnux_control_main(void *pd);
	extern void linnux_response_main(void *pd);
	extern void tcp_echo_server_main(void *pd);
	extern void tcp_daytime_server_main(void *pd);
	extern void tcp_echo_client_main(void *pd);
	extern void tcp_multiple_echo_server_main(void *pd);
    extern void c_os_critical_low_level_system_usleep(unsigned long num_us);
	extern void c_write_green_led_state_to_leds();
	extern void c_write_red_led_state_to_leds();
	extern void c_write_red_led_pattern (unsigned long the_pattern);
	extern void c_write_green_led_pattern (unsigned long the_pattern);
	extern unsigned long c_get_green_led_state();
	extern unsigned long c_get_red_led_state();
	extern unsigned long c_read_switches();
#else
	/* K&R style */
	extern int linnux_main(void *pd);
	//extern int exec_linnux_command_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj *const *argv);
#endif

#ifdef __cplusplus
}
#endif


#endif /* LINNUX_NICHESTACK_INTERFACE_H_ */
