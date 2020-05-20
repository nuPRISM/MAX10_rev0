/*
 * c_qsys_register_file_encapsulator.h
 *
 *  Created on: May 20, 2016
 *      Author: user
 */

#ifndef C_QSYS_REGISTER_FILE_ENCAPSULATOR_H_
#define C_QSYS_REGISTER_FILE_ENCAPSULATOR_H_

typedef enum {
	          SLAVE_TEMPLATE_DATA_IN_REG_TYPE = 0,
	          SLAVE_TEMPLATE_DATA_OUT_REG_TYPE = 1
             } slave_template_data_reg_type;

typedef struct c_qsys_register_file_encapsulator_s {
	unsigned long base_address;
	unsigned int num_of_bytes_per_reg;
	char* name;
	unsigned int index;
	struct c_qsys_register_file_encapsulator_s *next;
} c_qsys_register_file_encapsulator;

#define SPAN_IN_BYTES_OF_QSYS_REGISTER_FILE (0x100)
#define MAX_NUM_OF_REGS_IN_QSYS_REGISTER_FILE (16)

 void c_qsys_register_file_encapsulator_init(c_qsys_register_file_encapsulator* s,
		 unsigned long the_base_address,
		 unsigned int num_of_bytes_per_reg,
		 const char* the_name,
		 unsigned int index,
		 struct c_qsys_register_file_encapsulator_s *next);

 unsigned long c_qsys_register_file_encapsulator_read_datain(c_qsys_register_file_encapsulator* s,unsigned the_reg_num);
 unsigned long c_qsys_register_file_encapsulator_read_dataout(c_qsys_register_file_encapsulator* s,unsigned the_reg_num);
 void          c_qsys_register_file_encapsulator_write_dataout(c_qsys_register_file_encapsulator* s,unsigned the_reg_num, unsigned long data);
 
 /*
 void turn_on_dataout_bit(unsigned the_reg_num, unsigned long bit);
 void turn_off_dataout_bit(unsigned the_reg_num, unsigned long bit);
 unsigned long get_datain_bit(unsigned the_reg_num, unsigned long bit);
 unsigned long get_dataout_bit(unsigned the_reg_num, unsigned long bit);
 */
 
#endif /* C_QSYS_REGISTER_FILE_ENCAPSULATOR_H_ */
