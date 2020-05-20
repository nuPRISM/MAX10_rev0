/*
 * strformat.cpp
 *
 *  Created on: Apr 26, 2012
 *      Author: linnyair
 */

#include "strformat.h"
#include <stdlib.h>
#include <sstream>
#include <string>
#include <stdio.h>
#include <stdarg.h>
#include <iostream>
#include <iomanip>
#include "stdarg.h"
#include "tinyformat.h"
#include "basedef.h"




//=============================================================================
std::string strformat(const char* sformat, ... ) {
	va_list marker;
	va_start(marker, sformat);
	std::string result_str = vstrformat(sformat, marker);
	va_end(marker);
	return result_str;

}
std::string vstrformat(const char* sformat, va_list marker )
{
    char *s;
    char ch=0;
    int n, i=0, m;
    long l;
    double d;
    std::string sf = sformat;
    std::stringstream ss;

    m = sf.length();
    while (i<m)
    {
        ch = sf.at(i);
        if (ch == '%')
        {
            i++;
            if (i<m)
            {
                ch = sf.at(i);
                switch(ch)
                {
                    case 's': { s = va_arg(marker, char*);  ss << s;         } break;
                    case 'c': { n = va_arg(marker, int);    ss << (char)n;   } break;
                    case 'd': { n = va_arg(marker, int);    ss << (int)n;    } break;
                    case 'l': { l = va_arg(marker, long);   ss << (long)l;   } break;
                    case 'f': { d = va_arg(marker, double); ss << (float)d;  } break;
                    case 'e': { d = va_arg(marker, double); ss << (double)d; } break;
                    case 'X':
                    case 'x':
                        {
                            if (++i<m)
                            {
                                ss << std::hex << std::setiosflags (std::ios_base::showbase);
                                if (ch == 'X') ss << std::setiosflags (std::ios_base::uppercase);
                                char ch2 = sf.at(i);
                                if (ch2 == 'c') { n = va_arg(marker, int);  ss << std::hex << (char)n; }
                                else if (ch2 == 'd') { n = va_arg(marker, int); ss << std::hex << (int)n; }
                                else if (ch2 == 'l') { l = va_arg(marker, long);    ss << std::hex << (long)l; }
                                else ss << '%' << ch << ch2;
                                ss << std::resetiosflags (std::ios_base::showbase | std::ios_base::uppercase) << std::dec;
                            }
                        } break;
                    case '%': { ss << '%'; } break;
                    default:
                    {
                        ss << "%" << ch;
                        //i = m; //get out of loop
                    }
                }
            }
        }
        else ss << ch;
        i++;
    }
    return ss.str();
}
