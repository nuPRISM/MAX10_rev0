/*
 * c_pio_encapsulator.h
 *
 *  Created on: Jul 20, 2016
 *      Author: user
 */

#ifndef C_PIO_ENCAPSULATOR_H_
#define C_PIO_ENCAPSULATOR_H_
#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

#ifndef NULL
#define NULL (0)
#endif

typedef enum {ALTERA_PIO_TYPE_INPUT=0, ALTERA_PIO_TYPE_OUTPUT=1, ALTERA_PIO_TYPE_INOUT=2} Altera_PIO_Type;

typedef struct altera_pio_encapsulator_s {
	Altera_PIO_Type pio_type;
	unsigned long base_address;
	char* name;
	void* additional_info;
	unsigned int index;
	struct altera_pio_encapsulator_s *next;
} pio_encapsulator_struct;


void c_pio_encapsulator_init_w_additional_info(pio_encapsulator_struct* s, unsigned long the_base_address,
		Altera_PIO_Type the_pio_type,
		const char* the_name,
		unsigned int index,
		void* additional_info,
		struct altera_pio_encapsulator_s *next

);


typedef struct pio_bit_info_struct_s {
	pio_encapsulator_struct* pio_ptr;
	unsigned char bit_number;
	const char* name;
	void* additional_info;
	struct pio_bit_info_struct_s* next;
	int global_index;
} pio_bit_info_struct;


void c_pio_encapsulator_init(pio_encapsulator_struct* s, unsigned long the_base_address,
		Altera_PIO_Type the_pio_type,
		const char* the_name,
		unsigned int index,
		struct altera_pio_encapsulator_s *next
);

void c_pio_encapsulator_copy(pio_encapsulator_struct* src, pio_encapsulator_struct* dest);

void* c_pio_encapsulator_get_additional_info(pio_encapsulator_struct* s);
void c_pio_encapsulator_set_additional_info(pio_encapsulator_struct* s, void* additional_info);
Altera_PIO_Type c_pio_encapsulator_get_pio_type(pio_encapsulator_struct* s);
unsigned int c_pio_encapsulator_get_base_address(pio_encapsulator_struct* s);
int c_pio_encapsulator_write(pio_encapsulator_struct* s, unsigned long data);
void c_pio_encapsulator_set_direction(pio_encapsulator_struct* s, unsigned long data);
unsigned long c_pio_encapsulator_extract_bit_range(pio_encapsulator_struct* s, unsigned short lsb, unsigned short msb);
unsigned long c_pio_encapsulator_read(pio_encapsulator_struct* s);
unsigned long c_pio_encapsulator_get_direction(pio_encapsulator_struct* s, unsigned long data);
void c_pio_encapsulator_turn_on_bit(pio_encapsulator_struct* s,unsigned long bit);
void c_pio_encapsulator_turn_off_bit(pio_encapsulator_struct* s,unsigned long bit);
unsigned long c_pio_encapsulator_get_bit(pio_encapsulator_struct* s,unsigned long bit);
char* c_pio_encapsulator_get_name(pio_encapsulator_struct* s);
int c_pio_encapsulator_read_capture_reg(pio_encapsulator_struct* s, unsigned long* data);
int c_pio_encapsulator_clear_capture_reg(pio_encapsulator_struct* s);
void pio_bit_info_struct_init(
    pio_bit_info_struct* s,
    pio_encapsulator_struct* the_pio_ptr,
	unsigned char the_bit_number,
	const char* the_name,
	void* the_additional_info,
	pio_bit_info_struct* the_next
);

pio_bit_info_struct* find_pio_bit_info_struct(pio_bit_info_struct* list_start, const char* the_name);
pio_bit_info_struct* find_pio_bit_info_struct_by_index(pio_bit_info_struct* list_start, int the_index);
pio_encapsulator_struct* find_pio_encapsulator_struct(pio_encapsulator_struct* list_start, const char* the_name);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* C_PIO_ENCAPSULATOR_H_ */
