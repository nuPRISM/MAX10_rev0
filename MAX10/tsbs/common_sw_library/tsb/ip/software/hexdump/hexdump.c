#include <ctype.h>
#include "xprintf.h"
 
#ifndef HEXDUMP_COLS
#define HEXDUMP_COLS 8
#endif
 

unsigned int hexdump_raw_to_string(void *mem, unsigned int len, char* result_str) {
	 unsigned int i;
	 char* orig_result_str = result_str;
	  for(i = 0; i < len; i++)
	  {
        result_str+=xsprintf(result_str,((i < (len-1)) ? "%02x " : "%02x"), 0xFF & ((char*)mem)[i]);
	  }
	  return (((unsigned int) result_str) - ((unsigned int) orig_result_str));
}



void hexdump_to_comment_var_length(void *mem, unsigned int len, int do_raw_printout, int print_to_comment, char* comment_str, unsigned int hexdump_cols)
{

        unsigned int i, j;
	        print_to_comment = print_to_comment || (!comment_str);
	        	if (print_to_comment) {
	        		xprintf("%s",comment_str);
	        	}
	        unsigned int upper_loop_limit;
	        upper_loop_limit = len + ((len % hexdump_cols) ? (hexdump_cols - (len % hexdump_cols)): 0);
	        for(i = 0; i < upper_loop_limit ; i++)
	        {
				if (!do_raw_printout) {
					/* print offset */
					if(i % hexdump_cols == 0)
					{
							xprintf("0x%06x: ", i);
					}
				}
                /* print hex data */
                if(i < len)
                {
                        xprintf("%02x ", 0xFF & ((char*)mem)[i]);
                }
                else /* end of block, just aligning for ASCII dump */
                {
                        xprintf("   ");
                }
                
				if (!do_raw_printout) {
                /* print ASCII dump */
                if((i % hexdump_cols) == (hexdump_cols - 1))
                {
                        for(j = i - (hexdump_cols - 1); j <= i; j++)
                        {
                                if(j >= len) /* end of block, not really printing */
                                {
													xprintf(" ");
                                }
                                else if(isprint(((char*)mem)[j])) /* printable char */
                                {
                                	xprintf("%c",0xFF & ((char*)mem)[j]);
                                }
                                else /* other char */
                                {
												xprintf(".");
                                }
                        }
									xprintf("\n");
									if (print_to_comment) {
									 		xprintf("%s",comment_str);
								    }
                }
			}
        }
	        if (do_raw_printout || print_to_comment) {
			xprintf("\n");
        }

}

void hexdump_to_comment(void *mem, unsigned int len, int do_raw_printout, int print_to_comment, char* comment_str) {
	hexdump_to_comment_var_length(mem,len, do_raw_printout,print_to_comment,comment_str, HEXDUMP_COLS);
}

void hexdump(void *mem, unsigned int len, int do_raw_printout)
{
	hexdump_to_comment(mem,len,do_raw_printout,0,0);
}
