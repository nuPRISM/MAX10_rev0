/*
 * cpp_network_utilities.cpp
 *
 *  Created on: Dec 3, 2013
 *      Author: yairlinn
 */

#include "cpp_network_utilities.h"
#include "card_configuration_encapsulator.h"
#include "linnux_utils.h"
#include <stdio.h>
#include <string>
#include <iostream>
#include <fstream>


#define IP4_ADDR(ipaddr, a,b,c,d) ipaddr = \
    htonl((((alt_u32)(a & 0xff) << 24) | ((alt_u32)(b & 0xff) << 16) | \
          ((alt_u32)(c & 0xff) << 8) | (alt_u32)(d & 0xff)))

extern "C" {
u_long inet_addr(char far * str);
}

extern card_configuration_encapsulator card_configuration;

int c_get_default_mac_addr(unsigned int mac_addr[6]) {
	std::vector<unsigned int> mac_addr_vec = get_mac_addr_from_string(std::string(DEFAULT_INI_MAC_ADDR));
	std::cout << "Converted default mac addr = ";
	print_std_vector(mac_addr_vec);
	if (mac_addr_vec.size() != 6) {
		 return (LINNUX_RETVAL_FALSE);
	}

	for (unsigned i = 0; i < 6; i++) {
		 mac_addr[i] = mac_addr_vec.at(i);
	}

	return (LINNUX_RETVAL_TRUE);
}

int c_get_ini_file_mac_addr(unsigned int mac_addr[6]) {
	return card_configuration.get_ini_file_mac_addr_as_c_array(mac_addr);
}
static void assign_char_mac_addr_from_uint_macaddr(unsigned char mac_addr[6], unsigned int uint_macaddr[6]) {
  mac_addr[0] = uint_macaddr[0] & 0xff;
	     mac_addr[1] = uint_macaddr[1] & 0xff;
	     mac_addr[2] = uint_macaddr[2] & 0xff;
	     mac_addr[3] = uint_macaddr[3] & 0xff;
	     mac_addr[4] = uint_macaddr[4] & 0xff;
	     mac_addr[5] = uint_macaddr[5] & 0xff;
}

error_t cpp_get_board_mac_addr(unsigned char mac_addr[6]) {
	 error_t error = 0;
	 int use_autonegotiation;
	 unsigned int eth_speed;
	 unsigned int eth_duplex;


	  int retval;
	  unsigned int uint_macaddr[6];

	  if (c_get_ini_file_mac_addr(uint_macaddr))
	  {
		    assign_char_mac_addr_from_uint_macaddr(mac_addr,uint_macaddr);
		    safe_print(printf("Found Ethernet MAC Address in INI file: %02x:%02x:%02x:%02x:%02x:%02x\n",
		              mac_addr[0],
		              mac_addr[1],
		              mac_addr[2],
		              mac_addr[3],
		              mac_addr[4],
		              mac_addr[5]));
	  } else {
				  retval = get_mac_addr_from_fmc_eeprom(uint_macaddr);
				  if (retval == RETURN_VAL_ERROR) {
					  safe_print(printf("Error: get_board_mac_addr: could not read MAC address from INI file or EEPROM, reverting to default mac address\n"));
					  c_get_default_mac_addr(uint_macaddr);
					  assign_char_mac_addr_from_uint_macaddr(mac_addr,uint_macaddr);
				  } else {
					assign_char_mac_addr_from_uint_macaddr(mac_addr,uint_macaddr);
					 safe_print(printf("Found Ethernet MAC Address in EEPROM: %02x:%02x:%02x:%02x:%02x:%02x\n",
						              mac_addr[0],
						              mac_addr[1],
						              mac_addr[2],
						              mac_addr[3],
						              mac_addr[4],
						              mac_addr[5]));
				  }
	  }

	  safe_print(printf("Your Ethernet MAC address is %02x:%02x:%02x:%02x:%02x:%02x\n",
	          mac_addr[0],
	          mac_addr[1],
	          mac_addr[2],
	          mac_addr[3],
	          mac_addr[4],
	          mac_addr[5]));


	  board_mac_addr[0] = mac_addr[0];
	  board_mac_addr[1] = mac_addr[1];
	  board_mac_addr[2] = mac_addr[2];
	  board_mac_addr[3] = mac_addr[3];
	  board_mac_addr[4] = mac_addr[4];
	  board_mac_addr[5] = mac_addr[5];

	  use_autonegotiation = card_configuration.GetInteger("network", "use_autonegotiation", DEFAULT_INI_USE_AUTONEGOTIATION        );
	  eth_speed = card_configuration.GetInteger("network", "default_ethernet_speed_mbps"  , DEFAULT_INI_DEFAULT_ETHERNET_SPEED_MBPS);
	  eth_duplex = card_configuration.GetInteger("network", "default_ethernet_duplex"     , DEFAULT_INI_DEFAULT_ETHERNET_DUPLEX    );


	  if (use_autonegotiation) {
		  safe_print(printf("Autonegotiation enabled!!!"));
   	       tseSfpConfigureLink(eth_speed,eth_duplex,WATCHDOG_TIME_FOR_FOR_1000_BASE_T_IN_64_BIT_COUNTER_TICKS,WATCHDOG_TIME_FOR_FOR_1000_BASE_X_IN_64_BIT_COUNTER_TICKS);
	  } else {
		  safe_print(printf("Autonegotiation disabled!!!"));
		  //restartPCSAutonegotiation();
		 // deIsolatePCSFromMAC();
		 // tseSfpConfigureMAC(eth_speed,eth_duplex);
	  }
	/*
	  if (!tseSfpConfigureLink(1000,1,WATCHDOG_TIME_FOR_FOR_1000_BASE_T_IN_64_BIT_COUNTER_TICKS,WATCHDOG_TIME_FOR_FOR_1000_BASE_X_IN_64_BIT_COUNTER_TICKS)) { //ugly way to initialize autonegotiation
		  printf("Autonegotiation failed! trying again with double the timeout!\n");
	      tseSfpConfigureLink(1000,1,2*(WATCHDOG_TIME_FOR_FOR_1000_BASE_T_IN_64_BIT_COUNTER_TICKS),2*(WATCHDOG_TIME_FOR_FOR_1000_BASE_X_IN_64_BIT_COUNTER_TICKS)); //ugly way to initialize autonegotiation
	  }
	*/
	  return error;
}



int cpp_get_ip_addr (
		        alt_iniche_dev *p_dev,
                ip_addr* ipaddr,
                ip_addr* netmask,
                ip_addr* gw,
                int* use_dhcp
               )
{


unsigned int IPADDR0;
unsigned int IPADDR1;
unsigned int IPADDR2;
unsigned int IPADDR3;


unsigned int GWADDR0;
unsigned int GWADDR1;
unsigned int GWADDR2;
unsigned int GWADDR3;

unsigned int MSKADDR0;
unsigned int MSKADDR1;
unsigned int MSKADDR2;
unsigned int MSKADDR3;

    std::string static_ip = card_configuration.Get("network", "default_static_ip", DEFAULT_INI_FILE_DEFAULT_STATIC_IP);
    std::string gateway = card_configuration.Get("network", "gateway", DEFAULT_INI_FILE_DEFAULT_GATEWAY);
    std::string mask = card_configuration.Get("network", "mask", DEFAULT_INI_FILE_DEFAULT_MASK);

    safe_print(printf("Ini File default params: default_static_ip (%s) gateway (%s) mask (%s)", static_ip.c_str(), gateway.c_str(),mask.c_str()));

	if (!get_ip_addr_components_from_ip_addr_string(static_ip.c_str(),IPADDR0, IPADDR1, IPADDR2, IPADDR3)) {
        safe_print(printf("[cpp_get_ip_addr] error using get_ip_addr_components_from_ip_addr_string: invalid IP address (%s)?\n", static_ip.c_str()));
	}

	if (!get_ip_addr_components_from_ip_addr_string(gateway.c_str(),GWADDR0, GWADDR1, GWADDR2, GWADDR3)) {
	        safe_print(printf("[cpp_get_ip_addr] error using get_ip_addr_components_from_ip_addr_string: invalid gateway (%s)?\n",gateway.c_str()));
	}

	if (!get_ip_addr_components_from_ip_addr_string(mask.c_str(), MSKADDR0, MSKADDR1, MSKADDR2, MSKADDR3)) {
	        safe_print(printf("[cpp_get_ip_addr] error using get_ip_addr_components_from_ip_addr_string: invalid mask (%s)?\n",mask.c_str()));
	}

    IP4_ADDR(*ipaddr, IPADDR0, IPADDR1, IPADDR2, IPADDR3);
    IP4_ADDR(*gw, GWADDR0, GWADDR1, GWADDR2, GWADDR3);
    IP4_ADDR(*netmask, MSKADDR0, MSKADDR1, MSKADDR2, MSKADDR3);
    *use_dhcp = card_configuration.GetInteger("network", "use_dhcp", DEFAULT_INI_FILE_USE_DHCP);

     if (*use_dhcp) {
        safe_print(printf("[cpp_get_ip_addr] using DHCP\n"));
     } else {
		safe_print(printf("Static IP Address is %d.%d.%d.%d\n",
        ip4_addr1(*ipaddr),
        ip4_addr2(*ipaddr),
        ip4_addr3(*ipaddr),
        ip4_addr4(*ipaddr))
        );
     }

	return 1; //this is what NicheStack wants
}
