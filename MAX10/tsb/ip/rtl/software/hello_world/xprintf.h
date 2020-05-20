/*------------------------------------------------------------------------*/
/* Universal string handler for user console interface  (C)ChaN, 2011     */
/*------------------------------------------------------------------------*/

#ifndef _STRFUNC
#define _STRFUNC
#ifdef __cplusplus
extern "C" {
#endif

#define _USE_XFUNC_OUT	1	/* 1: Use output functions */

#ifndef _CR_CRLF
#define	_CR_CRLF		1	/* 1: Convert \n ==> \r\n in the output char */
#endif

#ifndef IGNORE_CARRIAGE_RETURN_ON_INPUT
#define IGNORE_CARRIAGE_RETURN_ON_INPUT 0
#endif

#define _USE_XFUNC_IN	1	/* 1: Use input function */
#define	_LINE_ECHO		0	/* 1: Echo back input chars in xgets function */


#if _USE_XFUNC_OUT
#define xdev_out(func) xfunc_out = (void(*)(unsigned char))(func)
void (*xfunc_out)(unsigned char);
int xputc (char c, void (*local_xfunc_out)(unsigned char));
int xputs (const char* str, char** outstr);
int xfputs (void (*func)(unsigned char), const char* str);
int xprintf (const char* fmt, ...);
int xsprintf (char* buff, const char* fmt, ...);
int xfprintf (void (*func)(unsigned char),  const char*	fmt, ...);
void put_dump (const void* buff, unsigned long addr, int len, int width);
#define DW_CHAR		sizeof(char)
#define DW_SHORT	sizeof(short)
#define DW_LONG		sizeof(long)
#endif

#if _USE_XFUNC_IN
#define xdev_in(func) xfunc_in = (unsigned char(*)(void))(func)
unsigned char (*xfunc_in)(void);
int xgets (char* buff, int len);
int xfgets (unsigned char (*local_xfunc_in)(void), void (*local_xfunc_out)(unsigned char), char* buff, int len);
int xatoi (char** str, long* res);
#endif

#ifdef __cplusplus
}
#endif

#endif
