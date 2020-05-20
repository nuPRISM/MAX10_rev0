/*
 * qsys_register_file_encapsulator.h
 *
 *  Created on: May 20, 2016
 *      Author: user
 */

#ifndef QSYS_REGISTER_FILE_ENCAPSULATOR_H_
#define QSYS_REGISTER_FILE_ENCAPSULATOR_H_

#include "altera_pio_encapsulator.h"
#include "generic_driver_encapsulator.h"
typedef enum {
	          SLAVE_TEMPLATE_DATA_IN_REG_TYPE = 0,
	          SLAVE_TEMPLATE_DATA_OUT_REG_TYPE = 1
             } slave_template_data_reg_type;

#define SPAN_IN_BYTES_OF_QSYS_REGISTER_FILE (0x100)
class qsys_register_file_encapsulator: public generic_driver_encapsulator {
protected:
            	 unsigned long get_datain_reg_word_addr(unsigned long regnum);
            	 unsigned long get_dataout_reg_word_addr(unsigned long regnum);
public:
	qsys_register_file_encapsulator() : generic_driver_encapsulator(0,SPAN_IN_BYTES_OF_QSYS_REGISTER_FILE) {};
	qsys_register_file_encapsulator(unsigned long the_base_address) : generic_driver_encapsulator(the_base_address,SPAN_IN_BYTES_OF_QSYS_REGISTER_FILE) {};

	virtual unsigned long read_datain(unsigned the_reg_num);
	virtual unsigned long read_dataout(unsigned the_reg_num);
	virtual void          write_dataout(unsigned the_reg_num, unsigned long data);
	virtual void turn_on_dataout_bit(unsigned the_reg_num, unsigned long bit);
	virtual void turn_off_dataout_bit(unsigned the_reg_num, unsigned long bit);
	virtual unsigned long get_datain_bit(unsigned the_reg_num, unsigned long bit);
	virtual unsigned long get_dataout_bit(unsigned the_reg_num, unsigned long bit);
	virtual ~qsys_register_file_encapsulator();
};

#endif /* QSYS_REGISTER_FILE_ENCAPSULATOR_H_ */
