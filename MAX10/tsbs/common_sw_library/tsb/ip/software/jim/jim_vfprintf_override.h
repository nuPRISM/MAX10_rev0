/*
 * jim_vfprintf_override.h
 *
 *  Created on: Oct 4, 2011
 *      Author: linnyair
 */

#ifndef JIM_VFPRINTF_OVERRIDE_H_
#define JIM_VFPRINTF_OVERRIDE_H_
#include <system.h>
#include <alt_types.h>
#include <stdlib.h> /* In order to export the Jim_Free() macro */
#include <stdarg.h> /* In order to get type va_list */

int jim_vfprintf_override_func(const char *fmt, va_list ap);
int jim_fwrite_override_func(const void *ptr, size_t size, size_t n, void *cookie);


#endif /* JIM_VFPRINTF_OVERRIDE_H_ */
