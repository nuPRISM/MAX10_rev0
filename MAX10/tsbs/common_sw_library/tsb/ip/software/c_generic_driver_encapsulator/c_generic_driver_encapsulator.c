
#include "io.h"
#include "alt_types.h"  // alt_u32
#include "altera_avalon_pio_regs.h" //IOWR_ALTERA_AVALON_PIO_DATA

#include "basedef.h"
#include "c_generic_driver_encapsulator.h"

#ifndef DEBUG_C_GENERIC_DRIVER
#define DEBUG_C_GENERIC_DRIVER 0
#endif

#define d_da(x) do { if (DEBUG_C_GENERIC_DRIVER) { x; } } while(0)

void c_generic_driver_encapsulator_init(c_generic_driver_encapsulator* s,unsigned long the_base_address, unsigned long span_in_bytes,	
     unsigned short bytes_per_word, 
	 unsigned long index,
     c_generic_driver_encapsulator* next,
	 char* name
	 ) {
	s->span_in_bytes = span_in_bytes;
	s->base_address = the_base_address;
	s->bytes_per_word = bytes_per_word;
	s->index = index;
    s->next = next;
	s->name = name;
}

unsigned long c_generic_driver_encapsulator_read(c_generic_driver_encapsulator* s,unsigned int the_reg_num, int* success) {
	 unsigned long offset = s->bytes_per_word*the_reg_num;
	 if (offset >= s->span_in_bytes) {
		 if (success) {
			 *success = 0;
		 }
		return 0;
	 } 
	 unsigned long addr = s->base_address + offset;
	 unsigned long data;
     switch (s->bytes_per_word) { 
     case 1: data	 = __builtin_ldbio((void *)addr); break;
     case 2: data	 = __builtin_ldhio((void *)addr); break;
     case 4: data	 = __builtin_ldwio((void *)addr); break;
       default: data	 = __builtin_ldwio((void *)addr); break;
	 }
	 if (success) {
			 *success = 1;
	 }
	 return data;
};

int c_generic_driver_encapsulator_write(c_generic_driver_encapsulator* s, unsigned int the_reg_num, unsigned long data) {
    unsigned long offset = s->bytes_per_word*the_reg_num;
	if (offset >= s->span_in_bytes) {
		return 0;
	} 
	unsigned long addr = s->base_address + offset;
	
	 switch (s->bytes_per_word) { 
	 case 1: __builtin_stbio((void *)addr,data);  break;
	 case 2: __builtin_sthio((void *)addr,data);  break;
	 case 4: __builtin_stwio((void *)addr,data);  break;
	 default: __builtin_stwio((void *)addr,data); break;
	 }
	
	return 1;
};

unsigned long  c_generic_driver_encapsulator_get_span_in_bytes(c_generic_driver_encapsulator* s) {
	return s->span_in_bytes;
};

unsigned long  c_generic_driver_encapsulator_get_base_address(c_generic_driver_encapsulator* s) {
	return s->base_address;
};

int c_generic_driver_encapsulator_turn_on_bit(c_generic_driver_encapsulator* s,unsigned the_reg_num, unsigned long bit){
	    unsigned long  val;
		int success = 1;
		val = c_generic_driver_encapsulator_read(s,the_reg_num, &success);
		val = val | (((unsigned long)1) << bit);
		success = success && c_generic_driver_encapsulator_write(s,the_reg_num,val);
		return success;
};

int c_generic_driver_encapsulator_turn_off_bit(c_generic_driver_encapsulator* s,unsigned the_reg_num, unsigned long bit){
	unsigned long  val;
	int success = 1;
	val = c_generic_driver_encapsulator_read(s,the_reg_num,&success);
   	val = val & (~(((unsigned long)1) << bit));
	success = success && c_generic_driver_encapsulator_write(s,the_reg_num,val);
	return success;
};

unsigned long c_generic_driver_encapsulator_get_bit(c_generic_driver_encapsulator* s,unsigned the_reg_num, unsigned long bit, int* success){
	unsigned long  val;
	val = c_generic_driver_encapsulator_read(s,the_reg_num,success);
	return ((val & (((unsigned long)1) << bit)) != 0);
}

