#ifndef TEST_MANAGEMENT_H_
#define TEST_MANAGEMENT_H_

//#include "error_packet_discard.h"
#include "overflow_packet_discard.h"
#include "prbs_packet_checker.h"
#include "prbs_packet_generator.h"
#include "udp_payload_extractor.h"
#include "udp_payload_inserter.h"
#include "udp_port_to_channel_mapper.h"
#include "in_utils.h"

extern void udp_demo_init(void);
extern int pio_printf_out(long id, char * outbuf, int len);
extern struct GenericIO out_pio_default;
extern int execute_udp_stream_command (const char * command_name, const char* full_command_str);

#endif /*TEST_MANAGEMENT_H_*/
