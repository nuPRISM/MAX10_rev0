/*
 * linnux_utils.cc
 *
 *  Created on: Apr 15, 2011
 *      Author: linnyair
 */

#include "linnux_utils.h"
#include "CBaseConverter.h"
#include "basedef.h"
#include "fparser/fparser.hh"
#include "exprtk/exprtk.hpp"
#include "exprtk/exprtk_test.hh"
//#include "register_keeper_api.h"
#include <altera_avalon_pio_regs.h>
#include <algorithm>

extern "C" {



#include "includes.h"
#include "ipport.h"
#include "tcpport.h"
#include "alt_error_handler.hpp"
#include "alt_types.h"
#include "ntp_client/ntp_client.h"
#include "target_clock.h"
#include "ucos_ii.h"
#include "cpp_to_c_header_interface.h"
#include <sys/alt_stdio.h>
#include "system.h"
#include <malloc.h>
}
using namespace std;

#include "easyzlib.h"

unsigned convert_array_of_four_chars_into_unsigned(unsigned char* rxBuffer) {
			unsigned returned_command = rxBuffer[0];
			returned_command = (returned_command << 8) +  rxBuffer[1];
			returned_command = (returned_command << 8) +  rxBuffer[2];
			returned_command = (returned_command << 8) +  rxBuffer[3];
			return returned_command;
}

std::string compress_string(std::string& str) {
					ezbuffer bufSrc( str.length());
					ezbuffer bufDest( str.length());
					memcpy(bufSrc.pBuf,str.c_str(),str.length());
					ezcompress( bufDest, bufSrc );
					std::string base64data;
					std::string binary_data;
					binary_data.append((char *)bufDest.pBuf,(size_t) bufDest.nLen);
					bufSrc.Release();
					bufDest.Release();
					return binary_data;
}


std::string compress_c_string(const char* c_str, size_t length) {
					ezbuffer bufSrc( length);
					ezbuffer bufDest( length);
					memcpy(bufSrc.pBuf,c_str,length);
					ezcompress( bufDest, bufSrc );
					std::string base64data;
					std::string binary_data;
					binary_data.append((char *)bufDest.pBuf,(size_t) bufDest.nLen);
					bufSrc.Release();
					bufDest.Release();
					return binary_data;
}


std::string compress_and_convert_to_base64(std::string& str)
{

	std::string base64data;
    std::string binary_data;
    binary_data = compress_string(str);
	strtk::convert_bin_to_base64(binary_data,base64data);
	return base64data;
}

std::string compress_and_convert_c_string_to_base64(const char* c_str, size_t length)
{

	std::string base64data;
    std::string binary_data;
    binary_data = compress_c_string(c_str,length);
	strtk::convert_bin_to_base64(binary_data,base64data);
	return base64data;
}


std::string string_to_hex(const std::string& input)
{
    static const char* const lut = "0123456789ABCDEF";
    size_t len = input.length();

    std::string output;
    output.reserve(2 * len);
    for (size_t i = 0; i < len; ++i)
    {
        const unsigned char c = input[i];
        output.push_back(lut[(c >> 4) & 0xF]);
        output.push_back(lut[c & 15]);
    }
    return output;
}


std::string hex_to_string(const std::string& input)
{
    static const char* const lut = "0123456789ABCDEF";
    size_t len = input.length();
    if (len & 1) {
    	safe_print(std::cout << "hex_to_string: Odd length string (" << input << ") " << std::endl;);
    	return std::string("");
    }

    std::string output;
    output.reserve(len / 2);
    for (size_t i = 0; i < len; i += 2)
    {
        char a = input[i];
        const char* p = std::lower_bound(lut, lut + 16, a);
        if (*p != a) {
        	safe_print(std::cout << "hex_to_string: not a hex digit in string (" << input << ") position " << i << std::endl;);
        	continue;
        }

        char b = input[i + 1];
        const char* q = std::lower_bound(lut, lut + 16, b);
        if (*q != b){
        	safe_print(std::cout << "hex_to_string: not a hex digit in string (" << input << ") position " << i+1 << std::endl;);
        	continue;
        }
        output.push_back(((p - lut) << 4) | (q - lut));
    }
    return output;
}
//==========================================================================================================================
//
//
// Utility Procedures
//
//
//==========================================================================================================================
unsigned int gm_rand() {
  static unsigned int u = 48376;
  static unsigned int v = 10443;
  v = 36969*(v & 65535) + (v >> 16);
  u = 18000*(u & 65535) + (u >> 16);
  return (v << 16) + u;
}

std::string gen_random_str(const int len) {
    static const char alphanum[] =
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    std::string s;
    int i = 0;
    for (i = 0; i < len; ++i) {
        s += alphanum[gm_rand() & (0x1F)]; //"&" should be faster than "%";
    }
    return s;
}
/* Returns an integer in the range [0, n).
 *
 * Uses rand(), and so is affected-by/affects the same seed.
 */
int randint(const int n) {
  if ((n - 1) == RAND_MAX) {
    return rand();
  } else {
    // Chop off all of the values that would cause skew...
    long end = RAND_MAX / n; // truncate skew
    end *= n;

    // ... and ignore results from rand() that fall above that limit.
    // (Worst case the loop condition should succeed 50% of the time,
    // so we can expect to bail out of this loop pretty quickly.)
    int r;
    while ((r = rand()) >= end);

    return r % n;
  }
}


std::string unsafe_get_current_time_and_date_as_string()
{
     struct tm *timeinfo;
     std::string retstr;
     char safer_str[100];
     timeinfo = (struct tm *)get_void_ptr_to_local_time();
     snprintf(safer_str,80,"%s",asctime(timeinfo));
     retstr = safer_str;
     return retstr;
}


std::string get_current_time_and_date_as_string()
{
     struct tm *timeinfo;
     std::string retstr;
     timeinfo = (struct tm *)get_void_ptr_to_local_time();
     retstr = TrimSpacesFromString(asctime(timeinfo)) + std::string(" ") + std::string(LINNUX_TIMEZONE_STRING) + "\n";
     return retstr;
}

std::string get_current_time_and_date_as_string_trimmed()
{
	std::string str = get_current_time_and_date_as_string();
	TrimSpaces(str);
	return (str);
}

char *get_current_time_as_c_string()
{
	return(strdup(get_current_time_and_date_as_string_trimmed().c_str()));
}

std::vector<unsigned int> get_mac_addr_from_string(const std::string& str)
{
  std::ostringstream ostr;
  std::vector<std::string> byte_vector = convert_string_to_vector<std::string>(str,":");
  std::vector<unsigned int> mac_addr(0);

  for (unsigned i = 0; i < byte_vector.size(); i++)
  {
    mac_addr.push_back(conv_hex_string_to_unsigned_long(byte_vector.at(i)) & 0xFF);
  }

  return mac_addr;
}
std::string get_mac_addr_string_from_char_array(unsigned char mac_addr[6])
{
	char tmp[50];
	snprintf(tmp,20,"%02x:%02x:%02x:%02x:%02x:%02x",
		              mac_addr[0],
		              mac_addr[1],
		              mac_addr[2],
		              mac_addr[3],
		              mac_addr[4],
		              mac_addr[5]);
	return std::string(tmp);
}

/*
void display_generic_matlab_vec(generic_matlab_vec the_vec, unsigned short use_hex_notation)
{
	if (use_hex_notation)
		cout << hex;
	cout << "[\n";
	for (unsigned long i = 0; i < GENERIC_MATLAB_VEC_LENGTH; i++)
	{
		cout << the_vec[i] << " ";
	}
	cout << "\n]\n";
	if (use_hex_notation)
		cout << dec; //revert to dec
}
*/


unsigned short convert_hex_char_to_num(char c)
{
	if ((c <= '9') && ('0' <= c))
	{
		return ((unsigned short) (c - '0'));
	}

	char upperC = toupper(c);
	if ((upperC <= 'F') && ('A' <= upperC))
	{
		return (((unsigned short) (upperC - 'A')) + 10);
	}
	//if we're here, error in input
	safe_print(cout << "Error in convert_hex_char_to_num c= " << c);
	return ('X');
}

char convert_num_to_hex_char(unsigned short h)
{
	if ((h <= 9))
	{
		return ((char) (h + '0'));
	}
	if ((h <= 15) && (10 <= h))
	{
		return ((char) ((h - 10) + 'A'));
	}
	//if we're here, error in input
	safe_print(cout << "Error in convert_num_to_hex_char h= " << h);
	return ('X');
}

unsigned long extract_bit_range(unsigned long the_data, unsigned short lsb, unsigned short msb)
{
	the_data = the_data >> lsb;
	the_data = the_data & (~(0xFFFFFFFF << (msb - lsb + 1)));
	return the_data;
}

unsigned long long extract_bit_range_ull(unsigned long long the_data, unsigned long long lsb, unsigned long long msb)
{
	the_data = the_data >> lsb;
	the_data = the_data & (~(0xFFFFFFFFFFFFFFFFULL << (msb - lsb + 1)));
	return the_data;
}

unsigned long set_bit_in_32bit_reg(unsigned long data, unsigned short bit_num, unsigned short val)
{
	unsigned long mask = 0;
	mask = 1 << bit_num;
	if (val == 0)
	{
		return (data & ~mask);
	} else
	{
		return (data | mask);
	}
}

unsigned long replace_bit_range(unsigned long the_data, unsigned short lsb, unsigned short msb, unsigned long the_new_data)
{
	unsigned long sanitized_data = the_new_data & (~(0xFFFFFFFFUL << (msb - lsb + 1)));
	unsigned long new_data_mask = (~(0xFFFFFFFFFFFFFFFFL << (msb - lsb + 1))) << lsb;
	the_data = the_data & (~(new_data_mask)) | (sanitized_data << lsb);
	return the_data;
}

unsigned long long StringToULL(const char * sz)
{
	unsigned long long u64Result = 0;
	while (*sz != '\0')
	{
		u64Result *= 10;
		u64Result += *sz - '0';
		sz++;
	}
	return u64Result;
}

void convert_ull_to_string(unsigned long long the_value, char *output_str)
{
	int i;
	int max_length = 25;
	for (i = (max_length - 1); i >= 0; i--)
	{
		output_str[i] = '0' + (the_value % 10);
		the_value = the_value / 10;
	}
	output_str[max_length] = (char) 0;
}


void c_convert_ull_to_string(unsigned long long the_value, char *output_str) {
	convert_ull_to_string(the_value, output_str);
}

void convert_ull_ascii_to_string(unsigned long long the_value, char *output_str)
{
	int i;
	int max_length = 16;
	for (i = (max_length - 1); i >= 0; i--)
	{
		output_str[i] = (char) (the_value % 256); //take each byte
		if (output_str[i] == 0)
		{
			output_str[i] = ' ';
		};
		the_value = the_value / 256;
	}
	output_str[max_length] = (char) 0;
}

void set_fail(unsigned short condition, unsigned short& so_far_so_good)
{
	if (condition)
	{
		cout << "FAIL: ";
		so_far_so_good = 0;
	} else
	{
		cout << "PASS: ";
	}

}


unsigned long long conv_hex_string_to_unsigned_long_long(std::string str)
{
	char ** dummy = NULL;
	return (strtoull(str.c_str(), dummy, 16));
}


unsigned long conv_hex_string_to_unsigned_long(std::string str)
{
	char ** dummy = NULL;
	return (strtoul(str.c_str(), dummy, 16));
}




unsigned long conv_dec_string_to_unsigned_long(std::string str)
{
	char ** dummy = NULL;
	return (strtoul(str.c_str(), dummy, 10));
}

unsigned long conv_hex_string_to_signed_long(std::string str)
{
	char ** dummy = NULL;
	return (strtol(str.c_str(), dummy, 16));
}

std::string conv_hex_string_to_ascii(std::string str)
{
	std::ostringstream result_string;
	  unsigned int ch ;
	  for(int i=0; std::sscanf( str.substr(i,2).c_str(), "%2x", &ch ) == 1 ; i += 2 )
	  {
		  safe_print(std::cout << " i = " << i << " ch = " << ch << " char(ch) = " << ((char)(ch)) << "\n");
		  result_string << ((char)(ch)) ;
	  }
	  safe_print(std::cout << "conv_hex_string_to_ascii: Result: " << result_string.str() << "\n" );
	  return result_string.str();
}
/*
// C++98 guarantees that '0', '1', ... '9' are consecutive.
// It only guarantees that 'a' ... 'f' and 'A' ... 'F' are
// in increasing order, but the only two alternative encodings
// of the basic source character set that are still used by
// anyone today (ASCII and EBCDIC) make them consecutive.
unsigned char hexval(unsigned char c)
{
    if ('0' <= c && c <= '9')
        return c - '0';
    else if ('a' <= c && c <= 'f')
        return c - 'a' + 10;
    else if ('A' <= c && c <= 'F')
        return c - 'A' + 10;
    else abort();
}

std::string hex2ascii(const std::string str)
{
	std::string out;
    out.clear();
    out.reserve(str.length() / 2);
    for (string::const_iterator p = str.begin(); p != str.end(); p++)
    {
       unsigned char c = hexval(*p);
       p++;
       if (p == in.end()) break; // incomplete last digit - should report error
       c = (c << 4) + hexval(*p); // + takes precedence over <<
       out.push_back(c);
    }
    return out;
}
*/


std::string conv_hex_string_to_safe_ascii(std::string str)
{
	std::ostringstream result_string;
	  unsigned int len = str.length();

	if (len == 0) {
		return std::string("");
	};


	  unsigned int ch ;
	  for(int i=0; (i <len) &&  (std::sscanf( str.substr(i,2).c_str(), "%2x", &ch ) == 1) ; i += 2 )
	  {
		//  safe_print(std::cout << " i = " << i << " ch = " << ch << " char(ch) = " << ((char)(ch)) << "\n");
		  if (ch == 0) {
			  ch = 32; // replace nulls with space
		  }
		  result_string << ((char)(ch)) ;
	  }

	  //safe_print(std::cout << "conv_hex_string_to_signed_long: Result: " << result_string.str() << "\n" );
	  return result_string.str();
}


double absolute(double number)
{
	if (number < 0)
		return -number;
	else
		return number;
}

/*********************************
 * Convert the to UpperCase      *
 *********************************/
void ConvertToUpperCase(char * str)
{
	unsigned int ch, i;

	for (i = 0; i < strlen(str); i++)
	{
		ch = toupper(str[i]);
		str[i] = ch;
	}
}

void ConvertToLowerCase(char * str)
{
	unsigned int ch, i;

	for (i = 0; i < strlen(str); i++)
	{
		ch = tolower(str[i]);
		str[i] = ch;
	}
}

void ConvertToUpperCase(string& str)
{
	unsigned int ch, i;

	for (i = 0; i < str.size(); i++)
	{
		ch = toupper(str.at(i));
		str.at(i) = ch;
	}
}

void ConvertToLowerCase(string& str)
{
	unsigned int ch, i;

	for (i = 0; i < str.size(); i++)
	{
		ch = tolower(str.at(i));
		str.at(i) = ch;
	}
}



std::string strtolower(string str)
{
	unsigned int ch, i;

	for (i = 0; i < str.size(); i++)
	{
		ch = tolower(str.at(i));
		str.at(i) = ch;
	}

	return str;
}


string ConvertStringToUpperCase(string str)
{
	unsigned int ch, i;
    string new_str = str;
	for (i = 0; i < str.size(); i++)
	{
		ch = toupper(str.at(i));
		new_str.at(i) = ch;
	}
	return new_str;
}

string ConvertStringToLowerCase(string str)
{
	unsigned int ch, i;
    string new_str = str;
	for (i = 0; i < str.size(); i++)
	{
		ch = tolower(str.at(i));
		new_str.at(i) = ch;
	}
	return new_str;
}

static unsigned long red_LED_state=0;
static unsigned long green_LED_state=0;


void write_green_led_state_to_leds()
{
	//IOWR_ALTERA_AVALON_PIO_DATA(LEDG_BASE,green_LED_state);
}
void write_red_led_state_to_leds()
{
	//IOWR_ALTERA_AVALON_PIO_DATA(LEDR_BASE,red_LED_state);
}

void write_red_led_pattern (unsigned long the_pattern)
{
	red_LED_state = the_pattern;
	write_red_led_state_to_leds();
}

void write_green_led_pattern (unsigned long the_pattern)
{
	green_LED_state = the_pattern;
    write_green_led_state_to_leds();
}

unsigned long get_green_led_state()
{
  return (green_LED_state);
}

unsigned long get_red_led_state()
{
  return (red_LED_state);
}

void TrimSpaces( string& str)
{
// Trim Both leading and trailing spaces
size_t startpos = str.find_first_not_of(" \t\n\r"); // Find the first character position after excluding leading blank spaces
size_t endpos = str.find_last_not_of(" \t\n\r"); // Find the first character position from reverse af

// if all spaces or empty return an empty string
if(( string::npos == startpos ) || ( string::npos == endpos))
{
 str = "";
}
else
str = str.substr( startpos, endpos-startpos+1 );

/*
// Code for Trim Leading Spaces only
size_t startpos = str.find_first_not_of(" \t"); // Find the first character position after excluding leading blank spaces
if( string::npos != startpos )
str = str.substr( startpos );
*/

/*
// Code for Trim trailing Spaces only
size_t endpos = str.find_last_not_of(" \t"); // Find the first character position from reverse af
if( string::npos != endpos )
str = str.substr( 0, endpos+1 );
*/
}



string TrimSpacesFromString( string str)
{
// Trim Both leading and trailing spaces
size_t startpos = str.find_first_not_of(" \t\n\r"); // Find the first character position after excluding leading blank spaces
size_t endpos = str.find_last_not_of(" \t\n\r"); // Find the first character position from reverse af

// if all spaces or empty return an empty string
if(( string::npos == startpos ) || ( string::npos == endpos))
{
 str = "";
}
else
str = str.substr( startpos, endpos-startpos+1 );


/*
// Code for Trim Leading Spaces only
size_t startpos = str.find_first_not_of(" \t"); // Find the first character position after excluding leading blank spaces
if( string::npos != startpos )
str = str.substr( startpos );
*/

/*
// Code for Trim trailing Spaces only
size_t endpos = str.find_last_not_of(" \t"); // Find the first character position from reverse af
if( string::npos != endpos )
str = str.substr( 0, endpos+1 );
*/

return str;
}


string TrimQuotesFromString( string str)
{
		// Trim Both leading and trailing quotes
		size_t startpos = str.find_first_not_of("\""); // Find the first character position
		size_t endpos = str.find_last_not_of("\""); // Find the first character position from reverse af

		// if all spaces or empty return an empty string
		if(( string::npos == startpos ) || ( string::npos == endpos))
		{
		 str = "";
		}
		else
		str = str.substr( startpos, endpos-startpos+1 );

       return str;
}


bool binBaseFormat = false;

ios_base& bin(ios_base& str) {
binBaseFormat = true;
return str;
}

ostream& operator<<(ostream& os, const binaryUInt& x) {
if (binBaseFormat == true) {
unsigned long n = (sizeof(x.val) * 8) - 1;
for (unsigned long i = 0; i <= n; i++) {
os << ((x.val >> (n-i)) & 1);
}
binBaseFormat = false;
} else {
os << x.val;
}
return os;
}




string linnux_uparse(string command_str)
{
	/*mu::Parser p;
	ostringstream outstr;

	      try
		  {
		    p.SetExpr(command_str);
		    outstr <<  p.Eval();
		  }
		  catch (mu::Parser::exception_type &e)
		  {
		    safe_print(std::cout << e.GetMsg() << std::endl);
		  }
*/

#ifdef LINNUX_USE_EXPRTK_AS_PARSER
  return linnux_exprtk_uparse(command_str);
#else
  ostringstream outstr;
  static FunctionParser fparser; //note that "static" means that parse can only be called from Linnux_MAIN thread!
  int res = fparser.Parse(command_str, "x"); //use x as a dummy variable
  double vals[] = { 0 }; //dummy variable for "x";

  std::string preamble_string = "Evaluating: ";
  //safe_print(std::cout << "\n" << preamble_string << command_str);
  safe_print(std::cout.flush());
  if(res >= 0) {
	 safe_print(std::cout << "\nMathematical Parser Error:" << std::endl);
     safe_print(std::cout << std::endl << std::string(res+preamble_string.size(), ' ') << "^\n"
               << fparser.ErrorMsg() << std::endl << std::endl);
     outstr << "UparseError";
  } else {
       outstr << fparser.Eval(vals); //use x as dummy variable
  //     safe_print(std::cout << "\n"<< "Result of evaluation is [" << outstr.str() << "]" << endl);
  }
  return outstr.str();
#endif

}


exprtk::expression<double> expression_main; //Note static!!!! Use only from Linnux_Main
exprtk::expression<double> expression_control; //Note static!!!! Use only from Linnux_Main

exprtk::symbol_table<double> symbol_table_main;
exprtk::symbol_table<double> symbol_table_control;

exprtk::parser<double> parser_main;
exprtk::parser<double> parser_control;

inline bool exprtk_eval_expression(const std::string& expression_string, double& result, std::string& error_string)
{
   static int first_time = 1;
   std::ostringstream ostr;

   exprtk::parser<double> *parser_ptr = NULL;
   exprtk::expression<double> *expression_ptr = NULL;

   if (first_time) {
	   first_time = 0;
       symbol_table_main.add_constants();
       expression_main.register_symbol_table(symbol_table_main);
       symbol_table_control.add_constants();
       expression_control.register_symbol_table(symbol_table_control);
   }

   error_string = "";

   if ((OSTCBCur->OSTCBPrio == LINNUX_CONTROL_TASK_PRIORITY) || (OSTCBCur->OSTCBPrio == LINNUX_MAIN_TASK_PRIORITY))
   {
	   if (OSTCBCur->OSTCBPrio == LINNUX_CONTROL_TASK_PRIORITY) {
		   parser_ptr = &parser_control;
		   expression_ptr = &expression_control;
	   } else {
		   parser_ptr = &parser_main;
		   expression_ptr = &expression_main;
	   }

      if (!(parser_ptr->compile(expression_string,*expression_ptr)))
      {
    	  ostr << "test_expression() - Error: " << parser_ptr->error() << "\tExpression: " << expression_string << std::endl;
    	  error_string = ostr.str();
         return false;
      }
      result = expression_ptr->value();
      return true;
   }  else
   {
	   ostr << "Error: exprtk_eval_expression called with priority: " << OSTCBCur->OSTCBPrio << std::endl;
	   result = -1;
	   error_string = ostr.str();
	   return false;
   }
   return false;
}


std::string linnux_exprtk_uparse(std::string command_str)
{
	double expression_result;
	bool expression_successful;
	std::string error_str;
	std::ostringstream outstr;

	expression_successful = exprtk_eval_expression(command_str,expression_result,error_str);
    if (expression_successful) {
          outstr << expression_result;
          return outstr.str();
    } else {
          return error_str;
    }
}

std::string convert_csv_string_to_relevant_string(std::string the_str, std::string indexes_of_relevant_columns)
{
 //get a comma delimited line from a csv file and return a string that is compose of only the relevant columns

 vector<unsigned int> relevant_indices_vector;
 set<unsigned int> relevant_indices_set;

 unsigned int i;
 unsigned int element_count=0;
 string relevant_str = "";
 relevant_indices_vector = convert_string_to_vector<unsigned int>(indexes_of_relevant_columns,", "); //get the relevant csv column indices

 for (i = 0; i < relevant_indices_vector.size(); i++)
 {
	 relevant_indices_set.insert(relevant_indices_vector.at(i)-1); //convert vector into a set
 }


 vector<string> raw_csv_data_vector = convert_string_to_vector<string>(the_str,",");
 for (i=0;i < raw_csv_data_vector.size(); i++)
 {
	if (relevant_indices_set.find(i) != relevant_indices_set.end())
	{
		element_count++;
		//this is a relevant column
		if (element_count != 0) relevant_str += " ";
		relevant_str += "\"";
		relevant_str += raw_csv_data_vector.at(i);
		relevant_str += "\"";
	}
 }

 //OK, now we have a string of only the relevant csv columns
 return relevant_str;
}

std::string convert_unsignedint_to_hex_str(unsigned int i)
{
  std::ostringstream oss;
  oss << hex << i;
  return oss.str();
}


std::string convert_int_to_hex_str(unsigned int i)
{
  std::ostringstream oss;
  oss << hex << i;
  return oss.str();
}


std::string convert_unsignedint_to_hex_str_0_justified(unsigned int i, unsigned int num_hex_digits)
{
  std::ostringstream oss;
  oss.width(num_hex_digits);
  oss.fill('0');
  oss << hex << i;
  return oss.str();
}

std::string convert_decimal_uint_as_str_to_hex_str_0_justified(std::string orig_str, unsigned int numdigits)
{
	unsigned int i = convert_string_to_type<unsigned int>(orig_str);
    return convert_unsignedint_to_hex_str_0_justified(i,numdigits);
}

std::string convert_decimal_uint_as_str_to_hex_str(std::string orig_str)
{
	unsigned int i = convert_string_to_type<unsigned int>(orig_str);
    return convert_unsignedint_to_hex_str(i);
}


std::string convert_decimal_int_as_str_to_hex_str(std::string orig_str, unsigned int numbits)
{
  int i = convert_string_to_type<int>(orig_str);
  unsigned int mask = 1;
  for (unsigned int current_bit=1; current_bit < numbits; current_bit++)
  {
	  mask = (mask << 1)+1;
  }
  unsigned int absi = i; //assign signed to unsigned on purpose
  absi = absi & mask; //note that this statement can't be merged with the previous one!

  if (i > 0)
  {
   return convert_unsignedint_to_hex_str(i);
  } else
  {
	   return convert_unsignedint_to_hex_str(absi);
  }
}
std::string dec2bin(unsigned long decimal_number,int num_binary_bits)
{
 CBaseConverter binary_base_converter(2);
 return binary_base_converter.ConvertToBase(decimal_number,num_binary_bits,1,1);

}



unsigned long long bin2dec(string binstr)
{
        unsigned int k;
        int n;
        unsigned long long sum = 0;

        for(k = 0; k < binstr.length(); k++)
        {
                n = (binstr.at(k) - '0'); // char to numeric value
                if ((n > 1) || (n < 0))
                {
                        puts("\n\n ERROR! BINARY has only 1 and 0!\n");
                        return (0);
                }
                sum = sum*2+n;
        }
        return(sum);
}

std::string low_level_get_testbench_description()
{

	return "testbench description";
}

unsigned long read_switches() {
	return 0; //return IORD_ALTERA_AVALON_PIO_DATA(SW_BASE);
}

unsigned long long low_level_system_timestamp() {

	//Note: one should really call this using mutual exclusion in order that snapl and snaph agree
	IOWR(COUNTER_64_BIT_0_BASE,0,0); //write operation gets snapshot of counter
	unsigned long long snapl = (unsigned long long) (IORD(COUNTER_64_BIT_0_BASE,0));
	unsigned long long snaph = (unsigned long long) (IORD(COUNTER_64_BIT_0_BASE,1));
	snapl = snapl & 0xFFFFFFFF;
	snaph = snaph & 0xFFFFFFFF;
	unsigned long long total_time = (snaph << 32) + snapl;
   	return total_time;
	return 0;
}

unsigned long long os_critical_low_level_system_timestamp() {
	int cpu_sr;
	unsigned long long ts;
    OS_ENTER_CRITICAL();
    ts = low_level_system_timestamp();
    OS_EXIT_CRITICAL();
    return ts;
}


unsigned long long verbose_low_level_system_timestamp() {

	//Note: one should really call this using mutual exclusion in order that snapl and snaph agree
	IOWR(COUNTER_64_BIT_0_BASE,0,0); //write operation gets snapshot of counter
	unsigned long long snapl = (unsigned long long) (IORD(COUNTER_64_BIT_0_BASE,0));
	unsigned long long snaph = (unsigned long long) (IORD(COUNTER_64_BIT_0_BASE,1));
	snapl = snapl & 0xFFFFFFFF;
	snaph = snaph & 0xFFFFFFFF;
	unsigned long long total_time = (snaph << 32) + snapl;
    ostringstream outstr;
    outstr << hex << "snaph: " << snaph << " snapl:" << snapl << " total: " << total_time << std::endl;
    safe_print(printf("%s",outstr.str().c_str()));
	return total_time;
	return 0;
}

unsigned long long c_low_level_system_timestamp() {
	return low_level_system_timestamp();
}
unsigned long long c_os_critical_low_level_system_timestamp() {
	return os_critical_low_level_system_timestamp();
}
unsigned long low_level_system_timestamp_in_secs() {
	unsigned long long ts = low_level_system_timestamp();
	return ((unsigned long) (((double)ts)/((double)NIOS_64_BIT_COUNTER_CLOCK_FREQ_HZ)));
}

double low_level_system_timestamp_in_secs_in_double() {
	unsigned long long ts = low_level_system_timestamp();
	return (((double)ts)/((double)NIOS_64_BIT_COUNTER_CLOCK_FREQ_HZ));
}


unsigned long os_critical_low_level_system_timestamp_in_secs() {
	unsigned long long ts = os_critical_low_level_system_timestamp();
	return ((unsigned long) (((double)ts)/((double)NIOS_64_BIT_COUNTER_CLOCK_FREQ_HZ)));
}

double os_critical_low_level_system_timestamp_in_secs_in_double() {
	unsigned long long ts = os_critical_low_level_system_timestamp();
	return (((double)ts)/((double)NIOS_64_BIT_COUNTER_CLOCK_FREQ_HZ));
}

unsigned long os_critical_c_low_level_system_timestamp_in_secs() {
	return os_critical_low_level_system_timestamp_in_secs();
}

unsigned long c_low_level_system_timestamp_in_secs() {
	return low_level_system_timestamp_in_secs();
}


int low_level_system_usleep(unsigned long num_us) {
	//sleeps at least num_us usecs. Interrupts and task switching should be disabled for good performance
	unsigned long long 	start_timestamp = low_level_system_timestamp();
	unsigned long long 	end_timestamp;
	unsigned long long 	timestamp_difference;

	unsigned long long watchdog_timer;

	watchdog_timer = 0;
	double  time_diff_in_us;
	do {
		watchdog_timer++;
		end_timestamp = low_level_system_timestamp();
		if (end_timestamp < start_timestamp) {
			end_timestamp = start_timestamp; //avoid unlikely errors
		}
		timestamp_difference = end_timestamp - start_timestamp;
		time_diff_in_us = 1000000.0*(((double)timestamp_difference)/((double)NIOS_64_BIT_COUNTER_CLOCK_FREQ_HZ));
		if (watchdog_timer > LINNUX_LOW_LEVEL_USLEEP_WATCHDOG_TIMER_LIMIT) {
			break;
		}
	}
	while (time_diff_in_us < (double) num_us);

	if (watchdog_timer > LINNUX_LOW_LEVEL_USLEEP_WATCHDOG_TIMER_LIMIT) {
		safe_print(alt_printf("Error during low_level_system_usleep, watchdog timer activated!\n"));
	}

	return 0;
}

int c_low_level_system_usleep(unsigned long num_us) {
	return low_level_system_usleep(num_us);
}


int os_critical_wait_counter_cycles(unsigned long numcycles) {
	unsigned long long 	start_timestamp = os_critical_low_level_system_timestamp();
	unsigned long long 	end_timestamp;
	unsigned long long 	timestamp_difference;

	unsigned long long watchdog_timer;

	watchdog_timer = 0;
	double  time_diff_in_us;
	do {
		watchdog_timer++;
		end_timestamp = os_critical_low_level_system_timestamp();
		if (end_timestamp < start_timestamp) {
			end_timestamp = start_timestamp; //avoid unlikely errors
		}
		timestamp_difference = end_timestamp - start_timestamp;
		if (watchdog_timer > LINNUX_LOW_LEVEL_USLEEP_WATCHDOG_TIMER_LIMIT) {
			break;
		}
	}
	while (timestamp_difference < numcycles);

	if (watchdog_timer > LINNUX_LOW_LEVEL_USLEEP_WATCHDOG_TIMER_LIMIT) {
		safe_print(alt_printf("Error during low_level_system_usleep, watchdog timer activated!\n"));
	}

	return 0;
}


int c_os_critical_wait_counter_cycles(unsigned long numcycles) {
	return os_critical_wait_counter_cycles(numcycles);
}

int os_critical_wait_short_amount_of_time() {
	unsigned long long 	start_timestamp = os_critical_low_level_system_timestamp();
	return 0;
}
int c_os_critical_wait_short_amount_of_time() {
	return os_critical_wait_short_amount_of_time();
}

int os_critical_low_level_system_usleep_double(double num_us) {
	//sleeps at least num_us usecs. Interrupts and task switching should be disabled for good performance
	unsigned long long 	start_timestamp = os_critical_low_level_system_timestamp();
	unsigned long long 	end_timestamp;
	unsigned long long 	timestamp_difference;

	unsigned long long watchdog_timer;

	watchdog_timer = 0;
	double  time_diff_in_us;
	do {
		watchdog_timer++;
		end_timestamp = os_critical_low_level_system_timestamp();
		if (end_timestamp < start_timestamp) {
			end_timestamp = start_timestamp; //avoid unlikely errors
		}
		timestamp_difference = end_timestamp - start_timestamp;
		time_diff_in_us = 1000000.0*(((double)timestamp_difference)/((double)NIOS_64_BIT_COUNTER_CLOCK_FREQ_HZ));
		if (watchdog_timer > LINNUX_LOW_LEVEL_USLEEP_WATCHDOG_TIMER_LIMIT) {
			break;
		}
	}
	while (time_diff_in_us < num_us);

	if (watchdog_timer > LINNUX_LOW_LEVEL_USLEEP_WATCHDOG_TIMER_LIMIT) {
		safe_print(alt_printf("Error during low_level_system_usleep, watchdog timer activated!\n"));
	}

	return 0;
}

int os_critical_low_level_system_usleep(unsigned long num_us) {
	//sleeps at least num_us usecs. Interrupts and task switching should be disabled for good performance
	unsigned long long 	start_timestamp = os_critical_low_level_system_timestamp();
	unsigned long long 	end_timestamp;
	unsigned long long 	timestamp_difference;

	unsigned long long watchdog_timer;

	watchdog_timer = 0;
	double  time_diff_in_us;
	do {
		watchdog_timer++;
		end_timestamp = os_critical_low_level_system_timestamp();
		if (end_timestamp < start_timestamp) {
			end_timestamp = start_timestamp; //avoid unlikely errors
		}
		timestamp_difference = end_timestamp - start_timestamp;
		time_diff_in_us = 1000000.0*(((double)timestamp_difference)/((double)NIOS_64_BIT_COUNTER_CLOCK_FREQ_HZ));
		if (watchdog_timer > LINNUX_LOW_LEVEL_USLEEP_WATCHDOG_TIMER_LIMIT) {
			break;
		}
	}
	while (time_diff_in_us < (double) num_us);

	if (watchdog_timer > LINNUX_LOW_LEVEL_USLEEP_WATCHDOG_TIMER_LIMIT) {
		safe_print(alt_printf("Error during low_level_system_usleep, watchdog timer activated!\n"));
	}

	return 0;
}

double get_timestamp_diff_in_usec(unsigned long long timestamp_difference) {
	double time_diff_in_us = 1000000.0*(((double)timestamp_difference)/((double)NIOS_64_BIT_COUNTER_CLOCK_FREQ_HZ));
	return time_diff_in_us;
}

int exprtk_test(unsigned long test_num) {
	/*return test_exprtk(test_num);*/
	safe_print(std::cout << "Error: exprtk_test not implemented" << std::endl);
	return 0;
}

int my_log2 (unsigned int val) {
    unsigned int ret = -1;
    while (val != 0) {
        val >>= 1;
        ret++;
    }
    return ret;
}



std::string convert_backslashes_to_forward_slashes(std::string the_str)
{
	str_replace(the_str,"\\","/");
	return the_str;
}



bool isipv4(const std::string& str)
{
	int dots = 0;
	// %! ignore :port?
	for (size_t i = 0; i < str.size(); ++i)
	{
		if (str[i] == '.')
			dots++;
		else
		if (!isdigit(str[i]))
			return false;
	}
	if (dots != 3)
		return false;
	return true;
}

bool get_ip_addr_components_from_ip_addr_string (const char* str,unsigned int& ip_int_0, unsigned int& ip_int_1, unsigned int& ip_int_2, unsigned int& ip_int_3)
{
  int num_args_received = sscanf(str, "%u.%u.%u.%u",&ip_int_0,&ip_int_1,&ip_int_2,&ip_int_3);
  return (num_args_received == 4);
}

void removeAllSpaces(std::string &str)
{
   str.erase(std::remove(str.begin(), str.end(), ' '), str.end());
}

std::string removeAllSpacesFromString(std::string str)
{
   str.erase(std::remove(str.begin(), str.end(), ' '), str.end());
   return str;
}

std::string bitwise_operate(unsigned long a, unsigned long b, std::string oper_str)
{
	    ostringstream result_stream;
		oper_str = TrimSpacesFromString(oper_str);
		if (oper_str == "|") {
				result_stream << (a | b);
		} else if (oper_str == "&") {
				result_stream << (a & b);
		} else if (oper_str == "^") {
			    result_stream << (a ^ b);
		} else if (oper_str == "<<") {
			result_stream << (a << b);
		} else if (oper_str == ">>") {
			result_stream << (a >> b);
		} else {
			safe_print(std::cout <<"Error: bitwise_operate: unknown operation (" << oper_str << ") in command: " << a << " " << oper_str << " " << b << std::endl);
		}
	return result_stream.str();
}

int get_primary_uart_from_string(std::string uart_name)
{
	std::vector<int> uart_nums = convert_string_to_vector<int>(uart_name,"_");
	if (uart_nums.empty()) {
		return (-1);
	} else {
		return (uart_nums.at(0));
	}
}

int get_secondary_uart_from_string(std::string uart_name)
{
	std::vector<int> uart_nums = convert_string_to_vector<int>(uart_name,"_");
	if (uart_nums.empty()) {
		return (-1);
	} else {
		if (uart_nums.size() == 1)
		{
			return (0); //primary uart without secondary uart explicit address, so secondary uart is 0;
		} else {
		   return (uart_nums.at(1));
		}
	}
}



void str_replace( string &s, const string &search, const string &replace )
{
	/*
    for( size_t pos = 0; ; pos += replace.length() )
	{
        pos = s.find( search, pos );
         if( pos == string::npos ) break;

         s.erase( pos, search.length() );
         s.insert( pos, replace );
     }
     */

	 size_t pos = 0;
	    while((pos = s.find(search, pos)) != std::string::npos) {
	         s.replace(pos, search.length(), replace);
	         pos += replace.length();
	    }
 }

void str_replace_chars( string &s, const string &search, const string &replace )
{
    for( size_t pos = 0; ; pos += replace.length() )
	{
        pos = s.find_first_of( search, pos );
         if( pos == string::npos ) break;

         s.erase( pos, search.length() );
         s.insert( pos, replace );
     }
 }

std::string get_second_string_and_trim(std::string& in_str) {
	    std::string argvstr;
        size_t argvstr_start = in_str.find(" ");
		if (argvstr_start != string::npos) {
			argvstr = in_str.substr(argvstr_start + 1);
			TrimSpaces(argvstr);
		} else {
			argvstr = "";
		}
		return argvstr;
}


std::string get_memory_usage_stats()
{

	struct mallinfo mallinfo_inst = mallinfo();
	std::ostringstream ostr;

	ostr << "\n******************************\n";
	ostr << "\n*    Memory Usage Summary    *\n";
	ostr << "\n******************************\n";
	ostr << "total amount of space in the heap:         " << mallinfo_inst.arena << endl;
	ostr << "number of chunks which are not in use:     " << mallinfo_inst.ordblks << endl;
	ostr << "total amount of space allocated by malloc: " << mallinfo_inst.uordblks << endl;
	ostr << "total amount of space not in use:          " << mallinfo_inst.fordblks << endl;
	ostr << "size of the top most memory block:         " << mallinfo_inst.keepcost << endl;
    return ostr.str();
}



std::string get_one_line_memory_usage_stats()
{

	struct mallinfo mallinfo_inst = mallinfo();
	std::ostringstream ostr;

	ostr << "total heap: " << mallinfo_inst.arena;
	ostr << " chunks not in use: " << mallinfo_inst.ordblks;
	ostr << " space allocated by malloc: " << mallinfo_inst.uordblks;
	ostr << " space not in use: " << mallinfo_inst.fordblks;
	ostr << " size top block: " << mallinfo_inst.keepcost;
    return ostr.str();
}




//==========================================================================================================================
//
//
// End Utility Procedures
//
//
//==========================================================================================================================
