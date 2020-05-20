/*
 * mtrand_c_interface.cpp
 *
 *  Created on: Jan 23, 2012
 *      Author: linnyair
 */

#include "mtrand_c_interface.h"
#include <stdio.h>
#include <stdlib.h>
#include "mtrand.h"

int mtrand() {

	static unsigned long init[4] = {0x123, 0x234, 0x345, 0x456}, length = 4;
	static MTRand_int32 irand(init, length); // 32-bit int generator
	// this is an example of initializing by an array
	// you may use MTRand(seed) with any 32bit integer

	return  irand();
}


