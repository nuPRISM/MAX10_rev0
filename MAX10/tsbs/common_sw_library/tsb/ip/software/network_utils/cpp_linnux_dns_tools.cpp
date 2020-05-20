/*
 * cpp_linnux_dns_tools.cpp
 *
 *  Created on: Dec 14, 2011
 *      Author: linnyair
 */

#include "cpp_linnux_dns_tools.h"
#include <string>
#include <ostream>
#include <sstream>
#include "basedef.h"
#include "card_configuration_encapsulator.h"

extern card_configuration_encapsulator card_configuration;

using namespace std;


std::string cpp_get_current_linnux_board_hostname()
{
	 static ostringstream outstr;
	 static int is_first_time = 1;
	 if (is_first_time) {
		 is_first_time = 0;
		 unsigned int board_id = card_configuration.get_card_assigned_number();
		 outstr << LINNUX_HOSTNAME_PREFIX << "0" << board_id << "." << LINNUX_HOSTNAME_POSTFIX;
	 }
	 return outstr.str();
}
std::string cpp_get_current_linnux_board_hostname_no_postfix()
{
	static ostringstream outstr;
	static int is_first_time = 1;
	if (is_first_time) {
		 is_first_time = 0;
		 unsigned int board_id = card_configuration.get_card_assigned_number();
		 outstr << LINNUX_HOSTNAME_PREFIX <<  "0" << board_id;
	}
	return outstr.str();
}

int get_linnux_board_id() {
    static int board_id;
	static int is_first_time = 1;
	if (is_first_time) {
		board_id = card_configuration.get_card_assigned_number();
		is_first_time = 0;
    }
	return board_id;
}
