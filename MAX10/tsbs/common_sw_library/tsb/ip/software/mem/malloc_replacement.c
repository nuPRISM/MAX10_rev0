/*
 * malloc_replacement.c
 *
 *  Created on: Apr 24, 2012
 *      Author: linnyair
 */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "basedef.h"
#include "includes.h"
#include "malloc_arbitrate.h"

void* malloc_replacement(size_t _size) {
	return cpp_original_malloc(_size);
}

void free_replacement(void *__ptr) {
	cpp_original_free(__ptr);
}


void* realloc_replacement(void *__ptr, size_t __size) {
	return cpp_original_realloc(__ptr, __size);
}
