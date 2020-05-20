/*******************************************************************
 *
 * bel_fft_test.c
 *
 *
 * This file is part of the "bel_fft" project
 *
 * Author(s):
 *     - Frank Storm (Frank.Storm@gmx.net)
 *
 *******************************************************************
 *
 * Copyright (C) 2011-2012 Authors
 *
 * This source file may be used and distributed without
 * restriction provided that this copyright statement is not
 * removed from the file and that any derivative work contains
 * the original copyright notice and the associated disclaimer.
 *
 * This source file is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation;
 * either version 2.1 of the License, or (at your option) any
 * later version.
 *
 * This source is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this source; if not, download it
 * from http://www.gnu.org/licenses/lgpl.html
 *
 *******************************************************************
 *
 * CVS Revision History
 *
 * $Log$
 *
 *******************************************************************
 */

#include <stdio.h>
#include <unistd.h>
#include "system.h"

#include "kiss_fft.h"

/*
 *  Altera types with bit width names
 */
#include "alt_types.h"


/*
 * Definitions for the Timestamp interval timer peripheral
 */
#include "sys/alt_timestamp.h"

/*
 *  Definition for the Performance Counter Peripheral
 */
#include "altera_avalon_performance_counter.h"



#define FFT_LEN 256


int main()
{
    kiss_fft_cfg cfg;

    kiss_fft_cpx fin[FFT_LEN] = {
    {0x00000000, 0x00000000}, {0x00002BD1, 0x00000000}, {0x000040E8, 0x00000000}, {0x000035CE, 0x00000000},
    {0x000013D4, 0x00000000}, {0xFFFFF18D, 0x00000000}, {0xFFFFE590, 0x00000000}, {0xFFFFF92F, 0x00000000},
    {0x000022F9, 0x00000000}, {0x00004C3D, 0x00000000}, {0x00005E4A, 0x00000000}, {0x00004FB5, 0x00000000},
    {0x000029DC, 0x00000000}, {0x00000361, 0x00000000}, {0xFFFFF2EC, 0x00000000}, {0x000001DE, 0x00000000},
    {0x000026DC, 0x00000000}, {0x00004B44, 0x00000000}, {0x00005878, 0x00000000}, {0x00004522, 0x00000000},
    {0x00001AAF, 0x00000000}, {0xFFFFEFD6, 0x00000000}, {0xFFFFDB4C, 0x00000000}, {0xFFFFE687, 0x00000000},
    {0x00000834, 0x00000000}, {0x000029C3, 0x00000000}, {0x0000349F, 0x00000000}, {0x00001F7A, 0x00000000},
    {0xFFFFF3CB, 0x00000000}, {0xFFFFC849, 0x00000000}, {0xFFFFB3B1, 0x00000000}, {0xFFFFBF74, 0x00000000},
    {0xFFFFE242, 0x00000000}, {0x00000582, 0x00000000}, {0x0000129B, 0x00000000}, {0x00000037, 0x00000000},
    {0xFFFFD7C0, 0x00000000}, {0xFFFFAFE4, 0x00000000}, {0xFFFF9F4D, 0x00000000}, {0xFFFFAF62, 0x00000000},
    {0xFFFFD6BF, 0x00000000}, {0xFFFFFEBB, 0x00000000}, {0x000010A9, 0x00000000}, {0x00000322, 0x00000000},
    {0xFFFFDF7D, 0x00000000}, {0xFFFFBC54, 0x00000000}, {0xFFFFB042, 0x00000000}, {0xFFFFC499, 0x00000000},
    {0xFFFFEFE8, 0x00000000}, {0x00001B73, 0x00000000}, {0x00003084, 0x00000000}, {0x000025A3, 0x00000000},
    {0x0000041F, 0x00000000}, {0xFFFFE28C, 0x00000000}, {0xFFFFD77C, 0x00000000}, {0xFFFFEC3E, 0x00000000},
    {0x0000175E, 0x00000000}, {0x00004224, 0x00000000}, {0x000055DA, 0x00000000}, {0x0000490F, 0x00000000},
    {0x00002518, 0x00000000}, {0x00000092, 0x00000000}, {0xFFFFF21E, 0x00000000}, {0x00000313, 0x00000000},
    {0x00002A0F, 0x00000000}, {0x0000506A, 0x00000000}, {0x00005F7D, 0x00000000}, {0x00004DE9, 0x00000000},
    {0x00002518, 0x00000000}, {0xFFFFFBB9, 0x00000000}, {0xFFFFE87B, 0x00000000}, {0xFFFFF4CE, 0x00000000},
    {0x0000175E, 0x00000000}, {0x00003994, 0x00000000}, {0x000044DB, 0x00000000}, {0x00002FE2, 0x00000000},
    {0x0000041F, 0x00000000}, {0xFFFFD84D, 0x00000000}, {0xFFFFC325, 0x00000000}, {0xFFFFCE1D, 0x00000000},
    {0xFFFFEFE8, 0x00000000}, {0x000011EF, 0x00000000}, {0x00001DA1, 0x00000000}, {0x000009AA, 0x00000000},
    {0xFFFFDF7D, 0x00000000}, {0xFFFFB5CC, 0x00000000}, {0xFFFFA34A, 0x00000000}, {0xFFFFB164, 0x00000000},
    {0xFFFFD6BF, 0x00000000}, {0xFFFFFCB9, 0x00000000}, {0x00000CAC, 0x00000000}, {0xFFFFFD3B, 0x00000000},
    {0xFFFFD7C0, 0x00000000}, {0xFFFFB2E1, 0x00000000}, {0xFFFFA53C, 0x00000000}, {0xFFFFB82C, 0x00000000},
    {0xFFFFE242, 0x00000000}, {0x00000CCA, 0x00000000}, {0x00002110, 0x00000000}, {0x0000159F, 0x00000000},
    {0xFFFFF3CB, 0x00000000}, {0xFFFFD224, 0x00000000}, {0xFFFFC740, 0x00000000}, {0xFFFFDC6D, 0x00000000},
    {0x00000834, 0x00000000}, {0x000033DD, 0x00000000}, {0x000048AB, 0x00000000}, {0x00003D2C, 0x00000000},
    {0x00001AAF, 0x00000000}, {0xFFFFF7CC, 0x00000000}, {0xFFFFEB19, 0x00000000}, {0xFFFFFDEE, 0x00000000},
    {0x000026DC, 0x00000000}, {0x00004F35, 0x00000000}, {0x0000604B, 0x00000000}, {0x000050B8, 0x00000000},
    {0x000029DC, 0x00000000}, {0x0000025E, 0x00000000}, {0xFFFFF0EB, 0x00000000}, {0xFFFFFEE7, 0x00000000},
    {0x000022F9, 0x00000000}, {0x00004685, 0x00000000}, {0x000052EF, 0x00000000}, {0x00003EE3, 0x00000000},
    {0x000013D4, 0x00000000}, {0xFFFFE878, 0x00000000}, {0xFFFFD389, 0x00000000}, {0xFFFFDE7B, 0x00000000},
    {0x00000000, 0x00000000}, {0x00002185, 0x00000000}, {0x00002C77, 0x00000000}, {0x00001788, 0x00000000},
    {0xFFFFEC2C, 0x00000000}, {0xFFFFC11D, 0x00000000}, {0xFFFFAD11, 0x00000000}, {0xFFFFB97B, 0x00000000},
    {0xFFFFDD07, 0x00000000}, {0x00000119, 0x00000000}, {0x00000F15, 0x00000000}, {0xFFFFFDA2, 0x00000000},
    {0xFFFFD624, 0x00000000}, {0xFFFFAF48, 0x00000000}, {0xFFFF9FB5, 0x00000000}, {0xFFFFB0CB, 0x00000000},
    {0xFFFFD924, 0x00000000}, {0x00000212, 0x00000000}, {0x000014E7, 0x00000000}, {0x00000834, 0x00000000},
    {0xFFFFE551, 0x00000000}, {0xFFFFC2D4, 0x00000000}, {0xFFFFB755, 0x00000000}, {0xFFFFCC23, 0x00000000},
    {0xFFFFF7CC, 0x00000000}, {0x00002393, 0x00000000}, {0x000038C0, 0x00000000}, {0x00002DDC, 0x00000000},
    {0x00000C35, 0x00000000}, {0xFFFFEA61, 0x00000000}, {0xFFFFDEF0, 0x00000000}, {0xFFFFF336, 0x00000000},
    {0x00001DBE, 0x00000000}, {0x000047D4, 0x00000000}, {0x00005AC4, 0x00000000}, {0x00004D1F, 0x00000000},
    {0x00002840, 0x00000000}, {0x000002C5, 0x00000000}, {0xFFFFF354, 0x00000000}, {0x00000347, 0x00000000},
    {0x00002941, 0x00000000}, {0x00004E9C, 0x00000000}, {0x00005CB6, 0x00000000}, {0x00004A34, 0x00000000},
    {0x00002083, 0x00000000}, {0xFFFFF656, 0x00000000}, {0xFFFFE25F, 0x00000000}, {0xFFFFEE11, 0x00000000},
    {0x00001018, 0x00000000}, {0x000031E3, 0x00000000}, {0x00003CDB, 0x00000000}, {0x000027B3, 0x00000000},
    {0xFFFFFBE1, 0x00000000}, {0xFFFFD01E, 0x00000000}, {0xFFFFBB25, 0x00000000}, {0xFFFFC66C, 0x00000000},
    {0xFFFFE8A2, 0x00000000}, {0x00000B32, 0x00000000}, {0x00001785, 0x00000000}, {0x00000447, 0x00000000},
    {0xFFFFDAE8, 0x00000000}, {0xFFFFB217, 0x00000000}, {0xFFFFA083, 0x00000000}, {0xFFFFAF96, 0x00000000},
    {0xFFFFD5F0, 0x00000000}, {0xFFFFFCED, 0x00000000}, {0x00000DE2, 0x00000000}, {0xFFFFFF6E, 0x00000000},
    {0xFFFFDAE8, 0x00000000}, {0xFFFFB6F1, 0x00000000}, {0xFFFFAA26, 0x00000000}, {0xFFFFBDDC, 0x00000000},
    {0xFFFFE8A2, 0x00000000}, {0x000013C2, 0x00000000}, {0x00002884, 0x00000000}, {0x00001D74, 0x00000000},
    {0xFFFFFBE1, 0x00000000}, {0xFFFFDA5D, 0x00000000}, {0xFFFFCF7C, 0x00000000}, {0xFFFFE48D, 0x00000000},
    {0x00001018, 0x00000000}, {0x00003B67, 0x00000000}, {0x00004FBE, 0x00000000}, {0x000043AC, 0x00000000},
    {0x00002083, 0x00000000}, {0xFFFFFCDE, 0x00000000}, {0xFFFFEF57, 0x00000000}, {0x00000145, 0x00000000},
    {0x00002941, 0x00000000}, {0x0000509E, 0x00000000}, {0x000060B3, 0x00000000}, {0x0000501C, 0x00000000},
    {0x00002840, 0x00000000}, {0xFFFFFFC9, 0x00000000}, {0xFFFFED65, 0x00000000}, {0xFFFFFA7E, 0x00000000},
    {0x00001DBE, 0x00000000}, {0x0000408C, 0x00000000}, {0x00004C4F, 0x00000000}, {0x000037B7, 0x00000000},
    {0x00000C35, 0x00000000}, {0xFFFFE086, 0x00000000}, {0xFFFFCB61, 0x00000000}, {0xFFFFD63D, 0x00000000},
    {0xFFFFF7CC, 0x00000000}, {0x00001979, 0x00000000}, {0x000024B4, 0x00000000}, {0x0000102A, 0x00000000},
    {0xFFFFE551, 0x00000000}, {0xFFFFBADE, 0x00000000}, {0xFFFFA788, 0x00000000}, {0xFFFFB4BC, 0x00000000},
    {0xFFFFD924, 0x00000000}, {0xFFFFFE22, 0x00000000}, {0x00000D14, 0x00000000}, {0xFFFFFC9F, 0x00000000},
    {0xFFFFD624, 0x00000000}, {0xFFFFB04B, 0x00000000}, {0xFFFFA1B6, 0x00000000}, {0xFFFFB3C3, 0x00000000},
    {0xFFFFDD07, 0x00000000}, {0x000006D1, 0x00000000}, {0x00001A70, 0x00000000}, {0x00000E73, 0x00000000},
    {0xFFFFEC2C, 0x00000000}, {0xFFFFCA32, 0x00000000}, {0xFFFFBF18, 0x00000000}, {0xFFFFD42F, 0x00000000}};

    volatile kiss_fft_cpx fout[FFT_LEN];
    int i;
    alt_u32 fft_start_time;
    alt_u32 fft_end_time;
    alt_u32 timestamp_overhead_time;

    printf ("Start Program\n");

    /*
     * Initialize the destination memory area to see that the FFT has actually calculated something.
     */
    for (i = 0; i < FFT_LEN; i++) {
    	fout[i].i = 0xDEADDEAD;
    	fout[i].r = 0xDEADDEAD;
    }

    /*
     * Reset (initialize to zero) all section counters and the global
     * counter of the performance_counter peripheral.
     */
    PERF_RESET (PERFORMANCE_COUNTER_BASE);

    if (alt_timestamp_start () < 0) {
        printf ("No timestamp device is available.\n");
    } else {

        cfg = kiss_fft_alloc (FFT_LEN, 0, NULL, 0);
        if (! cfg) {
            printf ("Error: Cannot allocate memory for FFT control structure.\n");
            return 1;
        }

        fft_start_time = alt_timestamp();

        kiss_fft (cfg, fin, fout);

        fft_end_time = alt_timestamp();

        /*
         * Measure the time overhead to read the timestamp timer by subsequently
         * calling alt_timestamp() back to back.
         */
        timestamp_overhead_time = alt_timestamp();

        /*
         * Print-out the Timestamp interval timer peripheral measurements.
         */
        printf("Actual time in checksum_test = %u ticks\n",
               (unsigned int) ((fft_end_time - fft_start_time) -
               (timestamp_overhead_time - fft_end_time)));
        printf("Timestamp timer frequency = %u\n",
               (unsigned int) alt_timestamp_freq());

        printf ("Finished.\n");

        /*
         *  Print out the FFT result.
         */
        for (i = 0; i < FFT_LEN; i++) {
            printf ("%X - %X\n", (int) fout[i].r, (int) fout[i].i);
        }

    }

    /*
     * Endless loop 
     */
    while (1) {
    }
    return 0;
}

