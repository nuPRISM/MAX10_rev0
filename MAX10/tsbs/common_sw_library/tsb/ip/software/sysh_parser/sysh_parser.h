/*
 * sysh_parser.h
 *
 *  Created on: Jun 12, 2015
 *      Author: yairlinn
 */

#ifndef SYSH_PARSER_H_
#define SYSH_PARSER_H_

#include <string>
#include <map>
#include <vector>

namespace syshparser {

class sysh_parser {
protected:
   std::map<std::string,std::string>* value_map;
   std::vector<std::string> string_set;

public:
	sysh_parser() { value_map = NULL; };
	void parse_into_value_map(std::string str);


	virtual ~sysh_parser();

	void convert_to_json(void* json_var_ptr);
	std::map<std::string, std::string>* get_value_map() const {
		return value_map;
	}

	void set_value_map(std::map<std::string, std::string>* valueMap) {
		value_map = valueMap;
	}

	std::vector<std::string> get_string_set() const {
		return string_set;
	}

	void set_string_set(std::vector<std::string> stringSet) {
		string_set = stringSet;
	}
};

} /* namespace syshparser */

#endif /* SYSH_PARSER_H_ */
