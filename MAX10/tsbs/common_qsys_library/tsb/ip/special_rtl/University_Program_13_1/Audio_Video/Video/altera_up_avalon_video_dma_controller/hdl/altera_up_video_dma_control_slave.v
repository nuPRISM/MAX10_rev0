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

module altera_up_video_dma_control_slave (
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
	use_external_priority_backbuffer,
	back_buf_start_address,
	last_written_buf_start_address,
	external_priority_backbuffer_address,
	num_buffer_swaps,
	currently_processing_packet,
	num_of_packets_processed,
	num_of_repeated_packets,
	increase_watchdog_event_count,
	num_watchdog_events,
	out_of_band_data_received,
	num_of_out_of_band_data_received,
	default_buffer_address,
	discarded_packet_event,
	num_of_discarded_packets,
    default_back_buf_address	
);


/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

// Parameters

parameter NUM_PIXELS_IN_FRAME = 10; //dummy
parameter NUM_OF_DMA_LOCATIONS = 10; //dummy

parameter COLOR_BITS						= 4'h7; // Bits per color plane minus 1 
parameter COLOR_PLANES					= 2'h2; // Color planes per pixel minus 1

parameter DEFAULT_DMA_ENABLED			                    = 1'b1; // 0: OFF or 1: ON
parameter DEFAULT_USE_EXTERNAL_BACKBUFFER_ADDRESS			= 1'b0; // 0: OFF or 1: ON
parameter DEFAULT_ALWAYS_DO_BUFFER_SWAP                     = 1'b0; // 0: OFF or 1: ON

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input						clk;
input						reset;

input			[ 3: 0]	address;
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
// Bi-Directional

// Outputs
output reg	[31: 0]	readdata;
output reg	[31: 0]	num_of_packets_processed;
output reg	[31: 0]	num_of_discarded_packets;
output reg	[31: 0]	num_of_out_of_band_data_received;
output reg	[31: 0]	num_of_repeated_packets;
output reg	[31: 0]	back_buf_start_address;
output reg	[31: 0]	last_written_buf_start_address;
output		[31: 0]	current_start_address;
output reg				dma_enabled;
output reg				use_external_priority_backbuffer;
output reg	[31: 0] num_buffer_swaps;
(*keep = 1, preserve = 1*) output reg	[31: 0] num_watchdog_events=0;
input increase_watchdog_event_count;

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

always @(posedge clk)
begin
     if (reset)
	 begin
	    prev_swap_addresses_enable <= 0;
		prev_currently_processing_packet <= 0;
		prev_actual_buffer_swap_enable <= 0;
	 end else
	 begin
	    prev_swap_addresses_enable <= swap_addresses_enable;
		prev_currently_processing_packet <= currently_processing_packet;
		prev_actual_buffer_swap_enable <= actual_buffer_swap_enable;
	 end
end

assign edge_detect_swap_addresses_enable = !prev_swap_addresses_enable & swap_addresses_enable;
wire edge_detect_actual_buffer_swap_enable = !prev_actual_buffer_swap_enable & actual_buffer_swap_enable;
wire edge_detect_currently_processing_packet = !prev_currently_processing_packet & currently_processing_packet;

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



// Output Registers
always @(posedge clk)
begin
	if (reset)
		readdata <= 32'h00000000;
   
	else if (read & (address == 4'h0))
		readdata <= buffer_start_address;
   
	else if (read & (address == 4'h1))
		readdata <= back_buf_start_address;
   
	else if (read & (address == 4'h2))
	begin
		readdata[31:0] <= NUM_OF_DMA_LOCATIONS;
	end
   
	else if (read & (address == 4'h3))
	begin
		readdata[31:24] <= COLOR_BITS;
		readdata[23:16] <= COLOR_PLANES;
		readdata[15: 6] <= 0;
		readdata[    5] <= currently_processing_packet;
		readdata[    4] <= always_do_buffer_swap;
		readdata[    3] <= use_external_priority_backbuffer;
		readdata[    2] <= dma_enabled;
		readdata[    1] <= 0;
		readdata[    0] <= buffer_swap;
	end
	else if (read & (address == 4'h4))
	begin
	      readdata <= num_of_packets_processed;	      
	end else if (read & (address == 4'h5))
	begin
	      readdata <= num_buffer_swaps;	      
	end else if (read & (address == 4'h6))
	begin
	      readdata <= num_of_repeated_packets;	      
	end else if (read & (address == 4'h7))
	begin
	     readdata <= last_written_buf_start_address;
	end else if (read & (address == 4'h8))
	begin
	     readdata <= num_watchdog_events;
	end else if (read & (address == 4'h9))
	begin
	     readdata <= num_of_discarded_packets;
	end else if (read & (address == 4'hA))
	begin
	     readdata <= num_of_out_of_band_data_received;
	end else if (read & (address == 4'hB))
	begin
	     readdata <= NUM_PIXELS_IN_FRAME;
	end else
	begin
	     readdata <= 32'hEAAEAA;
	end
end

 
// Internal Registers
always @(posedge clk)
begin
	if (reset)
	begin
		buffer_start_address	<= default_buffer_address;
		back_buf_start_address	<= default_back_buf_address;
		last_written_buf_start_address <= 32'hFFFFFFFF;
	end
	else if (write & (address == 4'h1))
	begin
		if (byteenable[0])
			back_buf_start_address[ 7: 0] <= writedata[ 7: 0];
		if (byteenable[1])
			back_buf_start_address[15: 8] <= writedata[15: 8];
		if (byteenable[2])
			back_buf_start_address[23:16] <= writedata[23:16];
		if (byteenable[3])
			back_buf_start_address[31:24] <= writedata[31:24];
	end
	else if (actual_buffer_swap_enable)
	begin
		buffer_start_address           <= use_external_priority_backbuffer ? external_priority_backbuffer_address : back_buf_start_address;
		back_buf_start_address         <= buffer_start_address;
		last_written_buf_start_address <= buffer_start_address; 
	end
end

always @(posedge clk)
begin
	if (reset)
		buffer_swap <= 1'b0;
	else if (write & (address == 4'h0))
		buffer_swap <= 1'b1;
	else if (swap_addresses_enable)
		buffer_swap <= 1'b0;
end

always @(posedge clk)
begin
	if (reset)
	begin
		dma_enabled <= DEFAULT_DMA_ENABLED;
		use_external_priority_backbuffer <= DEFAULT_USE_EXTERNAL_BACKBUFFER_ADDRESS;
		always_do_buffer_swap <= DEFAULT_ALWAYS_DO_BUFFER_SWAP;
	end
	else if (write & (address == 4'h3) & byteenable[0])
	begin
		dma_enabled <= writedata[2];
		use_external_priority_backbuffer <=  writedata[3];
		always_do_buffer_swap <= writedata[4];
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

