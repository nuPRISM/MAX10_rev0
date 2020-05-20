/*
**  This is a copyrighted work which is functionally identical to work
**  originally published in Micro Cornucopia magazine (issue #52, March-April,
**  1990) and is freely licensed by the author, Walter Bright, for any use.
*/

/*_ mem.c   Fri Jan 26 1990   Modified by: Walter Bright */
/* $Header: /proj/products/merlin/port/RCS/mem.c,v 1.19 89/10/20 14:36:02 bright Exp Locker: bright $ */
/* Memory management package				*/

#define USE_LINNUX_NIOS_IMPLEMENTATION_ALIGNMENT (1)

#if defined(VAX11C)
#define  __FILE__  "mem.c"
#endif

#include	<stdio.h>
#include	<stdlib.h>
#include	<io.h>

#ifndef MEM_H
#include	"mem.h"
#endif

#ifndef assert
#include	<assert.h>
#endif

#if defined(_MSC_VER)
#include	<dos.h>
#endif

#if !defined(VAX11C)
#ifdef BSDUNIX
#include <strings.h>
#else
#include <string.h>
#endif
#else
extern char *strcpy(),*memmove();
extern int strlen();
#endif  /* VAX11C */
#include "my_mem_defs.h"
#include "includes.h"
#include "ucos_ii.h"
#include "cpp_to_c_header_interface.h"
#include "basedef.h"

int mem_inited = 0;		/* != 0 if initialized			*/

extern int memory_error_inform_only;
static int mem_behavior = MEM_ABORTMSG;
static int (*fp)() = NULL;	/* out-of-memory handler	*/
static int mem_count;		/* # of allocs that haven't been free'd	*/
static int mem_scount;		/* # of sallocs that haven't been free'd */
static int mem_exception(); /* called when out of memory */

/* Determine where to send error messages	*/
#ifdef MSDOS
#define ferr	stdout	/* stderr can't be redirected with MS-DOS	*/
#else
#define ferr	stderr
#endif

/*******************************/

void mem_setexception(int flag,int (*handler_fp)())
{
    mem_behavior = flag;
    fp = (mem_behavior == MEM_CALLFP) ? handler_fp : 0;
#if MEM_DEBUG
    assert(0 <= flag && flag <= MEM_RETRY);
#endif
}

/*************************
 * This is called when we're out of memory.
 * Returns:
 *	1:	try again to allocate the memory
 *	0:	give up and return NULL
 */

static int mem_exception()
{   int behavior;

    behavior = mem_behavior;
    while (1)
    {
	switch (behavior)
	{
	    case MEM_ABORTMSG:
#if defined(MSDOS) || defined(__OS2__)
		/* Avoid linking in buffered I/O */
	    {	static char msg[] = "Fatal error: out of memory\r\n";

		write(1,msg,sizeof(msg) - 1);
	    }
#else
		fputs("Fatal error: out of memory\n",ferr);
#endif
		/* FALL-THROUGH */
	    case MEM_ABORT:
		exit(EXIT_FAILURE);
		/* NOTREACHED */
	    case MEM_CALLFP:
		assert(fp);
		behavior = (*fp)();
		break;
	    case MEM_RETNULL:
		return 0;
	    case MEM_RETRY:
		return 1;
	    default:
		assert(0);
	}
    }
    return 0;
}

/****************************/

#if MEM_DEBUG

#undef mem_strdup

char *mem_strdup(s)
const char *s;
{
	return mem_strdup_debug(s,__FILE__,__LINE__);
}

char *mem_strdup_debug(s,file,line)
char *file;
const char *s;
int line;
{
	char *p;

	p = s
	    ? (char *) mem_malloc_debug((unsigned) strlen(s) + 1,file,line)
	    : NULL;
	return p ? strcpy(p,s) : p;
}
#else
char *mem_strdup(s)
const char *s;
{
	char *p;

	p = s ? (char *) mem_malloc((unsigned) strlen(s) + 1) : NULL;
	return p ? strcpy(p,s) : p;
}

#endif /* MEM_DEBUG */

#if MEM_DEBUG

static long mem_maxalloc;	/* max # of bytes allocated		*/
static long mem_numalloc;	/* current # of bytes allocated		*/

#define BEFOREVAL	0x12345678	/* value to detect underrun	*/
#define AFTERVAL	0xABCDEF93	/* value to detect overrun	*/

#if SUN || USE_LINNUX_NIOS_IMPLEMENTATION_ALIGNMENT
static long afterval = AFTERVAL;	/* so we can do &afterval	*/
#endif

/* The following should be selected to give maximum probability that	*/
/* pointers loaded with these values will cause an obvious crash. On	*/
/* Unix machines, a large value will cause a segment fault.		*/
/* MALLOCVAL is the value to set malloc'd data to.			*/

#if MSDOS || __OS2__
#define BADVAL		0xFF
#define MALLOCVAL	0xEE
#else
#define BADVAL		0x7A
#define MALLOCVAL	0xEE
#endif

/* Disable mapping macros	*/
#undef	mem_malloc
#undef	mem_calloc
#undef	mem_realloc
#undef	mem_free

/* Create a list of all alloc'ed pointers, retaining info about where	*/
/* each alloc came from. This is a real memory and speed hog, but who	*/
/* cares when you've got obscure pointer bugs.				*/

//#define LINNUX_USE_ADDITIONAL_MEM_PADDING

#ifdef LINNUX_USE_ADDITIONAL_MEM_PADDING
		#ifdef USE_A_LOT_OF_PADDING_FOR_MEM
		#define ADDITIONAL_PRE_NUMCHARS 64
		#define bedrock_ADDITIONAL_PRE_CHARS "ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()+abcdefghijklmnopqrstuvwxyz\0"
		char *ADDITIONAL_PRE_CHARS     =  bedrock_ADDITIONAL_PRE_CHARS;
		#define ADDITIONAL_BEFORE_NUMCHARS 64
		#define bedrock_ADDITIONAL_BEFORE_CHARS "AbCdEfGhIjKlMnOpQrStUvWxYz!@#$%^&*()+aBcDeFgHiJkLmNoPqRsTuVwXyz\0"
		char *ADDITIONAL_BEFORE_CHARS  =  bedrock_ADDITIONAL_BEFORE_CHARS;
		#else
		#define ADDITIONAL_PRE_NUMCHARS 4
		#define bedrock_ADDITIONAL_PRE_CHARS "qRsT"
		char *ADDITIONAL_PRE_CHARS     =  bedrock_ADDITIONAL_PRE_CHARS;
		#define ADDITIONAL_BEFORE_NUMCHARS 4
		#define bedrock_ADDITIONAL_BEFORE_CHARS "UvWx"
		char *ADDITIONAL_BEFORE_CHARS  =  bedrock_ADDITIONAL_BEFORE_CHARS;
		#endif
#endif

static struct mem_debug
{	struct mh
	{
#ifdef LINNUX_USE_ADDITIONAL_MEM_PADDING
	  char pre_protection[ADDITIONAL_PRE_NUMCHARS];
#endif
	//  unsigned pre_more_protect[8];
	  struct mem_debug *Mnext;	/* next in list			*/
	  struct mem_debug *Mprev;	/* previous value in list	*/
	  char *Mfile;		/* filename of where allocated		*/
	  int Mline;		/* line number of where allocated	*/
	  unsigned Mtimestamp;
	  unsigned Mprocessid;
	  unsigned Mnbytes;	/* size of the allocation		*/
#ifdef LINNUX_USE_ADDITIONAL_MEM_PADDING
	  char additiona_before_protection[ADDITIONAL_BEFORE_NUMCHARS];
#endif
	//  unsigned additional_more_protect[8];
	  long Mbeforeval;	/* detect underrun of data		*/
	} m;
	char data[1];		/* the data actually allocated		*/
} mem_alloclist =
{
   {
	//	   {0x11111111,0x22222222,0x33333333,0x44444444,0x55555555,0x66666666,0x77777777,0x88888888},
#ifdef LINNUX_USE_ADDITIONAL_MEM_PADDING
    {'\0','\0','\0','\0'},
#endif
    (struct mem_debug *) NULL,
	(struct mem_debug *) NULL,
	"noname",
	11111,
	0,
	0,
	0,
#ifdef LINNUX_USE_ADDITIONAL_MEM_PADDING
	{'\0','\0','\0','\0'},
#endif
	//{0x99999999,0xAAAAAAAA,0xBBBBBBBB,0xCCCCCCCC,0xDDDDDDDD,0xEEEEEEEE,0xFFFFFFFF,0x01928374},
	BEFOREVAL
   },
   AFTERVAL
};

/* Convert from a void *to a mem_debug struct.	*/
#define mem_ptrtodl(p)	((struct mem_debug *) ((char *)p - sizeof(struct mh)))

/* Convert from a mem_debug struct to a mem_ptr.	*/
#define mem_dltoptr(dl)	((void *) &((dl)->data[0]))

#define next		m.Mnext
#define prev		m.Mprev
#define file		m.Mfile
#define line		m.Mline
#define nbytes		m.Mnbytes
#define timestamp   m.Mtimestamp
#define beforeval	m.Mbeforeval
#define process     m.Mprocessid

/*****************************
 * Set new value of file,line
 */

void mem_setnewfileline(ptr,fil,lin)
void *ptr;
char *fil;
int lin;
{
    struct mem_debug *dl;
    get_mem_access_semaphore();
    dl = mem_ptrtodl(ptr);
    dl->file = fil;
    dl->line = lin;
    release_mem_access_semaphore();
}

/****************************
 * Print out struct mem_debug.
 */

static void mem_printdl(struct mem_debug *dl)
{
#if LPTR
	safe_print(fprintf(ferr,"alloc'd from file '%s' line %d nbytes %d ptr x%lx\n",
		dl->file,dl->line,dl->nbytes,mem_dltoptr(dl)));
#else
	safe_print(fprintf(ferr,"alloc'd from file '%s' line %d nbytes %d timestamp %u process %u, ptr x%x\n",
		dl->file,dl->line,dl->nbytes,dl->timestamp, dl->process, (unsigned int) (mem_dltoptr(dl))));
#endif
}

/****************************
 * Print out file and line number.
 */

static void mem_fillin(char *fil,
int lin)
{
	safe_print(fprintf(ferr,"File '%s' line %d\n",fil,lin));
	fflush(ferr);
}

/****************************
 * If MEM_DEBUG is not on for some modules, these routines will get
 * called.
 */

void *mem_calloc(u)
unsigned u;
{
     	return mem_calloc_debug(u,__FILE__,__LINE__);
}

void *mem_malloc(u)
unsigned u;
{
     	return mem_malloc_debug(u,__FILE__,__LINE__);
}

void *mem_realloc(p,u)
void *p;
unsigned u;
{
     	return mem_realloc_debug(p,u,__FILE__,__LINE__);
}

void mem_free(p)
void *p;
{
	mem_free_debug(p,__FILE__,__LINE__);
}    


/**************************/

void mem_freefp(p)
void *p;
{
	mem_free(p);
}

/***********************
 * Debug versions of mem_calloc(), mem_free() and mem_realloc().
 */

void *mem_malloc_debug(n,fil,lin)
unsigned n;
char *fil;
int lin;
{   void *p;

    p = mem_calloc_debug(n,fil,lin);
    if (p) {
	   memset(p,MALLOCVAL,n);
    }
    return p;
}

void *mem_calloc_debug(n,fil,lin)
unsigned n;
char *fil;
int lin;
{
	unsigned int the_timestamp = os_critical_c_low_level_system_timestamp_in_secs();
	if (n<=0) {
		n = 1; //since here we always allocate more data, then ensure at least 1 byte is allocated
		printf("\n\n\n\n=================mem_calloc_debug: called with n = %d, file = %s, line = %d\n\n\n\n==================\n",n,fil,lin);
	}

#ifdef LINNUX_MEMC_ALWAYS_MAKE_ALIGNED_ALLOCATIONS
   	  int addition_to_n = 0;
       addition_to_n = 4-((n & 0x3));
	   if (addition_to_n == 4) {
		   addition_to_n = 0;
	   }
	   n = n + addition_to_n;
#endif
	struct mem_debug *dl;

    do {
    	TaskUserData[OSTCBCur->OSTCBPrio].in_my_malloc_op = 1;
	dl = (struct mem_debug *)
	    calloc(sizeof(*dl) + n + sizeof(afterval) - 1,1);
	    TaskUserData[OSTCBCur->OSTCBPrio].in_my_malloc_op = 0;
    }
    while (dl == NULL && mem_exception());
    if (dl == NULL)
    {
#if 0
	printf("Insufficient memory for alloc of %d at ",n);
	mem_fillin(fil,lin);
	printf("Max allocated was: %ld\n",mem_maxalloc);
#endif
	return NULL;
    }
    dl->file = fil;
    dl->line = lin;
    dl->nbytes = n;
    dl->timestamp = (unsigned int) the_timestamp;
    dl->process = (unsigned int) OSTCBCur->OSTCBPrio;
    dl->beforeval = BEFOREVAL;
#if SUN || USE_LINNUX_NIOS_IMPLEMENTATION_ALIGNMENT /* bus error if we store a long at an odd address */
    memmove(&(dl->data[n]),&afterval,sizeof(afterval));
#else
    *(long *) &(dl->data[n]) = AFTERVAL;
#endif
#ifdef LINNUX_USE_ADDITIONAL_MEM_PADDING

	memmove(&(dl->m.pre_protection[0]),ADDITIONAL_PRE_CHARS,ADDITIONAL_PRE_NUMCHARS);
	memmove(&(dl->m.additiona_before_protection[0]),ADDITIONAL_BEFORE_CHARS,ADDITIONAL_BEFORE_NUMCHARS);
#endif
    get_mem_access_semaphore();

    /* Add dl to start of allocation list	*/
    dl->next = mem_alloclist.next;
    dl->prev = &mem_alloclist;
    mem_alloclist.next = dl;
    if (dl->next != NULL) {
	  dl->next->prev = dl;
    }
    mem_count++;
    mem_numalloc += n;

    if (mem_numalloc > mem_maxalloc) {
	   mem_maxalloc = mem_numalloc;
    }

	release_mem_access_semaphore();
    return mem_dltoptr(dl);
}

void mem_free_debug(ptr,fil,lin)
void *ptr;
char *fil;
int lin;
{
	struct mem_debug *dl;

	if (ptr == NULL)
	{
		return;
	}
#if 0
	{	safe_print(fprintf(ferr,"Freeing NULL pointer at "));
		goto err;
	}
#endif
	if (mem_count <= 0)
	{	fprintf(ferr,"More frees than allocs at ");
		goto err;
	}
	dl = mem_ptrtodl(ptr);
	if (dl->beforeval != BEFOREVAL)
	{
#if LPTR
		safe_print(fprintf(ferr,"Pointer x%x underrun dl->nbytes = %d, &dl->nbytes = %x current_data: %x expected: %x curprocess: %u allocprocess: %u alloctime: %u\n",
	    		(unsigned int) ptr,dl->nbytes,(unsigned int)&dl->data[dl->nbytes],(unsigned int) dl->data[dl->nbytes],(unsigned int)afterval,
	    		(unsigned int) OSTCBCur->OSTCBPrio, (unsigned int) dl->process, (unsigned int) dl->timestamp));
#else
		safe_print(fprintf(ferr,"Pointer x%x underrun dl->nbytes = %d, &dl->nbytes = %x current_data: %x expected: %x curprocess: %u allocprocess: %u alloctime: %u\n",
	    		(unsigned int) ptr,dl->nbytes,
	    		(unsigned int)&dl->data[dl->nbytes],
	    		(unsigned int) dl->beforeval,
	    		(unsigned int)BEFOREVAL,
	    		(unsigned int) OSTCBCur->OSTCBPrio,
	    		(unsigned int) dl->process,
	    		(unsigned int) dl->timestamp));
#endif
		if (!memory_error_inform_only) {
			goto err2;
		}
	}
#if SUN || USE_LINNUX_NIOS_IMPLEMENTATION_ALIGNMENT /* Bus error if we read a long from an odd address	*/
	if (memcmp(&dl->data[dl->nbytes],&afterval,sizeof(afterval)) != 0)
#else
	if (*(long *) &dl->data[dl->nbytes] != AFTERVAL)
#endif
	{
#if LPTR
		safe_print(fprintf(ferr,"Pointer x%lx overrun\n",ptr));
#else
		safe_print(fprintf(ferr,"Pointer x%x overrun dl->nbytes = %d, &dl->nbytes = %x current_data: %x expected: %x curprocess: %u allocprocess: %u alloctime: %u\n",
	    		(unsigned int) ptr,
	    		dl->nbytes,
	    		(unsigned int)&dl->data[dl->nbytes],
	    		(unsigned int) dl->data[dl->nbytes],
	    		(unsigned int)afterval,
	    		(unsigned int) OSTCBCur->OSTCBPrio,
	    		(unsigned int) dl->process,
	    		(unsigned int) dl->timestamp)
				);
#endif
		if (!memory_error_inform_only) {
			 goto err2;
		}
	}
	mem_numalloc -= dl->nbytes;
	if (mem_numalloc < 0)
	{	safe_print(fprintf(ferr,"error: mem_numalloc = %ld, dl->nbytes = %d\n",mem_numalloc,dl->nbytes));
	    if (!memory_error_inform_only) {
		   goto err2;
	    }
	}
	get_mem_access_semaphore();

	/* Remove dl from linked list	*/
	if (dl->prev){
		dl->prev->next = dl->next;
	}

	if (dl->next){
		dl->next->prev = dl->prev;
	}
	mem_count--;

	release_mem_access_semaphore();

	/* Stomp on the freed storage to help detect references	*/
	/* after the storage was freed.				*/
	memset((void *) dl,BADVAL,sizeof(*dl) + dl->nbytes);

	/* Some compilers can detect errors in the heap.	*/
#if defined(DLC)
	{	int i;
		i = free(dl);
		assert(i == 0);
	}
#else
	TaskUserData[OSTCBCur->OSTCBPrio].in_my_malloc_op = 1;
	free((void *) dl);
	TaskUserData[OSTCBCur->OSTCBPrio].in_my_malloc_op = 0;
#endif
	return;

err2:
	mem_printdl(dl);
err:
	safe_print(fprintf(ferr,"free'd from "));
	mem_fillin(fil,lin);
	/* assert(0); */
	/* NOTREACHED */
}

/*******************
 * Debug version of mem_realloc().
 */

void *mem_realloc_debug(oldp,n,fil,lin)
void *oldp;
unsigned n;
char *fil;
int lin;
{
	void *p;
    struct mem_debug *dl;

    if (n == 0)
    {	mem_free_debug(oldp,fil,lin);
	p = NULL;
    }
    else if (oldp == NULL) {
	   p = mem_malloc_debug(n,fil,lin);
    }
    else
    {
  	  p = mem_malloc_debug(n,fil,lin);
      if (p != NULL)
      {
        dl = mem_ptrtodl(oldp);
	    if (dl->nbytes < n)
		n = dl->nbytes;
	    memmove(p,oldp,n);
	    mem_free_debug(oldp,fil,lin);
	  }
    }
    return p;
}

/***************************/

void mem_check()
{   register struct mem_debug *dl;
    get_mem_access_semaphore();
    for (dl = mem_alloclist.next; dl != NULL; dl = dl->next)
	    mem_checkptr(mem_dltoptr(dl),1);
    release_mem_access_semaphore();
}

/***************************/

void mem_checkptr(p,mem_check_inform_only)
register void *p;
int mem_check_inform_only;
{   register struct mem_debug *dl;

    for (dl = mem_alloclist.next; dl != NULL; dl = dl->next)
    {
	if (p >= (void *) &(dl->data[0]) &&
	    p < (void *)((char *)dl + sizeof(struct mem_debug)-1 + dl->nbytes))
	    goto L1;
    }
    assert(0);

L1:
    dl = mem_ptrtodl(p);
    if (dl->beforeval != BEFOREVAL)
    {
#if LPTR
	    safe_print(fprintf(ferr,"Pointer x%lx underrun\n",p));
#else
	    safe_print(fprintf(ferr,"Pointer x%x underrun dl->nbytes = %d, &dl->nbytes = %x beforeval: %x expected beforeval: %x curprocess: %u allocprocess: %u alloctime: %u\n",
	    		(unsigned int) p,dl->nbytes,(unsigned int)&dl->data[dl->nbytes],(unsigned int) dl->beforeval,(unsigned int)BEFOREVAL,
	    		(unsigned int) OSTCBCur->OSTCBPrio, (unsigned int) dl->process, (unsigned int) dl->timestamp));
#endif
	    if (!mem_check_inform_only) {
	    	goto err2;
	    }
    }
#if SUN || USE_LINNUX_NIOS_IMPLEMENTATION_ALIGNMENT /* Bus error if we read a long from an odd address	*/
    if (memcmp(&dl->data[dl->nbytes],&afterval,sizeof(afterval)) != 0)
#else
    if (*(long *) &dl->data[dl->nbytes] != AFTERVAL)
#endif
    {
#if LPTR
	    safe_print(fprintf(ferr,"Pointer x%lx overrun\n",p));
#else
	    safe_print(fprintf(ferr,"Pointer x%x overrun dl->nbytes = %d, &dl->nbytes = %x current_data: %x expected: %x curprocess: %u allocprocess: %u alloctime: %u\n",
	    		(unsigned int) p,dl->nbytes,(unsigned int)&dl->data[dl->nbytes],(unsigned int) dl->data[dl->nbytes],(unsigned int)afterval,
	    		(unsigned int) OSTCBCur->OSTCBPrio, (unsigned int) dl->process, (unsigned int) dl->timestamp));

#endif
	    if (!mem_check_inform_only) {
	    	goto err2;
	    }
    }
    return;

err2:
    mem_printdl(dl);
    assert(0);
}

#else

/***************************/

void *mem_malloc(numbytes)
unsigned numbytes;
{	void *p;

	if (numbytes == 0)
		return NULL;
	while (1)
	{
		p = malloc(numbytes);
		if (p == NULL)
		{	if (mem_exception())
				continue;
		}
		else
			mem_count++;
		break;
	}
	/*printf("malloc(%d) = x%lx\n",numbytes,p);*/
	return p;
}

/***************************/

void *mem_calloc(numbytes)
unsigned numbytes;
{	void *p;

	if (numbytes == 0)
		return NULL;
	while (1)
	{
		p = calloc(numbytes,1);
		if (p == NULL)
		{	if (mem_exception())
				continue;
		}
		else
			mem_count++;
		break;
	}
	/*printf("calloc(%d) = x%lx\n",numbytes,p);*/
	return p;
}

/***************************/

void *mem_realloc(oldmem_ptr,newnumbytes)
void *oldmem_ptr;
unsigned newnumbytes;
{   void *p;

    if (oldmem_ptr == NULL)
	p = mem_malloc(newnumbytes);
    else if (newnumbytes == 0)
    {	mem_free(oldmem_ptr);
	p = NULL;
    }
    else
    {
	do
	    p = realloc(oldmem_ptr,newnumbytes);
	while (p == NULL && mem_exception());
    }
    /*printf("realloc(x%lx,%d) = x%lx\n",oldmem_ptr,newnumbytes,p);*/
    return p;
}

/***************************/

void mem_free(ptr)
void *ptr;
{
    /*printf("free(x%lx)\n",ptr);*/
    if (ptr != NULL)
    {	assert(mem_count > 0);
	mem_count--;
#if DLC
	{	int i;

		i = free(ptr);
		assert(i == 0);
	}
#else
	free(ptr);
#endif
    }
}

#endif /* MEM_DEBUG */

/***************************/

void mem_init()
{
	get_mem_access_semaphore();
	//memmove(&mem_alloclist.m.pre_protection,ADDITIONAL_PRE_CHARS,ADDITIONAL_PRE_NUMCHARS);
	//memmove(&mem_alloclist.m.additiona_before_protection,ADDITIONAL_BEFORE_CHARS,ADDITIONAL_BEFORE_NUMCHARS);
	//xsprintf(mem_alloclist.m.pre_protection,"%s",ADDITIONAL_PRE_CHARS);
	//xsprintf(mem_alloclist.m.additiona_before_protection,"%s",ADDITIONAL_BEFORE_NUMCHARS);

	if (mem_inited == 0)
	{	mem_count = 0;
#if MEM_DEBUG
		mem_numalloc = 0;
		mem_maxalloc = 0;
		mem_alloclist.next = NULL;
#endif
#if defined(__ZTC__) || defined(__SC__)
		/* Necessary if mem_sfree() calls free() before any	*/
		/* calls to malloc().					*/
		free(malloc(1));	/* initialize storage allocator	*/
#endif
		mem_inited++;
	}
	release_mem_access_semaphore();
}

/***************************/

void mem_term()
{
	get_mem_access_semaphore();
	if (mem_inited)
	{
#if MEM_DEBUG
		register struct mem_debug *dl;

		for (dl = mem_alloclist.next; dl; dl = dl->next)
		{	safe_print(fprintf(ferr,"Unfreed pointer: "));
			mem_printdl(dl);
		}
#if 0
		safe_print(fprintf(ferr,"Max amount ever allocated == %ld bytes\n",
			mem_maxalloc));
#endif
#else
		if (mem_count)
			safe_print(fprintf(ferr,"%d unfreed items\n",mem_count));
		if (mem_scount)
			safe_print(fprintf(ferr,"%d unfreed s items\n",mem_scount));
#endif /* MEM_DEBUG */
		assert(mem_count == 0 && mem_scount == 0);
		mem_inited = 0;
	}
	release_mem_access_semaphore();
}



mem_reporting_structure_type mem_display(int verbose)
{
	long temp_mem_numalloc = -1;
	get_mem_access_semaphore();
	mem_reporting_structure_type return_val;
	if (mem_inited)
	{
#if MEM_DEBUG
		register struct mem_debug *dl;
		safe_print(printf("Malloc Memory Summary\n"));
		safe_print(printf("===================================\n"));
		safe_print(printf("%ld Total bytes Allocated:\n",mem_numalloc));
		safe_print(printf("%ld Total Max bytes Allocated:\n",mem_maxalloc));
		temp_mem_numalloc = mem_numalloc;
		if (verbose) {
				printf("%d unfreed items, as follows\n",mem_count);
				printf("===================================\n");

				for (dl = mem_alloclist.next; dl; dl = dl->next)
				{
					safe_print(fprintf(ferr,"Unfreed pointer: "));
					mem_printdl(dl);
				}
		}
#endif /* MEM_DEBUG */
	} else {
		safe_print(printf("mem_display: error: memory handler not initialized\n"));
	}
	release_mem_access_semaphore();
#if MEM_DEBUG

	return_val.current_alloc = mem_numalloc;
	return_val.max_alloc = mem_maxalloc;
#else
	return_val.current_alloc = 0;
	return_val.max_alloc = 0;
#endif
	return return_val;
}
#undef next
#undef prev
#undef file
#undef line
#undef nbytes
#undef beforeval

