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

module altera_up_video_dma_to_stream (
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
	increase_watchdog_event_count	
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter DW	=  15; // Frame's datawidth
parameter EW	=   0; // Frame's empty width

parameter MDW	=  15; // Avalon master's datawidth

parameter BYTEENABLEWIDTH = (MDW+1)/8;
parameter MAXBURSTCOUNT   = 8;
parameter BURSTCOUNTWIDTH = 4;
parameter MAX_WATCHDOG_COUNT = 10000000;
parameter WATCHDOG_ENABLED = 1;

parameter NUM_OF_DMA_LOCATIONS = 10; //dummy

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
output     reg          currently_processing_packet;
output                  burst_read_master_go;
output                  burst_read_master_done;
output					swap_buffers_now;
input                	pause_after_each_frame;
input                	get_frame_now;
output     reg         	get_frame_now_ack;
output     [15:0]       state;
input      [31:0]       buffer_start_address;
output      [31:0]      data_read_count;
output      [31:0]      read_bytes_left;
output reg discarded_packet_event;

(*keep = 1, preserve = 1*) output reg [31:0]   watchdog_counter = 0;
(*keep = 1, preserve = 1*) output              watchdog_reset;
(*keep = 1, preserve = 1*) output              increase_watchdog_event_count;
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
assign get_frame_now_ack             = s_dma_to_stream[6];
assign currently_processing_packet   = s_dma_to_stream[7];
assign reset_watchdog_counter_n      = s_dma_to_stream[8];
assign enable_watchdog_counter       = s_dma_to_stream[9];
assign increase_watchdog_event_count = s_dma_to_stream[10];
assign watchdog_reset = increase_watchdog_event_count;

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
reg			[ 3: 0]	pending_reads;
reg						startofpacket;
wire						endofpacket;

// State Machine Registers
reg			[ 15: 0]	s_dma_to_stream;
reg			[ 15: 0]	ns_dma_to_stream;

// Integers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/

always @(posedge clk)
begin
	if (reset)
		s_dma_to_stream <= STATE_PRE_IDLE;
	else
		s_dma_to_stream <= ns_dma_to_stream;
end
always @(posedge clk)
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

always @(*)
begin
   case (s_dma_to_stream)
    STATE_PRE_IDLE     : begin //handle startup - make sure that first frame  is not emitted if we are supposed to pause after each frame
							 if (pause_after_each_frame)
							 	  ns_dma_to_stream = STATE_WAIT_FOR_GO;
							 else 
								  ns_dma_to_stream = STATE_DO_CONTROLLED_BUFFER_SWAP;						
						end
						
	STATE_DO_CONTROLLED_BUFFER_SWAP : begin
										ns_dma_to_stream = STATE_WAIT_FOR_BUFFER_SWAP;
								    end
	STATE_WAIT_FOR_BUFFER_SWAP : begin
										ns_dma_to_stream = STATE_START_BURST_READ_MASTER;
								    end
	STATE_START_BURST_READ_MASTER:
		begin
		      ns_dma_to_stream =  STATE_WAIT_FOR_LAST_PIXEL;
		end
		

									 
	STATE_WAIT_FOR_LAST_PIXEL:
		begin
			if (burst_read_master_done)
            begin	
                if (pause_after_each_frame)
                begin
                     ns_dma_to_stream = STATE_WAIT_FOR_GO;
				end else
                begin				
				    ns_dma_to_stream = STATE_DO_CONTROLLED_BUFFER_SWAP;
			    end
			end else
			begin
			    if ((watchdog_counter >= MAX_WATCHDOG_COUNT) && WATCHDOG_ENABLED)
				begin
				      ns_dma_to_stream = STATE_WATCHDOG_EVENT;
				end else
				begin
				     ns_dma_to_stream = STATE_WAIT_FOR_LAST_PIXEL;
				end
			end
		end
	


	STATE_WAIT_FOR_GO:
	    begin
		    
				 if (get_frame_now)
				 begin
					   ns_dma_to_stream = STATE_GO_ACKNOWLEDGE;
				 end else
				 begin
				        if (pause_after_each_frame)
			            begin
					         ns_dma_to_stream =  STATE_WAIT_FOR_GO;	
						end else
						begin
							 ns_dma_to_stream = STATE_DO_CONTROLLED_BUFFER_SWAP;
						end							   
				 end	
             	 
		end
		
	STATE_GO_ACKNOWLEDGE:
	       begin
		          ns_dma_to_stream =  STATE_DO_CONTROLLED_BUFFER_SWAP;
		   end
		   
    STATE_WATCHDOG_EVENT : begin
						         ns_dma_to_stream = STATE_PRE_IDLE;
						   end 
		
	default:
		begin
			ns_dma_to_stream = STATE_PRE_IDLE;
		end
	endcase
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



always @(posedge clk)
begin
    discarded_packet_event <= get_frame_now & (read_bytes_left != 0);
end

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
burst_read_master 
#(
.DATAWIDTH       (MDW+1),
.MAXBURSTCOUNT   (MAXBURSTCOUNT),
.BURSTCOUNTWIDTH (BURSTCOUNTWIDTH),
.BYTEENABLEWIDTH (BYTEENABLEWIDTH),
.ADDRESSWIDTH    (32),
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
	.control_read_length   (NUM_OF_DMA_LOCATIONS*(BYTEENABLEWIDTH)),
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

