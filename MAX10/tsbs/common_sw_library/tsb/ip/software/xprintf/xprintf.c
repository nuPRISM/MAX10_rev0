/*------------------------------------------------------------------------/
/  Universal string handler for user console interface
/-------------------------------------------------------------------------/
/
/  Copyright (C) 2011, ChaN, all right reserved.
/
/ * This software is a free software and there is NO WARRANTY.
/ * No restriction on use. You can use, modify and redistribute it for
/   personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.
/ * Redistributions of source code must retain the above copyright notice.
/
/-------------------------------------------------------------------------*/

#include "xprintf.h"
#include <stdarg.h>

#if _USE_XFUNC_OUT
void (*xfunc_out)(unsigned char);	/* Pointer to the output stream */
int xputc_for_xsprintf (char c, char** outstr, int num_prev_chars, void (*local_xfunc_outvoid)(unsigned char));

/*----------------------------------------------*/
/* Put a character                              */
/*----------------------------------------------*/

int xputc (char c, void (*local_xfunc_out)(unsigned char))
{
	if (_CR_CRLF && (c == '\n')) xputc('\r',local_xfunc_out);		/* CR -> CRLF */

	if (local_xfunc_out) local_xfunc_out((unsigned char)c);

	if (_CR_CRLF && (c == '\n')) { return 2; }

	return 1;
}



/*----------------------------------------------*/
/* Put a null-terminated string                 */
/*----------------------------------------------*/

int xfputs_or_to_string (					/* Put a string to the specified device */
	void(*func)(unsigned char),	/* Pointer to the output function */
	const char*	str,				/* Pointer to the string */
    char** outstr
)
{
    int char_count = 0;
	while (*str)
	{
		char_count+=xputc_for_xsprintf(*str,outstr,0,func);
		str++;
	}
	return char_count;
}
int xputs (					/* Put a string to the default device */
	const char* str,				/* Pointer to the string */
	 char** outstr
)
{
   return xfputs_or_to_string(xfunc_out,str,outstr);
}

int xfputs (					/* Put a string to the specified device */
	void(*func)(unsigned char),	/* Pointer to the output function */
	const char*	str				/* Pointer to the string */
)
{
	return xfputs_or_to_string(func,str,0);
}



/*----------------------------------------------*/
/* Formatted string output                      */
/*----------------------------------------------*/
/*  xprintf("%d", 1234);			"1234"
    xprintf("%6d,%3d%%", -200, 5);	"  -200,  5%"
    xprintf("%-6u", 100);			"100   "
    xprintf("%ld", 12345678L);		"12345678"
    xprintf("%04x", 0xA3);			"00a3"
    xprintf("%08LX", 0x123ABC);		"00123ABC"
    xprintf("%016b", 0x550F);		"0101010100001111"
    xprintf("%s", "String");		"String"
    xprintf("%-4s", "abc");			"abc "
    xprintf("%4s", "abc");			" abc"
    xprintf("%c", 'a');				"a"
    xprintf("%f", 10.0);            <xprintf lacks floating point support>
*/

#define xputc_and_count(x, outstr, charcnt, local_xfunc_out) do {                                               \
	                                     if (outstr) {                                 \
                                            charcnt += xputc_for_xsprintf(x,outstr,0, local_xfunc_out); \
                                         } else {                                      \
                                            charcnt += xputc(x, local_xfunc_out);                       \
                                        };                                             \
                                    } while (0)

static
int xvprintf (
	void (*local_xfunc_out)(unsigned char),
	char** outstr,
	const char*	fmt,	/* Pointer to the format string */
	va_list arp			/* Pointer to arguments */
)
{
	unsigned int r, i, j, w, f;
	unsigned long v;
	int charcnt = 0;
	char s[16], c, d, *p;


	for (;;) {
		c = *fmt++;					/* Get a char */
		if (!c) break;				/* End of format? */
		if (c != '%') {				/* Pass through it if not a % sequense */
			xputc_and_count(c,outstr,charcnt,local_xfunc_out); continue;
		}
		f = 0;
		c = *fmt++;					/* Get first char of the sequense */
		if (c == '0') {				/* Flag: '0' padded */
			f = 1; c = *fmt++;
		} else {
			if (c == '-') {			/* Flag: left justified */
				f = 2; c = *fmt++;
			}
		}
		for (w = 0; c >= '0' && c <= '9'; c = *fmt++)	/* Minimum width */
			w = w * 10 + c - '0';
		if (c == 'l' || c == 'L') {	/* Prefix: Size is long int */
			f |= 4; c = *fmt++;
		}
		if (!c) break;				/* End of format? */
		d = c;
		if (d >= 'a') d -= 0x20;
		switch (d) {				/* Type is... */
		case 'S' :					/* String */
			p = va_arg(arp, char*);
			for (j = 0; p[j]; j++) ;
			while (!(f & 2) && j++ < w) xputc_and_count(' ',outstr,charcnt, local_xfunc_out);
			charcnt += xfputs_or_to_string(local_xfunc_out, p, outstr);
			while (j++ < w) xputc_and_count(' ',outstr,charcnt,local_xfunc_out);
			continue;
		case 'C' :					/* Character */
			xputc_and_count((char)va_arg(arp, int),outstr,charcnt, local_xfunc_out); continue;
		case 'B' :					/* Binary */
			r = 2; break;
		case 'O' :					/* Octal */
			r = 8; break;
		case 'D' :					/* Signed decimal */
		case 'U' :					/* Unsigned decimal */
			r = 10; break;
		case 'X' :					/* Hexdecimal */
			r = 16; break;
		default:					/* Unknown type (passthrough) */
			xputc_and_count(c,outstr,charcnt,local_xfunc_out); continue;
		}

		/* Get an argument and put it in numeral */
		v = (f & 4) ? va_arg(arp, long) : ((d == 'D') ? (long)va_arg(arp, int) : (long)va_arg(arp, unsigned int));
		if (d == 'D' && (v & 0x80000000)) {
			v = 0 - v;
			f |= 8;
		}
		i = 0;
		do {
			d = (char)(v % r); v /= r;
			if (d > 9) d += (c == 'x') ? 0x27 : 0x07;
			s[i++] = d + '0';
		} while (v && i < sizeof(s));
		if (f & 8) s[i++] = '-';
		j = i; d = (f & 1) ? '0' : ' ';
		while (!(f & 2) && j++ < w) xputc_and_count(d,outstr,charcnt, local_xfunc_out);
		do xputc_and_count(s[--i],outstr,charcnt, local_xfunc_out); while(i);
		while (j++ < w) xputc_and_count(' ',outstr,charcnt, local_xfunc_out);
	}
	return charcnt;
}


int xprintf (			/* Put a formatted string to the default device */
	const char*	fmt,	/* Pointer to the format string */
	...					/* Optional arguments */
)
{
	int charcnt;
	va_list arp;


	va_start(arp, fmt);
	charcnt = xvprintf(xfunc_out,0,fmt, arp);
	va_end(arp);
	return charcnt;
}


/*----------------------------------------------*/
/* Put a character                              */
/*----------------------------------------------*/

int xputc_for_xsprintf (char c, char** outstr, int num_prev_chars, void (*local_xfunc_out)(unsigned char))
{

	
	if (outstr) {
		/* for xsprintf */
	    if (*outstr) {
	     if (_CR_CRLF && (c == '\n')) {
	       	xputc_for_xsprintf('\r',outstr, num_prev_chars + 1, local_xfunc_out);
	       	num_prev_chars = num_prev_chars + 1;
	       }
		 *(*outstr) = (unsigned char)c;
		 (*outstr) = (*outstr) + 1;
		 return (num_prev_chars + 1);
		}
	} else {
		/* for xprintf */
	    return (num_prev_chars + xputc(c, local_xfunc_out)) ;
	}
	return num_prev_chars;
}

int xsprintf (			/* Put a formatted string to the memory */
	char* buff,			/* Pointer to the output buffer */
	const char*	fmt,	/* Pointer to the format string */
	...					/* Optional arguments */
)
{
	int charcnt;
	va_list arp;

    char *outstr;
	outstr = buff;		/* Switch destination for memory */

	va_start(arp, fmt);
	charcnt = xvprintf(xfunc_out,&outstr,fmt, arp);
	va_end(arp);

	*outstr = 0;		/* Terminate output string with a \0 */
	return charcnt;

}


int xfprintf (					/* Put a formatted string to the specified device */
	void(*func)(unsigned char),	/* Pointer to the output function */
	const char*	fmt,			/* Pointer to the format string */
	...							/* Optional arguments */
)
{
	int charcnt;
	va_list arp;

	va_start(arp, fmt);
	charcnt = xvprintf(func,0,fmt, arp);
	va_end(arp);

	return charcnt;
}



/*----------------------------------------------*/
/* Dump a line of binary dump                   */
/*----------------------------------------------*/

void put_dump (
	const void* buff,		/* Pointer to the array to be dumped */
	unsigned long addr,		/* Heading address value */
	int len,				/* Number of items to be dumped */
	int width				/* Size of the items (DF_CHAR, DF_SHORT, DF_LONG) */
)
{
	int i;
	const unsigned char *bp;
	const unsigned short *sp;
	const unsigned long *lp;


	xprintf("%08lX ", addr);		/* address */

	switch (width) {
	case DW_CHAR:
		bp = buff;
		for (i = 0; i < len; i++)		/* Hexdecimal dump */
			xprintf(" %02X", bp[i]);
		xputc(' ',xfunc_out);
		for (i = 0; i < len; i++)		/* ASCII dump */
			xputc((bp[i] >= ' ' && bp[i] <= '~') ? bp[i] : '.', xfunc_out);
		break;
	case DW_SHORT:
		sp = buff;
		do								/* Hexdecimal dump */
			xprintf(" %04X", *sp++);
		while (--len);
		break;
	case DW_LONG:
		lp = buff;
		do								/* Hexdecimal dump */
			xprintf(" %08LX", *lp++);
		while (--len);
		break;
	}

	xputc('\n', xfunc_out);
}

#endif /* _USE_XFUNC_OUT */



#if _USE_XFUNC_IN
unsigned char (*xfunc_in)(void);	/* Pointer to the input stream */

/*----------------------------------------------*/
/* Get a line from the input                    */
/*----------------------------------------------*/

int xfgets (	/* 0:End of stream, 1:A line arrived */
	unsigned char (*local_xfunc_in)(void),	/* Pointer to the input stream function */
	void (*local_xfunc_out)(unsigned char),
	char* buff,	/* Pointer to the buffer */
	int len		/* Buffer length */
)
{
	int c, i;


		if (!local_xfunc_in) return 0;		/* No input function specified */

		i = 0;
		for (;;) {
			c = local_xfunc_in();				/* Get a char from the incoming stream */
			if (!c) return 0;			/* End of stream? */
			if ((c == '\r') && !(IGNORE_CARRIAGE_RETURN_ON_INPUT)) break;		/* End of line? */
			if (c == '\n') break;		/* End of line? */
			if (c == '\b' && i) {		/* Back space? */
				i--;
				if (_LINE_ECHO) xputc(c, local_xfunc_out);
				continue;
			}
			if (c >= ' ' && i < len - 1) {	/* Visible chars */
				buff[i++] = c;
				if (_LINE_ECHO) xputc(c, local_xfunc_out);
			}
		}
		buff[i] = 0;	/* Terminate with a \0 */
		if (_LINE_ECHO) xputc('\n', local_xfunc_out);
		return 1;
}

int xgets (		/* 0:End of stream, 1:A line arrived */
	char* buff,	/* Pointer to the buffer */
	int len		/* Buffer length */
)
{
	return xfgets(xfunc_in,xfunc_out,buff,len);
}
/*----------------------------------------------*/
/* Get a value of the string                    */
/*----------------------------------------------*/
/*	"123 -5   0x3ff 0b1111 0377  w "
	    ^                           1st call returns 123 and next ptr
	       ^                        2nd call returns -5 and next ptr
                   ^                3rd call returns 1023 and next ptr
                          ^         4th call returns 15 and next ptr
                               ^    5th call returns 255 and next ptr
                                  ^ 6th call fails and returns 0
*/

int xatoi (			/* 0:Failed, 1:Successful */
	char **str,		/* Pointer to pointer to the string */
	long *res		/* Pointer to the valiable to store the value */
)
{
	unsigned long val;
	unsigned char c, r, s = 0;


	*res = 0;

	while ((c = **str) == ' ') (*str)++;	/* Skip leading spaces */

	if (c == '-') {		/* negative? */
		s = 1;
		c = *(++(*str));
	}

	if (c == '0') {
		c = *(++(*str));
		switch (c) {
		case 'x':		/* hexdecimal */
			r = 16; c = *(++(*str));
			break;
		case 'b':		/* binary */
			r = 2; c = *(++(*str));
			break;
		default:
			if (c <= ' ') return 1;	/* single zero */
			if (c < '0' || c > '9') return 0;	/* invalid char */
			r = 8;		/* octal */
		}
	} else {
		if (c < '0' || c > '9') return 0;	/* EOL or invalid char */
		r = 10;			/* decimal */
	}

	val = 0;
	while (c > ' ') {
		if (c >= 'a') c -= 0x20;
		c -= '0';
		if (c >= 17) {
			c -= 7;
			if (c <= 9) return 0;	/* invalid char */
		}
		if (c >= r) return 0;		/* invalid char for current radix */
		val = val * r + c;
		c = *(++(*str));
	}
	if (s) val = 0 - val;			/* apply sign if needed */

	*res = val;
	return 1;
}

#endif /* _USE_XFUNC_IN */
