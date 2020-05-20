/*
 * c_pio_encapsulator.c
 *
 *  Created on: Jul 20, 2016
 *      Author: user
 */


#include "c_pio_encapsulator.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include "misc_str_utils.h"

static int global_index = 0;
void c_pio_encapsulator_init_w_additional_info(
		pio_encapsulator_struct* s,
		unsigned long the_base_address,
		Altera_PIO_Type the_pio_type,
		const char* the_name,
		unsigned int index,
		void* additional_info,
		struct altera_pio_encapsulator_s *next)
{
	s->additional_info = additional_info;
	s->base_address = the_base_address;
	s->pio_type = the_pio_type;
	s->name         = (char *)the_name;
	s->next = next;
    s->index = index;
}


void c_pio_encapsulator_init(pio_encapsulator_struct* s, unsigned long the_base_address,
		Altera_PIO_Type the_pio_type,
		const char* the_name,
		unsigned int index,
		struct altera_pio_encapsulator_s *next

) {
	c_pio_encapsulator_init_w_additional_info(s,the_base_address,the_pio_type,the_name,index,(void *)0,next);
}

void c_pio_encapsulator_copy(pio_encapsulator_struct* src, pio_encapsulator_struct* dest) {
	dest->additional_info = src->additional_info ;
	dest->base_address    = src->base_address    ;
	dest->pio_type        = src->pio_type        ;
	dest->name            = src->name            ;
	dest->next            = src->next            ;
    dest->index           = src->index           ;
}


Altera_PIO_Type c_pio_encapsulator_get_pio_type(pio_encapsulator_struct* s)
{
    return s->pio_type;
}

unsigned int c_pio_encapsulator_get_base_address(pio_encapsulator_struct* s)
{
    return s->base_address;
}
 void* c_pio_encapsulator_get_additional_info(pio_encapsulator_struct* s) {
	 return s->additional_info;
 }
 
 void c_pio_encapsulator_set_additional_info(pio_encapsulator_struct* s, void* additional_info) {
	 s->additional_info = additional_info;
 }

int c_pio_encapsulator_write(pio_encapsulator_struct* s, unsigned long data)
{
	if (s->pio_type != ALTERA_PIO_TYPE_INPUT) {
		IOWR_32DIRECT(c_pio_encapsulator_get_base_address(s),0,data);
		return 1;
	} else {
		return 0;
	}
}

int c_pio_encapsulator_read_capture_reg(pio_encapsulator_struct* s, unsigned long* data)
{
	if ((s->pio_type == ALTERA_PIO_TYPE_INPUT) || (s->pio_type == ALTERA_PIO_TYPE_INOUT)){
		*data = IORD(c_pio_encapsulator_get_base_address(s),3);
		return 1;
	} else {
		return 0;
	}
}

int c_pio_encapsulator_clear_capture_reg(pio_encapsulator_struct* s)
{
	if ((s->pio_type == ALTERA_PIO_TYPE_INPUT) || (s->pio_type == ALTERA_PIO_TYPE_INOUT)){
		IOWR(c_pio_encapsulator_get_base_address(s),3,0);
		return 1;
	} else {
		return 0;
	}
}

void c_pio_encapsulator_set_direction(pio_encapsulator_struct* s, unsigned long data)
{
	IOWR_ALTERA_AVALON_PIO_DIRECTION(c_pio_encapsulator_get_base_address(s), data);
}
unsigned long c_pio_encapsulator_read(pio_encapsulator_struct* s)
{
	return IORD_32DIRECT(c_pio_encapsulator_get_base_address(s),0);
}

unsigned long c_pio_encapsulator_get_direction(pio_encapsulator_struct* s, unsigned long data)
{
	return IORD_ALTERA_AVALON_PIO_DIRECTION(c_pio_encapsulator_get_base_address(s));
}

void c_pio_encapsulator_turn_on_bit(pio_encapsulator_struct* s,unsigned long bit){
	unsigned long  val;
	val = c_pio_encapsulator_read(s);
	val = val | (((unsigned long)1) << bit);
	c_pio_encapsulator_write(s,val);
};

void c_pio_encapsulator_turn_off_bit(pio_encapsulator_struct* s,unsigned long bit){
	unsigned long  val;
	val = c_pio_encapsulator_read(s);
   	val = val & (~(((unsigned long)1) << bit));
	c_pio_encapsulator_write(s,val);
};

unsigned long c_pio_encapsulator_get_bit(pio_encapsulator_struct* s,unsigned long bit){
	unsigned long  val;
	val = c_pio_encapsulator_read(s);
	return ((val & (((unsigned long)1) << bit)) != 0);
}

char* c_pio_encapsulator_get_name(pio_encapsulator_struct* s) {
	return s->name;
}

void pio_bit_info_struct_init(
    pio_bit_info_struct* s,
    pio_encapsulator_struct* the_pio_ptr,
	unsigned char the_bit_number,
	const char* the_name,
	void* the_additional_info,
	pio_bit_info_struct* the_next
	) {
	s->global_index = global_index;
	global_index++;
	
    s->pio_ptr = the_pio_ptr;
	s->bit_number = the_bit_number;
	s->name = the_name;
	s->additional_info = the_additional_info;
	s->next = the_next;

}

pio_encapsulator_struct* find_pio_encapsulator_struct(pio_encapsulator_struct* list_start, const char* the_name) {
	if (the_name == NULL) return NULL;
	pio_encapsulator_struct* x = list_start;
	while (x != NULL) {
		if (!my_strcmp(x->name,the_name)) {
			return (x);
		} else {
		    x = x->next;
		}
	}	
	return NULL;	
}

pio_bit_info_struct* find_pio_bit_info_struct(pio_bit_info_struct* list_start, const char* the_name) {
	if (the_name == NULL) return NULL;
	pio_bit_info_struct* x = list_start;
	while (x != NULL) {
		if (!my_strcmp(x->name,the_name)) {
			return (x);
		} else {
		    x = x->next;
		}
	}	
	return NULL;	
}

pio_bit_info_struct* find_pio_bit_info_struct_by_index(pio_bit_info_struct* list_start, int the_index) {
	if (the_index < 0) return NULL;
	pio_bit_info_struct* x = list_start;
	while (x != NULL) {
		if (x->global_index == the_index) {
			return (x);
		} else {
		    x = x->next;
		}
	}
	return NULL;

}

unsigned long c_pio_encapsulator_extract_bit_range(pio_encapsulator_struct* s, unsigned short lsb, unsigned short msb)
{
	unsigned long the_data = c_pio_encapsulator_read(s);
	the_data = the_data >> lsb;
	the_data = the_data & (~(0xFFFFFFFF << (msb - lsb + 1)));
	return the_data;
}
