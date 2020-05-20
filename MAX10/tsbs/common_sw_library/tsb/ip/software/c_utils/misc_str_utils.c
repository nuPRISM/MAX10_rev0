/*
 * misc_str_utils.c
 *
 *  Created on: Apr 4, 2012
 *      Author: linnyair
 */

#include "xprintf.h"
#include "misc_str_utils.h"


void make_string_lowercase(char *the_str) {
	while (*the_str != '\0') {
		if ((*the_str >= 'A') && (*the_str  <= 'Z')) {
			*the_str = *the_str + 0x20; //convert to lower case;
			}
		the_str++;
	}
}

void make_string_uppercase(char *the_str) {
	while (*the_str != '\0') {
		if ((*the_str >= 'a') && (*the_str  <= 'z')) {
			*the_str = *the_str - 0x20; //convert to upper case;
			}
		the_str++;
	}
}


void trim_trailing_spaces(char *the_str) {
   char *end_ptr;
   end_ptr = the_str+my_strlen(the_str)-1;
   while ((end_ptr != the_str) &&  ((*end_ptr == '\0') || (*end_ptr == ' '))) {
	   *end_ptr = '\0';
	   end_ptr = end_ptr - 1;
   }
}

unsigned int convert_char_to_number ( const unsigned char c )
{
	return ((unsigned int) c);
}

unsigned int convert_string_to_list_of_hex_numbers( const char * instr, char * outstr, int maxlength) {
	unsigned int i = 0;
	unsigned length_count = 0;

	while (1) {
		if ((instr[i]) && (length_count+2 < maxlength)) {
			xsprintf(outstr+length_count,"%02x",convert_char_to_number(instr[i]));
			length_count+=2;
		} else {
			break;
		}
		i++;
	}
	outstr[length_count] = '\0';
	return length_count;
}

char* get_second_string_pointer(char* original_string) {
   char* retptr;
   //char dummy_token[10];
   //char *brake_chars = " \t\n\r";
   retptr = original_string; //stptok(original_string, dummy_token, 9, brake_chars);
   while ((*retptr != '\0') && (*retptr != ' ')) {
	   retptr++;
   }
   
   while (*retptr == ' ') {
	   retptr++; //point to next char
   }
   
   return retptr;
}

void get_first_string(char* original_string,  char* token, int token_max_length) {
   char *brake_chars = " \t\n\r";
   stptok(original_string, token, token_max_length, brake_chars);
}

int my_strcmp(const char* s1, const char* s2)
{
    while(*s1 && (*s1==*s2))
        s1++,s2++;
    return (*s1 < *s2) ? -1 : *s1 > *s2;
}
