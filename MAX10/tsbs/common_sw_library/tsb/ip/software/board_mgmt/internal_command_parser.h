/*
 * internal_command_parser.h
 *
 *  Created on: Jul 15, 2013
 *      Author: yairlinn
 */

#ifndef INTERNAL_COMMAND_PARSER_H_
#define INTERNAL_COMMAND_PARSER_H_
#include <string>
unsigned int execute_internal_command (char * the_command, char* result_str, int max_command_chars, int max_response_chars);

std::string execute_internal_command_subjugate(std::string the_command, void* additional_data);

#endif /* INTERNAL_COMMAND_PARSER_H_ */
