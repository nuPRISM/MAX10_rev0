
#ifndef C_GENERIC_DRIVER_ENCAPSULATOR_H_
#define C_GENERIC_DRIVER_ENCAPSULATOR_H_

typedef struct c_generic_driver_encapsulator_s {
	        char* name;
			unsigned long base_address;
			unsigned long span_in_bytes;
			unsigned short bytes_per_word;
			unsigned long index;
			struct c_generic_driver_encapsulator_s* next;
} c_generic_driver_encapsulator;

	void c_generic_driver_encapsulator_init(
	                                        c_generic_driver_encapsulator* s,
											unsigned long the_base_address, 
											unsigned long span_in_bytes, 
											unsigned short bytes_per_word,
											unsigned long index,
											c_generic_driver_encapsulator* next,
											char* name
										   );
											
	unsigned long c_generic_driver_encapsulator_read(c_generic_driver_encapsulator* s,unsigned the_reg_num, int* success);
	int           c_generic_driver_encapsulator_write(c_generic_driver_encapsulator* s,unsigned the_reg_num, unsigned long data);
	unsigned long c_generic_driver_encapsulator_get_span_in_bytes(c_generic_driver_encapsulator* s);
	unsigned long c_generic_driver_encapsulator_get_base_address(c_generic_driver_encapsulator* s);
	int           c_generic_driver_encapsulator_turn_on_bit(c_generic_driver_encapsulator* s,unsigned the_reg_num, unsigned long bit);
	int           c_generic_driver_encapsulator_turn_off_bit(c_generic_driver_encapsulator* s,unsigned the_reg_num, unsigned long bit);
	unsigned long c_generic_driver_encapsulator_get_bit(c_generic_driver_encapsulator* s,unsigned the_reg_num, unsigned long bit, int* success);


#endif /* GENERIC_DRIVER_ENCAPSULATOR_H_ */
