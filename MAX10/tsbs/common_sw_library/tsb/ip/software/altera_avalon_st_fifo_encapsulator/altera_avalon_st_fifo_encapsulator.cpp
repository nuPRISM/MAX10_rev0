/*
 * altera_avalon_st_fifo_encapsulator.cpp
 *
 *  Created on: Mar 20, 2016
 *      Author: user
 */
extern "C" {
#include "altera_avalon_fifo_util.h"
}
#include "altera_avalon_st_fifo_encapsulator.h"


altera_avalon_st_fifo_encapsulator::~altera_avalon_st_fifo_encapsulator() {
	// TODO Auto-generated destructor stub
}


int altera_avalon_st_fifo_encapsulator::init(alt_u32 ienable,
  alt_u32 emptymark, alt_u32 fullmark){
	return altera_avalon_fifo_init(this->get_base_address(),ienable,emptymark, fullmark);
};

int altera_avalon_st_fifo_encapsulator::read_status(alt_u32 mask){return altera_avalon_fifo_read_status(this->get_base_address(),mask);   };
int altera_avalon_st_fifo_encapsulator::read_ienable(alt_u32 mask){return altera_avalon_fifo_read_ienable(this->get_base_address(),mask);   };
int altera_avalon_st_fifo_encapsulator::read_almostfull(){return altera_avalon_fifo_read_almostfull(this->get_base_address());   };
int altera_avalon_st_fifo_encapsulator::read_almostempty(){return altera_avalon_fifo_read_almostempty(this->get_base_address());   };
int altera_avalon_st_fifo_encapsulator::read_event(alt_u32 mask){return altera_avalon_fifo_read_event(this->get_base_address(),mask);   };
int altera_avalon_st_fifo_encapsulator::read_level(){return altera_avalon_fifo_read_level(this->get_base_address());   };

int altera_avalon_st_fifo_encapsulator::clear_event(alt_u32 mask){return altera_avalon_fifo_clear_event(this->get_base_address(),mask);   };
int altera_avalon_st_fifo_encapsulator::write_ienable(alt_u32 mask){return altera_avalon_fifo_write_ienable(this->get_base_address(),mask);   };

