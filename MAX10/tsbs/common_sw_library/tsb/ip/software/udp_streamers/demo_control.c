/* MicroC/OS-II definitions */
#include "includes.h"

#include <math.h>
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "ipport.h"
#include "menu.h"
#include "demo_control.h"
#include "altera_eth_tse_regs.h"
#include "demo_tasks.h"
#include <sys/alt_timestamp.h>
#include <stdio.h>
#include "xprintf.h"
#include "in_utils.h"
#include "basedef.h"
#include "cpp_to_c_header_interface.h"

int display_build(void * pio);
int dump_all(void * pio);
int dump_common(void * pio);
int dump_chan_0(void * pio);
int dump_chan_1(void * pio);
int dump_chan_2(void * pio);
int dump_chan_3(void * pio);
int dump_mac_info(void * pio);
int start_stream(void * pio);
int stop_stream(void * pio);
int stat_stream(void * pio);
int rx_pps(void * pio);

void print_packet_checker_stats(void *pio, PKT_CHKR_STATS *stats);
void print_packet_generator_stats(void *pio, PKT_GEN_STATS *stats);
void print_udp_payload_extractor_stats(void *pio, UDP_EXT_STATS *stats);
void print_udp_payload_inserter_stats(void *pio, UDP_INS_STATS *stats);
void print_udp_port_to_channel_mapper_stats(void *pio, CHAN_MAP_STATS *stats);
//void print_error_packet_discard_stats(void *pio, EPD_STATS *stats);
void print_overflow_packet_discard_stats(void *pio, OPD_STATS *stats);

int pio_printf_out(long id, char * outbuf, int len){
	//xprintf("%s",outbuf);
	c_print_out_to_all_streams(outbuf);
	return len;
}

struct GenericIO out_pio_default;
typedef int (*menu_op_func_type)(void * pio);

int dispatch_nsmenu_func( menu_op_func_type piofunc, const char* arg_str ) {
	snprintf(out_pio_default.inbuf, MAX_PIO_INBUF_CHARS-5, "%s",arg_str);
	return (piofunc((void*) &out_pio_default));
}
//
//	Menu definition for InterNiche menu command environment
//
//the commands need to be in alphabetical order
struct command {
    char *name;
    menu_op_func_type cmd_func;
    char* desc;
} command_tbl[] =
{
	//{ "build",				display_build,		"Built on " __DATE__ " at " __TIME__} ,
	//{ "cpu_stats",			cpu_stats,			"Dump CPU runtime statistics." } ,
	//{ "clear_cpu_stats",	clear_cpu_stats,	"Clear the CPU statistics." } ,
	{ "dump_all",			dump_all,			"Dump all status registers for packet pipeline." } ,
	{ "dump_chan_0",		dump_chan_0,		"Dump the channel 0 status registers." } ,
	{ "dump_chan_1",		dump_chan_1,		"Dump the channel 1 status registers." } ,
	{ "dump_chan_2",		dump_chan_2,		"Dump the channel 2 status registers." } ,
	{ "dump_chan_3",		dump_chan_3,		"Dump the channel 3 status registers." } ,
	{ "dump_common",		dump_common,		"Dump the common status registers for packet pipeline." } ,
	{ "dump_mac_info",		dump_mac_info,		"Dump the MAC registers." } ,
	//{ "rx_pps",				rx_pps,				"Samples instantaneous RX bandwidth for all streams." },
	//{ "start_stream",		start_stream,		"start_stream <ip_addr> <packet_length> - starts a new stream" } ,
	{ "stat_stream",		stat_stream,		"Shows state of all streams" },
	//{ "stop_stream",		stop_stream,		"stop_stream <channel> - stops a stream, use 0-3 or 4 for all" } ,
};


#define N_CMDS (sizeof command_tbl / sizeof command_tbl[0])

static int comp_cmd(const void *c1, const void *c2)
{
    const struct command *cmd1 = c1, *cmd2 = c2;

    //return memcmp(cmd1->name, cmd2->name, 2); //change this to something better
    return strcmp(cmd1->name, cmd2->name);
}

static struct command *get_cmd(char *name)
{
    struct command target = { name, NULL };

    return bsearch(&target, command_tbl, N_CMDS, sizeof command_tbl[0], comp_cmd);
}


int execute_udp_stream_command (const char * command_name, const char* full_command_str)
{
	struct command *cmd = get_cmd(command_name);

	if (cmd) {
	    return (dispatch_nsmenu_func(cmd->cmd_func,full_command_str));
	} else {
		xprintf("Error: execute_udp_stream_command commmand not found (%s) full command str = (%s)!\n", command_name,full_command_str);
		return -1;
	}
	return -1;
}










//
//	Initialize our menu and add it to the menu system so we can invoke our menu
//	commands from a console or telnet session.
//
void udp_demo_init(void) {
	out_pio_default.inbuf = calloc(MAX_PIO_INBUF_CHARS,sizeof(char));
	out_pio_default.getch = NULL;
	out_pio_default.id = 123;
	out_pio_default.out = pio_printf_out;

	// turn off user leds
	//IOWR_ALTERA_AVALON_PIO_DATA(LED_PIO_BASE, 0xFF);
	
	// install menu applications
	/*
	if (install_menu(demo_menu)) {
		ns_printf(0, "\nUDP Demo Menu failed to install...\n");
	} else {
		display_build(NULL);
		ns_printf(0, "UDP Demo Menu installed and ready to use...\n");
		ns_printf(0, "Type \"help\" and \"help udpoffload\" for more information.\n");
	}
	*/
}

//
//	This menu command displays the build date and time of this application
//
int display_build(void * pio) {

    ns_printf(pio,"\nBuilt on %s at %s\n\n", __DATE__, __TIME__);

    return 0;
}

//
//	This menu command displays the control and status registers for all of the
//	custom peripherals in the packet pipeline.
//	
int dump_all(void * pio) {
	
	PKT_CHKR_STATS checker_0, checker_1, checker_2, checker_3;
	PKT_GEN_STATS generator_0, generator_1, generator_2, generator_3;
	UDP_EXT_STATS extractor_0, extractor_1, extractor_2, extractor_3;
	UDP_INS_STATS inserter_0, inserter_1, inserter_2, inserter_3;
	CHAN_MAP_STATS channel_mapper;
	//EPD_STATS error_packet_discard;
	OPD_STATS overflow_packet_discard;
#ifdef UDP_INSERTER_0_BASE
	get_udp_payload_inserter_stats((void*)UDP_INSERTER_0_BASE, &inserter_0);
	get_udp_payload_inserter_stats((void*)UDP_INSERTER_1_BASE, &inserter_1);
	get_udp_payload_inserter_stats((void*)UDP_INSERTER_2_BASE, &inserter_2);
	get_udp_payload_inserter_stats((void*)UDP_INSERTER_3_BASE, &inserter_3);
#endif
	
	ns_printf(pio, "Complete Status Dump...\n");
	
	ns_printf(pio, "******************* INSERTER 0 STATUS *********************\n\n");
	print_udp_payload_inserter_stats(pio, &inserter_0);
	ns_printf(pio, "******************* INSERTER 1 STATUS *********************\n\n");
	print_udp_payload_inserter_stats(pio, &inserter_1);
	ns_printf(pio, "******************* INSERTER 2 STATUS *********************\n\n");
	print_udp_payload_inserter_stats(pio, &inserter_2);
	ns_printf(pio, "******************* INSERTER 3 STATUS *********************\n\n");
	print_udp_payload_inserter_stats(pio, &inserter_3);
	
	ns_printf(pio, "***************** CHANNEL MAPPER STATUS *******************\n\n");
	print_udp_port_to_channel_mapper_stats(pio, &channel_mapper);
/*
	ns_printf(pio, "******************* ERROR PACKET STATUS *******************\n\n");
	print_error_packet_discard_stats(pio, &error_packet_discard);
	*/
	ns_printf(pio, "***************** OVERFLOW PACKET STATUS ******************\n\n");
	print_overflow_packet_discard_stats(pio, &overflow_packet_discard);

	return 0;
}

//
//	This menu command displays the control and status registers for the common
//	custom peripherals in the packet pipeline, no dedicated channel peripherals.
//	
int dump_common(void * pio) {
	
	CHAN_MAP_STATS channel_mapper;
	//EPD_STATS error_packet_discard;
	OPD_STATS overflow_packet_discard;
	
	
	ns_printf(pio, "Common Status Dump...\n");
	
	
	return 0;
}

//
//	This menu command displays the control and status registers for only the
//	channel 0 related custom peripherals in the packet pipeline.
//	
int dump_chan_0(void * pio) {
	
	UDP_INS_STATS inserter;
#ifdef UDP_INSERTER_0_BASE
	get_udp_payload_inserter_stats((void*)UDP_INSERTER_0_BASE, &inserter);
#endif
	ns_printf(pio, "Channel 0 Status Dump...\n");
	
		ns_printf(pio, "******************* INSERTER 0 STATUS *********************\n\n");
	print_udp_payload_inserter_stats(pio, &inserter);
	
	return 0;
}

//
//	This menu command displays the control and status registers for only the
//	channel 1 related custom peripherals in the packet pipeline.
//	
int dump_chan_1(void * pio) {
	
	UDP_INS_STATS inserter;
#ifdef UDP_INSERTER_1_BASE
	get_udp_payload_inserter_stats((void*)UDP_INSERTER_1_BASE, &inserter);
#endif
	ns_printf(pio, "Channel 1 Status Dump...\n");
	
	ns_printf(pio, "******************* INSERTER 1 STATUS *********************\n\n");
	print_udp_payload_inserter_stats(pio, &inserter);
	
	return 0;
}

//
//	This menu command displays the control and status registers for only the
//	channel 2 related custom peripherals in the packet pipeline.
//	
int dump_chan_2(void * pio) {
	
    UDP_INS_STATS inserter;
#ifdef UDP_INSERTER_2_BASE
	get_udp_payload_inserter_stats((void*)UDP_INSERTER_2_BASE, &inserter);
#endif
	ns_printf(pio, "Channel 2 Status Dump...\n");
	
	
	ns_printf(pio, "******************* INSERTER 2 STATUS *********************\n\n");
	print_udp_payload_inserter_stats(pio, &inserter);
	
	return 0;
}

//
//	This menu command displays the control and status registers for only the
//	channel 3 related custom peripherals in the packet pipeline.
//	
int dump_chan_3(void * pio) {
	
	UDP_INS_STATS inserter;
#ifdef UDP_INSERTER_3_BASE
	get_udp_payload_inserter_stats((void*)UDP_INSERTER_3_BASE, &inserter);
#endif
	ns_printf(pio, "Channel 3 Status Dump...\n");
	

	ns_printf(pio, "******************* INSERTER 3 STATUS *********************\n\n");
	print_udp_payload_inserter_stats(pio, &inserter);
	
	return 0;
}

//
//	This menu command displays the control and status registers for the TSE MAC.
//	
int dump_mac_info(void * pio) {
	
	// allocate a structure to hold the current register values
	np_tse_mac MY_MAC;
	
	// read all the registers
	MY_MAC.REV								= IORD_ALTERA_TSEMAC_REV(TSE_MAC_BASE);
	MY_MAC.SCRATCH							= IORD_ALTERA_TSEMAC_SCRATCH(TSE_MAC_BASE);
	MY_MAC.COMMAND_CONFIG					= IORD_ALTERA_TSEMAC_CMD_CONFIG(TSE_MAC_BASE);
	MY_MAC.MAC_0							= IORD_ALTERA_TSEMAC_MAC_0(TSE_MAC_BASE);
	MY_MAC.MAC_1							= IORD_ALTERA_TSEMAC_MAC_1(TSE_MAC_BASE);
	MY_MAC.FRM_LENGTH						= IORD_ALTERA_TSEMAC_FRM_LENGTH(TSE_MAC_BASE);
	MY_MAC.PAUSE_QUANT						= IORD_ALTERA_TSEMAC_PAUSE_QUANT(TSE_MAC_BASE);
	MY_MAC.RX_SECTION_EMPTY					= IORD_ALTERA_TSEMAC_RX_SECTION_EMPTY(TSE_MAC_BASE);
	MY_MAC.RX_SECTION_FULL					= IORD_ALTERA_TSEMAC_RX_SECTION_FULL(TSE_MAC_BASE);
	MY_MAC.TX_SECTION_EMPTY					= IORD_ALTERA_TSEMAC_TX_SECTION_EMPTY(TSE_MAC_BASE);
	MY_MAC.TX_SECTION_FULL					= IORD_ALTERA_TSEMAC_TX_SECTION_FULL(TSE_MAC_BASE);
	MY_MAC.RX_ALMOST_EMPTY					= IORD_ALTERA_TSEMAC_RX_ALMOST_EMPTY(TSE_MAC_BASE);
	MY_MAC.RX_ALMOST_FULL					= IORD_ALTERA_TSEMAC_RX_ALMOST_FULL(TSE_MAC_BASE);
	MY_MAC.TX_ALMOST_EMPTY					= IORD_ALTERA_TSEMAC_TX_ALMOST_EMPTY(TSE_MAC_BASE);
	MY_MAC.TX_ALMOST_FULL					= IORD_ALTERA_TSEMAC_TX_ALMOST_FULL(TSE_MAC_BASE);
	MY_MAC.MDIO_ADDR0						= IORD_ALTERA_TSEMAC_MDIO_ADDR0(TSE_MAC_BASE);
	MY_MAC.MDIO_ADDR1						= IORD_ALTERA_TSEMAC_MDIO_ADDR1(TSE_MAC_BASE);
	MY_MAC.REG_STAT							= IORD_ALTERA_TSEMAC_REG_STAT(TSE_MAC_BASE);
	MY_MAC.TX_IPG_LENGTH					= IORD_ALTERA_TSEMAC_TX_IPG_LENGTH(TSE_MAC_BASE);
	MY_MAC.aMACID_1							= IORD_ALTERA_TSEMAC_A_MACID_1(TSE_MAC_BASE);
	MY_MAC.aMACID_2							= IORD_ALTERA_TSEMAC_A_MACID_2(TSE_MAC_BASE);
	MY_MAC.aFramesTransmittedOK				= IORD_ALTERA_TSEMAC_A_FRAMES_TX_OK(TSE_MAC_BASE);
	MY_MAC.aFramesReceivedOK				= IORD_ALTERA_TSEMAC_A_FRAMES_RX_OK(TSE_MAC_BASE);
	MY_MAC.aFramesCheckSequenceErrors		= IORD_ALTERA_TSEMAC_A_FRAME_CHECK_SEQ_ERRS(TSE_MAC_BASE);
	MY_MAC.aAlignmentErrors					= IORD_ALTERA_TSEMAC_A_ALIGNMENT_ERRS(TSE_MAC_BASE);
	MY_MAC.aOctetsTransmittedOK				= IORD_ALTERA_TSEMAC_A_OCTETS_TX_OK(TSE_MAC_BASE);
	MY_MAC.aOctetsReceivedOK				= IORD_ALTERA_TSEMAC_A_OCTETS_RX_OK(TSE_MAC_BASE);
	MY_MAC.aTxPAUSEMACCtrlFrames			= IORD_ALTERA_TSEMAC_A_TX_PAUSE_MAC_CTRL_FRAMES(TSE_MAC_BASE);
	MY_MAC.aRxPAUSEMACCtrlFrames			= IORD_ALTERA_TSEMAC_A_RX_PAUSE_MAC_CTRL_FRAMES(TSE_MAC_BASE);
	MY_MAC.ifInErrors						= IORD_ALTERA_TSEMAC_IF_IN_ERRORS(TSE_MAC_BASE);
	MY_MAC.ifOutErrors						= IORD_ALTERA_TSEMAC_IF_OUT_ERRORS(TSE_MAC_BASE);
	MY_MAC.ifInUcastPkts					= IORD_ALTERA_TSEMAC_IF_IN_UCAST_PKTS(TSE_MAC_BASE);
	MY_MAC.ifInMulticastPkts				= IORD_ALTERA_TSEMAC_IF_IN_MULTICAST_PKTS(TSE_MAC_BASE);
	MY_MAC.ifInBroadcastPkts				= IORD_ALTERA_TSEMAC_IF_IN_BROADCAST_PKTS(TSE_MAC_BASE);
	MY_MAC.ifOutDiscards					= IORD_ALTERA_TSEMAC_IF_OUT_DISCARDS(TSE_MAC_BASE);
	MY_MAC.ifOutUcastPkts					= IORD_ALTERA_TSEMAC_IF_OUT_UCAST_PKTS(TSE_MAC_BASE);
	MY_MAC.ifOutMulticastPkts				= IORD_ALTERA_TSEMAC_IF_OUT_MULTICAST_PKTS(TSE_MAC_BASE);
	MY_MAC.ifOutBroadcastPkts				= IORD_ALTERA_TSEMAC_IF_OUT_BROADCAST_PKTS(TSE_MAC_BASE);
	MY_MAC.etherStatsDropEvent				= IORD_ALTERA_TSEMAC_ETHER_STATS_DROP_EVENTS(TSE_MAC_BASE);
	MY_MAC.etherStatsOctets					= IORD_ALTERA_TSEMAC_ETHER_STATS_OCTETS(TSE_MAC_BASE);
	MY_MAC.etherStatsPkts					= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS(TSE_MAC_BASE);
	MY_MAC.etherStatsUndersizePkts			= IORD_ALTERA_TSEMAC_ETHER_STATS_UNDERSIZE_PKTS(TSE_MAC_BASE);
	MY_MAC.etherStatsOversizePkts			= IORD_ALTERA_TSEMAC_ETHER_STATS_OVERSIZE_PKTS(TSE_MAC_BASE);
	MY_MAC.etherStatsPkts64Octets			= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_64_OCTETS(TSE_MAC_BASE);
	MY_MAC.etherStatsPkts65to127Octets		= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_65_TO_127_OCTETS(TSE_MAC_BASE);
	MY_MAC.etherStatsPkts128to255Octets		= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_128_TO_255_OCTETS(TSE_MAC_BASE);
	MY_MAC.etherStatsPkts256to511Octets		= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_256_TO_511_OCTETS(TSE_MAC_BASE);
	MY_MAC.etherStatsPkts512to1023Octets	= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_512_TO_1023_OCTETS(TSE_MAC_BASE);
	MY_MAC.etherStatsPkts1024to1518Octets	= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_1024_TO_1518_OCTETS(TSE_MAC_BASE);
	MY_MAC.etherStatsPkts1519toXOctets						= IORD_ALTERA_TSEMAC_ETHER_STATS_PKTS_1519_TO_X_OCTETS(TSE_MAC_BASE);
	MY_MAC.etherStatsJabbers						= IORD_ALTERA_TSEMAC_ETHER_STATS_JABBERS(TSE_MAC_BASE);
	MY_MAC.etherStatsFragments						= IORD_ALTERA_TSEMAC_ETHER_STATS_FRAGMENTS(TSE_MAC_BASE);
	MY_MAC.TX_CMD_STAT						= IORD_ALTERA_TSEMAC_TX_CMD_STAT(TSE_MAC_BASE);
	MY_MAC.RX_CMD_STAT						= IORD_ALTERA_TSEMAC_RX_CMD_STAT(TSE_MAC_BASE);
	
	ns_printf(pio,"********************* CURRENT MAC STATS *********************\n\n", MY_MAC.REV);
	
	ns_printf(pio,"                           REV = 0x%08X\n", MY_MAC.REV);
	ns_printf(pio,"                       SCRATCH = 0x%08X\n", MY_MAC.SCRATCH);
	ns_printf(pio,"                COMMAND_CONFIG = 0x%08X\n", MY_MAC.COMMAND_CONFIG);
	ns_printf(pio,"                         MAC_0 = 0x%08X\n", MY_MAC.MAC_0);
	ns_printf(pio,"                         MAC_1 = 0x%08X\n", MY_MAC.MAC_1);
	ns_printf(pio,"                    FRM_LENGTH = 0x%08X  %uu\n", MY_MAC.FRM_LENGTH, MY_MAC.FRM_LENGTH);
	ns_printf(pio,"                   PAUSE_QUANT = 0x%08X\n", MY_MAC.PAUSE_QUANT);
	ns_printf(pio,"              RX_SECTION_EMPTY = 0x%08X\n", MY_MAC.RX_SECTION_EMPTY);
	ns_printf(pio,"               RX_SECTION_FULL = 0x%08X\n", MY_MAC.RX_SECTION_FULL);
	ns_printf(pio,"              TX_SECTION_EMPTY = 0x%08X\n", MY_MAC.TX_SECTION_EMPTY);
	ns_printf(pio,"               TX_SECTION_FULL = 0x%08X\n", MY_MAC.TX_SECTION_FULL);
	ns_printf(pio,"               RX_ALMOST_EMPTY = 0x%08X\n", MY_MAC.RX_ALMOST_EMPTY);
	ns_printf(pio,"                RX_ALMOST_FULL = 0x%08X\n", MY_MAC.RX_ALMOST_FULL);
	ns_printf(pio,"               TX_ALMOST_EMPTY = 0x%08X\n", MY_MAC.TX_ALMOST_EMPTY);
	ns_printf(pio,"                TX_ALMOST_FULL = 0x%08X\n", MY_MAC.TX_ALMOST_FULL);
	ns_printf(pio,"                    MDIO_ADDR0 = 0x%08X\n", MY_MAC.MDIO_ADDR0);
	ns_printf(pio,"                    MDIO_ADDR1 = 0x%08X\n", MY_MAC.MDIO_ADDR1);
	ns_printf(pio,"                      REG_STAT = 0x%08X\n", MY_MAC.REG_STAT);
	ns_printf(pio,"                 TX_IPG_LENGTH = 0x%08X  %uu\n", MY_MAC.TX_IPG_LENGTH, MY_MAC.TX_IPG_LENGTH);
	ns_printf(pio,"                      aMACID_1 = 0x%08X\n", MY_MAC.aMACID_1);
	ns_printf(pio,"                      aMACID_2 = 0x%08X\n", MY_MAC.aMACID_2);
	ns_printf(pio,"          aFramesTransmittedOK = 0x%08X  %uu\n", MY_MAC.aFramesTransmittedOK, MY_MAC.aFramesTransmittedOK);
	ns_printf(pio,"             aFramesReceivedOK = 0x%08X  %uu\n", MY_MAC.aFramesReceivedOK, MY_MAC.aFramesReceivedOK);
	ns_printf(pio,"    aFramesCheckSequenceErrors = 0x%08X  %uu\n", MY_MAC.aFramesCheckSequenceErrors, MY_MAC.aFramesCheckSequenceErrors);
	ns_printf(pio,"              aAlignmentErrors = 0x%08X  %uu\n", MY_MAC.aAlignmentErrors, MY_MAC.aAlignmentErrors);
	ns_printf(pio,"          aOctetsTransmittedOK = 0x%08X  %uu\n", MY_MAC.aOctetsTransmittedOK, MY_MAC.aOctetsTransmittedOK);
	ns_printf(pio,"             aOctetsReceivedOK = 0x%08X  %uu\n", MY_MAC.aOctetsReceivedOK, MY_MAC.aOctetsReceivedOK);
	ns_printf(pio,"         aTxPAUSEMACCtrlFrames = 0x%08X  %uu\n", MY_MAC.aTxPAUSEMACCtrlFrames, MY_MAC.aTxPAUSEMACCtrlFrames);
	ns_printf(pio,"         aRxPAUSEMACCtrlFrames = 0x%08X  %uu\n", MY_MAC.aRxPAUSEMACCtrlFrames, MY_MAC.aRxPAUSEMACCtrlFrames);
	ns_printf(pio,"                    ifInErrors = 0x%08X  %uu\n", MY_MAC.ifInErrors, MY_MAC.ifInErrors);
	ns_printf(pio,"                   ifOutErrors = 0x%08X  %uu\n", MY_MAC.ifOutErrors, MY_MAC.ifOutErrors);
	ns_printf(pio,"                 ifInUcastPkts = 0x%08X  %uu\n", MY_MAC.ifInUcastPkts, MY_MAC.ifInUcastPkts);
	ns_printf(pio,"             ifInMulticastPkts = 0x%08X  %uu\n", MY_MAC.ifInMulticastPkts, MY_MAC.ifInMulticastPkts);
	ns_printf(pio,"             ifInBroadcastPkts = 0x%08X  %uu\n", MY_MAC.ifInBroadcastPkts, MY_MAC.ifInBroadcastPkts);
	ns_printf(pio,"                 ifOutDiscards = 0x%08X  %uu\n", MY_MAC.ifOutDiscards, MY_MAC.ifOutDiscards);
	ns_printf(pio,"                ifOutUcastPkts = 0x%08X  %uu\n", MY_MAC.ifOutUcastPkts, MY_MAC.ifOutUcastPkts);
	ns_printf(pio,"            ifOutMulticastPkts = 0x%08X  %uu\n", MY_MAC.ifOutMulticastPkts, MY_MAC.ifOutMulticastPkts);
	ns_printf(pio,"            ifOutBroadcastPkts = 0x%08X  %uu\n", MY_MAC.ifOutBroadcastPkts, MY_MAC.ifOutBroadcastPkts);
	ns_printf(pio,"           etherStatsDropEvent = 0x%08X  %uu\n", MY_MAC.etherStatsDropEvent, MY_MAC.etherStatsDropEvent);
	ns_printf(pio,"              etherStatsOctets = 0x%08X  %uu\n", MY_MAC.etherStatsOctets, MY_MAC.etherStatsOctets);
	ns_printf(pio,"                etherStatsPkts = 0x%08X  %uu\n", MY_MAC.etherStatsPkts, MY_MAC.etherStatsPkts);
	ns_printf(pio,"       etherStatsUndersizePkts = 0x%08X  %uu\n", MY_MAC.etherStatsUndersizePkts, MY_MAC.etherStatsUndersizePkts);
	ns_printf(pio,"        etherStatsOversizePkts = 0x%08X  %uu\n", MY_MAC.etherStatsOversizePkts, MY_MAC.etherStatsOversizePkts);
	ns_printf(pio,"        etherStatsPkts64Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts64Octets, MY_MAC.etherStatsPkts64Octets);
	ns_printf(pio,"   etherStatsPkts65to127Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts65to127Octets, MY_MAC.etherStatsPkts65to127Octets);
	ns_printf(pio,"  etherStatsPkts128to255Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts128to255Octets, MY_MAC.etherStatsPkts128to255Octets);
	ns_printf(pio,"  etherStatsPkts256to511Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts256to511Octets, MY_MAC.etherStatsPkts256to511Octets);
	ns_printf(pio," etherStatsPkts512to1023Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts512to1023Octets, MY_MAC.etherStatsPkts512to1023Octets);
	ns_printf(pio,"etherStatsPkts1024to1518Octets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts1024to1518Octets, MY_MAC.etherStatsPkts1024to1518Octets);
	ns_printf(pio,"   etherStatsPkts1519toXOctets = 0x%08X  %uu\n", MY_MAC.etherStatsPkts1519toXOctets, MY_MAC.etherStatsPkts1519toXOctets);
	ns_printf(pio,"             etherStatsJabbers = 0x%08X  %uu\n", MY_MAC.etherStatsJabbers, MY_MAC.etherStatsJabbers);
	ns_printf(pio,"           etherStatsFragments = 0x%08X  %uu\n", MY_MAC.etherStatsFragments, MY_MAC.etherStatsFragments);
	ns_printf(pio,"                   TX_CMD_STAT = 0x%08X\n", MY_MAC.TX_CMD_STAT);
	ns_printf(pio,"                   RX_CMD_STAT = 0x%08X\n", MY_MAC.RX_CMD_STAT);
	
	ns_printf(pio,"\n");
	
	return 0;
}

//
//	This menu command sends a request to the local hardware UDP stream client
//	to initiate a stream from a remote hardware UDP stream server.
//	
//	The command line format of this command is:
//		start_stream <ip_addr> <packet_length> <stream_index>
//	
//	Where <ip_addr> is the host address of the remote stream server you wish to
//	contact.  And <packet_length> is the size of the UDP packets that you wish
//	the remote server to generate over this hardware UDP channel.
//	
int start_stream(void * pio) {
	
	char *arg1 = (char *)NULL;
	char *arg2  = (char *)NULL;
	char *arg3  = (char *)NULL;
	size_t span;
	char *ip_digit_0;
	char *ip_digit_1;
	char *ip_digit_2;
	char *ip_digit_3;
	char ip_addr_text[17] = { 0 };
	char packet_length_text[5] = { 0 };
	char stream_index_text[5] = { 0 };
	int ip_addr_int_0;
	int ip_addr_int_1;
	int ip_addr_int_2;
	int ip_addr_int_3;
	int packet_length_int;
	alt_u8 os_error;
	client_request *client_request_ptr;
	alt_u32 requested_stream_index;
	GEN_IO io = (GEN_IO)(pio);
	
	/* extract args from command buffer */
	if (io != NULL)
		arg1 = nextarg((io->inbuf));
	if((arg1 == NULL) || (*arg1 == '\0')) {
		ns_printf(pio, "invalid arguments to command...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -1;
	}
	arg2 = nextarg(arg1);
	arg3 = nextarg(arg2);

	if (*arg2 == '\0') {
		ns_printf(pio, "invalid arguments to command...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -2;
	}

	// parse and validate the command line arguments
	span = strspn(arg1, "0123456789.");
	if((span > 16) || (span < 7)) {
		ns_printf(pio, "ip_addr argument is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -3;
	}
	if(strcspn(arg1, " ") != span) {
		ns_printf(pio, "ip_addr argument is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -4;
	}
	strncpy(ip_addr_text, arg1, span);

	span = strspn(arg2, "0123456789");
	if((span > 4) || (span < 1)) {
		ns_printf(pio, "packet_length argument is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -5;
	}
	if(strcspn(arg2, " ") != span) {
		ns_printf(pio, "packet_length argument is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -6;
	}
	strncpy(packet_length_text, arg2, span);

	span = strspn(arg3, "0123456789");
	if((span > 1) || (span < 1)) {
		ns_printf(pio, "Stream number is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -25;
	}

	if(strcspn(arg3, " ") != span) {
		ns_printf(pio, "stream number is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -26;
	}
	strncpy(stream_index_text, arg3, span);

	ip_digit_0 = strtok(ip_addr_text, ".");
	if(ip_digit_0 == NULL) {
		ns_printf(pio, "ip_addr argument is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -7;
	}
	ip_digit_1 = strtok(NULL, ".");
	if(ip_digit_1 == NULL) {
		ns_printf(pio, "ip_addr argument is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -8;
	}
	ip_digit_2 = strtok(NULL, ".");
	if(ip_digit_2 == NULL) {
		ns_printf(pio, "ip_addr argument is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -9;
	}
	ip_digit_3 = strtok(NULL, ".");
	if(ip_digit_3 == NULL) {
		ns_printf(pio, "ip_addr argument is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -10;
	}
	if(strtok(NULL, ".") != NULL) {
		ns_printf(pio, "ip_addr argument is invalid...\nstart_stream <ip_addr> <packet_length>\nstart_stream XXX.XXX.XXX.XXX xxxx\n");
		return -11;
	}
	
	ip_addr_int_0 = atoi(ip_digit_0);
	ip_addr_int_1 = atoi(ip_digit_1);
	ip_addr_int_2 = atoi(ip_digit_2);
	ip_addr_int_3 = atoi(ip_digit_3);
	packet_length_int = atoi(packet_length_text);
	requested_stream_index = atoi(stream_index_text);

	if((ip_addr_int_0 > 0xFF) || (ip_addr_int_1 > 0xFF) || (ip_addr_int_2 > 0xFF) || (ip_addr_int_3 > 0xFF)) {
		ns_printf(pio, "ip_addr argument is invalid, each octet must be 255 or less...\n");
		return -12;
	}
	
	if(packet_length_int > 1472) {
		ns_printf(pio, "packet_length argument is invalid, it must be 1472 or less...\n");
		return -13;
	}
	
	if((requested_stream_index > 3)) {
			ns_printf(pio, "requested_stream_index argument is invalid, it must be 0-3...\n");
			return -27;
		}

	ns_printf(pio, "Attempting to start stream from %d.%d.%d.%d with %d byte packets...\n", \
			ip_addr_int_0, \
			ip_addr_int_1, \
			ip_addr_int_2, \
			ip_addr_int_3, \
			packet_length_int \
		);
	
	client_request_ptr = (client_request *)(OSMboxPend(client_request_Mbox, 0, &os_error));
	if(client_request_ptr == 0) {
		printf("client_request_ptr is NULL\n");
		return -14;
	}

	client_request_ptr->pio = *io;
	client_request_ptr->packet_length = packet_length_int;
	client_request_ptr->ip_address = (ip_addr_int_0 << 24) | (ip_addr_int_1 << 16) | (ip_addr_int_2 << 8) | (ip_addr_int_3);
	client_request_ptr->streamer_index = requested_stream_index;

	os_error = OSMboxPost(stream_client_Mbox, (void *)(client_request_ptr));
	if(os_error != OS_NO_ERR) {
		printf("OS ERROR on MBOX post to client %d\n", os_error);
	}

	return 0;
}

//
//	This menu command sends a request to the remote hardware UDP stream server
//	to terminate a previously established stream.  When the remote server
//	terminates the stream, it will signal back to the local client that started
//	the stream that the stream has been terminated.
//
//	The command line format of this command is:
//		stop_stream <channel>
//	
//	Where <channel> is an integer from 0 thru 3 indicating what channel you wish
//	to terminate.  The stream channel corresponds to the channel reported back
//	from the start_stream command.  If you'd like to terminate all active
//	streams you may pass in the value 4 for the <channel> argument.
//	
int stop_stream(void * pio) {
	
	char *arg1 = (char *)NULL;
	size_t span;
	char channel_text[2] = { 0 };
	int channel_int;
	int result;
	GEN_IO io = (GEN_IO)(pio);
	
	/* extract args from command buffer */
	if (io != NULL)
		arg1 = nextarg((io->inbuf));
	if((arg1 == NULL) || (*arg1 == '\0')) {
		ns_printf(pio, "invalid arguments to command...\nstop_stream <channel>\n");
		return -1;
	}

	// parse and validate the command line arguments
	span = strspn(arg1, "0123456789");
	if((span > 1) || (span < 1)) {
		ns_printf(pio, "invalid arguments to command...\nstop_stream <channel>\n");
		return -3;
	}
	if(strcspn(arg1, " ") != span) {
		ns_printf(pio, "invalid arguments to command...\nstop_stream <channel>\n");
		return -4;
	}
	strncpy(channel_text, arg1, span);

	channel_int = atoi(channel_text);

	if(channel_int > 4) {
		ns_printf(pio, "channel argument is invalid, it must be 0 thru 3, or 4 for all...\n");
		return -5;
	}
	
	if(channel_int > 3) {
		for(channel_int = 0 ; channel_int < 4 ; channel_int++) {
			if(!client_session_fd[channel_int]) {
				ns_printf(pio, "channel %d, does not appear to be running...\n", channel_int);
			} else {
				ns_printf(pio, "Signaling server to stop channel %d...\n", channel_int);
				
				result = tx_command(client_session_fd[channel_int], RELEASE_STR, RELEASE_STR_SIZE, 0);
				if (result == -1) {
					ns_printf(pio, "An error occurred when sending signal to server...\n");
				}
			}
		}
		
	} else {
		if(!client_session_fd[channel_int]) {
			ns_printf(pio, "channel %d, does not appear to be running...\n", channel_int);
			return -6;
		}
	
		ns_printf(pio, "Signaling server to stop channel %d...\n", channel_int);
		
		result = tx_command(client_session_fd[channel_int], RELEASE_STR, RELEASE_STR_SIZE, 0);
		if (result == -1) {
			ns_printf(pio, "An error occurred when sending signal to server...\n");
		}
	}
	return 0;
}

//
//	This menu command displays the status of each hardware stream channel on
//	on this system.
//	
int stat_stream(void * pio) {
	
	int i;
	
	for(i = 0 ; i < 4 ; i++) {
		if(client_session_fd[i]) {
			ns_printf(pio, "channel %d - RUNNING\n", i);
		} else {
			ns_printf(pio, "channel %d - STOPPED\n", i);
		}
	}

	return 0;
}


//
//	Print Routines for all the custom component statistics
//	
void print_packet_checker_stats(void *pio, PKT_CHKR_STATS *stats) {
	ns_printf(pio, "CSR state = 0x%08X\n", stats->csr_state);
	ns_printf(pio, "LSB is Go\n\n");
	ns_printf(pio, "  length error count = %u\n",	stats->length_error_count);
	ns_printf(pio, "sequence error count = %u\n",	stats->sequence_error_count);
	ns_printf(pio, "    data error count = %u\n\n",	stats->data_error_count);
	ns_printf(pio, "       rx byte count = %u\n",	stats->byte_count);
	ns_printf(pio, "     rx packet count = %u\n\n",	stats->packet_count);
}

void print_packet_generator_stats(void *pio, PKT_GEN_STATS *stats) {
	ns_printf(pio, "CSR state = 0x%08X\n",				stats->csr_state);
	ns_printf(pio, "2 LSBs are Running|Go\n\n");
	ns_printf(pio, "packet byte count = %u\n",			stats->byte_count);
	ns_printf(pio, "    initial value = 0x%08X\n\n",	stats->initial_value);
	ns_printf(pio, "     packet count = %u\n\n",		stats->packet_count);
}

void print_udp_payload_extractor_stats(void *pio, UDP_EXT_STATS *stats) {
	ns_printf(pio, "packet count = %u\n\n", stats->packet_count);
}

void print_udp_payload_inserter_stats(void *pio, UDP_INS_STATS *stats) {
	ns_printf(pio, "packet count = %u\n\n",	stats->packet_count);
	ns_printf(pio, "CSR state = 0x%08X\n",	stats->csr_state);
	ns_printf(pio, "3 LSBs are Error|Running|Go\n\n");
	ns_printf(pio, "destination MAC address = %02X:%02X:%02X:%02X:%02X:%02X\n",
				(stats->mac_dst_hi >> 24)	& 0xFF,
				(stats->mac_dst_hi >> 16)	& 0xFF,
				(stats->mac_dst_hi >> 8)	& 0xFF,
				(stats->mac_dst_hi >> 0)	& 0xFF,
				(stats->mac_dst_lo >> 8)	& 0xFF,
				(stats->mac_dst_lo >> 0)	& 0xFF
			);
	ns_printf(pio, "     source MAC address = %02X:%02X:%02X:%02X:%02X:%02X\n\n",
				(stats->mac_src_hi >> 24)	& 0xFF,
				(stats->mac_src_hi >> 16)	& 0xFF,
				(stats->mac_src_hi >> 8)	& 0xFF,
				(stats->mac_src_hi >> 0)	& 0xFF,
				(stats->mac_src_lo >> 8)	& 0xFF,
				(stats->mac_src_lo >> 0)	& 0xFF
			);
	ns_printf(pio, "     source IP address = %0d.%0d.%0d.%0d\n",
				(stats->ip_src >> 24)	& 0xFF,
				(stats->ip_src >> 16)	& 0xFF,
				(stats->ip_src >> 8)	& 0xFF,
				(stats->ip_src >> 0)	& 0xFF
			);
	ns_printf(pio, "destination IP address = %0d.%0d.%0d.%0d\n\n",
				(stats->ip_dst >> 24)	& 0xFF,
				(stats->ip_dst >> 16)	& 0xFF,
				(stats->ip_dst >> 8)	& 0xFF,
				(stats->ip_dst >> 0)	& 0xFF
			);
	ns_printf(pio, "     UDP source port = %u\n", stats->udp_src);
	ns_printf(pio, "UDP destination port = %u\n\n", stats->udp_dst);
}

void print_udp_port_to_channel_mapper_stats(void *pio, CHAN_MAP_STATS *stats) {
	ns_printf(pio, "      packet count = %u\n\n", stats->packet_count);
	ns_printf(pio, "channel 0 udp port = 0x%04X\n", stats->chan_0_udp_port);
	ns_printf(pio, "channel 0 is %s\n", (stats->chan_0_en) ? ("ENABLED") : ("DISABLED"));
	ns_printf(pio, "channel 1 udp port = 0x%04X\n", stats->chan_1_udp_port);
	ns_printf(pio, "channel 1 is %s\n", (stats->chan_1_en) ? ("ENABLED") : ("DISABLED"));
	ns_printf(pio, "channel 2 udp port = 0x%04X\n", stats->chan_2_udp_port);
	ns_printf(pio, "channel 2 is %s\n", (stats->chan_2_en) ? ("ENABLED") : ("DISABLED"));
	ns_printf(pio, "channel 3 udp port = 0x%04X\n", stats->chan_3_udp_port);
	ns_printf(pio, "channel 3 is %s\n\n", (stats->chan_3_en) ? ("ENABLED") : ("DISABLED"));
}
/*
void print_error_packet_discard_stats(void *pio, EPD_STATS *stats) {
	ns_printf(pio, "      packet count = %u\n", stats->packet_count);
	ns_printf(pio, "error packet count = %u\n\n", stats->error_packet_count);
}
*/
void print_overflow_packet_discard_stats(void *pio, OPD_STATS *stats) {
	ns_printf(pio, "overflow packet count = %u\n\n", stats->overflow_packet_count);
}





