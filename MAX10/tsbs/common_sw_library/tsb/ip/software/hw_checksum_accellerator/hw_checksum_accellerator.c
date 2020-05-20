/* Simple C program that exercises the checksum_accelerator component by
 * filling a memory buffer with test data and then configuring the
 * checksum_accelerator to read back the data.
 */
#include "basedef.h"
#ifdef CONTROLLER_BLOCK_BASE
#include "hw_checksum_accellerator.h"

static int isr_flag;

/**********************************
 * Checksum ISR                   *
 **********************************/
static void handle_checksum_interrupt(void* context, alt_u32 id)
{
    write_clear_to_status_register(CHECKSUM_BASE);
    isr_flag=1;
}

/**********************************
 * Register Checksum ISR          *
 **********************************/
int init_checksum()
{
    isr_flag=0;
    if(alt_irq_register(CHECKSUM_IRQ, NULL, handle_checksum_interrupt) != 0)
    {
      return 1;
    }
    return 0;
}

//
///******************************************************************************
//* Portable C implementation of the Internet checksum, derived                 *
//* from Braden, Borman, and Partridge's example implementation                 *
//* in RFC 1071.                                                                *
//*                                                                             *
//* Inputs:  unsigned short *:  base address of the buffer to be summed         *
//*          int:               length of the buffer to be summed               *
//* Outputs: unsigned short:    calculated 16 bit checksum                      *
//*                                                                             *
//* Note:  This implementation doesn't take care of the 32 bit rollover that    *
//*        can occur if too many values are accumulated.  Adding this would     *
//*        slow down the algorithm by over a factor of two so it is excluded    *
//*        on purpose.                                                          *
//*******************************************************************************/
unsigned short sw_checksum(unsigned short * addr, int count)
{
  /* Compute Internet Checksum for "count" bytes
  *         beginning at location "addr".
  */
  register long sum = 0;

  while( count > 1 )  {
  /*  This is the inner loop */
    sum += *addr++; /* JCJB:  the line from RFC 1071 example was incorrect */
    count -= 2;
  }

  /*  Add left-over byte, if any */
  if( count > 0 )
    sum += * (unsigned char *)addr;

  /*  Fold 32-bit sum to 16 bits */
  while (sum>>16)
    sum = (sum & 0xffff) + (sum >> 16);

  return (sum);
}



/* FUNCTION: ccksum.c
 *
 * C language checksum example from RFC 1071
 *
 * PARAM1: ptr          pointer to data to be checksum-ed
 * PARAM2: count        number of 16-bit words to process
 *
 * RETURN: ccksum       16-bit checksum value
 *
 * The InterNiche Stack guarentees that data is 16-bit aligned
 * and odd byte lengths are padded with zero, so processing can
 * be done in 16-bit chunks.
 */

unsigned short
hw_checksum (void *ptr, unsigned words)
{
   int byte_count = ((int)words)*2;
   unsigned short hardware_result;
   unsigned int watchdog_timer = 0;
   int error_code;

       /****************************************
        * Starting HW checksum                 *
        ****************************************/

       /* If a data cache is present, flush to avoid cache coherency problems.  This will make sure the buffer is written to memory. */
       #if (NIOS2_DCACHE_SIZE > 0)
         alt_dcache_flush_all();
       #endif
         if (CHECKSUM_INTERRUPT_ENABLE==0)  // Polled version
        {
        	    write_clear_to_status_register(CHECKSUM_BASE);
            error_code = write_to_add_len_ctrl_registers(CHECKSUM_BASE,
            		                                     (unsigned long *)ptr,
            		                                      byte_count,
                                                          //CHECKSUM_CONTROLLER_CTRL_INV_MSK |
                                                          CHECKSUM_CONTROLLER_CTRL_GO_MSK
                                            );
            if(error_code == 1)
            {
              //printf("Error:  Attempting to start the checksum accelerator while it is busy... exiting %c\n", 0x4);
              return 1;
            }
            else if(error_code == 2)
            {
             // printf("Error:  Attempting to start the checksum accelerator using an unaligned address... exiting %c\n", 0x4);
              return 2;
            }

            while (read_status_of_checksum(CHECKSUM_BASE) == CHECKSUM_CONTROLLER_STATUS_BSY_MSK) {
            	watchdog_timer++;
            	if (watchdog_timer > HW_CHECKSUM_WATCHDOG_LIMIT)
            	{
            		return 3;
            	}
            }
        }
         else {


        error_code = write_to_add_len_ctrl_registers
        		                          (CHECKSUM_BASE,
                                           (unsigned long *)ptr,
                                           byte_count,
                                          // CHECKSUM_CONTROLLER_CTRL_INV_MSK |
                                           CHECKSUM_CONTROLLER_CTRL_GO_MSK |
                                           CHECKSUM_CONTROLLER_CTRL_IEN_MSK
                                           );
           if(error_code == 1)
           {
            // printf("Error:  Attempting to start the checksum accelerator while it is busy... exiting %c\n", 0x4);
             return 4;
           }
           else if(error_code == 2)
           {
             //printf("Error:  Attempting to start the checksum accelerator using an unaligned address... exiting %c\n", 0x4);
             return 5;
           }

           while(isr_flag==0) {
        	   watchdog_timer++;
        	               	if (watchdog_timer > HW_CHECKSUM_WATCHDOG_LIMIT)
        	               	{
        	               		return 6;
        	               	}

           }  // nothing else better to do so waiting for the ISR to change isr_flag from 0 to 1
         }
         hardware_result=read_checksum_result(CHECKSUM_BASE);
         return   hardware_result;

}




/* **************************************************************
 * Function that sets buffer contents to random data            *
 * **************************************************************/
void set_buf_val(alt_u8* buffer, int length)
{
    int i=0;
    static unsigned int seed = 0;


    do
    {
      seed += __TIME__[i] << 8;
      i++;
    } while(__TIME__[i] != '\0' );
    i = 0;

    do
    {
      seed += __DATE__[i] << 8;
      i++;
    } while(__DATE__[i] != '\0' );

    srand(seed);
    seed++;

    printf("Using %u as seed\n", seed);
    printf("Creating random test data\n\n");

    for (i = 0; i < BUFFER_LENGTH; i++)
    {
      buffer[i] = (0xFF & rand()) % 256;  // random values between 0 and 255
    }
}

#endif

//
//int main()
//{
//    alt_u64 hw_time, sw_time;
//    int cpu_freq;
//    unsigned short software_result, hardware_result;
//    alt_u8* buf;
//    int error_code;
//
//    /* the checksum accelerator must be connected to whatever memory is used for the Nios II heap */
//    buf = (alt_u8 *)malloc (BUFFER_LENGTH);
//    if (buf == NULL)
//    {
//      printf("Allocation of buffer memory space failed\n");
//      return 1;
//    }
//
//
//    /* Check buffer length.*/
//    if (BUFFER_LENGTH>(64*1024))
//    {
//        printf("Buffer length must be 64kB or less to ensure that the software checksum result is correct.\n");
//        return 1;
//    }
//
//    set_buf_val(buf, BUFFER_LENGTH);
//
//
//    PERF_RESET(PERFORMANCE_COUNTER_BASE);
//    cpu_freq = alt_get_cpu_freq();
//
//    /******************************
//     * Starting Software Checksum *
//     ******************************/
//    printf("Starting Software Checksum\n");
//    PERF_START_MEASURING(PERFORMANCE_COUNTER_BASE);
//    software_result= sw_checksum((unsigned short *)buf, BUFFER_LENGTH);
//    sw_time = perf_get_total_time((void*) PERFORMANCE_COUNTER_BASE);
//
//
//    /****************************************
//     * Starting HW checksum                 *
//     ****************************************/
//
//    /* If a data cache is present, flush to avoid cache coherency problems.  This will make sure the buffer is written to memory. */
//    #if (NIOS2_DCACHE_SIZE > 0)
//      alt_dcache_flush_all();
//    #endif
//
//    PERF_RESET(PERFORMANCE_COUNTER_BASE);
//    if (CHECKSUM_INTERRUPT_ENABLE==0)  // Polled version
//    {
//        printf("Starting polling based hardware checksum\n\n");
//
//        PERF_START_MEASURING(PERFORMANCE_COUNTER_BASE);
//        error_code = write_to_add_len_ctrl_registers(CHECKSUM_BASE,
//                                        (unsigned long *)buf,
//                                        BUFFER_LENGTH,
//																				CHECKSUM_CONTROLLER_CTRL_IEN_MSK |
//                                        //CHECKSUM_CONTROLLER_CTRL_INV_MSK |
//                                        CHECKSUM_CONTROLLER_CTRL_GO_MSK
//                                        );
//        if(error_code == 1)
//        {
//          printf("Error:  Attempting to start the checksum accelerator while it is busy... exiting %c\n", 0x4);
//          return 1;
//        }
//        else if(error_code == 2)
//        {
//          printf("Error:  Attempting to start the checksum accelerator using an unaligned address... exiting %c\n", 0x4);
//          return 1;
//        }
//
//        while (read_status_of_checksum(CHECKSUM_BASE) == CHECKSUM_CONTROLLER_STATUS_BSY_MSK) {}
//    }
//    else   // Interrupt version
//    {
//        if (init_checksum() == 0)
//        {
//          printf("ISR for hardware checksum successfully registered.\n");
//        }
//        else
//        {
//          printf("Failed to successfully register ISR.\n");
//          return 1;
//        }
//
//        printf("Starting IRQ based hardware checksum.\n\n");
//
//        PERF_START_MEASURING(PERFORMANCE_COUNTER_BASE);
//        error_code = write_to_add_len_ctrl_registers(CHECKSUM_BASE,
//                                        (unsigned long *)buf,
//                                        BUFFER_LENGTH,
//                                        CHECKSUM_CONTROLLER_CTRL_INV_MSK |
//                                        CHECKSUM_CONTROLLER_CTRL_GO_MSK |
//                                        CHECKSUM_CONTROLLER_CTRL_IEN_MSK
//                                        );
//        if(error_code == 1)
//        {
//          printf("Error:  Attempting to start the checksum accelerator while it is busy... exiting %c\n", 0x4);
//          return 1;
//        }
//        else if(error_code == 2)
//        {
//          printf("Error:  Attempting to start the checksum accelerator using an unaligned address... exiting %c\n", 0x4);
//          return 1;
//        }
//
//        while(isr_flag==0) {}  // nothing else better to do so waiting for the ISR to change isr_flag from 0 to 1
//    }
//
//    hardware_result=read_checksum_result(CHECKSUM_BASE);
//    hw_time = perf_get_total_time((void*) PERFORMANCE_COUNTER_BASE);
//    output_results(software_result, hardware_result, sw_time, hw_time, cpu_freq);
//
//    printf("Exiting...%c\n", 0x4);  // 0x4 is ^D
//    return 0;
//}

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
