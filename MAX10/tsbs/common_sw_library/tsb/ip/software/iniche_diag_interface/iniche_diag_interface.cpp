/*
 * iniche_diag_interface.cpp
 *
 *  Created on: Feb 1, 2012
 *      Author: linnyair
 */


#include "iniche_diag_interface.h"

#include <sstream>

extern "C" {
   #include "ipport.h"
   #include "menu.h"
   #include <xprintf.h>
}
char     record_diag_menu_in_stream_cbuf[CBUFLEN];

/* Generic IO structure that do_command() will be called with */
//struct GenericIO  std_io2   =  {  cbuf, std_out, 0, std_in   }  ;

std::ostringstream iniche_diag_str;

int record_diag_menu_in_stream (long id, char * outbuf, int len){
	//xprintf("[record_diag_menu_in_stream] %s",outbuf);
	if (outbuf)
	{
	 iniche_diag_str << outbuf;
	}
	return len;
}

struct GenericIO record_output_pio = { record_diag_menu_in_stream_cbuf, record_diag_menu_in_stream, 456, NULL};



std::string do_iniche_diag_command(std::string cmdstr) {
      strncpy(record_diag_menu_in_stream_cbuf,cmdstr.c_str(),CBUFLEN-1);
      record_diag_menu_in_stream_cbuf[CBUFLEN-1]='\0'; //just in case
      iniche_diag_str.str("");
      do_command(&record_output_pio);
      return iniche_diag_str.str();
}
