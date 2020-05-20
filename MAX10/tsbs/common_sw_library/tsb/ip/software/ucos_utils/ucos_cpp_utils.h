/*
 * ucos_cpp_utils.h
 *
 *  Created on: Feb 13, 2012
 *      Author: linnyair
 */

#ifndef UCOS_CPP_UTILS_H_
#define UCOS_CPP_UTILS_H_

#include "basedef.h"
#include "includes.h"
#include <sstream>
#include <string>


std::string raw_print_ucosdiag();
std::string raw_print_pktlog();
std::string get_task_stat_str();
INT8U register_os_event_name(OS_EVENT* eptr,const char *the_name);


#endif /* UCOS_CPP_UTILS_H_ */
