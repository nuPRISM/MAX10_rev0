#ifndef __CHECKSUM_CONTROLLER_REGS_H__
#define __CHECKSUM_CONTROLLER_REGS_H__

#include <io.h>

#define CHECKSUM_CONTROLLER_ADDR_REGISTER_OFFSET           0
#define CHECKSUM_CONTROLLER_LENGTH_REGISTER_OFFSET	       4
#define CHECKSUM_CONTROLLER_CTRL_REGISTER_OFFSET           8
#define CHECKSUM_CONTROLLER_STATUS_REGISTER_OFFSET         12
#define CHECKSUM_CONTROLLER_RESULT_REGISTER_OFFSET         16

/* Basic address, read and write macros. */
#define IOADDR_CHECKSUM_CONTROLLER_ADDR(base)              __IO_CALC_ADDRESS_NATIVE(base, CHECKSUM_CONTROLLER_ADDR_REGISTER_OFFSET)
#define IORD_CHECKSUM_CONTROLLER_ADDR(base)                IORD_32DIRECT(base, CHECKSUM_CONTROLLER_ADDR_REGISTER_OFFSET)
#define IOWR_CHECKSUM_CONTROLLER_ADDR(base, data)          IOWR_32DIRECT(base, CHECKSUM_CONTROLLER_ADDR_REGISTER_OFFSET, data)

#define IOADDR_CHECKSUM_CONTROLLER_LENGTH(base)            __IO_CALC_ADDRESS_NATIVE(base, CHECKSUM_CONTROLLER_LENGTH_REGISTER_OFFSET)
#define IORD_CHECKSUM_CONTROLLER_LENGTH(base)              IORD_32DIRECT(base, CHECKSUM_CONTROLLER_LENGTH_REGISTER_OFFSET)
#define IOWR_CHECKSUM_CONTROLLER_LENGTH(base, data)        IOWR_32DIRECT(base, CHECKSUM_CONTROLLER_LENGTH_REGISTER_OFFSET, data)

#define IOADDR_CHECKSUM_CONTROLLER_CTRL(base)              __IO_CALC_ADDRESS_NATIVE(base, CHECKSUM_CONTROLLER_CTRL_REGISTER_OFFSET)
#define IORD_CHECKSUM_CONTROLLER_CTRL(base)                IORD_32DIRECT(base, CHECKSUM_CONTROLLER_CTRL_REGISTER_OFFSET)
#define IOWR_CHECKSUM_CONTROLLER_CTRL(base, data)          IOWR_32DIRECT(base, CHECKSUM_CONTROLLER_CTRL_REGISTER_OFFSET, data)

#define IOADDR_CHECKSUM_CONTROLLER_STATUS(base)            __IO_CALC_ADDRESS_NATIVE(base, CHECKSUM_CONTROLLER_STATUS_REGISTER_OFFSET)
#define IORD_CHECKSUM_CONTROLLER_STATUS(base)              IORD_32DIRECT(base, CHECKSUM_CONTROLLER_STATUS_REGISTER_OFFSET)
#define IOWR_CHECKSUM_CONTROLLER_STATUS(base, data)        IOWR_32DIRECT(base, CHECKSUM_CONTROLLER_STATUS_REGISTER_OFFSET, data)

#define IOADDR_CHECKSUM_CONTROLLER_RESULT(base)            __IO_CALC_ADDRESS_NATIVE(base, CHECKSUM_CONTROLLER_RESULT_REGISTER_OFFSET)
#define IORD_CHECKSUM_CONTROLLER_RESULT(base)              IORD_32DIRECT(base, CHECKSUM_CONTROLLER_RESULT_REGISTER_OFFSET)

/* Masks for Status Register */
#define CHECKSUM_CONTROLLER_STATUS_DONE_MSK                (0x1)
#define CHECKSUM_CONTROLLER_STATUS_BSY_MSK                 (0x100)

/*Mask for Control Register */
#define CHECKSUM_CONTROLLER_CTRL_IEN_MSK                   (0x1)
#define CHECKSUM_CONTROLLER_CTRL_INV_MSK                   (0x100)
#define CHECKSUM_CONTROLLER_CTRL_GO_MSK                    (0x10000)

/*Mask for Results Register*/
#define CHECKSUM_CONTROLLER_RESULT_MSK                     (0xFFFF)

/* Offsets for Status Register */
#define CHECKSUM_CONTROLLER_STATUS_DONE_OFST               (0)
#define CHECKSUM_CONTROLLER_STATUS_BSY_OFST                (8)

/* Offsets for Control Register */
#define CHECKSUM_CONTROLLER_CTRL_IEN_OFST                  (0)
#define CHECKSUM_CONTROLLER_CTRL_INV_OFST                  (8)
#define CHECKSUM_CONTROLLER_CTRL_GO_OFST                   (16)


#endif /* __ALTERA_AVALON_CHECKSUM_REGS_H__ */


/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
