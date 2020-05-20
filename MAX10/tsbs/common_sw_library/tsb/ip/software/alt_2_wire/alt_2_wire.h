/*
 * alt_2_wire.h - code to support 2 wire protocol to support 
 * reading and writing to 2 wire device, eg. eeproms memory
 *
 * Author: Percy Chen
 * Date  : August 17/2007
 */
#ifndef _ALT_2_WIRE_H
#define _ALT_2_WIRE_H

#define ALTERA_AVALON_PIO_DIRECTION_INPUT  0
#define ALTERA_AVALON_PIO_DIRECTION_OUTPUT 1

#include <alt_types.h>

typedef struct alt_two_wire
{
  alt_u32 scl_pio;
  alt_u32 sda_pio;
  int delay_us;
  char* name;
} alt_two_wire;

void alt_2_wireInit(alt_two_wire* bus,
		            char* the_name,
		            alt_u32 the_scl_pio,
		            alt_u32 the_sda_pio,
                    int the_delay_us);

void alt_2_wireSetDelay(alt_two_wire* bus, int delay);

void alt_2_wireStart(alt_two_wire* bus);
void alt_2_wireStop(alt_two_wire* bus);

int alt_2_wireSendByte(alt_two_wire* bus,int byte);
int alt_2_wireReadByte(alt_two_wire* bus,int ackControl);

enum { EXPECT_ACK, SEND_ACK, SEND_NACK };

#endif
