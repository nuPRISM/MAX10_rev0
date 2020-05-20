/*
 * low_level_counter.cpp
 *
 *  Created on: Jun 29, 2017
 *      Author: user
 */

#include "low_level_counter.h"
#include "io.h"

namespace llvcnt {

low_level_counter::low_level_counter() {
	// TODO Auto-generated constructor stub

}

low_level_counter::low_level_counter(std::string name, unsigned long base)  {
	this->set_base(base);
	this->set_name(name);
}

low_level_counter::~low_level_counter() {
	// TODO Auto-generated destructor stub
}

unsigned long long low_level_counter::get_timestamp() {

	//Note: one should really call this using mutual exclusion in order that snapl and snaph agree
	IOWR(base,0,0); //write operation gets snapshot of counter
	unsigned long long snapl = (unsigned long long) (IORD(base,0));
	unsigned long long snaph = (unsigned long long) (IORD(base,1));
	snapl = snapl & 0xFFFFFFFF;
	snaph = snaph & 0xFFFFFFFF;
	unsigned long long total_time = (snaph << 32) + snapl;
   	return total_time;
	return 0;
}

} /* namespace llvcnt */
