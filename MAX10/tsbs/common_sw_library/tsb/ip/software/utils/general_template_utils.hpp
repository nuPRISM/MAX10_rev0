/*
 * general_template_utils.hpp
 *
 */

#ifndef GENERAL_TEMPLATE_UTILS_H_
#define GENERAL_TEMPLATE_UTILS_H_
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <map>
#include <float.h>
#include <vector>

#if defined(_WIN32) || defined(__WIN32__) || defined(_MSC_VER)
#include "io.h"
#else
#include <unistd.h>
#endif


#include <sstream>
#include <iosfwd>
#include <utility>
#include "../strtk/strtk.hpp"

namespace gtutils {
unsigned convert_array_of_four_chars_into_unsigned(unsigned char*);
typedef std::map<std::string,unsigned int> map_of_str_to_uint_type;
std::string bitwise_operate(unsigned long a, unsigned long b, std::string oper_str);
//void display_generic_matlab_vec(generic_matlab_vec the_vec, unsigned short use_hex_notation);
unsigned short convert_hex_char_to_num(char c);
char convert_num_to_hex_char(unsigned short h);
unsigned long extract_bit_range(unsigned long the_data, unsigned short lsb, unsigned short msb);
unsigned long long extract_bit_range_ull(unsigned long long the_data, unsigned long long lsb, unsigned long long msb);
unsigned long set_bit_in_32bit_reg(unsigned long data, unsigned short bit_num, unsigned short val);
unsigned long replace_bit_range(unsigned long the_data, unsigned short lsb, unsigned short msb, unsigned long the_new_data);
unsigned long long StringToULL(const char * sz);
unsigned long long conv_hex_string_to_unsigned_long_long(std::string str);
void convert_ull_to_string(unsigned long long the_value, char *output_str);
void convert_ull_ascii_to_string(unsigned long long the_value, char *output_str);
unsigned long conv_hex_string_to_unsigned_long(std::string str);
unsigned long conv_dec_string_to_unsigned_long(std::string str);
unsigned long conv_hex_string_to_signed_long(std::string str);
std::string conv_hex_string_to_ascii(std::string str);
std::string conv_hex_string_to_safe_ascii(std::string str);
std::string convert_decimal_uint_as_str_to_hex_str_0_justified(std::string orig_str, unsigned int numdigits);
std::string string_to_hex(const std::string& input);
std::string hex_to_string(const std::string& input);
double absolute(double number);
void ConvertToUpperCase(char * str);
void ConvertToLowerCase(char * str);
void ConvertToUpperCase(std::string& str);
void ConvertToLowerCase(std::string& str);
std::string strtolower(std::string str);
void TrimSpaces( std::string& str);
std::string TrimSpacesFromString(std::string str);
std::string TrimQuotesFromString(std::string str);
void removeAllSpaces(std::string &str);
std::string removeAllSpacesFromString(std::string str);
std::string convert_unsignedint_to_hex_str(unsigned int i);
std::string convert_int_to_hex_str(unsigned int i);
std::string convert_decimal_uint_as_str_to_hex_str(std::string orig_str);
std::string convert_decimal_int_as_str_to_hex_str(std::string orig_str, unsigned int numbits = 32);
std::string ConvertStringToUpperCase(std::string str);
std::string ConvertStringToLowerCase(std::string str);
int my_log2 (unsigned int val);
unsigned int gm_rand();
std::string gen_random_str(const int len);
std::string get_second_string_and_trim(std::string& in_str);
int randint(const int n);
std::vector<unsigned int> get_mac_addr_from_string(const std::string& str);
std::string get_mac_addr_string_from_char_array(unsigned char mac_addr[6]);
std::string convert_csv_string_to_relevant_string(std::string the_str, std::string indexes_of_relevant_columns);
struct binaryUInt {
unsigned long val;
binaryUInt() : val(0) { }
binaryUInt(unsigned long x) : val(x) { }
};

std::ios_base& bin(std::ios_base& str);
std::ostream& operator<<(std::ostream& os, const binaryUInt& x);
unsigned long long bin2dec(std::string binstr);
//std::string dec2bin(unsigned long,int);
std::string convert_backslashes_to_forward_slashes(std::string the_str);
bool isipv4(const std::string& str);
bool get_ip_addr_components_from_ip_addr_string (const char* str,unsigned int& ip_int_0, unsigned int& ip_int_1, unsigned int& ip_int_2, unsigned int& ip_int_3);
int get_primary_uart_from_string(std::string uart_name);
int get_secondary_uart_from_string(std::string uart_name);
void str_replace( std::string &s, const std::string &search, const std::string &replace);
void str_replace_chars( std::string &s, const std::string &search, const std::string &replace);
std::string get_memory_usage_stats();
std::string get_one_line_memory_usage_stats();

char hexToChar(char first,char second);
std::string charToHex(char c);
std::string urlencode(const std::string& src);
std::string urldecode(const std::string& src);

template<class T>
std::string convert_vector_to_string(const std::vector<T>& vec, int convert_to_hex_numbers = 0,std::string delimiter = " ")
{
 std::ostringstream result_str;

 if (convert_to_hex_numbers) result_str << std::hex;

 for (size_t i=0; i < vec.size(); i++)
 {
	 result_str << vec[i];
	 if (i!= (vec.size()-1))
	 {
		 result_str << delimiter;
	 }
 }

 return(result_str.str());
}

template<class T>
std::string convert_type_to_string(T val, int convert_to_hex_numbers = 0)
{
 std::ostringstream result_str;

 if (convert_to_hex_numbers) result_str << std::hex;

 result_str << val;


 return(result_str.str());
}

int randint(const int n);
template<class T>
void append_vector_to_ostringstream(std::vector<T>& vec,std::ostringstream& result_str, int convert_to_hex_numbers = 0,std::string delimiter = " ")
{
 if (convert_to_hex_numbers) result_str << std::hex;

 for (int i=0; i < vec.size()-1; i++)
 {
	 result_str << vec[i];
	 result_str << delimiter;
 }
 result_str << vec[vec.size()-1];
}

template<class T>
void append_vector_to_string(std::vector<T>& vec,std::string& result_str,int convert_to_hex_numbers = 0,std::string delimiter = " ")
{
 result_str += convert_vector_to_string<T>(vec,convert_to_hex_numbers,delimiter);
}

template<class T> std::string print_std_vector (std::vector<T>& vec) {
	std::string ostr = convert_vector_to_string(vec);
	std::cout << ostr << std::endl;
	return ostr;
}

template<class T>
std::string convert_vector_of_vectors_to_string(std::vector<std::vector<T> > vec, int convert_to_hex_numbers = 0)
{
 std::ostringstream result_str;

 if (convert_to_hex_numbers) result_str << std::hex;

 for (size_t i=0; i < vec.size(); i++)
 {
	 if (i!=0) { result_str << " ";};

	 result_str << "{";

	 for (size_t j = 0; j < vec.at(i).size(); j++) {
		 result_str << vec.at(i).at(j);
	     if (j!= vec.at(i).size()-1)
		 {
			result_str << " ";
		 }
	 }

	 result_str << "}";
 }

 return(result_str.str());
}



template<class T>
std::vector<T>  convert_string_to_vector(std::string the_str, std::string delimiter)
{
 std::vector<T> the_vector;

 strtk::parse(the_str,delimiter,the_vector);

 return(the_vector);
}


template<class T>
T convert_string_to_type(std::string the_str, bool use_hex_modifier = false)
{

  std::istringstream iss;
  T retval;
  iss.str(the_str);
  if (use_hex_modifier) {
    iss >> std::hex >> retval;
  } else {
    iss >> retval;
  }
  return retval;
}

template<class Keytype, class Valuetype>
std::map<Keytype,Valuetype>  convert_string_to_key_value_map(std::string the_str, std::string delimiter,  bool use_hex_modifier = false)
{
 std::map<Keytype,Valuetype> the_map;
 std::vector<std::string> str_vec = convert_string_to_vector<std::string>(the_str, delimiter);

 for (int i = 0; i < ((int)(str_vec.size()/2))*2; i+=2  ) {
	 Keytype   k = convert_string_to_type<Keytype>(str_vec.at(i),use_hex_modifier);
	 Valuetype v = convert_string_to_type<Valuetype>(str_vec.at(i+1),use_hex_modifier);
	 //std::cout << "i = " << i << "str_vec(i) = (" << str_vec.at(i) << ") str_vec(i+1) = (" << str_vec.at(i+1) << ") key = (" << k << ")" << " value = (" << v << ")" << std::endl;
	 the_map[k] = v;
 }
 return the_map;
}

template<class Keytype, class Valuetype>
std::vector<std::pair<Keytype,Valuetype> >  convert_string_to_vector_of_pairs(std::string the_str, std::string delimiter,  bool use_hex_modifier = false)
{
 std::vector<std::pair<Keytype,Valuetype> > the_vector;
 std::vector<std::string> str_vec = convert_string_to_vector<std::string>(the_str, delimiter);

 for (int i = 0; i < ((int)(str_vec.size()/2))*2; i+=2 ) {
	 Keytype   k = convert_string_to_type<Keytype>(str_vec.at(i),use_hex_modifier);
	 Valuetype v = convert_string_to_type<Valuetype>(str_vec.at(i+1),use_hex_modifier);
	 //std::cout << "i = " << i << "str_vec(i) = (" << str_vec.at(i) << ") str_vec(i+1) = (" << str_vec.at(i+1) << ") key = (" << k << ")" << " value = (" << v << ")" << std::endl;
	 the_vector.push_back(std::make_pair<Keytype,Valuetype>(k,v));
 }
 return the_vector;
}

template<class Keytype, class Valuetype>
std::vector<std::pair<Keytype,Valuetype> >  convert_string_to_vector_of_pairs_separate_hex_modifiers(std::string the_str, std::string delimiter,  bool key_use_hex_modifier = false, bool value_use_hex_modifier = false)
{
 std::vector<std::pair<Keytype,Valuetype> > the_vector;
 std::vector<std::string> str_vec = convert_string_to_vector<std::string>(the_str, delimiter);

 for (int i = 0; i < ((int)(str_vec.size()/2))*2; i+=2 ) {
	 Keytype   k = convert_string_to_type<Keytype>(str_vec.at(i),key_use_hex_modifier);
	 Valuetype v = convert_string_to_type<Valuetype>(str_vec.at(i+1),value_use_hex_modifier);
	 //std::cout << "i = " << i << "str_vec(i) = (" << str_vec.at(i) << ") str_vec(i+1) = (" << str_vec.at(i+1) << ") key = (" << k << ")" << " value = (" << v << ")" << std::endl;
	 the_vector.push_back(std::make_pair<Keytype,Valuetype>(k,v));
 }
 return the_vector;
}


template<class mapclass>
std::vector<typename mapclass::key_type> get_all_map_keys(mapclass& m) {
	std::vector<typename mapclass::key_type> v;
	for(typename mapclass::iterator it = m.begin(); it != m.end(); ++it) {
	  v.push_back(it->first);
	}
	return v;
};

}

#endif /* GENERAL_TEMPLATE_UTILS_H_ */
