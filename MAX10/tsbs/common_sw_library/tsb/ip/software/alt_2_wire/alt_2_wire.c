/*
 * alt_2_wire.h - code to support 2 wire protocol to support 
 * reading and writing to 2 wire device, eg. eeproms memory
 *
 * Author: Percy Chen
 * Date  : August 17/2007
 */

#include <unistd.h>
#include <stdio.h>

#include "sys/alt_irq.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "xprintf.h"

#include "alt_2_wire.h"

int SDA = 1;
int SCL = 1;
int debug = 0;

static inline void setupDelay(alt_two_wire* bus) {
	int i;
	for(i = 0; i < bus->delay_us; i++) {
	   usleep(1);
	}
}



static void pulldownSDA(alt_two_wire* bus) {
    IOWR_ALTERA_AVALON_PIO_DATA(bus->sda_pio, 0x0);
	setupDelay(bus);
}
static void pullupSDA(alt_two_wire* bus) {
    IOWR_ALTERA_AVALON_PIO_DATA(bus->sda_pio, 0x1);
	setupDelay(bus);
}
static void pulldownSCL(alt_two_wire* bus) {
    IOWR_ALTERA_AVALON_PIO_DATA(bus->scl_pio, 0x0);
	setupDelay(bus);
}
static void pullupSCL(alt_two_wire* bus) {
    IOWR_ALTERA_AVALON_PIO_DATA(bus->scl_pio, 0x1);
	setupDelay(bus);
}

static int readSDA(alt_two_wire* bus) {
  int read_data = 0;
  IOWR_ALTERA_AVALON_PIO_DIRECTION(bus->sda_pio, ALTERA_AVALON_PIO_DIRECTION_INPUT);
  read_data = (IORD_ALTERA_AVALON_PIO_DATA(bus->sda_pio) & 0x01);

  IOWR_ALTERA_AVALON_PIO_DIRECTION(bus->sda_pio, ALTERA_AVALON_PIO_DIRECTION_OUTPUT);
	return read_data;
}

void alt_2_wireStart(alt_two_wire* bus) {
#ifdef ALT_2_WIRE_DEBUG
	xprintf("enter alt_2_wireStart()\n");
#endif
	pullupSCL(bus);
	pullupSDA(bus);

	pulldownSDA(bus);

	pulldownSCL(bus);
#ifdef ALT_2_WIRE_DEBUG
	xprintf("exit alt_2_wireStart()\n");
#endif
}

void alt_2_wireStop(alt_two_wire* bus) {
#ifdef ALT_2_WIRE_DEBUG
	xprintf("enter alt_2_wireStop()\n");
#endif
	pulldownSDA(bus);
 	pullupSCL(bus);

	pullupSDA(bus);
#ifdef ALT_2_WIRE_DEBUG
	xprintf("exit alt_2_wireStop()\n");
#endif
}

int alt_2_wireSendByte(alt_two_wire* bus, int byte) {
    int i, ret;

#ifdef ALT_2_WIRE_DEBUG
    xprintf("start alt_2_wireSendByte(0x%.2X)\n", byte & 0xFF);
#endif
    for(i = 7; i > -1; i--) {
        (byte & (1 << i))?(pullupSDA(bus)):(pulldownSDA(bus));

        pullupSCL(bus);
        pulldownSCL(bus);
    }

    pullupSDA(bus);
    IOWR_ALTERA_AVALON_PIO_DIRECTION(bus->sda_pio, ALTERA_AVALON_PIO_DIRECTION_INPUT);
    
    pullupSCL(bus);
    ret = readSDA(bus);
    pulldownSCL(bus);

#ifdef ALT_2_WIRE_DEBUG
    xprintf("exit alt_2_wireSendByte(), ack = %d\n", ret);
#endif
    return ret;
}

int alt_2_wireReadByte(alt_two_wire* bus, int ackControl) {
	int i, val = 0, ack;

#ifdef ALT_2_WIRE_DEBUG
	xprintf("start alt_2_wireReadByte(%d)\n", ackControl);
#endif
	pullupSDA(bus);

	for(i = 7; i > -1; i--) {
		pullupSCL(bus);
		val |= (readSDA(bus) << i);
		pulldownSCL(bus);
	}

	switch(ackControl) {
		case EXPECT_ACK:
			pullupSCL(bus);
			ack = readSDA(bus);
			pulldownSCL(bus);
			if(ack) return -1;
			break;
		case SEND_ACK:
			pulldownSDA(bus);
			pullupSCL(bus);
			pulldownSCL(bus);
			pullupSDA(bus);
			break;
		case SEND_NACK:
			pullupSDA(bus);
			pullupSCL(bus);
			pulldownSCL(bus);
			pulldownSDA(bus);
			break;
		default:
#ifdef ALT_2_WIRE_DEBUG
			xprintf("error: unknown ack control mode!\n");
#endif
			alt_2_wireStop(bus);
            return -1;
	}

#ifdef ALT_2_WIRE_DEBUG
	xprintf("exit alt_2_wireReadByte(), byte = 0x%.2X\n", val & 0xFF);
#endif
	return val;
}

void alt_2_wireSetDelay(alt_two_wire* bus, int delay) {
	bus->delay_us = delay;
}

void alt_2_wireInit(alt_two_wire* bus,
        char* the_name,
        alt_u32 the_scl_pio,
        alt_u32 the_sda_pio,
        int the_delay_us
)
{
	bus->name =  the_name;
    bus->scl_pio = the_scl_pio;
    bus->sda_pio = the_sda_pio;
	bus->delay_us = the_delay_us;
    IOWR_ALTERA_AVALON_PIO_DIRECTION(bus->sda_pio, ALTERA_AVALON_PIO_DIRECTION_OUTPUT);
}
