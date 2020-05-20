/*
 * global_stream_defs.hpp
 *
 *  Created on: Oct 3, 2011
 *      Author: linnyair
 */

#ifndef GLOBAL_STREAM_DEFS_HPP_
#define GLOBAL_STREAM_DEFS_HPP_

#include <iostream>
#include <vector>
#include <string>
#include <sstream>

extern "C" {
/* MicroC/OS-II definitions */
#include "includes.h"

/* Simple Socket Server definitions */
#include "simple_socket_server.h"

/* Nichestack definitions */
#include "ucos_ii.h"
	//#include "../../iniche/src/autoip4/upnp.h"
}

#include "log_file_encapsulator.h"

extern log_file_encapsulator auto_log_file;
extern log_file_encapsulator manual_log_file;

extern  std::stringstream myostream;
extern  std::stringstream c_myostream;
extern  std::stringstream dut_proc_myostream;

extern int we_are_in_ethernet_quiet_mode;
extern int output_cout_streams_to_command_uart;
extern void my_puts_to_command_uart (std::string);
extern void local_out_to_all_streams(std::string);

#define bedrock_out_to_all_streams(myostream,x) { std::stringstream myostream_tmpstream; \
        myostream_tmpstream << x;\
        myostream << myostream_tmpstream.str(); \
        if (!we_are_in_ethernet_quiet_mode) \
        {safe_print(std::cout << myostream_tmpstream.str(); std::cout.flush());}\
        if (output_cout_streams_to_command_uart) {\
	      my_puts_to_command_uart(myostream_tmpstream.str());\
        }\
        if (OSTCBCur->OSTCBPrio == LINNUX_MAIN_TASK_PRIORITY) \
        { \
        	if (auto_log_file.is_open())\
			{ \
			  auto_log_file.write_str(myostream_tmpstream.str());\
			} \
			if (manual_log_file.is_open())\
		    { \
				manual_log_file.write_str(myostream_tmpstream.str());\
			} \
        }\
      };

#define out_to_all_streams(x) if (OSTCBCur->OSTCBPrio == LINNUX_MAIN_TASK_PRIORITY) { \
	                              	 bedrock_out_to_all_streams(myostream,x);\
	                          } else { \
	                        	  if (OSTCBCur->OSTCBPrio == LINNUX_CONTROL_TASK_PRIORITY) { \
	                                 bedrock_out_to_all_streams(c_myostream,x);\
                                  } else \
                                  { \
                                	if (OSTCBCur->OSTCBPrio == LINNUX_DUT_PROCESSOR_TASK_PRIORITY) { \
									 bedrock_out_to_all_streams(dut_proc_myostream,x);\
									} else \
									{ \
									   std::stringstream myostream_tmpstream; \
									   myostream_tmpstream << x;\
									   local_out_to_all_streams(myostream_tmpstream.str()); \
									   /* safe_print(std::cout << "illegal call to out_to_all_streams" << std::endl);*/ \
									   /*safe_print(std::cout << "Error: out_to_all_streams called from process: [" << OSTCBCur->OSTCBPrio << "] File: [" << __FILE__ << "] Function: [" << __FUNCTION__ << "] Line: [" << __LINE__ << "] Data is: ["<< x << "]" << std::endl);*/ \
									 } \
                                  } \
	                          }




#define c_out_to_all_streams(x) if (OSTCBCur->OSTCBPrio == LINNUX_CONTROL_TASK_PRIORITY) { \
									bedrock_out_to_all_streams(c_myostream,x); \
								} else { \
									safe_print(std::cout << "illegal call to c_out_to_all_streams" << std::endl); \
                                    /*safe_print(std::cout << "Error: c_out_to_all_streams called from process: [" << OSTCBCur->OSTCBPrio << "] File: [" << __FILE__ << "] Function: [" << __FUNCTION__ << "] Line: [" << __LINE__ << "] Data is: ["<< x << "]" << std::endl);*/\
								}




#define bedrock_out_to_all_streams_safe(myostream,x) { \
                                std::stringstream myostream_tmpstream; \
	                            myostream_tmpstream << x;\
	                            myostream << myostream_tmpstream.str(); \
	                            if (!we_are_in_ethernet_quiet_mode) \
	                            {safe_print(std::cout << myostream_tmpstream.str());}\
	                          };

#define out_to_all_streams_safe(x)   if (OSTCBCur->OSTCBPrio == LINNUX_MAIN_TASK_PRIORITY)  {\
                                          bedrock_out_to_all_streams_safe(myostream,x) \
                                     } else { \
       	                        	  if (OSTCBCur->OSTCBPrio == LINNUX_CONTROL_TASK_PRIORITY) { \
       	                                 bedrock_out_to_all_streams(c_myostream,x);\
                                         } else \
                                         { \
                                          safe_print(std::cout << "illegal call to out_to_all_streams_safe" << std::endl); \
                                          /* safe_print(std::cout << "Error: out_to_all_streams_safe called from process: [" << OSTCBCur->OSTCBPrio << "] File: [" << __FILE__ << "] Function: [" << __FUNCTION__ << "] Line: [" << __LINE__ << "] Data is: ["<< x << "]" << std::endl);\*/ \
                                         } \
								     }

#define c_out_to_all_streams_safe(x)  if (OSTCBCur->OSTCBPrio == LINNUX_CONTROL_TASK_PRIORITY) { \
                                         bedrock_out_to_all_streams_safe(c_myostream,x) \
                                     } else { \
                                         safe_print(std::cout << "illegal call to c_out_to_all_streams_safe" << std::endl); \
                                         /*safe_print(std::cout << "Error: c_out_to_all_streams_safe called from process: [" << OSTCBCur->OSTCBPrio << "] File: [" << __FILE__ << "] Function: [" << __FUNCTION__ << "] Line: [" << __LINE__ << "] Data is: ["<< x << "]" << std::endl);*/\
								     }

#endif /* GLOBAL_STREAM_DEFS_HPP_ */
