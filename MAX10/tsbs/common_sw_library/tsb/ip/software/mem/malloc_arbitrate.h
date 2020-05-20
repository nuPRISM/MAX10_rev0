/*
 * malloc_arbitrate.h
 *
 *  Created on: Apr 24, 2012
 *      Author: linnyair
 */

#ifndef MALLOC_ARBITRATE_H_
#define MALLOC_ARBITRATE_H_
#include <stdlib.h>
extern int use_non_default_malloc_please;
extern void *cpp_original_malloc(size_t _size);
extern void cpp_original_free(void *__ptr);
extern void *cpp_truly_original_malloc(size_t _size);
extern void cpp_truly_original_free(void *__ptr);
extern void cpp_truly_original_free_char_ptr(char *__ptr);
extern void *cpp_original_realloc (void *__ptr, size_t __size);
extern void *cpp_original_calloc(size_t num, size_t size);


#endif /* MALLOC_ARBITRATE_H_ */
