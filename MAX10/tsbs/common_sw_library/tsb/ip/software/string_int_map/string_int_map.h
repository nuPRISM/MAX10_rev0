

#ifndef STRING_INT_MAP_H
#define STRING_INT_MAP_H

#include <map>
#include <string>

extern "C" {
#include  "c_string_int_map.h"
}

class string_int_map {
protected:
	std::map<int,std::string> _int_to_str_map;
	std::map<std::string,int> _str_to_int_map;
	
public:
     string_int_map();
	 string_int_map(c_string_int_map* the_c_string_int_map_ptr, unsigned int numelements);
	 bool is_member(std::string the_name);
	 bool is_member(int the_val);
	 bool get_val(std::string the_name, int& the_val);
	 bool get_name(std::string& the_name, int the_val);
     void init_with_struct(c_string_int_map* the_c_string_int_map_ptr, unsigned int numelements);
};

#endif
