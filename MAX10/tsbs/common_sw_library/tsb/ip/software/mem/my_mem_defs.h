/*
 * my_mem_defs.h
 *
 *  Created on: Apr 23, 2012
 *      Author: linnyair
 */

#ifndef MY_MEM_DEFS_H_
#define MY_MEM_DEFS_H_
#include "../xprintf/xprintf.h"
#include "ucos_ii.h"
#include "../../../../../../tsb/ip/rtl/software/allserver_sfp/src/local/basedef.h"

extern OS_EVENT* MEM_access_Semaphore;

#define get_mem_access_semaphore() INT8U semaphore_err; OSSemPend(MEM_access_Semaphore,0,&semaphore_err);\
	                               if (semaphore_err != OS_NO_ERR) { \
	                                  xprintf("[get_mem_access_semaphore] Could not get MEM_access_Semaphore File = %s, line = %d, process = %d, Error is: %d\n", __FILE__, (int) __LINE__, (int) OSTCBCur->OSTCBPrio, (int) semaphore_err); \
	                               };

#define release_mem_access_semaphore() semaphore_err = OSSemPost(MEM_access_Semaphore); \
                                       if (semaphore_err != OS_NO_ERR) { \
                                            xprintf("[release_mem_access_semaphore] Could not release MEM_access_Semaphore File = %s, line = %d, process = %d, Error is: %d\n", __FILE__, (int) __LINE__, (int) OSTCBCur->OSTCBPrio, (int) semaphore_err);\
                                       }

#ifdef DISABLE_MEM_FUNCTIONS
#define my_mem_malloc     malloc
#define my_mem_free       free
#define my_mem_strdup     strdup
#define my_mem_calloc     calloc
#define my_mem_realloc    realloc
#define my_trio_asprintf  asprintf
#define my_trio_vasprintf vasprintf
#else
#define my_mem_malloc(x)      mem_malloc(x)
#define my_mem_free(x)       mem_free(x)
#define my_mem_strdup(x)     mem_strdup(x)
#define my_mem_calloc(x,y)     mem_calloc((x)*(y))
#define my_mem_realloc(x,y)    mem_realloc((x),(y))
#define my_trio_asprintf trio_asprintf
#define my_trio_vasprintf trio_vasprintf
#endif



#endif /* MY_MEM_DEFS_H_ */
