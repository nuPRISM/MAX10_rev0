`default_nettype none
module frame_buffer_video_dma_control_slave (
	// Inputs
	clk,
	reset,

	address,
	byteenable,
	read,
	write,
	writedata,

	swap_addresses_enable,

	// Bi-Directional

	// Outputs
	readdata,

	current_start_address,
	dma_enabled,	
	soft_reset_now,
	reset_request_pending,
	use_external_priority_backbuffer,
	set_buffer_address_directly,
	back_buf_start_address,
	last_written_buf_start_address,
	external_priority_backbuffer_address,
	num_buffer_swaps,
	currently_processing_packet,
	reset_of_frame_buffer_accepted,
	num_of_packets_processed,
	num_of_packets_finished_processing,
	num_of_repeated_packets,
	increase_watchdog_event_count,
	num_watchdog_events,
	out_of_band_data_received,
	num_of_out_of_band_data_received,
	default_buffer_address,
	discarded_packet_event,
	num_of_discarded_packets,
    default_back_buf_address,
    watchdog_max_count,
	num_of_dma_locations,
	num_pixels_in_frame,
	use_internal_get_frame_now ,
    internal_get_frame_now     ,
    enable_watchdog,
    actual_swap_buffer_now           ,
    override_swap_buffer_now       	 ,
    actual_pause_after_each_frame    ,
    override_pause_after_each_frame	,
	avmm_swap_buffer_now           ,
	avmm_pause_after_each_frame,
	actual_swap_symbol_order_to_from_ddr,
	avmm_swap_symbol_order_to_from_ddr   , 
	override_swap_symbol_order_to_from_ddr,
	actual_get_frame_now,
	get_frame_now,
	fsm_state
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
   
// Parameters

parameter NUM_PIXELS_IN_FRAME_DEFAULT = 10;

parameter BITS_PER_PIXEL						= 7; // Bits per pixel
parameter PARALLELIZATION_RATIO					= 2; // Parallelization ratio to/from DMA
parameter DEFAULT_DMA_ENABLED			                    = 1'b1; 
parameter DEFAULT_USE_EXTERNAL_BACKBUFFER_ADDRESS			= 1'b0; 
parameter DEFAULT_ALWAYS_DO_BUFFER_SWAP                     = 1'b0; 
parameter DEFAULT_SET_BUFFER_ADDRESS_DIRECTLY               = 1'b0; 
parameter WATCHDOG_ENABLED_DEFAULT = 1'b0;
parameter DEFAULT_OVERRIDE_EXTERNAL_SWAP_BUFFERS_NOW       = 1'b0;
parameter DEFAULT_AVMM_EXTERNAL_SWAP_BUFFERS_NOW_VAL       = 1'b0;
parameter [63:0] MAX_WATCHDOG_COUNT_DEFAULT = 2000000000;
parameter DEFAULT_AVMM_SWAP_SYMBOL_ORDER_TO_FROM_DDR       = 1'b0; 
parameter DEFAULT_OVERRIDE_SWAP_SYMBOL_ORDER_TO_FROM_DDR   = 1'b0;

parameter DEFAULT_OVERRIDE_PAUSE_AFTER_EACH_FRAME      = 0;
parameter DEFAULT_AVMM_PAUSE_AFTER_EACH_FRAME          = 0;


parameter CLOG2_PARALLELIZATION_RATIO = my_clog2(PARALLELIZATION_RATIO);
output reg [31:0] num_pixels_in_frame =  NUM_PIXELS_IN_FRAME_DEFAULT;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input						clk;
input						reset;

input			[ 7: 0]	address;
input			[ 3: 0]	byteenable;
input						read;
input						write;
input			[31: 0]	writedata;
input           [31: 0]	external_priority_backbuffer_address;
input           [31: 0]	default_buffer_address;
input           [31: 0]	default_back_buf_address;
input					swap_addresses_enable;
input                   currently_processing_packet;
input                   discarded_packet_event;	
input                   out_of_band_data_received;	
input                   reset_of_frame_buffer_accepted;
// Bi-Directional

// Outputs
output reg	[31: 0]	readdata;
output reg	[31: 0]	num_of_packets_processed;
output reg	[31: 0]	num_of_packets_finished_processing;
output reg	[31: 0]	num_of_discarded_packets;
output reg	[31: 0]	num_of_out_of_band_data_received;
output reg	[31: 0]	num_of_repeated_packets;
output reg	[31: 0]	back_buf_start_address;
output reg	[31: 0]	last_written_buf_start_address;
output		[31: 0]	current_start_address;
output reg				dma_enabled;
output reg				soft_reset_now;
output reg				use_external_priority_backbuffer;
output reg				set_buffer_address_directly;
output reg	[31: 0] num_buffer_swaps;
output reg	[63: 0] watchdog_max_count = MAX_WATCHDOG_COUNT_DEFAULT;
output wire	[31: 0] num_of_dma_locations;


output logic use_internal_get_frame_now ;
output logic internal_get_frame_now     ;
input  logic actual_swap_buffer_now          ;
input  logic actual_swap_symbol_order_to_from_ddr          ;
output reg override_swap_buffer_now     = DEFAULT_OVERRIDE_EXTERNAL_SWAP_BUFFERS_NOW;
input logic actual_pause_after_each_frame   ;
output reg override_pause_after_each_frame = DEFAULT_OVERRIDE_PAUSE_AFTER_EACH_FRAME;
output reg avmm_swap_buffer_now       = DEFAULT_AVMM_EXTERNAL_SWAP_BUFFERS_NOW_VAL;
output reg avmm_pause_after_each_frame   = DEFAULT_AVMM_PAUSE_AFTER_EACH_FRAME;
output reg avmm_swap_symbol_order_to_from_ddr     = DEFAULT_AVMM_SWAP_SYMBOL_ORDER_TO_FROM_DDR    ;  
output reg override_swap_symbol_order_to_from_ddr = DEFAULT_OVERRIDE_SWAP_SYMBOL_ORDER_TO_FROM_DDR;


assign num_of_dma_locations = (num_pixels_in_frame >> CLOG2_PARALLELIZATION_RATIO);
output reg enable_watchdog = WATCHDOG_ENABLED_DEFAULT;
(*keep = 1, preserve = 1*) output reg	[31: 0] num_watchdog_events=0;
(*keep = 1, preserve = 1*) output reg reset_request_pending = 0;
input increase_watchdog_event_count;
input [15:0] fsm_state;
input actual_get_frame_now;
input get_frame_now;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires

// Internal Registers
reg			[31: 0]	buffer_start_address;

reg						buffer_swap;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
wire edge_detect_swap_addresses_enable;
reg always_do_buffer_swap;
wire actual_buffer_swap_enable = ((buffer_swap & swap_addresses_enable) || (edge_detect_swap_addresses_enable & always_do_buffer_swap));

reg prev_swap_addresses_enable;
reg prev_currently_processing_packet;
reg prev_actual_buffer_swap_enable;
reg prev_soft_reset_now;

always @(posedge clk)
begin
     if (reset)
	 begin
	    prev_swap_addresses_enable <= 0;
		prev_currently_processing_packet <= 0;
		prev_actual_buffer_swap_enable <= 0;
		prev_soft_reset_now <= 0;
	 end else
	 begin
	    prev_swap_addresses_enable <= swap_addresses_enable;
		prev_currently_processing_packet <= currently_processing_packet;
		prev_actual_buffer_swap_enable <= actual_buffer_swap_enable;
		prev_soft_reset_now <= soft_reset_now;
	 end
end

assign edge_detect_swap_addresses_enable = !prev_swap_addresses_enable & swap_addresses_enable;
wire edge_detect_actual_buffer_swap_enable = !prev_actual_buffer_swap_enable & actual_buffer_swap_enable;
wire edge_detect_currently_processing_packet = !prev_currently_processing_packet & currently_processing_packet;
wire falling_edge_detect_currently_processing_packet = prev_currently_processing_packet & !currently_processing_packet;
wire edge_detect_soft_reset_now = !prev_soft_reset_now & soft_reset_now;

always @(posedge clk)
begin
	if (reset)
	begin
         num_buffer_swaps <= 0;
	end else
	begin
	     if (edge_detect_actual_buffer_swap_enable)
		 begin
		      num_buffer_swaps <= num_buffer_swaps+1;
		 end
	end
end

always @(posedge clk)
begin
	if (reset)
	begin
         num_of_packets_processed <= 0;
	end else
	begin
	     if (edge_detect_currently_processing_packet)
		 begin
		      num_of_packets_processed <= num_of_packets_processed+1;
		 end
	end
end

always @(posedge clk)
begin
	if (reset)
	begin
         num_of_packets_finished_processing <= 0;
	end else
	begin
	     if (falling_edge_detect_currently_processing_packet)
		 begin
		      num_of_packets_finished_processing <= num_of_packets_finished_processing+1;
		 end
	end
end

always @(posedge clk)
begin
	if (reset)
	begin
         num_of_discarded_packets <= 0;
	end else
	begin
	     if (discarded_packet_event)
		 begin
		      num_of_discarded_packets <= num_of_discarded_packets+1;
		 end
	end
end

always @(posedge clk)
begin
	if (reset)
	begin
         num_of_out_of_band_data_received <= 0;
	end else
	begin
	     if (out_of_band_data_received)
		 begin
		      num_of_out_of_band_data_received <= num_of_out_of_band_data_received+1;
		 end
	end
end

always @(posedge clk)
begin
	if (reset)
	begin
         num_of_repeated_packets <= 0;
	end else
	begin
	     if ((edge_detect_currently_processing_packet) && (last_written_buf_start_address == buffer_start_address))
		 begin
		      num_of_repeated_packets <= num_of_repeated_packets+1;
		 end
	end
end

always @(posedge clk)
begin
     if (reset)
	 begin
	      num_watchdog_events <= 0;
	 end else
	 begin
	      if (increase_watchdog_event_count)
		  begin
		         num_watchdog_events <= num_watchdog_events + 1;
		  end
	 end
end

always @(posedge clk)
begin
     if (reset)
	 begin
	      reset_request_pending <= 0;
	 end else
	 begin
	      if (edge_detect_soft_reset_now)
		  begin
		         reset_request_pending <= 1;
		  end else
		  begin
		         if (reset_of_frame_buffer_accepted || (!soft_reset_now))
				 begin
				        reset_request_pending <= 0;
				 end
		  end
	 end
end


// Output Registers
always @(posedge clk)
begin
	if (reset)
	begin
		readdata <= 32'h00000000;
   end else
   begin
         if (read)
		 begin
		        case (address)
				0  : readdata <= buffer_start_address;
			    1  : readdata <= back_buf_start_address;
			    2  : readdata <= num_of_dma_locations;
				3  :	begin
							readdata[31:24] <= BITS_PER_PIXEL; //backwards compatibility for BITS_PER_PIXEL < 256
							readdata[23:16] <= PARALLELIZATION_RATIO; //backwards compatibility for PARALLELIZATION_RATIO < 256
							readdata[   15] <= 0;
							readdata[   14] <= actual_swap_buffer_now           ;
							readdata[   13] <= override_swap_buffer_now         ;
							readdata[   12] <= actual_pause_after_each_frame    ;
							readdata[   11] <= override_pause_after_each_frame  ;
							readdata[   10] <= enable_watchdog;
							readdata[    9] <= use_internal_get_frame_now ;
							readdata[    8] <= internal_get_frame_now     ;
							readdata[    7] <= set_buffer_address_directly;
							readdata[    6] <= reset_request_pending;
							readdata[    5] <= currently_processing_packet;
							readdata[    4] <= always_do_buffer_swap;
							readdata[    3] <= use_external_priority_backbuffer;
							readdata[    2] <= dma_enabled;
							readdata[    1] <= soft_reset_now;
							readdata[    0] <= buffer_swap;
						end
				4  : readdata <= num_of_packets_processed;	      
				5  : readdata <= num_buffer_swaps;	      
				6  : readdata <= num_of_repeated_packets;	      
				7  : readdata <= last_written_buf_start_address;
				8  : readdata <= num_watchdog_events;
				9  : readdata <= num_of_discarded_packets;
				10 : readdata <= num_of_out_of_band_data_received;
				11 : readdata <= num_pixels_in_frame;
				12 : readdata <= num_of_packets_finished_processing; 
				13 : readdata <= watchdog_max_count[31:0];
				14 : readdata <= watchdog_max_count[63:32];
				15 : readdata <= buffer_start_address;
				16 : readdata <= BITS_PER_PIXEL; 
				17 : readdata <= PARALLELIZATION_RATIO; 
				18 : begin
							readdata[0] <= avmm_swap_symbol_order_to_from_ddr    ;
							readdata[1] <= override_swap_symbol_order_to_from_ddr;
				            readdata[2] <= DEFAULT_AVMM_SWAP_SYMBOL_ORDER_TO_FROM_DDR    ;
							readdata[3] <= DEFAULT_OVERRIDE_SWAP_SYMBOL_ORDER_TO_FROM_DDR;							
							readdata[4] <= actual_swap_symbol_order_to_from_ddr;	
							readdata[7:5] <= 0;
							readdata[8] <= actual_get_frame_now;
							readdata[9] <= get_frame_now;							
                            readdata[31:10] <= 0;							
					  end
			    19 : readdata <= fsm_state;
				default : readdata <= 32'hEAAEAA;
				endcase
		end
	end
end


always @(posedge clk)
begin
	if (reset)
	begin
		avmm_swap_symbol_order_to_from_ddr     <= DEFAULT_AVMM_SWAP_SYMBOL_ORDER_TO_FROM_DDR    ;
		override_swap_symbol_order_to_from_ddr <= DEFAULT_OVERRIDE_SWAP_SYMBOL_ORDER_TO_FROM_DDR;	
	end
	else if (write & (address == 18))
	begin
		if (byteenable[0])
		begin
			avmm_swap_symbol_order_to_from_ddr     <= writedata[0];
	    	override_swap_symbol_order_to_from_ddr <= writedata[1];
		end
	end 
end
 
always @(posedge clk)
begin
	if (reset)
	begin
		num_pixels_in_frame	<= NUM_PIXELS_IN_FRAME_DEFAULT;
	end
	else if (write & (address == 8'hB))
	begin
		if (byteenable[0])
			num_pixels_in_frame[ 7: 0] <= writedata[ 7: 0];
		if (byteenable[1])
			num_pixels_in_frame[15: 8] <= writedata[15: 8];
		if (byteenable[2])
			num_pixels_in_frame[23:16] <= writedata[23:16];
		if (byteenable[3])
			num_pixels_in_frame[31:24] <= writedata[31:24];
	end 
end
 
always @(posedge clk)
begin
	if (reset)
	begin
		back_buf_start_address	<= default_back_buf_address;
	end
	else if (write & (address == 8'h1))
	begin
		if (byteenable[0])
			back_buf_start_address[ 7: 0] <= writedata[ 7: 0];
		if (byteenable[1])
			back_buf_start_address[15: 8] <= writedata[15: 8];
		if (byteenable[2])
			back_buf_start_address[23:16] <= writedata[23:16];
		if (byteenable[3])
			back_buf_start_address[31:24] <= writedata[31:24];
	end else if (actual_buffer_swap_enable)
	begin
		back_buf_start_address         <= buffer_start_address;
	end
end


always @(posedge clk)
begin
	if (reset)
	begin
		last_written_buf_start_address <= 32'hFFFFFFFF;
	end
	else if (actual_buffer_swap_enable)
	begin
		last_written_buf_start_address <= buffer_start_address; 
	end
end

always @(posedge clk)
begin
	if (reset)
	begin
		buffer_start_address	<= default_buffer_address;
	end else
	if (write & (address == 8'hF))
	begin
		if (byteenable[0])
			buffer_start_address[ 7: 0] <= writedata[ 7: 0];
		if (byteenable[1])
			buffer_start_address[15: 8] <= writedata[15: 8];
		if (byteenable[2])
			buffer_start_address[23:16] <= writedata[23:16];
		if (byteenable[3])
			buffer_start_address[31:24] <= writedata[31:24];
	end	else 
	if (actual_buffer_swap_enable)
	begin
		buffer_start_address           <= set_buffer_address_directly ? buffer_start_address : (use_external_priority_backbuffer ? external_priority_backbuffer_address : back_buf_start_address);
	end
end

always @(posedge clk)
begin
	if (reset)
		buffer_swap <= 1'b0;
	else if (write & (address == 8'h0))
		buffer_swap <= 1'b1;
	else if (swap_addresses_enable)
		buffer_swap <= 1'b0;
end

always @(posedge clk)
begin
	if (reset)
	begin
		dma_enabled <= DEFAULT_DMA_ENABLED;
		soft_reset_now <= 0;
		use_external_priority_backbuffer <= DEFAULT_USE_EXTERNAL_BACKBUFFER_ADDRESS;
		always_do_buffer_swap <= DEFAULT_ALWAYS_DO_BUFFER_SWAP;
		set_buffer_address_directly <= DEFAULT_SET_BUFFER_ADDRESS_DIRECTLY;
		enable_watchdog <= WATCHDOG_ENABLED_DEFAULT;
		use_internal_get_frame_now      <=    0;
		internal_get_frame_now          <=    0;
		avmm_swap_buffer_now              <= DEFAULT_AVMM_EXTERNAL_SWAP_BUFFERS_NOW_VAL               ;
		override_swap_buffer_now          <= DEFAULT_OVERRIDE_EXTERNAL_SWAP_BUFFERS_NOW           ;
		avmm_pause_after_each_frame       <= DEFAULT_AVMM_PAUSE_AFTER_EACH_FRAME        ;
		override_pause_after_each_frame   <= DEFAULT_OVERRIDE_PAUSE_AFTER_EACH_FRAME    ;
		
	end
	else
    begin
			if (write & (address == 8'h3))
			begin
				if (byteenable[0])
				begin
					dma_enabled <= writedata[2];
					soft_reset_now <=  writedata[1];
					use_external_priority_backbuffer <=  writedata[3];
					always_do_buffer_swap <= writedata[4];
					set_buffer_address_directly <= writedata[7];
				end 
				
				if (byteenable[1])
				begin					
					avmm_swap_buffer_now            <= writedata[14];
					override_swap_buffer_now        <= writedata[13];
					avmm_pause_after_each_frame     <= writedata[12];
					override_pause_after_each_frame <= writedata[11];
					enable_watchdog                 <= writedata[10];
					use_internal_get_frame_now      <= writedata[9];
					internal_get_frame_now          <= writedata[8];    
				end
			end
	end
end

// Internal Registers
always @(posedge clk)
begin
	if (reset)
	begin
		watchdog_max_count[31:0]	<= MAX_WATCHDOG_COUNT_DEFAULT[31:0];
	end
	else if (write & (address == 8'hD))
	begin
		if (byteenable[0])
			watchdog_max_count[ 7: 0] <= writedata[ 7: 0];
		if (byteenable[1])
			watchdog_max_count[15: 8] <= writedata[15: 8];
		if (byteenable[2])
			watchdog_max_count[23:16] <= writedata[23:16];
		if (byteenable[3])
			watchdog_max_count[31:24] <= writedata[31:24];
	end
end


// Internal Registers
always @(posedge clk)
begin
	if (reset)
	begin
		watchdog_max_count[63:32]	<= MAX_WATCHDOG_COUNT_DEFAULT[63:32];
	end
	else if (write & (address == 8'hE))
	begin
		if (byteenable[0])
			watchdog_max_count[39:32] <= writedata[ 7: 0];
		if (byteenable[1])
			watchdog_max_count[47:40] <= writedata[15: 8];
		if (byteenable[2])
			watchdog_max_count[55:48] <= writedata[23:16];
		if (byteenable[3])
			watchdog_max_count[63:56] <= writedata[31:24];
	end
end
/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// Output Assignments
assign current_start_address	= buffer_start_address;

// Internal Assignments

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule
`default_nettype wire
