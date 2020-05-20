#include  "string_int_map.h"
#include  "general_template_utils.hpp"
using namespace gtutils;

string_int_map::string_int_map();
string_int_map::string_int_map(c_string_int_map* the_c_string_int_map_ptr, unsigned int numelements) {
 this->init_with_struct(the_c_string_int_map_ptr,numelements);
}
bool string_int_map::is_member(std::string the_name) { return (this->_str_to_int_map.find(strtolower(the_name)) != this->_str_to_int_map.end()); };
bool string_int_map::is_member(int the_val)  { return (this->_int_to_str_map.find(the_val) != this->_int_to_str_map.end()); };
bool string_int_map::get_val(std::string the_name, int& the_val) {
 the_name = strtolower(the_name);
 if (!this->is_member(the_name)) {
	 return false;
 }
 the_val = this->_str_to_int_map[the_name];
 return true;
}

bool string_int_map::get_name(std::string& the_name, int the_val) {
 if (!this->is_member(the_val)) {
			 return false;
		 }
 the_name = this->_int_to_str_map[the_val];
 return true;
}

void string_int_map::init_with_struct(c_string_int_map* the_c_string_int_map_ptr, unsigned int numelements) {
	this->_int_to_str_map.clear();
	this->_str_to_int_map.clear();
	if (the_c_string_int_map_ptr != NULL) {
        for (unsigned int i = 0; i < numelements; i++) {
        	std::string the_str = the_c_string_int_map_ptr[i].name;
        	ConvertToLowerCase(the_str);
        	this->_int_to_str_map[the_c_string_int_map_ptr[i].val] = the_str;
        	this->_str_to_int_map[the_str] = the_c_string_int_map_ptr[i].val;
        }
	}

}

