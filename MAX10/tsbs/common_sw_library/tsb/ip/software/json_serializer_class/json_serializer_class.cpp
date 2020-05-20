/*
 * json_serializer_class.cpp
 *
 *  Created on: May 28, 2014
 *      Author: yairlinn
 */

#include "json_serializer_class/json_serializer_class.h"

#include <sstream>

std::string json_serializer_class::get_json_string() {
	json::Value jo = get_json_object();
	std::ostringstream outstr;
	outstr << jo;
	return outstr.str();
}
