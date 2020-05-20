#include <alt_types.h>
#include <io.h>
#include "mem_test_func.h"

/******************************************************************
*  Function: MemTestDataBus
*
*  Purpose: Tests that the data bus is connected with no 
*           stuck-at's, shorts, or open circuits.
*
******************************************************************/
int MemTestDataBus(unsigned int address)
{
  unsigned int pattern;
  unsigned int ret_code = 0x0;

  /* Perform a walking 1's test at the given address. */
  for (pattern = 1; pattern != 0; pattern <<= 1)
  {
    /* Write the test pattern. */
    IOWR_32DIRECT(address, 0, pattern);

    /* Read it back (immediately is okay for this test). */
    if (IORD_32DIRECT(address, 0) != pattern)
    {
      ret_code = pattern;
      break;
    }
  }
  return ret_code;
}


/******************************************************************
*  Function: MemTestAddressBus
*
*  Purpose: Tests that the address bus is connected with no 
*           stuck-at's, shorts, or open circuits.
*
******************************************************************/
int MemTestAddressBus(unsigned int memory_base, unsigned int nBytes)
{
  unsigned int address_mask = (nBytes - 1);
  unsigned int offset;
  unsigned int test_offset;

  unsigned int pattern     = 0xAAAAAAAA;
  unsigned int antipattern  = 0x55555555;

  unsigned int ret_code = 0x0;

  /* Write the default pattern at each of the power-of-two offsets. */
  for (offset = sizeof(unsigned int); (offset & address_mask) != 0; offset <<= 1)
  {
    IOWR_32DIRECT(memory_base, offset, pattern);
  }

  /* Check for address bits stuck high. */
  test_offset = 0;
  IOWR_32DIRECT(memory_base, test_offset, antipattern);
  for (offset = sizeof(unsigned int); (offset & address_mask) != 0; offset <<= 1)
  {
     if (IORD_32DIRECT(memory_base, offset) != pattern)
     {
        ret_code = (memory_base+offset);
        break;
     }
  }

  /* Check for address bits stuck low or shorted. */
  IOWR_32DIRECT(memory_base, test_offset, pattern);
  for (test_offset = sizeof(unsigned int); (test_offset & address_mask) != 0; test_offset <<= 1)
  {
    if (!ret_code)
    {
      IOWR_32DIRECT(memory_base, test_offset, antipattern);
      for (offset = sizeof(unsigned int); (offset & address_mask) != 0; offset <<= 1)
      {
        if ((IORD_32DIRECT(memory_base, offset) != pattern) && (offset != test_offset))
        {
          ret_code = (memory_base + test_offset);
          break;
        }
      }
      IOWR_32DIRECT(memory_base, test_offset, pattern);
    }
  }

  return ret_code;
}


/******************************************************************
*  Function: MemTest8_16BitAccess
*
*  Purpose: Tests that the memory at the specified base address
*           can be read and written in both byte and half-word 
*           modes.
*
******************************************************************/
int MemTest8_16BitAccess(unsigned int memory_base)
{
  int ret_code = 0x0;

  /* Write 4 bytes */
  IOWR_8DIRECT(memory_base, 0, 0x0A);
  IOWR_8DIRECT(memory_base, 1, 0x05);
  IOWR_8DIRECT(memory_base, 2, 0xA0);
  IOWR_8DIRECT(memory_base, 3, 0x50);

  /* Read it back as one word */
  if(IORD_32DIRECT(memory_base, 0) != 0x50A0050A)
  {
    ret_code = memory_base;
  }

  /* Read it back as two half-words */
  if (!ret_code)
  {
    if ((IORD_16DIRECT(memory_base, 2) != 0x50A0) ||
        (IORD_16DIRECT(memory_base, 0) != 0x050A))
    {
      ret_code = memory_base;
    }
  }

  /* Read it back as 4 bytes */
  if (!ret_code)
  {
    if ((IORD_8DIRECT(memory_base, 3) != 0x50) ||
        (IORD_8DIRECT(memory_base, 2) != 0xA0) ||
        (IORD_8DIRECT(memory_base, 1) != 0x05) ||
        (IORD_8DIRECT(memory_base, 0) != 0x0A))
    {
    ret_code = memory_base;
    }
  }

  /* Write 2 half-words */
  if (!ret_code)
  {
    IOWR_16DIRECT(memory_base, 0, 0x50A0);
    IOWR_16DIRECT(memory_base, 2, 0x050A);

    /* Read it back as one word */
    if(IORD_32DIRECT(memory_base, 0) != 0x050A50A0)
    {
      ret_code = memory_base;
    }
  }

  /* Read it back as two half-words */
  if (!ret_code)
  {
    if ((IORD_16DIRECT(memory_base, 2) != 0x050A) ||
        (IORD_16DIRECT(memory_base, 0) != 0x50A0))
    {
      ret_code = memory_base;
    }
  }

  /* Read it back as 4 bytes */
  if (!ret_code)
  {
    if ((IORD_8DIRECT(memory_base, 3) != 0x05) ||
        (IORD_8DIRECT(memory_base, 2) != 0x0A) ||
        (IORD_8DIRECT(memory_base, 1) != 0x50) ||
        (IORD_8DIRECT(memory_base, 0) != 0xA0))
    {
      ret_code = memory_base;
    }
  }

  return(ret_code);
}


/******************************************************************
*  Function: MemTestDevice
*
*  Purpose: Tests that every bit in the memory device within the 
*           specified address range can store both a '1' and a '0'.
*
******************************************************************/
int MemTestDevice(unsigned int memory_base, unsigned int nBytes)
{
  unsigned int offset;
  unsigned int pattern;
  unsigned int antipattern;
  unsigned int ret_code = 0x0;

  /* Fill memory with a known pattern. */
  for (pattern = 1, offset = 0; offset < nBytes; pattern++, offset+=4)
  {
    IOWR_32DIRECT(memory_base, offset, pattern);
  }

  /* Check each location and invert it for the second pass. */
  for (pattern = 1, offset = 0; offset < nBytes; pattern++, offset+=4)
  {
    if (IORD_32DIRECT(memory_base, offset) != pattern)
    {
      ret_code = (memory_base + offset);
      break;
    }
    antipattern = ~pattern;
    IOWR_32DIRECT(memory_base, offset, antipattern);
  }

  /* Check each location for the inverted pattern and zero it. */
  for (pattern = 1, offset = 0; offset < nBytes; pattern++, offset+=4)
  {
    antipattern = ~pattern;
    if (IORD_32DIRECT(memory_base, offset) != antipattern)
    {
      ret_code = (memory_base + offset);
      break;
    }
    IOWR_32DIRECT(memory_base, offset, 0x0);
  }
  return ret_code;
}
