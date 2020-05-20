/*
 * interrupt_handling_utils.h
 *
 *  Created on: May 24, 2011
 *      Author: linnyair
 */

#ifndef INTERRUPT_HANDLING_UTILS_H_
#define INTERRUPT_HANDLING_UTILS_H_

/*
 * interrupt_handling_utils.h
 *
 *  Created on: May 24, 2011
 *      Author: linnyair
 */

void reset_interrupt_positions(unsigned long position_mask);
unsigned long get_interrupt_positions(unsigned long position_mask);
void display_interrupt_reg_on_leds();
void clear_sjtol_stop_request_irq_edge_capture();
void clear_tcl_stop_request_irq_edge_capture();
void do_interrupt_critical_operations();

#endif /* INTERRUPT_HANDLING_UTILS_H_ */
