
#include <stdio.h>
#include "alt_2_wire.h"
#include "sfp_support_2_wire_pio.h"
#include <unistd.h>
#include "sys/alt_irq.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"

// SFP Module PHY Registers Definition
#define SFP_SLAVE_ADDR_WRITE            0xAC
#define SFP_SLAVE_ADDR_READ             0xAD
#define SFP_PHY_CONTROL                 0x00
#define SFP_PHY_STATUS                  0x01
#define SFP_PHY_ID0                     0x02
#define SFP_PHY_ID1                     0x03
#define SFP_PHY_AUTONEG_ADVERTISEMENT   0x04
#define SFP_PHY_LINK_PARTNER_ABILITY    0x05
#define SFP_PHY_1000BASET_CONTROL       0x09
#define SFP_PHY_PHY_SPECIFIC_STAT       0x11
#define SFP_PHY_EXT_PHY_SPECIFIC_STAT   0x1B
#define SFPA_SCL                        PIO_BASE
#define SFPA_SDA                        PIO_1_BASE
#define SFPB_SCL                        PIO_2_BASE
#define SFPB_SDA                        PIO_3_BASE

void sfp_reg_write_alt_2_wire (void *additional_data,int address, int data)
{
    alt_two_wire* bus = (alt_two_wire* )additional_data;
    int ret;
    
    alt_2_wireStart(bus);
    ret = alt_2_wireSendByte(bus,SFP_SLAVE_ADDR_WRITE);
    ret = alt_2_wireSendByte(bus,address);
    ret = alt_2_wireSendByte(bus,data >> 8);
    ret = alt_2_wireSendByte(bus,data & 0xFF);
    alt_2_wireStop(bus);
}

int sfp_reg_read_alt_2_wire (void *additional_data,int address)
{   
    alt_two_wire* bus = (alt_two_wire* )additional_data;
    int ret;
    int data;

    
    alt_2_wireStart(bus);
    ret = alt_2_wireSendByte(bus,SFP_SLAVE_ADDR_WRITE);
    ret = alt_2_wireSendByte(bus,address);
    alt_2_wireStart(bus);
    ret = alt_2_wireSendByte(bus,SFP_SLAVE_ADDR_READ);
    data = alt_2_wireReadByte(bus,SEND_ACK);
    ret = alt_2_wireReadByte(bus,SEND_NACK);
    data = (bus,(data << 8) | ret);
    alt_2_wireStop(bus);
    return data;
}
