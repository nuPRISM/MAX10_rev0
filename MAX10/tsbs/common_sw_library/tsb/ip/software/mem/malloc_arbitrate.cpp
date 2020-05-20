/*
 * malloc_arbitrate.cpp
 *
 *  Created on: Apr 24, 2012
 *      Author: linnyair
 */

extern "C" {
   #include "my_mem_defs.h"
   #include "mem.h"
 #include "ucos_ii.h"
#include <sys/alt_stdio.h>
#include "malloc_arbitrate.h"
#include "includes.h"
}


#include <stdlib.h>
namespace std {
   using ::malloc;
   using ::free;
   using ::realloc;
   using ::calloc;
   using ::_calloc_r;
   using ::_free_r;
   using ::_malloc_r;
}

int use_non_default_malloc_please = 0;

void *cpp_original_malloc(size_t _size) {
	   //alt_printf("+");
	if (TaskUserData[OSTCBCur->OSTCBPrio].in_my_malloc_op || (!mem_inited)) {
	   return _malloc_r(_REENT,_size);
	} else {
		return my_mem_malloc(_size);
	}
}


void *cpp_truly_original_malloc(size_t _size) {
	#ifndef DISABLE_MEM_FUNCTIONS
	   return _malloc_r(_REENT,_size);
#else
	   return malloc(_size);
#endif
}

void cpp_original_free(void *__ptr) {
	  // alt_printf("-");
	if (TaskUserData[OSTCBCur->OSTCBPrio].in_my_malloc_op || (!mem_inited)) {
	   std::_free_r(_REENT,__ptr);
	} else {
		my_mem_free(__ptr);
	}
}

void cpp_truly_original_free(void *__ptr) {
#ifndef DISABLE_MEM_FUNCTIONS
	std::_free_r(_REENT,__ptr);
#else
	free(__ptr);
#endif

}


void cpp_truly_original_free_char_ptr(char *__ptr) {
#ifndef DISABLE_MEM_FUNCTIONS
    std::_free_r(_REENT,(void *) __ptr);
#else
	free((void*)__ptr);
#endif

}

void *cpp_original_realloc (void *__ptr, size_t __size)
{
	//alt_printf("+");
    return std::realloc(__ptr, __size);
}

void *cpp_original_calloc(size_t num, size_t size)
{
	#ifndef DISABLE_MEM_FUNCTIONS
         return std::_calloc_r(_REENT,num,size);
    #else
         return calloc(num,size);
    #endif
}

/*
void *malloc(size_t _size) {
	  if(use_non_default_malloc_please) {
          alt_printf("!");
		  return my_mem_malloc(_size);
	  } else {
          alt_printf(".");
		  return std::malloc(_size);
	  }
}
*/
void *original_calloc (size_t __nmemb, size_t __size) {
	alt_printf(":");
	return NULL;
}
