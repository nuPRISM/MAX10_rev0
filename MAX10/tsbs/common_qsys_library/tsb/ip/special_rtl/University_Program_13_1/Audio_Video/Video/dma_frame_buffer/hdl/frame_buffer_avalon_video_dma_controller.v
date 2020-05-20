`default_nettype none
`undef USE_TO_MEMORY
`define USE_32BIT_MASTER

module frame_buffer_avalon_video_dma_controller (
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
	stream_data_to_writer,
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
    snoop_stream_data_to_writer,
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
	snoop_soft_reset_now,
	snoop_actual_soft_reset,
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
    default_back_buf_address,
    num_of_dma_locations,
	num_pixels_in_frame,
	num_of_packets_finished_processing,
	snoop_num_of_packets_finished_processing
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
	function automatic int my_clog2 (input int n);
						int original_n;
						original_n = n;
						if (n <=1) return 1; // abort function
						my_clog2 = 0;
						while (n > 1) begin
						    n = n/2;
						    my_clog2++;
						end
						
						if (2**my_clog2 != original_n)
						begin
						     my_clog2 = my_clog2 + 1;
						end
						
	endfunction
   
parameter DW								=  15; // Frame's datawidth
parameter EW								=   0; // Frame's empty width
parameter NUM_PIXELS_IN_FRAME_DEFAULT = 10; //dummy
parameter NUM_OF_DMA_LOCATIONS_DEFAULT = 10; //dummy
parameter AW	                       =  32; // Avalon master's address width
parameter LENGTH_ADDRESSWIDTH				        =  32; // Avalon length width
parameter MDW								=  15; // Avalon master's datawidth
parameter BYTEENABLEWIDTH = (MDW+1)/8;
parameter CLOG2_BYTEENABLEWIDTH = my_clog2(BYTEENABLEWIDTH);
parameter MAXBURSTCOUNT = 8;
parameter BURSTCOUNTWIDTH = 4;

parameter BITS_PER_PIXEL						= 7;
parameter PARALLELIZATION_RATIO					= 2;
parameter SWAP_SYMBOL_ORDER_TO_FROM_DDR            = 1'b0;
parameter NUM_BITS_IN_ORIGINAL_SYMBOL            = BITS_PER_PIXEL;
parameter NUM_ORIGINAL_SYMBOLS_IN_DATA_WORD      = (MDW+1)/NUM_BITS_IN_ORIGINAL_SYMBOL;

parameter DEFAULT_DMA_ENABLED			                    = 1'b1; // 0: OFF or 1: ON
parameter DEFAULT_USE_EXTERNAL_BACKBUFFER_ADDRESS			= 1'b0; // 0: OFF or 1: ON
parameter DEFAULT_ALWAYS_DO_BUFFER_SWAP                     = 1'b0; // 0: OFF or 1: ON

parameter WATCHDOG_ENABLED   = 1;
parameter WATCHDOG_COUNT_NUMBITS = 64;
parameter [63:0] MAX_WATCHDOG_COUNT = 2000000000;

parameter DEFAULT_OVERRIDE_EXTERNAL_SWAP_BUFFERS_NOW       = 1'b0;
parameter DEFAULT_AVMM_EXTERNAL_SWAP_BUFFERS_NOW_VAL       = 1'b0;
parameter DEFAULT_AVMM_SWAP_SYMBOL_ORDER_TO_FROM_DDR       = 1'b0; 
parameter DEFAULT_OVERRIDE_SWAP_SYMBOL_ORDER_TO_FROM_DDR   = 1'b0;



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
	
input			[ 7: 0]	slave_address;
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
output		[DW: 0]	    stream_data_to_writer;
`else
output		[DW: 0]	stream_data;
logic		[DW: 0]	stream_data_raw;
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
output		[31: 0]	num_of_dma_locations;
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
output logic	[31: 0]	num_of_packets_finished_processing;
output logic	[31: 0]	snoop_num_of_packets_finished_processing;

assign snoop_num_of_packets_finished_processing = num_of_packets_finished_processing;
output [31: 0]    snoop_back_buf_start_address;
output	          snoop_dma_enabled;
output	          snoop_soft_reset_now;
output	          snoop_actual_soft_reset;
output [31: 0]    snoop_last_written_buf_start_address;
output [31: 0]    snoop_external_priority_backbuffer_address;
output	          snoop_use_external_priority_backbuffer;
output	          snoop_currently_processing_packet;
output	          snoop_pause_after_each_frame;
output            snoop_get_frame_now;
output	          snoop_get_frame_now_ack;
output [31: 0]    snoop_buffer_start_address;

output  [DW: 0]	    snoop_stream_data            ;
output  [DW: 0]	    snoop_stream_data_to_writer  ;
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
output logic [WATCHDOG_COUNT_NUMBITS-1:0] watchdog_counter;
output                  watchdog_reset;
output                  increase_watchdog_event_count;
output   [31:0]           num_watchdog_events;
output logic [31:0] num_pixels_in_frame; 

logic use_internal_get_frame_now ;
logic internal_get_frame_now     ;
logic actual_get_frame_now     ;
logic actual_pause_after_each_frame  ;
logic override_pause_after_each_frame; 
logic avmm_pause_after_each_frame; 
logic actual_swap_buffer_now         ;
logic override_swap_buffer_now       ;
logic avmm_swap_buffer_now           ;
logic actual_swap_symbol_order_to_from_ddr;
logic avmm_swap_symbol_order_to_from_ddr; 
logic override_swap_symbol_order_to_from_ddr;

assign actual_get_frame_now = use_internal_get_frame_now ? internal_get_frame_now : get_frame_now;
assign actual_pause_after_each_frame = override_pause_after_each_frame ? avmm_pause_after_each_frame : pause_after_each_frame;

always_ff @(posedge clk)
begin
     actual_swap_symbol_order_to_from_ddr <= override_swap_symbol_order_to_from_ddr ? avmm_swap_symbol_order_to_from_ddr : SWAP_SYMBOL_ORDER_TO_FROM_DDR;
end

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
assign snoop_pause_after_each_frame                     = actual_pause_after_each_frame;
assign snoop_get_frame_now                              = get_frame_now;
assign snoop_get_frame_now_ack                          = get_frame_now_ack;
assign snoop_buffer_start_address                       = buffer_start_address;
assign snoop_state = state;
assign snoop_num_buffer_swaps            = num_buffer_swaps;
assign snoop_num_of_packets_processed    = num_of_packets_processed;
assign snoop_num_of_repeated_packets = num_of_repeated_packets;
assign snoop_write_bytes_left = write_bytes_left;
assign snoop_swap_buffers_now = swap_buffers_now;
assign snoop_external_swap_buffer_now = actual_swap_buffer_now;
assign snoop_wait_for_swap            =  wait_for_swap;
assign snoop_soft_reset_now            =  soft_reset_now;
assign snoop_actual_soft_reset            =  actual_soft_reset;


/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire						inc_address;
wire						reset_address;
wire                         soft_reset_now;
(* keep = 1, preserve = 1*) wire control_go	;
(* keep = 1, preserve = 1*) reg actual_soft_reset = 0;
(* keep = 1, preserve = 1*) wire control_done	;
(* keep = 1, preserve = 1*) wire [BURSTCOUNTWIDTH-1:0] burst_counter;
logic [WATCHDOG_COUNT_NUMBITS-1:0] watchdog_max_count;
logic        enable_watchdog   ;

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

frame_buffer_video_dma_control_slave DMA_Control_Slave (
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
	//.soft_reset_now                      (soft_reset_now),
	.reset_request_pending             (soft_reset_now),
	.reset_of_frame_buffer_accepted    (actual_soft_reset),
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
	.num_of_dma_locations              (num_of_dma_locations),
	.num_pixels_in_frame               (num_pixels_in_frame),
	.out_of_band_data_received        (out_of_band_data_received),
	.default_buffer_address           (default_buffer_address),
	.default_back_buf_address         (default_back_buf_address),
    .watchdog_max_count               (watchdog_max_count),
    .enable_watchdog                  (enable_watchdog   ),
	.use_internal_get_frame_now       (use_internal_get_frame_now),
	.internal_get_frame_now           (internal_get_frame_now    ),
	.num_of_packets_finished_processing (num_of_packets_finished_processing),
	.actual_pause_after_each_frame, 
	.override_pause_after_each_frame,
	.avmm_pause_after_each_frame, 
	.actual_swap_buffer_now,     
	.override_swap_buffer_now,   
	.avmm_swap_buffer_now,
	.override_swap_symbol_order_to_from_ddr,
	.avmm_swap_symbol_order_to_from_ddr,
	.actual_swap_symbol_order_to_from_ddr,
	.actual_get_frame_now,
	.get_frame_now,	
    .fsm_state(state)	
	
);
defparam
	DMA_Control_Slave.NUM_PIXELS_IN_FRAME_DEFAULT								= NUM_PIXELS_IN_FRAME_DEFAULT,
	DMA_Control_Slave.BITS_PER_PIXEL						= BITS_PER_PIXEL,
	DMA_Control_Slave.PARALLELIZATION_RATIO					= PARALLELIZATION_RATIO,
	DMA_Control_Slave.DEFAULT_DMA_ENABLED			= DEFAULT_DMA_ENABLED,
	DMA_Control_Slave.DEFAULT_USE_EXTERNAL_BACKBUFFER_ADDRESS			= DEFAULT_USE_EXTERNAL_BACKBUFFER_ADDRESS,
	DMA_Control_Slave.DEFAULT_ALWAYS_DO_BUFFER_SWAP			= DEFAULT_ALWAYS_DO_BUFFER_SWAP,
    DMA_Control_Slave.MAX_WATCHDOG_COUNT_DEFAULT = MAX_WATCHDOG_COUNT,
	DMA_Control_Slave.WATCHDOG_ENABLED_DEFAULT = WATCHDOG_ENABLED,
	DMA_Control_Slave.DEFAULT_OVERRIDE_EXTERNAL_SWAP_BUFFERS_NOW = DEFAULT_OVERRIDE_EXTERNAL_SWAP_BUFFERS_NOW, 
	DMA_Control_Slave.DEFAULT_AVMM_EXTERNAL_SWAP_BUFFERS_NOW_VAL = DEFAULT_AVMM_EXTERNAL_SWAP_BUFFERS_NOW_VAL, 
	DMA_Control_Slave.DEFAULT_AVMM_SWAP_SYMBOL_ORDER_TO_FROM_DDR      = DEFAULT_AVMM_SWAP_SYMBOL_ORDER_TO_FROM_DDR,
	DMA_Control_Slave.DEFAULT_OVERRIDE_SWAP_SYMBOL_ORDER_TO_FROM_DDR  = DEFAULT_OVERRIDE_SWAP_SYMBOL_ORDER_TO_FROM_DDR ; 

(* keep = 1, preserve = 1 *)	reg actual_total_reset = 0;

`ifdef USE_TO_MEMORY
assign snoop_stream_data_to_writer = stream_data_to_writer          ;
	
(* keep = 1, preserve = 1 *)	wire user_buffer_full;

assign stream_ready = (!user_buffer_full & !wait_for_swap) | (!currently_processing_packet && !stream_startofpacket && stream_valid); //flush any data that is out of band

assign control_go = stream_startofpacket & stream_valid & stream_ready & (!actual_total_reset) & (!reset);


assign actual_swap_buffer_now = override_swap_buffer_now ? avmm_swap_buffer_now : external_swap_buffer_now;


assign swap_buffers_now	 = actual_swap_buffer_now;



always @(posedge clk)
begin
	if (reset)
		currently_processing_packet <= 1'b0;
	else if (~dma_enabled || soft_reset_now)
	    currently_processing_packet <= 1'b0;
	else if (control_go)
		currently_processing_packet <= 1'b1;
	else if ((stream_endofpacket & stream_ready & stream_valid) || (currently_processing_packet && control_done) || increase_watchdog_event_count)
		currently_processing_packet <= 1'b0;
end	

always @(posedge clk)
begin
	  if (reset)
         wait_for_swap <= 0;
	 else if ((currently_processing_packet && wait_for_swap) ||  (~dma_enabled) || soft_reset_now)
	   wait_for_swap <= 0;
	 else if (currently_processing_packet &  ((stream_endofpacket & stream_ready & stream_valid) || increase_watchdog_event_count))
	     wait_for_swap <= 1;
	 else if (actual_swap_buffer_now) 
	     wait_for_swap <= 0;
end

(* keep = 1, preserve = 1 *) logic user_write_buffer;
assign user_write_buffer = (stream_valid & stream_ready & (currently_processing_packet | control_go)) | ((!user_buffer_full) & soft_reset_now); //for soft reset, flush the buffer

always @(posedge clk)
begin
    out_of_band_data_received <= stream_valid & stream_ready & !(currently_processing_packet | control_go);
end


always @(posedge clk)
begin
    discarded_packet_event <= control_go & currently_processing_packet & (write_bytes_left != 0);
end

always @(posedge clk)
begin
     actual_soft_reset <= (soft_reset_now && control_done && (burst_counter == 0));
end

always @(posedge clk)
begin
      actual_total_reset <= (~dma_enabled) || actual_soft_reset;
end


always_comb
begin         
     for (int symbol_index = 0; symbol_index < NUM_ORIGINAL_SYMBOLS_IN_DATA_WORD; symbol_index = symbol_index +1)
     begin : swap_data_loop
     		stream_data_to_writer[(symbol_index+1)*NUM_BITS_IN_ORIGINAL_SYMBOL-1 -: NUM_BITS_IN_ORIGINAL_SYMBOL] = actual_swap_symbol_order_to_from_ddr ? stream_data[(NUM_ORIGINAL_SYMBOLS_IN_DATA_WORD-symbol_index)*NUM_BITS_IN_ORIGINAL_SYMBOL-1 -: NUM_BITS_IN_ORIGINAL_SYMBOL] : stream_data[(symbol_index+1)*NUM_BITS_IN_ORIGINAL_SYMBOL-1 -: NUM_BITS_IN_ORIGINAL_SYMBOL];
     end		
end		 

frame_buf_burst_write_master
burst_write_master_inst(
	.clk		     	   (clk),
	.reset                  (reset | actual_total_reset),
	
	// control inputs and outputs
	.control_fixed_location(1'b0),
	.control_write_base(buffer_start_address),
	.control_write_length(num_of_dma_locations << CLOG2_BYTEENABLEWIDTH),//number of bytes to write
	.control_go(control_go),
	.control_done(control_done),
	.length(write_bytes_left),
	// user logic inputs and outputs
	.user_write_buffer(user_write_buffer),
	.user_buffer_data(stream_data_to_writer),
	.user_buffer_full(user_buffer_full),
	
	// master inputs and outputs
	.master_address(master_address),
	.master_write(master_write),
	.master_byteenable(master_byteenable),
	.master_writedata(master_writedata),
	.master_burstcount(master_burstcount),
	.master_waitrequest(master_waitrequest),
	.burst_counter(burst_counter),
	.watchdog_enabled(enable_watchdog),
	.watchdog_limit(watchdog_max_count),
	.watchdog_count(watchdog_counter),
	.watchdog_event_occured(increase_watchdog_event_count)
);

defparam 
    burst_write_master_inst.WATCHDOG_COUNT_NUMBITS = WATCHDOG_COUNT_NUMBITS,
	burst_write_master_inst.DATAWIDTH = (MDW+1),
	burst_write_master_inst.MAXBURSTCOUNT = MAXBURSTCOUNT,
	burst_write_master_inst.BURSTCOUNTWIDTH = BURSTCOUNTWIDTH,
	burst_write_master_inst.BYTEENABLEWIDTH = BYTEENABLEWIDTH,
	burst_write_master_inst.LENGTH_ADDRESSWIDTH = LENGTH_ADDRESSWIDTH,
	burst_write_master_inst.ADDRESSWIDTH = AW, 
	burst_write_master_inst.FIFODEPTH = 64,  // must be at least twice MAXBURSTCOUNT in order to be efficient
	burst_write_master_inst.FIFODEPTH_LOG2 = 6,
	burst_write_master_inst.FIFOUSEMEMORY = 1;  // set to 0 to use LEs instead
	
`else

always @(posedge clk)
begin
     actual_soft_reset <= (soft_reset_now & (!currently_processing_packet));
end

always @(posedge clk)
begin
      actual_total_reset <= reset || (~dma_enabled) || actual_soft_reset;
end


frame_buffer_video_dma_to_stream 
From_Memory_to_Stream (
	// Inputs
	.clk									(clk),
	.reset								( actual_total_reset ),

	.stream_ready						(stream_ready | soft_reset_now), //make sure burst master finishes

	.master_address       (master_address      ),
	.master_read          (master_read         ),
	.master_byteenable    (master_byteenable   ),
	.master_readdata      (master_readdata     ),
	.master_readdatavalid (master_readdatavalid),
	.master_burstcount    (master_burstcount   ),
	.master_waitrequest   (master_waitrequest  ),
    .data_read_count     (),
	 
	 
	// Bidirectional

	// Outputs
	.stream_data						(stream_data_raw),
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
    .pause_after_each_frame             (actual_pause_after_each_frame),
    .get_frame_now                      (actual_get_frame_now         ),
    .get_frame_now_ack                  (get_frame_now_ack     ),
	.read_bytes_left                    (write_bytes_left), //fix naming
	.state                              (state),
	.max_watchdog_count                (watchdog_max_count),
	.num_of_dma_locations              (num_of_dma_locations),
	.watchdog_enabled                  (enable_watchdog   )
	
);
defparam
	From_Memory_to_Stream.DW	= DW,
	From_Memory_to_Stream.EW	= EW,
	From_Memory_to_Stream.MDW	= MDW,
	From_Memory_to_Stream.MAXBURSTCOUNT = MAXBURSTCOUNT,
	From_Memory_to_Stream.BURSTCOUNTWIDTH = BURSTCOUNTWIDTH,
	From_Memory_to_Stream.BYTEENABLEWIDTH = BYTEENABLEWIDTH,
	From_Memory_to_Stream.LENGTH_ADDRESSWIDTH = LENGTH_ADDRESSWIDTH,
	From_Memory_to_Stream.ADDRESSWIDTH = AW,
	From_Memory_to_Stream.WATCHDOG_COUNT_NUMBITS = WATCHDOG_COUNT_NUMBITS;

	
	
always_comb
begin
             for (int symbol_index = 0; symbol_index < NUM_ORIGINAL_SYMBOLS_IN_DATA_WORD; symbol_index = symbol_index +1)
				 begin : swap_data_loop
					   stream_data[(symbol_index+1)*NUM_BITS_IN_ORIGINAL_SYMBOL-1 -: NUM_BITS_IN_ORIGINAL_SYMBOL] = actual_swap_symbol_order_to_from_ddr ? stream_data_raw[(NUM_ORIGINAL_SYMBOLS_IN_DATA_WORD-symbol_index)*NUM_BITS_IN_ORIGINAL_SYMBOL-1 -: NUM_BITS_IN_ORIGINAL_SYMBOL] : stream_data_raw[(symbol_index+1)*NUM_BITS_IN_ORIGINAL_SYMBOL-1 -: NUM_BITS_IN_ORIGINAL_SYMBOL];
				 end 
end	 
	

	

`endif

endmodule

`default_nettype wire