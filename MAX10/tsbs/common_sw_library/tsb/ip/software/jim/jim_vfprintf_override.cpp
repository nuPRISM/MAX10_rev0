/*
 * jim_vfprintf_override.cpp
 *
 *  Created on: Oct 4, 2011
 *      Author: linnyair
 */


#include "jim_vfprintf_override.h"

#include "global_stream_defs.hpp"
#include "send_to_ethernet_stdout.h"
#include "trio/trio.h"
extern "C" {
 #include "mem.h"
 #include "my_mem_defs.h"
}
#include <stdio.h>
#include <string>
#include "strformat.h"
int jim_vfprintf_override_func(const char *fmt, va_list ap)
{

    char *buf=NULL;
	int result;
#ifdef LINNUX_USE_VASPRINTF_WITH_ORIGINAL_MALLOC_AND_FREE
	result = vasprintf(&buf, fmt, ap);
#else
	#ifdef LINNUX_REPLACE_VASPRINTF_BY_TRIO_VASPRINTF
		result = trio_vasprintf(&buf, fmt, ap);
	#else
		result = vasprintf(&buf, fmt, ap);
	#endif
#endif
	if (!(result < 0)){
		out_to_all_streams(buf); send_myostream_to_ethernet_stdout();
	} else {
		printf("jim_vfprintf_override_func - result = 0 for fmt string: %s\n",fmt);
	}
	if (buf != NULL) {
#ifdef LINNUX_USE_VASPRINTF_WITH_ORIGINAL_MALLOC_AND_FREE
	cpp_truly_original_free(buf);
#else
		#ifdef LINNUX_REPLACE_VASPRINTF_BY_TRIO_VASPRINTF
				TRIO_FREE(buf);
		#else
				  free(buf);
		#endif
#endif
	}
	return result;

/*
	    char *buf=NULL;
		int result;

		int len = snprintf(NULL,0,fmt,ap);
		if (!(buf=(char *)my_mem_malloc((len+5)*sizeof(char)))) {
			safe_print(std::cout << "Error: malloc failed in jim_vfprintf_override_func\n!");
			exit(-1);
		}
		int actual_len = snprintf(buf,len+1,fmt,ap);
		safe_print(std::cout << "[jim_vfprintf_override_func] required length is: " << len << " actual_len = " << actual_len << "str = [" << buf << "]\n");
		if (!(actual_len < 0)){ out_to_all_streams(buf); send_myostream_to_ethernet_stdout(); };
		free(buf);
		return actual_len;
		*/
	/*
	char *buf=NULL;
	int result;
	result = trio_vasprintf(&buf, fmt, ap);
	if (!(result < 0)){ out_to_all_streams(buf); send_myostream_to_ethernet_stdout(); };
	if (buf != NULL) {
	  free(buf);
	}
	return result;
*/
/*
	std::string result_str="";
	result_str = vstrformat(fmt,ap);
	out_to_all_streams(result_str); send_myostream_to_ethernet_stdout();
	return result_str.length();
*/
}

int jim_fwrite_override_func(const void *ptr, size_t size, size_t n, void *cookie)
{
    out_to_all_streams(((char *) ptr));
    send_myostream_to_ethernet_stdout();
    return n;
}
