/*
 * sysh_parser.cpp
 *
 *  Created on: Jun 12, 2015
 *      Author: yairlinn
 */

#include "sysh_parser.h"
#include "iostream"
#include "linnux_utils.h"
#include "jansson.hpp"
#include "json_serializer_class.h"

namespace syshparser {


sysh_parser::~sysh_parser() {
	// TODO Auto-generated destructor stub
}


void sysh_parser::parse_into_value_map(std::string str){
	this->set_string_set( convert_string_to_vector<std::string>(str,"\n"));
	delete value_map;
	value_map = new std::map<std::string,std::string>;
    for (size_t i = 0; i <  this->get_string_set().size(); i++ ) {
    	std::vector<std::string> line_set = convert_string_to_vector<std::string>(string_set.at(i)," \t\r\n");

        /*
     	std::cout << "line " << i << " found : ";

         for (size_t j = 0; j < line_set.size(); j++) {
    		std::cout << "(" << line_set.at(j) << ") ";
    	}
    	std::cout << "\n";
        */

    	if (line_set.size() == 3) {
               this->value_map[0][line_set.at(1)] = line_set.at(2);
    	}
    }
}

void sysh_parser::convert_to_json(void *json_var_ptr){
	json::Value* json_var = (json::Value *) json_var_ptr;
	for(std::map<std::string, std::string> ::iterator outer_iter=value_map[0].begin(); outer_iter!=value_map[0].end(); ++outer_iter) {
			//std::cout << "Key: " << outer_iter->first << " Value: " << outer_iter->second << std::endl;
			//std::cout.flush();
			json_var->set_key(outer_iter->first,json::Value(outer_iter->second));
		}
}


} /* namespace syshparser */
