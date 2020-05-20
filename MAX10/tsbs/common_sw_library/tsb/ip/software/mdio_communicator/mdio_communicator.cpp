/*
 * mdio_communicator.cpp
 *
 *  Created on: Aug 16, 2013
 *      Author: yairlinn
 */

#include "mdio_communicator.h"




void mdio_communicator::mdio_write(unsigned long reg, unsigned long val) {
	if ((get_uart_proc() == NULL) || (!is_enabled()) ) {
		safe_print(std::cout << " mdio_communicator::mdio_write Error: uart_connected_proc is = " << get_uart_proc() << " or mdio communicator not enabled enable = " << is_enabled() << std::endl);
	}
	else {
		std::ostringstream internal_command;
		std::string retstr;
		internal_command << "sfp_write_reg " << std::hex <<  reg << " " << val << std::dec;
		retstr = uart_connected_proc->exec_internal_command(internal_command.str());
		mdio_debug("wrote to mdio reg: 0x" << std::hex << reg << " val: 0x" << val << " command : (" << internal_command.str() << ") retstr (" << retstr << ")" << std::endl);
	}
 }


unsigned long mdio_communicator::mdio_read(unsigned long reg) {
	if ((get_uart_proc() == NULL) || (!is_enabled()) ) {
			safe_print(std::cout << " mdio_communicator::mdio_write Error: uart_connected_proc is = " << get_uart_proc() << " or mdio communicator not enabled enable = " << is_enabled() << std::endl);
			return 0xEAAEAA;
	}
	else {
		unsigned long retval;
		unsigned long numargs;
		std::ostringstream internal_command;
		std::string response_str;
		internal_command << "sfp_read_reg " << std::hex <<  reg << std::dec;
		response_str = uart_connected_proc->exec_internal_command(internal_command.str());
		mdio_debug("read from  mdio reg: 0x" << std::hex << reg << " command : (" << internal_command.str() << ") retstr (" << response_str << ")" << std::endl);
		numargs = sscanf(response_str.c_str(),"%lu",&retval);
		if (numargs != 1) {
			safe_print(std::cout << " mdio_communicator::mdio_read Error: numargs = " << numargs << " Response_str = (" << response_str << ") retval = " << retval << std::endl);
		}
		return retval;
	}
 }

int mdio_communicator::get_mac_addr(unsigned int mac_addr[6]) {
	if (get_uart_proc() == NULL  || (!is_enabled()) ) {
		safe_print(std::cout << " mdio_communicator::mdio_write Error: uart_connected_proc is = " << get_uart_proc() << " or mdio communicator not enabled enable = " << is_enabled() << std::endl);
		return RETURN_VAL_ERROR;
	}
	else {
		mac_addr[0]=mac_addr[1]=mac_addr[2]=mac_addr[3]=mac_addr[4]=mac_addr[5]=0;
		unsigned long retval;
		unsigned long numargs;
		std::ostringstream internal_command;
		std::string response_str;
		internal_command << "get_mac_addr";
		response_str = uart_connected_proc->exec_internal_command(internal_command.str());
		mdio_debug("mdio_communicator::get_mac_addr:  (" << response_str << ")" << std::endl);
		unsigned int a,c,b,d,e,f;
		numargs = sscanf(response_str.c_str(),"%02x:%02x:%02x:%02x:%02x:%02x",&a,&b,&c,&d,&e,&f);

		mac_addr[0]=a;
		mac_addr[1]=b;
		mac_addr[2]=c;
		mac_addr[3]=d;
		mac_addr[4]=e;
		mac_addr[5]=f;
		mdio_debug("mdio_communicator::get_mac_addr:  parsed: (" << std::hex  << mac_addr[0] << ":" << mac_addr[1] << ":"  << mac_addr[2] << ":" << mac_addr[3] << ":" << mac_addr[4] << ":" << mac_addr[5] << ")" << std::dec << std::endl);

		if (numargs != 6) {
			safe_print(std::cout << " mdio_communicator::mdio_read Error: numargs = (" << response_str << ")" << std::endl);
			return RETURN_VAL_ERROR;
		}
		return RETURN_VAL_TRUE;
	}
 }



