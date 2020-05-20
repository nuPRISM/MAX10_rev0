/******************************************************************************
 * License Agreement                                                          *
 *                                                                            *
 * Copyright (c) 1991-2014 Altera Corporation, San Jose, California, USA.     *
 * All rights reserved.                                                       *
 *                                                                            *
 * Any megafunction design, and related net list (encrypted or decrypted),    *
 *  support information, device programming or simulation file, and any other *
 *  associated documentation or information provided by Altera or a partner   *
 *  under Altera's Megafunction Partnership Program may be used only to       *
 *  program PLD devices (but not masked PLD devices) from Altera.  Any other  *
 *  use of such megafunction design, net list, support information, device    *
 *  programming or simulation file, or any other related documentation or     *
 *  information is prohibited for any other purpose, including, but not       *
 *  limited to modification, reverse engineering, de-compiling, or use with   *
 *  any other silicon devices, unless such use is explicitly licensed under   *
 *  a separate agreement with Altera or a megafunction partner.  Title to     *
 *  the intellectual property, including patents, copyrights, trademarks,     *
 *  trade secrets, or maskworks, embodied in any such megafunction design,    *
 *  net list, support information, device programming or simulation file, or  *
 *  any other related documentation or information provided by Altera or a    *
 *  megafunction partner, remains with Altera, the megafunction partner, or   *
 *  their respective licensors.  No other licenses, including any licenses    *
 *  needed under any third party's intellectual property, are provided herein.*
 *  Copying or modifying any file, or portion thereof, to which this notice   *
 *  is attached violates this copyright.                                      *
 *                                                                            *
 * THIS FILE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    *
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   *
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    *
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER *
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    *
 * FROM, OUT OF OR IN CONNECTION WITH THIS FILE OR THE USE OR OTHER DEALINGS  *
 * IN THIS FILE.                                                              *
 *                                                                            *
 * This agreement shall be governed in all respects by the laws of the State  *
 *  of California and by the laws of the United States of America.            *
 *                                                                            *
 ******************************************************************************/

/******************************************************************************
 *                                                                            *
 * This module store and retrieves video frames to and from memory.           *
 *                                                                            *
 ******************************************************************************/

`undef USE_TO_MEMORY
`define USE_32BIT_MASTER

module altera_up_avalon_video_dma_controller (
	// Inputs
	clk,
	reset,
    buffer_start_address,
	
`ifdef USE_TO_MEMORY
	stream_data,
	stream_startofpacket,
	stream_endofpacket,
	stream_empty,
	stream_valid,

`else
	stream_ready,
`endif

pause_after_each_frame,
get_frame_now,
get_frame_now_ack,

`ifndef USE_TO_MEMORY
	master_readdata,
	master_readdatavalid,

`endif
	master_waitrequest,
	
	slave_address,
	slave_byteenable,
	slave_read,
	slave_write,
	slave_writedata,

	// Bidirectional

	// Outputs
`ifdef USE_TO_MEMORY
	stream_ready,
`else
	stream_data,
	stream_startofpacket,
	stream_endofpacket,
	stream_empty,
	stream_valid,
`endif

	master_address,
	master_byteenable,	
	master_burstcount,
`ifdef USE_TO_MEMORY
	master_write,
	master_writedata,
`else
	master_read,
`endif
	snoop_master_readdata,
	snoop_master_readdatavalid,
	snoop_master_waitrequest,
	snoop_master_address,
	snoop_master_write,
	snoop_master_writedata,
	snoop_master_read,
    snoop_stream_data,
    snoop_stream_startofpacket,	
    snoop_stream_endofpacket,	
    snoop_stream_empty,
    snoop_stream_valid,
    snoop_stream_ready,
	back_buf_start_address,
	dma_enabled,
    last_written_buf_start_address,
	external_priority_backbuffer_address,
	use_external_priority_backbuffer,
	currently_processing_packet,
	snoop_back_buf_start_address,
	snoop_dma_enabled,
    snoop_last_written_buf_start_address,
	snoop_external_priority_backbuffer_address,
	snoop_use_external_priority_backbuffer,
	snoop_currently_processing_packet,
	snoop_pause_after_each_frame,
    snoop_get_frame_now,
	snoop_get_frame_now_ack,
	snoop_buffer_start_address,
    snoop_state,
	snoop_write_bytes_left,
	num_buffer_swaps,
	num_of_packets_processed,
	snoop_num_buffer_swaps,
	snoop_num_of_packets_processed,
	num_of_repeated_packets,
	snoop_num_of_repeated_packets,
	swap_buffers_now,
	snoop_swap_buffers_now,
	state,
	slave_readdata,
	external_swap_buffer_now,
	snoop_external_swap_buffer_now,
	wait_for_swap,
	snoop_wait_for_swap,
	watchdog_counter,
    watchdog_reset,
	increase_watchdog_event_count,
	num_watchdog_events,
	out_of_band_data_received,
	discarded_packet_event,
	num_of_discarded_packets,
	default_buffer_address,
    default_back_buf_address	
	
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter DW								=  15; // Frame's datawidth
parameter EW								=   0; // Frame's empty width

parameter WIDTH							= 640; // Frame's width in pixels
parameter HEIGHT							= 480; // Frame's height in lines
parameter NUM_PIXELS_IN_FRAME = 10; //dummy
parameter NUM_OF_DMA_LOCATIONS = 10; //dummy
parameter MDW								=  15; // Avalon master's datawidth
parameter BYTEENABLEWIDTH = (MDW+1)/8;
parameter MAXBURSTCOUNT = 8;
parameter BURSTCOUNTWIDTH = 4;

parameter COLOR_BITS						= 4'h7;
parameter COLOR_PLANES					= 2'h2;

parameter DEFAULT_DMA_ENABLED			                    = 1'b1; // 0: OFF or 1: ON
parameter DEFAULT_USE_EXTERNAL_BACKBUFFER_ADDRESS			= 1'b0; // 0: OFF or 1: ON
parameter DEFAULT_ALWAYS_DO_BUFFER_SWAP                     = 1'b0; // 0: OFF or 1: ON

parameter MAX_WATCHDOG_COUNT = 2000000000;
parameter WATCHDOG_ENABLED   = 1;
/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input						clk;
input						reset;
output wire [BYTEENABLEWIDTH-1:0] master_byteenable;
output wire [BURSTCOUNTWIDTH-1:0]  master_burstcount;

`ifdef USE_TO_MEMORY
input			[DW: 0]	stream_data;
input						stream_startofpacket;
input						stream_endofpacket;
input			[EW: 0]	stream_empty;
input						stream_valid;


`else
input						stream_ready;
`endif

output      [31:0]           snoop_write_bytes_left;
wire        [31:0]           write_bytes_left;

`ifndef USE_TO_MEMORY
input			[MDW:0]	master_readdata;
input						master_readdatavalid;
`endif
input						master_waitrequest;
	
input			[ 3: 0]	slave_address;
input			[ 3: 0]	slave_byteenable;
input						slave_read;
input						slave_write;
input			[31: 0]	slave_writedata;

input [31:0] external_priority_backbuffer_address;
input external_swap_buffer_now;
// Bidirectional

// Outputs
`ifdef USE_TO_MEMORY
output					stream_ready;
`else
output		[DW: 0]	stream_data;
output					stream_startofpacket;
output					stream_endofpacket;
output		[EW: 0]	stream_empty;
output					stream_valid;
`endif

output		[31: 0]	master_address;
`ifdef USE_TO_MEMORY
output					master_write;
output      reg currently_processing_packet;

output		[MDW:0]	master_writedata;
`else
output      currently_processing_packet;

output					master_read;
`endif
output      use_external_priority_backbuffer;
output		dma_enabled;
output		[31: 0]	slave_readdata;
output		[31: 0]	buffer_start_address;
output		[31: 0]	num_of_discarded_packets;
input           [31: 0]	default_buffer_address;
input           [31: 0]	default_back_buf_address;
input                	pause_after_each_frame;
input                	get_frame_now;
output     reg         	get_frame_now_ack;
output     reg         	wait_for_swap;
output                  snoop_external_swap_buffer_now;
output               	snoop_wait_for_swap;


output [MDW:0] snoop_master_readdata;
output snoop_master_readdatavalid;
output snoop_master_waitrequest;
output [31: 0] snoop_master_address;
output snoop_master_write;
output [MDW:0] snoop_master_writedata;
output snoop_master_read;
output [31: 0]    snoop_back_buf_start_address;
output	          snoop_dma_enabled;
output [31: 0]    snoop_last_written_buf_start_address;
output [31: 0]    snoop_external_priority_backbuffer_address;
output	          snoop_use_external_priority_backbuffer;
output	          snoop_currently_processing_packet;
output	          snoop_pause_after_each_frame;
output            snoop_get_frame_now;
output	          snoop_get_frame_now_ack;
output [31: 0]    snoop_buffer_start_address;

output  [DW: 0]	    snoop_stream_data            ;
output  		    snoop_stream_startofpacket   ;
output  		    snoop_stream_endofpacket	 ;
output  [EW: 0]	    snoop_stream_empty           ;
output              snoop_stream_valid           ;
output              snoop_stream_ready           ;
output   [15:0] snoop_state;
output   [15:0] state;
output [31: 0]	back_buf_start_address;
output [31: 0]	last_written_buf_start_address;
output [31:0] num_buffer_swaps;
output [31:0] num_of_packets_processed;
output [31:0] snoop_num_buffer_swaps;
output [31:0] snoop_num_of_packets_processed;
output [31:0]	num_of_repeated_packets;
output [31:0]	snoop_num_of_repeated_packets;
output swap_buffers_now;
output snoop_swap_buffers_now;
output reg out_of_band_data_received;
output reg discarded_packet_event;
output reg [31:0]       watchdog_counter;
output                  watchdog_reset;
output                  increase_watchdog_event_count;
output   [31:0]           num_watchdog_events;




wire	[MDW:0]	master_readdata;
wire				master_readdatavalid;
wire				master_waitrequest;
wire	[31: 0]	master_address;
wire				master_write;
wire	[MDW:0]	master_writedata;
wire				master_read;

assign snoop_master_readdata      = master_readdata      ;
assign snoop_master_readdatavalid = master_readdatavalid ;
assign snoop_master_waitrequest   = master_waitrequest   ;
assign snoop_master_address       = master_address       ;
assign snoop_master_write         = master_write         ;
assign snoop_master_writedata     = master_writedata     ;
assign snoop_master_read          = master_read          ;
assign snoop_stream_data          = stream_data          ;
assign snoop_stream_startofpacket = stream_startofpacket ;
assign snoop_stream_endofpacket	  = stream_endofpacket	 ;
assign snoop_stream_empty         = stream_empty         ;
assign snoop_stream_valid         = stream_valid         ;
assign snoop_stream_ready         = stream_ready         ;
assign snoop_back_buf_start_address                     = back_buf_start_address;
assign snoop_dma_enabled                                = dma_enabled;
assign snoop_last_written_buf_start_address             = last_written_buf_start_address;
assign snoop_external_priority_backbuffer_address       = external_priority_backbuffer_address;
assign snoop_use_external_priority_backbuffer           = use_external_priority_backbuffer;
assign snoop_currently_processing_packet                = currently_processing_packet;
assign snoop_pause_after_each_frame                     = pause_after_each_frame;
assign snoop_get_frame_now                              = get_frame_now;
assign snoop_get_frame_now_ack                          = get_frame_now_ack;
assign snoop_buffer_start_address                       = buffer_start_address;
assign snoop_state = state;
assign snoop_num_buffer_swaps            = num_buffer_swaps;
assign snoop_num_of_packets_processed    = num_of_packets_processed;
assign snoop_num_of_repeated_packets = num_of_repeated_packets;
assign snoop_write_bytes_left = write_bytes_left;
assign snoop_swap_buffers_now = swap_buffers_now;
assign snoop_external_swap_buffer_now = external_swap_buffer_now;
assign snoop_wait_for_swap            =  wait_for_swap;



/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire						inc_address;
wire						reset_address;
(* keep = 1, preserve = 1*) wire control_go	;
(* keep = 1, preserve = 1*) wire control_done	;


// State Machine Registers

// Integers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

// Output Registers



/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
// Internal Assignments

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

altera_up_video_dma_control_slave DMA_Control_Slave (
	// Inputs
	.clk									(clk),
	.reset								(reset),

	.address								(slave_address),
	.byteenable							(slave_byteenable),
	.read									(slave_read),
	.write								(slave_write),
	.writedata							(slave_writedata),

    .swap_addresses_enable		   (swap_buffers_now),

	// Bi-Directional

	// Outputs
	.readdata							(slave_readdata),

	.current_start_address			(buffer_start_address),
	.dma_enabled						(dma_enabled),
	.use_external_priority_backbuffer  (use_external_priority_backbuffer),
	.increase_watchdog_event_count    (increase_watchdog_event_count),
	.back_buf_start_address             (back_buf_start_address        ),
	.last_written_buf_start_address     (last_written_buf_start_address),
	.external_priority_backbuffer_address (external_priority_backbuffer_address),
	.num_buffer_swaps                 (num_buffer_swaps            ),
	.currently_processing_packet      (currently_processing_packet ),
	.num_of_repeated_packets          (num_of_repeated_packets),
	.num_of_packets_processed         (num_of_packets_processed ),
	.num_watchdog_events              (num_watchdog_events),
	.discarded_packet_event           (discarded_packet_event),
	.num_of_discarded_packets         (num_of_discarded_packets),
	.out_of_band_data_received        (out_of_band_data_received),
	.default_buffer_address           (default_buffer_address),
	.default_back_buf_address         (default_back_buf_address)	
);
defparam
	DMA_Control_Slave.NUM_OF_DMA_LOCATIONS								= NUM_OF_DMA_LOCATIONS,
	DMA_Control_Slave.NUM_PIXELS_IN_FRAME								= NUM_PIXELS_IN_FRAME,
	DMA_Control_Slave.COLOR_BITS						= COLOR_BITS,
	DMA_Control_Slave.COLOR_PLANES					= COLOR_PLANES,
	DMA_Control_Slave.DEFAULT_DMA_ENABLED			= DEFAULT_DMA_ENABLED,
	DMA_Control_Slave.DEFAULT_USE_EXTERNAL_BACKBUFFER_ADDRESS			= DEFAULT_USE_EXTERNAL_BACKBUFFER_ADDRESS,
	DMA_Control_Slave.DEFAULT_ALWAYS_DO_BUFFER_SWAP			= DEFAULT_ALWAYS_DO_BUFFER_SWAP;

`ifdef USE_TO_MEMORY
	
(* keep = 1, preserve = 1 *)	wire user_buffer_full;

assign stream_ready = !user_buffer_full & !wait_for_swap; //control_done takes precedence over user_buffer_full in order to avoid hangup

assign control_go = stream_startofpacket & stream_valid & stream_ready;
assign swap_buffers_now	 = external_swap_buffer_now;

always @(posedge clk)
begin
	if (reset)
		currently_processing_packet <= 1'b0;
	else if (~dma_enabled)
	    currently_processing_packet <= 1'b0;
	else if (control_go)
		currently_processing_packet <= 1'b1;
	else if (stream_endofpacket & stream_ready & stream_valid)
		currently_processing_packet <= 1'b0;
end	

always @(posedge clk)
begin
	  if (reset)
         wait_for_swap <= 0;
	 else if ((currently_processing_packet && wait_for_swap) || ~dma_enabled)
	   wait_for_swap <= 0;
	 else if (currently_processing_packet &  stream_endofpacket & stream_ready & stream_valid)
	     wait_for_swap <= 1;
	 else if (external_swap_buffer_now) 
	     wait_for_swap <= 0;
end

(* keep = 1, preserve = 1 *) logic user_write_buffer;
assign user_write_buffer = stream_valid & stream_ready & (currently_processing_packet | control_go);

always @(posedge clk)
begin
    out_of_band_data_received <= stream_valid & stream_ready & !(currently_processing_packet | control_go);
end


always @(posedge clk)
begin
    discarded_packet_event <= control_go & currently_processing_packet & (write_bytes_left != 0);
end

burst_write_master
burst_write_master_inst(
	.clk		     	   (clk),
	.reset                  (reset | ~dma_enabled),
	
	// control inputs and outputs
	.control_fixed_location(1'b0),
	.control_write_base(buffer_start_address),
	.control_write_length(NUM_OF_DMA_LOCATIONS*(BYTEENABLEWIDTH)),//number of bytes to write
	.control_go(control_go),
	.control_done(control_done),
	.length(write_bytes_left),
	// user logic inputs and outputs
	.user_write_buffer(user_write_buffer),
	.user_buffer_data(stream_data),
	.user_buffer_full(user_buffer_full),
	
	// master inputs and outputs
	.master_address(master_address),
	.master_write(master_write),
	.master_byteenable(master_byteenable),
	.master_writedata(master_writedata),
	.master_burstcount(master_burstcount),
	.master_waitrequest(master_waitrequest)
);

defparam 
	burst_write_master_inst.DATAWIDTH = (MDW+1),
	burst_write_master_inst.MAXBURSTCOUNT = MAXBURSTCOUNT,
	burst_write_master_inst.BURSTCOUNTWIDTH = BURSTCOUNTWIDTH,
	burst_write_master_inst.BYTEENABLEWIDTH = BYTEENABLEWIDTH,
	burst_write_master_inst.ADDRESSWIDTH = 32,
	burst_write_master_inst.FIFODEPTH = 64,  // must be at least twice MAXBURSTCOUNT in order to be efficient
	burst_write_master_inst.FIFODEPTH_LOG2 = 6,
	burst_write_master_inst.FIFOUSEMEMORY = 1;  // set to 0 to use LEs instead
	
`else
altera_up_video_dma_to_stream 
From_Memory_to_Stream (
	// Inputs
	.clk									(clk),
	.reset								(reset | ~dma_enabled),

	.stream_ready						(stream_ready),

	.master_address       (master_address      ),
	.master_read          (master_read         ),
	.master_byteenable    (master_byteenable   ),
	.master_readdata      (master_readdata     ),
	.master_readdatavalid (master_readdatavalid),
	.master_burstcount    (master_burstcount   ),
	.master_waitrequest   (master_waitrequest  ),
    .data_read_count      (pixel_address),
	// Bidirectional

	// Outputs
	.stream_data						(stream_data),
	.stream_startofpacket			(stream_startofpacket),
	.stream_endofpacket				(stream_endofpacket),
	.stream_empty						(stream_empty),
	.stream_valid						(stream_valid),
	.buffer_start_address(buffer_start_address),
	.watchdog_counter                (watchdog_counter             ),
	.watchdog_reset                  (watchdog_reset               ),
    .increase_watchdog_event_count   (increase_watchdog_event_count),
    .currently_processing_packet (currently_processing_packet),
	.swap_buffers_now                   (swap_buffers_now),
    .pause_after_each_frame             (pause_after_each_frame),
    .get_frame_now                      (get_frame_now         ),
    .get_frame_now_ack                  (get_frame_now_ack     ),
	.read_bytes_left                    (write_bytes_left), //fix naming
	.state                              (state)
	
	
);
defparam
	From_Memory_to_Stream.DW	= DW,
	From_Memory_to_Stream.EW	= EW,
	From_Memory_to_Stream.MDW	= MDW,
	From_Memory_to_Stream.NUM_OF_DMA_LOCATIONS	= NUM_OF_DMA_LOCATIONS,
	From_Memory_to_Stream.MAXBURSTCOUNT = MAXBURSTCOUNT,
	From_Memory_to_Stream.BURSTCOUNTWIDTH = BURSTCOUNTWIDTH,
	From_Memory_to_Stream.BYTEENABLEWIDTH = BYTEENABLEWIDTH,
	From_Memory_to_Stream.MAX_WATCHDOG_COUNT = MAX_WATCHDOG_COUNT,
	From_Memory_to_Stream.WATCHDOG_ENABLED = WATCHDOG_ENABLED;
	
	

`endif

endmodule

