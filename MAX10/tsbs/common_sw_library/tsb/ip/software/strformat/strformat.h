/*
 * strformat.h
 *
 *  Created on: Apr 26, 2012
 *      Author: linnyair
 */

#ifndef STRFORMAT_H_
#define STRFORMAT_H_
#include <string>
#include <stdarg.h>

std::string strformat(const char* sformat, ... );
std::string vstrformat(const char* sformat, va_list marker);


#endif /* STRFORMAT_H_ */
