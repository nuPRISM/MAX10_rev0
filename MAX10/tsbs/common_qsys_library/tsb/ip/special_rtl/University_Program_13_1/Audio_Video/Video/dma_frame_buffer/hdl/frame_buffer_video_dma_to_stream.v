`default_nettype none
module frame_buffer_video_dma_to_stream (
	// Inputs
	clk,
	reset,

	stream_ready,

	master_readdata,
	master_readdatavalid,
	master_waitrequest,
	
	// Bidirectional

	// Outputs
	stream_data,
	stream_startofpacket,
	stream_endofpacket,
	stream_empty,
	stream_valid,
	
   master_byteenable,
   master_burstcount,
   master_address,
	
	master_read,
	buffer_start_address,
	swap_buffers_now,
	pause_after_each_frame,
	get_frame_now,
	get_frame_now_ack,
    currently_processing_packet,
    burst_read_master_go,
    burst_read_master_done,
	data_read_count,
	read_bytes_left,
	state,
    watchdog_counter,
    watchdog_reset,
	discarded_packet_event,
	increase_watchdog_event_count,
    max_watchdog_count,
    num_of_dma_locations,
    watchdog_enabled
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
   
parameter DW	=  15; // Frame's datawidth
parameter EW	=   0; // Frame's empty width

parameter MDW	=  15; // Avalon master's datawidth

parameter BYTEENABLEWIDTH = (MDW+1)/8;
parameter CLOG2_BYTEENABLEWIDTH = my_clog2(BYTEENABLEWIDTH);

parameter MAXBURSTCOUNT   = 8;
parameter BURSTCOUNTWIDTH = 4;

parameter WATCHDOG_COUNT_NUMBITS = 32;
parameter LENGTH_ADDRESSWIDTH    = 32;
parameter ADDRESSWIDTH           = 32;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input						clk;
input						reset;

input						stream_ready;

input			[MDW:0]	master_readdata;
input						master_readdatavalid;
input						master_waitrequest;
input watchdog_enabled;
 
output		[31: 0]	master_address;
// Bidirectional

// Outputs
output		[DW: 0]	stream_data;
output					stream_startofpacket;
output					stream_endofpacket;
output		[EW: 0]	stream_empty;
output					stream_valid;
output  [BYTEENABLEWIDTH-1:0] master_byteenable;
output  [BURSTCOUNTWIDTH-1:0]  master_burstcount;
output					master_read;
output     logic          currently_processing_packet;
output                  burst_read_master_go;
output                  burst_read_master_done;
output					swap_buffers_now;
input                	pause_after_each_frame;
input                	get_frame_now;
output              	get_frame_now_ack;
(*keep = 1, preserve = 1*) logic         	get_frame_now_ack;
(*keep = 1, preserve = 1*) logic         	get_frame_now_ack_raw;
output     [15:0]       state;
input      [31:0]       buffer_start_address;
input      [WATCHDOG_COUNT_NUMBITS-1:0]       max_watchdog_count;
output      [31:0]      data_read_count;
output      [31:0]      read_bytes_left;
output logic discarded_packet_event;
logic reset_watchdog_counter_n;
logic enable_watchdog_counter;
(*keep = 1, preserve = 1*) output logic [WATCHDOG_COUNT_NUMBITS-1:0]    watchdog_counter = 0;
(*keep = 1, preserve = 1*) output              watchdog_reset;
(*keep = 1, preserve = 1*) output              increase_watchdog_event_count;
input [31:0] num_of_dma_locations;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/

// states
parameter   STATE_PRE_IDLE                  = 16'b0000_0000_0000_0000;	
parameter 	STATE_DO_CONTROLLED_BUFFER_SWAP	= 16'b0000_0000_0001_0001;			
parameter 	STATE_WAIT_FOR_BUFFER_SWAP	    = 16'b0000_0001_1000_0111;			
parameter   STATE_START_BURST_READ_MASTER   = 16'b0000_0001_1010_0010;
parameter 	STATE_WAIT_FOR_LAST_PIXEL		= 16'b0000_0011_1000_0011;
parameter 	STATE_WAIT_FOR_GO              	= 16'b0000_0001_0000_0101;
parameter 	STATE_GO_ACKNOWLEDGE         	= 16'b0000_0001_0100_0110;
parameter 	STATE_WATCHDOG_EVENT         	= 16'b0000_0100_0000_1000;

assign swap_buffers_now              = s_dma_to_stream[4];
assign burst_read_master_go          = s_dma_to_stream[5];
assign get_frame_now_ack_raw         = s_dma_to_stream[6];
assign currently_processing_packet   = s_dma_to_stream[7];
assign reset_watchdog_counter_n      = s_dma_to_stream[8];
assign enable_watchdog_counter       = s_dma_to_stream[9];
assign increase_watchdog_event_count = s_dma_to_stream[10];
assign watchdog_reset = increase_watchdog_event_count;


edge_detector 
get_frame_now_ack_detector
(
 .insignal (get_frame_now_ack_raw), 
 .outsignal(get_frame_now_ack), 
 .clk      (clk)
);
		
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[(DW+2):0]	fifo_data_in;
wire						fifo_read;
wire						fifo_write;

wire		[(DW+2):0]	fifo_data_out;
wire						fifo_empty;
wire						fifo_full;
wire						fifo_almost_empty;
wire						fifo_almost_full;

// Internal Registers
logic		[ 3: 0]	pending_reads;
logic					startofpacket;
wire						endofpacket;

// State Machine Registers
reg		[ 15: 0]	s_dma_to_stream = STATE_PRE_IDLE;

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


always_ff @(posedge clk)
begin
	if (!reset_watchdog_counter_n)
		watchdog_counter <= 0;
	else
	begin
	    if (enable_watchdog_counter)
		begin
		     watchdog_counter <= watchdog_counter+1;
		end
	end
end

assign state = s_dma_to_stream; //for debugging

always_ff @(posedge clk)
begin
	if (reset)
	begin
		s_dma_to_stream <= STATE_PRE_IDLE;
	end else
	begin
		  case (s_dma_to_stream)
							STATE_PRE_IDLE     : begin //handle startup - make sure that first frame  is not emitted if we are supposed to pause after each frame
													 if (pause_after_each_frame)
														  s_dma_to_stream <= STATE_WAIT_FOR_GO;
													 else 
														  s_dma_to_stream <= STATE_DO_CONTROLLED_BUFFER_SWAP;						
												end
												
							STATE_DO_CONTROLLED_BUFFER_SWAP : begin
																s_dma_to_stream <= STATE_WAIT_FOR_BUFFER_SWAP;
															end
							STATE_WAIT_FOR_BUFFER_SWAP : begin
																s_dma_to_stream <= STATE_START_BURST_READ_MASTER;
															end
							STATE_START_BURST_READ_MASTER:
								begin
									  s_dma_to_stream <=  STATE_WAIT_FOR_LAST_PIXEL;
								end
								

															 
							STATE_WAIT_FOR_LAST_PIXEL:
								begin
									if (burst_read_master_done)
									begin	
										if (pause_after_each_frame)
										begin
											 s_dma_to_stream <= STATE_WAIT_FOR_GO;
										end else
										begin				
											s_dma_to_stream <= STATE_DO_CONTROLLED_BUFFER_SWAP;
										end
									end else
									begin
										if ((watchdog_counter >= max_watchdog_count) && watchdog_enabled)
										begin
											  s_dma_to_stream <= STATE_WATCHDOG_EVENT;
										end else
										begin
											 s_dma_to_stream <= STATE_WAIT_FOR_LAST_PIXEL;
										end
									end
								end
							


							STATE_WAIT_FOR_GO:
								begin
									
										 if (get_frame_now)
										 begin
											   s_dma_to_stream <= STATE_GO_ACKNOWLEDGE;
										 end else
										 begin
												if (pause_after_each_frame)
												begin
													 s_dma_to_stream <=  STATE_WAIT_FOR_GO;	
												end else
												begin
													 s_dma_to_stream <= STATE_DO_CONTROLLED_BUFFER_SWAP;
												end							   
										 end	
										 
								end
								
							STATE_GO_ACKNOWLEDGE:
								   begin
										  s_dma_to_stream <=  STATE_DO_CONTROLLED_BUFFER_SWAP;
								   end
								   
							STATE_WATCHDOG_EVENT : begin
														 s_dma_to_stream <= STATE_PRE_IDLE;
												   end 
			endcase
	end
end

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
// Output Assignments
assign stream_data				= fifo_data_out[DW:0];
assign stream_startofpacket   	= fifo_data_out[DW+1];
assign stream_endofpacket		= fifo_data_out[DW+2];
assign stream_empty				= 'h0;

assign fifo_read					= stream_ready & stream_valid;



always_ff @(posedge clk)
begin
    discarded_packet_event <= get_frame_now & (read_bytes_left != 0);
end

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
frame_buf_burst_read_master 
#(
.DATAWIDTH              (MDW+1),
.MAXBURSTCOUNT          (MAXBURSTCOUNT),
.BURSTCOUNTWIDTH        (BURSTCOUNTWIDTH),
.BYTEENABLEWIDTH        (BYTEENABLEWIDTH),
.ADDRESSWIDTH           (ADDRESSWIDTH),
.LENGTH_ADDRESSWIDTH    (LENGTH_ADDRESSWIDTH),
.FIFODEPTH       (128),
.FIFODEPTH_LOG2  (7),
.FIFOUSEMEMORY   (1),  // set to 0 to use LEs instead
.SUPPORT_PACKETS (1)
)
burst_read_master_inst
(
	.clk(clk),
	.reset(reset | watchdog_reset),

	// control inputs and outputs
	.control_fixed_location(1'b0),
	.control_read_base     (buffer_start_address),
	.control_read_length   (num_of_dma_locations << CLOG2_BYTEENABLEWIDTH),
	.control_go            (burst_read_master_go),
	.control_done          (burst_read_master_done),
	.control_early_done    (),
	
	// user logic inputs and outputs
	.user_read_buffer   (fifo_read),
	.user_buffer_data   (fifo_data_out),
	.user_data_available(stream_valid),
	.length             (read_bytes_left),
	// master inputs and outputs
	.master_address       (master_address      ),
	.master_read          (master_read         ),
	.master_byteenable    (master_byteenable   ),
	.master_readdata      (master_readdata     ),
	.master_readdatavalid (master_readdatavalid),
	.master_burstcount    (master_burstcount   ),
	.master_waitrequest   (master_waitrequest  )
);

endmodule
`default_nettype wire
