/*
 * cpp_to_c_header_interface.h
 *
 *  Created on: Nov 9, 2011
 *      Author: linnyair
 */

#ifndef CPP_TO_C_H_
#define CPP_TO_C_H_

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__STDC__) || defined(__cplusplus)
	/* ANSI C prototypes */
#include "ucos_ii.h"

	extern  OS_STK*   NicheStackGlobalStaticStack_Ptr; //use "/2" to give 2x margin, sinc OSSTK is 4 bytes

	extern void c_write_decimal_to_7seg_encapsulator(unsigned int);
    //#define c_write_task_prio_to_7seg c_write_decimal_to_7seg_encapsulator(OSTCBCur->OSTCBPrio)
    #define c_write_task_prio_to_7seg

	extern void disrupt_tcpip();
	extern void undisrupt_tcpip();
	extern void print_pktlog();
	extern void print_ucosdiag();
	extern unsigned long long c_low_level_system_timestamp();
	extern unsigned long long c_os_critical_low_level_system_timestamp();
	extern int c_low_level_system_usleep(unsigned long num_us);
	extern int c_os_critical_wait_counter_cycles(unsigned long numcycles);
	unsigned long c_low_level_system_timestamp_in_secs();
	unsigned long os_critical_c_low_level_system_timestamp_in_secs();
	extern char *get_current_time_as_c_string();
	extern int c_os_critical_wait_short_amount_of_time();
	extern void MDIO_IOWR(unsigned long, unsigned long, unsigned long);
	extern unsigned long MDIO_IORD(unsigned long, unsigned long);
	extern int get_mac_addr_from_fmc_eeprom(unsigned int mac_addr [6]);
	int tseSfpConfigureLink(unsigned int speed, unsigned int duplex, unsigned long long timeout_baset, unsigned long long timeout_basex);
	void tseSfpConfigureMAC(unsigned int speed, unsigned int duplex);
	void restartPCSAutonegotiation();
	void deIsolatePCSFromMAC();
	extern void c_print_out_to_all_streams(const char*);
	extern int SD_card_is_detected();
	extern int c_get_ini_file_mac_addr(unsigned int mac_addr[6]);
	extern int c_get_default_mac_addr(unsigned int mac_addr[6]);
	extern void c_convert_ull_to_string(unsigned long long the_value, char *output_str);
	extern int get_rgmii_phy_tx_delay_disable();
	extern int get_rgmii_phy_rx_delay_disable();
	extern int get_rgmii_disable_1gbit_mode();
	extern int get_rgmii_disable_100mbps_mode();

	// extern void os_critical_delay_exactly_40_ns();
	// extern void os_critical_delay_exactly_1_us();

#else
	/* K&R style */


#endif

#ifdef __cplusplus
}
#endif


#endif /* CPP_TO_C_H_ */


