/*
 * card_configuration_encapsulator.h
 *
 *  Created on: Nov 21, 2013
 *      Author: yairlinn
 */

#ifndef CARD_CONFIGURATION_ENCAPSULATOR_H_
#define CARD_CONFIGURATION_ENCAPSULATOR_H_

#include "basedef.h"
#include "linnux_utils.h"
#include "dip_switch_encapsulator.h"
#include "ini_reader/INIReader.h"
#include "linnux_utils.h"
#include <vector>

#define CARD_CONFIG_ENCAPSULATOR_IS_MASTER_MASK (0x1)
#define CARD_CONFIG_ENCAPSULATOR_CARD_REV_LSB   (2)
#define CARD_CONFIG_ENCAPSULATOR_CARD_REV_MSB   (3)
#define CARD_CONFIG_ENCAPSULATOR_CARD_ASSIGNED_NUM_LSB   (4)
#define CARD_CONFIG_ENCAPSULATOR_CARD_ASSIGNED_NUM_MSB   (7)

class card_configuration_encapsulator : public INIReader {
protected:
	dip_switch_encapsulator dip_switches;
public:
	card_configuration_encapsulator(unsigned long base_address) : INIReader()  {

		dip_switches.set_base_address(base_address);

		// TODO Auto-generated constructor stub

	}

	int is_slave() {return !(this->is_master()); };
	int is_master() {return ((dip_switches.read() & CARD_CONFIG_ENCAPSULATOR_IS_MASTER_MASK) != 0); };
	unsigned int get_card_revision() {
		return extract_bit_range(dip_switches.read(),
			                     CARD_CONFIG_ENCAPSULATOR_CARD_REV_LSB,
			                     CARD_CONFIG_ENCAPSULATOR_CARD_REV_MSB);
	}

	unsigned int get_card_assigned_number(){
		   return extract_bit_range(dip_switches.read(),
				   CARD_CONFIG_ENCAPSULATOR_CARD_ASSIGNED_NUM_LSB,
				   CARD_CONFIG_ENCAPSULATOR_CARD_ASSIGNED_NUM_MSB);
	        };

	int get_ini_file_mac_addr(std::vector<unsigned int>& mac_addr) {
			if (this->KeyExists("network", "mac_addr")) {
			std::string mac_addr_str = this->Get("network", "mac_addr", DEFAULT_INI_MAC_ADDR);
			mac_addr = get_mac_addr_from_string(mac_addr_str);
			 if (mac_addr.size() != 6) {
				 return (LINNUX_RETVAL_FALSE);
			 }
			return (LINNUX_RETVAL_TRUE);
		} else {
			return (LINNUX_RETVAL_FALSE);
		}
	}

		int get_ini_file_mac_addr_as_c_array(unsigned int mac_addr[6]) {
			std::vector<unsigned int> mac_addr_vec;
             if (get_ini_file_mac_addr(mac_addr_vec)) {
            	 if (mac_addr_vec.size() != 6) {
            		 return (LINNUX_RETVAL_FALSE);
            	 }
            	 for (unsigned i = 0; i < 6; i++) {
            		 mac_addr[i] = mac_addr_vec.at(i);
            	 }
            	 return (LINNUX_RETVAL_TRUE);
             } else {
            	 return (LINNUX_RETVAL_FALSE);
             }
		}


};

#endif /* CARD_CONFIGURATION_ENCAPSULATOR_H_ */
