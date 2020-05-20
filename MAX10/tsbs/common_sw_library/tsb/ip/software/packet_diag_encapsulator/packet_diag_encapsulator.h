
#ifndef PACKET_DIAG_ENCAPSULATOR_H_
#define PACKET_DIAG_ENCAPSULATOR_H_

#include "generic_driver_encapsulator.h"

namespace pdiag {
	const unsigned int packet_diag_SPAN_IN_BYTES = 64;
	
	typedef enum {                                    
				PACKET_DIAG_CONTROL_REG                                    = 0 ,
				PACKET_DIAG_STATUS_REG                                     = 1 ,
				PACKET_DIAG_NUM_OF_PACKETS                                 = 2 ,
				PACKET_DIAG_SOP_2_EOP_CAPTURE_REG                          = 3 ,
				PACKET_DIAG_SOP_2_SOP_CAPTURE_REG                          = 4 ,
				PACKET_DIAG_SOP_2_EOP_REG                                  = 5 ,
				PACKET_DIAG_SOP_2_SOP_REG                                  = 6 ,
				PACKET_DIAG_VALID_COUNTER_REG                              = 7 ,
				PACKET_DIAG_VALID_COUNTER_CAPTURE_REG                      = 8 ,
				PACKET_DIAG_IN_PACKET_CONTROL                              = 9 ,
				PACKET_DIAG_IN_PACKET_DATA                                 = 10,
				PACKET_DIAG_OUT_PACKET_CONTROL                             = 12,
				PACKET_DIAG_OUT_PACKET_DATA                                = 13,
				PACKET_DIAG_FOUND_VALID_PACKET                             = 11,
				PACKET_DIAG_PACKET_LENGTH_AT_ERROR                         = 14,
				PACKET_DIAG_NUM_PACKET_ERRORS                              = 15,
				PACKET_DIAG_PACKET_NUM_AT_ERROR                            = 16,
				PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY                 = 17,
				PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_VALID                 = 18,
				PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY_AND_VALID       = 19,
				PACKET_DIAG_S2S_READY_COUNT                                = 20,
				PACKET_DIAG_S2S_VALID_COUNT                                = 21,
				PACKET_DIAG_S2S_READY_AND_VALID_COUNT                      = 22,
				PACKET_DIAG_S2S_NOT_READY_AND_NOT_VALID_COUNT              = 23,
				PACKET_DIAG_COMPARED_PACKET_LENGTH_START                   = 48,
				PACKET_DIAG_NUM_COMPARED_PACKETS_REG_ADDR                  = 63
	} packet_diag_address_map_type;
	
	const unsigned int PACKET_DIAGNOSTICS_ENABLED_BITNUM = 4;

class packet_diag_encapsulator: public generic_driver_encapsulator {
public:
	packet_diag_encapsulator() : generic_driver_encapsulator() {
	};
	packet_diag_encapsulator(unsigned long the_base_address, std::string name = "undefined") :
		generic_driver_encapsulator(the_base_address,packet_diag_SPAN_IN_BYTES,name) {
	};

	unsigned long get_PACKET_DIAG_CONTROL_REG                           () { return this->read( PACKET_DIAG_CONTROL_REG                    ); };
	unsigned long get_PACKET_DIAG_STATUS_REG                            () { return this->read( PACKET_DIAG_STATUS_REG                     ); };
	unsigned long get_PACKET_DIAG_NUM_OF_PACKETS                        () { return this->read( PACKET_DIAG_NUM_OF_PACKETS                 ); };
	unsigned long get_PACKET_DIAG_SOP_2_EOP_CAPTURE_REG                       () { return this->read( PACKET_DIAG_SOP_2_EOP_CAPTURE_REG                ); };
	unsigned long get_PACKET_DIAG_SOP_2_SOP_CAPTURE_REG                       () { return this->read( PACKET_DIAG_SOP_2_SOP_CAPTURE_REG                ); };
	unsigned long get_PACKET_DIAG_SOP_2_EOP_REG                               () { return this->read( PACKET_DIAG_SOP_2_EOP_REG                        ); };
	unsigned long get_PACKET_DIAG_SOP_2_SOP_REG                               () { return this->read( PACKET_DIAG_SOP_2_SOP_REG                        ); };
	unsigned long get_PACKET_DIAG_VALID_COUNTER_REG                     () { return this->read( PACKET_DIAG_VALID_COUNTER_REG              ); };
	unsigned long get_PACKET_DIAG_VALID_COUNTER_CAPTURE_REG              () { return this->read( PACKET_DIAG_VALID_COUNTER_CAPTURE_REG       ); };
	unsigned long get_PACKET_DIAG_IN_PACKET_CONTROL                     () { return this->read( PACKET_DIAG_IN_PACKET_CONTROL              ); };
	unsigned long get_PACKET_DIAG_IN_PACKET_DATA                        () { return this->read( PACKET_DIAG_IN_PACKET_DATA                 ); };
	unsigned long get_PACKET_DIAG_OUT_PACKET_CONTROL                    () { return this->read( PACKET_DIAG_OUT_PACKET_CONTROL             ); };
	unsigned long get_PACKET_DIAG_OUT_PACKET_DATA                       () { return this->read( PACKET_DIAG_OUT_PACKET_DATA                ); };
	unsigned long get_PACKET_DIAG_NUM_COMPARED_PACKETS                      () { return this->read( PACKET_DIAG_NUM_COMPARED_PACKETS_REG_ADDR                ); };
	unsigned long get_PACKET_DIAG_PACKET_LENGTH_AT_ERROR                       () { return this->read( PACKET_DIAG_PACKET_LENGTH_AT_ERROR                ); };
	unsigned long get_PACKET_DIAG_NUM_PACKET_ERRORS                       () { return this->read( PACKET_DIAG_NUM_PACKET_ERRORS                ); };
	unsigned long get_PACKET_DIAG_FOUND_VALID_PACKET                      () { return this->read( PACKET_DIAG_FOUND_VALID_PACKET                ); };
	unsigned long get_PACKET_DIAG_PACKET_NUM_AT_ERROR                      () { return this->read( PACKET_DIAG_PACKET_NUM_AT_ERROR                ); };
	unsigned long get_PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY                                      () { return this->read( PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY                             ); };
	unsigned long get_PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_VALID                                      () { return this->read( PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_VALID                             ); };
	unsigned long get_PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY_AND_VALID                            () { return this->read( PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY_AND_VALID                   ); };
	unsigned long get_PACKET_DIAG_S2S_READY_COUNT                                                     () { return this->read( PACKET_DIAG_S2S_READY_COUNT                                            ); };
	unsigned long get_PACKET_DIAG_S2S_VALID_COUNT                                                     () { return this->read( PACKET_DIAG_S2S_VALID_COUNT                                            ); };
	unsigned long get_PACKET_DIAG_S2S_READY_AND_VALID_COUNT                                           () { return this->read( PACKET_DIAG_S2S_READY_AND_VALID_COUNT                                  ); };
    unsigned long get_PACKET_DIAG_S2S_NOT_READY_AND_NOT_VALID_COUNT                                   () { return this->read( PACKET_DIAG_S2S_NOT_READY_AND_NOT_VALID_COUNT                          ); };

	unsigned long get_PACKET_DIAG_COMPARED_PACKET_LENGTH (unsigned int i) {
		unsigned int current_compared_packet_length_address = PACKET_DIAG_COMPARED_PACKET_LENGTH_START + i;
		if (current_compared_packet_length_address >=   PACKET_DIAG_NUM_COMPARED_PACKETS_REG_ADDR) {
			return 0xFFFFFFFF; //error
		} else {
	       return this->read( current_compared_packet_length_address );
		};
	}

	int set_PACKET_DIAG_COMPARED_PACKET_LENGTH (unsigned int i, unsigned int val) {
		unsigned int current_compared_packet_length_address = PACKET_DIAG_COMPARED_PACKET_LENGTH_START + i;
		if (current_compared_packet_length_address >=   PACKET_DIAG_NUM_COMPARED_PACKETS_REG_ADDR) {
			return 0; //error
		} else {
	       this->write( current_compared_packet_length_address, val );
	       return 1;
		};
	}

	void set_CONTROL_REG                       (unsigned long x) { this->write( PACKET_DIAG_CONTROL_REG,x); };

	bool is_enabled() { return (this->get_bit(PACKET_DIAG_STATUS_REG,PACKET_DIAGNOSTICS_ENABLED_BITNUM) != 0); };

	virtual ~packet_diag_encapsulator();

};
}
#endif /* cameralink_rx_encapsulator_H_ */
