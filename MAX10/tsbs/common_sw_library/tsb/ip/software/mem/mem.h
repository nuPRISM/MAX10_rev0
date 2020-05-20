/*
**  This is a copyrighted work which is functionally identical to work
**  originally published in Micro Cornucopia magazine (issue #52, March-April,
**  1990) and is freely licensed by the author, Walter Bright, for any use.
*/

/*_ mem.h   Fri May 26 1989   Modified by: Walter Bright */
/* $Header: /proj/products/merlin/port/RCS/mem.h,v 1.11 89/10/23 11:39:00 bright Exp $ */
/* Copyright 1986-1988 by Northwest Software	*/
/* All Rights Reserved				*/
/* Written by Walter Bright			*/

#ifndef MEM_H
#define MEM_H	1

#ifndef TOOLKIT_H
#include	"../snippets/toolkit.h"
#endif

#include "../../../../../../tsb/ip/rtl/software/allserver_sfp/src/local/basedef.h"
#include "malloc_arbitrate.h"

/*
 * Memory management routines.
 *
 * Compiling:
 *
 *	#define MEM_DEBUG 1 when compiling to enable extended debugging
 *	features.
 *
 * Features always enabled:
 *
 *	o mem_init() is called at startup, and mem_term() at
 *	  close, which checks to see that the number of alloc's is
 *	  the same as the number of free's.
 *	o Behavior on out-of-memory conditions can be controlled
 *	  via mem_setexception().
 *
 * Extended debugging features:
 *
 *	o Enabled by #define MEM_DEBUG 1 when compiling.
 *	o Check values are inserted before and after the alloc'ed data
 *	  to detect pointer underruns and overruns.
 *	o Free'd pointers are checked against alloc'ed pointers.
 *	o Free'd storage is cleared to smoke out references to free'd data.
 *	o Realloc'd pointers are always changed, and the previous storage
 *	  is cleared, to detect erroneous dependencies on the previous
 *	  pointer.
 *	o The routine mem_checkptr() is provided to check an alloc'ed
 *	  pointer.
 */

/********************* GLOBAL VARIABLES *************************/

extern int mem_inited;		/* != 0 if mem package is initialized.	*/
				/* Test this if you have other packages	*/
				/* that depend on mem being initialized	*/

/********************* PUBLIC FUNCTIONS *************************/

/***********************************
 * Set behavior when mem runs out of memory.
 * Input:
 *	flag =	MEM_ABORTMSG:	Abort the program with the message
 *				'Fatal error: out of memory' sent
 *				to stdout. This is the default behavior.
 *		MEM_ABORT:	Abort the program with no message.
 *		MEM_RETNULL:	Return NULL back to caller.
 *		MEM_CALLFP:	Call application-specified function.
 *				fp must be supplied.
 *	fp			Optional function pointer. Supplied if
 *				(flag == MEM_CALLFP). This function returns
 *				MEM_XXXXX, indicating what mem should do next.
 *				The function could do things like swap
 *				data out to disk to free up more memory.
 *	fp could also return:
 *		MEM_RETRY:	Try again to allocate the space. Be
 *				careful not to go into an infinite loop.
 */

#define MEM_ABORTMSG	0
#define MEM_ABORT	1
#define MEM_RETNULL	2
#define MEM_CALLFP	3
#define MEM_RETRY	4
#define __MEM_P_LINNUX(x) x
void mem_setexception __MEM_P_LINNUX((int, int(*)()));


/****************************
 * Allocate space for string, copy string into it, and
 * return pointer to the new string.
 * This routine doesn't really belong here, but it is used so often
 * that I gave up and put it here.
 * Use:
 *	char *mem_strdup(const char *s);
 * Returns:
 *	pointer to copied string if succussful.
 *	else returns NULL (if MEM_RETNULL)
 */

char *mem_strdup __MEM_P_LINNUX((const char *));

/**************************
 * Function so we can have a pointer to function mem_free().
 * This is needed since mem_free is sometimes defined as a macro,
 * and then the preprocessor screws up.
 * The pointer to mem_free() is used frequently with the list package.
 * Use:
 *	void mem_freefp(void *p);
 */

/***************************
 * Check for errors. This routine does a consistency check on the
 * storage allocator, looking for corrupted data. It should be called
 * when the application has CPU cycles to burn.
 * Use:
 *	void mem_check(void);
 */

void mem_check __MEM_P_LINNUX((void ));

/***************************
 * Check ptr to see if it is in the range of allocated data.
 * Cause assertion failure if it isn't.
 */

void mem_checkptr __MEM_P_LINNUX((void *ptr, int memory_error_inform_only));

/***************************
 * Allocate and return a pointer to numbytes of storage.
 * Use:
 *	void *mem_malloc(unsigned numbytes);
 *	void *mem_calloc(unsigned numbytes); allocated memory is cleared
 * Input:
 *	numbytes	Number of bytes to allocate
 * Returns:
 *	if (numbytes > 0)
 *		pointer to allocated data, NULL if out of memory
 *	else
 *		return NULL
 */

void *mem_malloc __MEM_P_LINNUX((unsigned));
void *mem_calloc __MEM_P_LINNUX((unsigned));

/*****************************
 * Reallocate memory.
 * Use:
 *	void *mem_realloc(void *ptr,unsigned numbytes);
 */

void *mem_realloc __MEM_P_LINNUX((void *,unsigned));

/*****************************
 * Free memory allocated by mem_malloc(), mem_calloc() or mem_realloc().
 * Use:
 *	void mem_free(void *ptr);
 */

void mem_free __MEM_P_LINNUX((void *));

/***************************
 * Initialize memory handler.
 * Use:
 *	void mem_init(void);
 * Output:
 *	mem_inited = 1
 */

void mem_init __MEM_P_LINNUX((void ));

/***************************
 * Terminate memory handler. Useful for checking for errors.
 * Use:
 *	void mem_term(void);
 * Output:
 *	mem_inited = 0
 */

typedef struct mem_reporting_structure {
long current_alloc;
long max_alloc;
} mem_reporting_structure_type;

void mem_term __MEM_P_LINNUX((void ));
mem_reporting_structure_type mem_display __MEM_P_LINNUX((int ));

/* The following stuff forms the implementation rather than the
 * definition, so ignore it.
 */

#if MEM_DEBUG		/* if creating debug version	*/
#define mem_strdup(p)	mem_strdup_debug((p),__FILE__,__LINE__)
#define mem_malloc(u)	mem_malloc_debug((u),__FILE__,__LINE__)
#define mem_calloc(u)	mem_calloc_debug((u),__FILE__,__LINE__)
#define mem_realloc(p,u)	mem_realloc_debug((p),(u),__FILE__,__LINE__)
#define mem_free(p)	mem_free_debug((p),__FILE__,__LINE__)

char *mem_strdup_debug	__MEM_P_LINNUX((const char *,char *,int));
void *mem_calloc_debug	__MEM_P_LINNUX((unsigned,char *,int));
void *mem_malloc_debug	__MEM_P_LINNUX((unsigned,char *,int));
void *mem_realloc_debug __MEM_P_LINNUX((void *,unsigned,char *,int));
void  mem_free_debug	__MEM_P_LINNUX((void *,char *,int));
void  mem_freefp	__MEM_P_LINNUX((void *));

void mem_setnewfileline __MEM_P_LINNUX((void *,char *,int));

#else

#define mem_freefp	mem_free
#define mem_check()
#define mem_checkptr(p)

#endif /* MEM_DEBUG */



#endif /* MEM_H */
