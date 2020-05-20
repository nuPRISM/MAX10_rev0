/*****************************************************************************\
|*
|*  VERSION CONTROL:    $Version$   $Date$
|*
|*  IN PACKAGE:         
|*
|*  COPYRIGHT:          Copyright (c) 2007, Altium
|*
|*  DESCRIPTION:        
|*
 */

/**
 * @file
 * Interface to device driver for WB_SPI peripheral.
 *
 */

#ifndef DRV_SPI_H
#define DRV_SPI_H

#ifdef  __cplusplus
extern "C" {
#endif

#include "adc_mcs_basedef.h"
#include <stdint.h>
#include <stdbool.h>
//include <drv_spi_cfg_instance.h>

#define DRV_SPI_INSTANCE_CHANNELS_MAX 8
#define DRV_SPI_INSTANCE_COUNT 1
/**
 * @brief SPI modes
 *
 * SPI mode
 */
typedef enum
{
    SPI_MODE0,  /**< Mode 0 */
    SPI_MODE1,  /**< Mode 1 */
    SPI_MODE2,  /**< Mode 2 */
    SPI_MODE3   /**< Mode 3 */
} spi_mode_t;

#define spi_t struct drv_spi_s

spi_t * spi_open( unsigned long baseaddress, unsigned long CTRL_SETTINGS, unsigned baudrate );
extern void spi_set_baudrate( spi_t *  drv, uint32_t baudrate );
extern uint32_t spi_get_baudrate( spi_t *  drv );
extern void spi_set_endianess( spi_t *  drv, bool endianess );


#ifdef COMPILE_SPI_32BIT
extern uint32_t spi_transceive32( spi_t *  drv, uint32_t val );
extern uint32_t spi_received32( spi_t *  drv );
unsigned long SPI_TransferData(spi_t *  drv, char txSize, char* txBuf, char rxSize, char* rxBuf);

#endif


#ifdef COMPILE_SPI_16BIT
extern void spi_transmit16( spi_t *  drv, uint16_t val );
extern uint16_t spi_transceive16( spi_t *  drv, uint16_t val );
extern uint16_t spi_received16( spi_t *  drv );
#endif

#ifdef COMPILE_SPI_8BIT
extern void spi_transmit8( spi_t *  drv, uint8_t val );
extern uint8_t spi_transceive8( spi_t *  drv, uint8_t val );
extern uint8_t spi_received8( spi_t *  drv );
#endif

extern void spi_readblock( spi_t *  drv, uint8_t * buf, int bufsize );
extern void spi_writeblock( spi_t *  drv, uint8_t * buf, int bufsize );

#ifdef COMPILE_ADVANCED_SPI_FUNCTIONS

extern void spi_cs_lo( spi_t *  drv );
extern void spi_cs_hi( spi_t *  drv );
extern bool spi_get_bus( spi_t *  drv, uint8_t channel );
extern void spi_release_bus( spi_t *  drv );
extern bool spi_init_channel( spi_t *  drv, uint8_t channel, uint32_t baudrate, spi_mode_t spimode );
extern bool spi_busy( spi_t *  drv );

#endif

#ifdef  __cplusplus
}
#endif

#endif // _SPI_H
