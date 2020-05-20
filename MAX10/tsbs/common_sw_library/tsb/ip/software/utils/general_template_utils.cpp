/*
 * linnux_utils.cc
 *
 *  Created on: Apr 15, 2011
 *      Author: linnyair
 */

#include "general_template_utils.hpp"
#include <algorithm>
#include <malloc.h>

using namespace std;
namespace gtutils {
unsigned convert_array_of_four_chars_into_unsigned(unsigned char* rxBuffer) {
			unsigned returned_command = rxBuffer[0];
			returned_command = (returned_command << 8) +  rxBuffer[1];
			returned_command = (returned_command << 8) +  rxBuffer[2];
			returned_command = (returned_command << 8) +  rxBuffer[3];
			return returned_command;
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
    	std::cout << "hex_to_string: Odd length string (" << input << ") " << std::endl;
    	return std::string("");
    }

    std::string output;
    output.reserve(len / 2);
    for (size_t i = 0; i < len; i += 2)
    {
        char a = input[i];
        const char* p = std::lower_bound(lut, lut + 16, a);
        if (*p != a) {
        	std::cout << "hex_to_string: not a hex digit in string (" << input << ") position " << i << std::endl;
        	continue;
        }

        char b = input[i + 1];
        const char* q = std::lower_bound(lut, lut + 16, b);
        if (*q != b){
        	std::cout << "hex_to_string: not a hex digit in string (" << input << ") position " << i+1 << std::endl;
        	continue;
        }
        output.push_back(((p - lut) << 4) | (q - lut));
    }
    return output;
}

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
	cout << "Error in convert_hex_char_to_num c= " << c << std::endl;
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
	cout << "Error in convert_num_to_hex_char h= " << h << std::endl;
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
		  //std::cout << " i = " << i << " ch = " << ch << " char(ch) = " << ((char)(ch)) << "\n";
		  result_string << ((char)(ch)) ;
	  }
	  //std::cout << "conv_hex_string_to_ascii: Result: " << result_string.str() << "\n" ;
	  return result_string.str();
}

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
/*
std::string dec2bin(unsigned long decimal_number,int num_binary_bits)
{
 CBaseConverter binary_base_converter(2);
 return binary_base_converter.ConvertToBase(decimal_number,num_binary_bits,1,1);

}
*/


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
			std::cout <<"Error: bitwise_operate: unknown operation (" << oper_str << ") in command: " << a << " " << oper_str << " " << b << std::endl;
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



std::string urlencode(const std::string& src)
{
	std::string result;
	std::string::const_iterator iter;

	for (iter = src.begin(); iter != src.end(); ++iter) {
		switch (*iter) {
		case ' ':
			result.append(1, '+');
			break;
			// alnum
		case 'A': case 'B': case 'C': case 'D': case 'E': case 'F': case 'G':
		case 'H': case 'I': case 'J': case 'K': case 'L': case 'M': case 'N':
		case 'O': case 'P': case 'Q': case 'R': case 'S': case 'T': case 'U':
		case 'V': case 'W': case 'X': case 'Y': case 'Z':
		case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'g':
		case 'h': case 'i': case 'j': case 'k': case 'l': case 'm': case 'n':
		case 'o': case 'p': case 'q': case 'r': case 's': case 't': case 'u':
		case 'v': case 'w': case 'x': case 'y': case 'z':
		case '0': case '1': case '2': case '3': case '4': case '5': case '6':
		case '7': case '8': case '9':
			// mark
		case '-': case '_': case '.': case '!': case '~': case '*': case '\'':
		case '(': case ')':
			result.append(1, *iter);
			break;
			// escape
		default:
			result.append(1, '%');
			result.append(charToHex(*iter));
			break;
		}
	}

	return result;
}

char hexToChar(char first,
	char second)
{
	int digit;

	digit = (first >= 'A' ? ((first & 0xDF) - 'A') + 10 : (first - '0'));
	digit *= 16;
	digit += (second >= 'A' ? ((second & 0xDF) - 'A') + 10 : (second - '0'));
	return static_cast<char>(digit);
}

std::string charToHex(char c)
{
	std::string result;
	char first, second;

	first = (c & 0xF0) / 16;
	first += first > 9 ? 'A' - 10 : '0';
	second = c & 0x0F;
	second += second > 9 ? 'A' - 10 : '0';

	result.append(1, first);
	result.append(1, second);

	return result;
}

std::string urldecode(const std::string& src)
{
	std::string result;
	std::string::const_iterator iter;
	char c;

	for (iter = src.begin(); iter != src.end(); ++iter) {
		switch (*iter) {
		case '+':
			result.append(1, ' ');
			break;
		case '%':
			// Don't assume well-formed input
			if (std::distance(iter, src.end()) >= 2
				&& std::isxdigit(*(iter + 1)) && std::isxdigit(*(iter + 2))) {
				c = *++iter;
				result.append(1, hexToChar(c, *++iter));
			}
			// Just pass the % through untouched
			else {
				result.append(1, '%');
			}
			break;

		default:
			result.append(1, *iter);
			break;
		}
	}

	return result;
}


#if defined(_WIN32) || defined(__WIN32__) || defined(_MSC_VER)
std::string get_memory_usage_stats()
{
	std::ostringstream ostr;
	ostr  << "This function is not support for Windows";
	return ostr.str();
}



std::string get_one_line_memory_usage_stats() {
	std::ostringstream ostr;
	ostr  << "This function is not support for Windows";
	return ostr.str();
}

#else
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
#endif
}

