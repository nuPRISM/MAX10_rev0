/*
 * malloc_replacement.h
 *
 *  Created on: Apr 24, 2012
 *      Author: linnyair
 */

#ifndef MALLOC_REPLACEMENT_H_
#define MALLOC_REPLACEMENT_H_

extern void* malloc_replacement(size_t _size);
extern void free_replacement(void *__ptr);
extern void* realloc_replacement(void *__ptr, size_t __size);
#endif /* MALLOC_REPLACEMENT_H_ */
