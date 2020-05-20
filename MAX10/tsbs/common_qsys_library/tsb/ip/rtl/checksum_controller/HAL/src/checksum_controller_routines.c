#include "alt_types.h"
#include "checksum_controller_regs.h"
#include "checksum_controller_routines.h"
 

int write_to_add_len_ctrl_registers(alt_u32 base, alt_u32* address, alt_u32 length, alt_u32 control)
{
  if ((read_status_of_checksum(base)&CHECKSUM_CONTROLLER_STATUS_BSY_MSK)==CHECKSUM_CONTROLLER_STATUS_BSY_MSK)
  {
		return 1;  // DMA is busy
	}
	else
  {
		if (((alt_u32)address&0x3)==0)
    {
			IOWR_CHECKSUM_CONTROLLER_ADDR(base, (alt_u32)address);
			IOWR_CHECKSUM_CONTROLLER_LENGTH(base, length);
      IOWR_CHECKSUM_CONTROLLER_CTRL(base, control);
		}
		else
    {
			return 2;  // address is not word aligned
		}
	}
  return 0;
}


void write_clear_to_status_register(alt_u32 base)
{
	IOWR_CHECKSUM_CONTROLLER_STATUS(base, 0);
	return;
}

alt_u32 read_status_of_checksum(alt_u32 base)
{
	return IORD_CHECKSUM_CONTROLLER_STATUS(base);
}

alt_u16 read_checksum_result(alt_u32 base)
{
	return IORD_CHECKSUM_CONTROLLER_RESULT(base);
}


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
