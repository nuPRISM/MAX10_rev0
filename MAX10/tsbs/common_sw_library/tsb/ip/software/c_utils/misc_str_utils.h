/*
 * misc_str_utils.h
 *
 *  Created on: Apr 4, 2012
 *      Author: linnyair
 */

#ifndef MISC_STR_UTILS_H_
#define MISC_STR_UTILS_H_

void make_string_lowercase(char *);
void trim_trailing_spaces(char *);
unsigned int convert_string_to_list_of_hex_numbers( const char * instr, char * outstr, int maxlength);
unsigned int convert_char_to_number ( unsigned char c );
void get_first_string(char* original_string,  char* token, int token_max_length);
char* get_second_string_pointer(char* original_string);
void make_string_uppercase(char *the_str);
int my_strcmp(const char* s1, const char* s2);

#endif /* MISC_STR_UTILS_H_ */
