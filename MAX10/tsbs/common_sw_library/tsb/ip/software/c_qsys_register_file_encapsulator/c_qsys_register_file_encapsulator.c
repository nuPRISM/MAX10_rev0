
#include "basedef.h"
#include "xprintf.h"
#include "c_qsys_register_file_encapsulator.h"
#include "slave_template_macros.h"

#ifndef DEBUG_QSYS_REGISTER_FILE
#define DEBUG_QSYS_REGISTER_FILE 0
#endif


#define d_da(x) do { if (DEBUG_QSYS_REGISTER_FILE) { x; } } while(0)


#define BYTES_PER_WORD (4)


static unsigned long get_datain_reg_word_addr(c_qsys_register_file_encapsulator* s, unsigned long regnum){
	// return (((SLAVE_TEMPLATE_PER_REGISTER_WORD_SPAN/4)*(s->num_of_bytes_per_reg)*regnum)+SLAVE_TEMPLATE_DATA_IN_OFFSET);
	return ((SLAVE_TEMPLATE_PER_REGISTER_WORD_SPAN*regnum)+SLAVE_TEMPLATE_DATA_IN_OFFSET);
}
static unsigned long get_dataout_reg_word_addr(c_qsys_register_file_encapsulator* s, unsigned long regnum){
	// return (((SLAVE_TEMPLATE_PER_REGISTER_WORD_SPAN/4)*(s->num_of_bytes_per_reg)*regnum)+SLAVE_TEMPLATE_DATA_OUT_OFFSET);
    return ((SLAVE_TEMPLATE_PER_REGISTER_WORD_SPAN*regnum)+SLAVE_TEMPLATE_DATA_OUT_OFFSET);
}


static unsigned long qsys_regfile_read(c_qsys_register_file_encapsulator* s,unsigned the_reg_num){
	 unsigned long addr = s->base_address + s->num_of_bytes_per_reg*the_reg_num;
	 unsigned long data = __builtin_ldwio((void *)addr);
     d_da(xprintf("%sread from %x: got: %x base_address = %x the_reg_num = %x\n",COMMENT_STR,addr,data,s->base_address,the_reg_num););
	 return data;
};

static void qsys_regfile_write(c_qsys_register_file_encapsulator* s,unsigned the_reg_num, unsigned long data) {
	unsigned long addr = s->base_address + s->num_of_bytes_per_reg*the_reg_num;
	__builtin_stwio((void *)addr,data);
    d_da(xprintf("%swrote to %x: with data: %x base_address = %x the_reg_num = %x\n",COMMENT_STR,addr,data, s->base_address,the_reg_num););
};


void c_qsys_register_file_encapsulator_init(c_qsys_register_file_encapsulator* s,
		unsigned long the_base_address,
		unsigned int num_of_bytes_per_reg,
		const char* the_name,
		unsigned int index,
		struct c_qsys_register_file_encapsulator_s *next) {
	s->num_of_bytes_per_reg = num_of_bytes_per_reg;
	s->base_address = the_base_address;
	s->name = the_name;
	s->next = next;
	s->index = index;
}
unsigned long c_qsys_register_file_encapsulator_read_datain(c_qsys_register_file_encapsulator* s,unsigned the_reg_num){
	 return qsys_regfile_read(s,get_datain_reg_word_addr(s,the_reg_num));
};

unsigned long c_qsys_register_file_encapsulator_read_dataout(c_qsys_register_file_encapsulator* s,unsigned the_reg_num){
	 return qsys_regfile_read(s,get_dataout_reg_word_addr(s,the_reg_num));
};

void c_qsys_register_file_encapsulator_write_dataout(c_qsys_register_file_encapsulator* s,unsigned the_reg_num, unsigned long data) {
	return qsys_regfile_write(s,get_dataout_reg_word_addr(s,the_reg_num),data);
};

/*
void c_qsys_register_file_encapsulator::turn_on_dataout_bit(unsigned the_reg_num, unsigned long bit){
	return (turn_on_bit(get_dataout_reg_word_addr(the_reg_num),bit));
};

void c_qsys_register_file_encapsulator::turn_off_dataout_bit(unsigned the_reg_num, unsigned long bit){
	return (turn_off_bit(get_dataout_reg_word_addr(the_reg_num),bit));
};


unsigned long c_qsys_register_file_encapsulator::get_datain_bit(unsigned the_reg_num, unsigned long bit){
	return (get_bit(get_datain_reg_word_addr(the_reg_num),bit));
}

unsigned long c_qsys_register_file_encapsulator::get_dataout_bit(unsigned the_reg_num, unsigned long bit){
	return (get_bit(get_dataout_reg_word_addr(the_reg_num),bit));
}


*/
