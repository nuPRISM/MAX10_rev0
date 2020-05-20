#ifndef _HEXDUMP_H
#define _HEXDUMP_H
 
void hexdump(void *mem, unsigned int len, int do_raw_printout);
void hexdump_to_comment(void *mem, unsigned int len, int do_raw_printout, int print_to_comment, char* comment_str);
unsigned int hexdump_raw_to_string(void *mem, unsigned int len, char* result_str);
 
#endif
