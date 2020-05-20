
`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;

module fmem_w_uart_support
#(
parameter  [15:0] data_width            = 128,
parameter  [15:0] num_locations_in_fifo   = 256,
parameter  [7:0] num_words_bits          = $clog2(num_locations_in_fifo),
parameter  [7:0] event_counter_width = 32,
parameter  [7:0] word_counter_width = 32,
parameter  OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter  OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter  UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter  REGFILE_BAUD_RATE = 2000000,
parameter  [63:0]  prefix_uart_name = "undef",
parameter  [127:0] uart_name = {prefix_uart_name,"Fmem"},
parameter  UART_REGFILE_TYPE = uart_regfile_types::DATA_ACQUISITION_TRIGGERED_FIFO,
parameter  MEM_DEPTH	= num_locations_in_fifo,
parameter  SZ_DATA 	= data_width,
localparam NUM_BUFF 	= 1 							// For now, we'll only double-buffer
localparam SZ_BUFF   = $clog2(NUM_BUFF),
localparam SZ_MEM 	=num_words_bits,		// Depth of each memory buffer
localparam SZ_CNT		= $clog2(num_locations_in_fifo+1);



)
(

    input  UART_REGFILE_CLK,
	input  RESET_FOR_UART_REGFILE_CLK,
	
	output uart_tx,
	input  uart_rx,
	
	input [data_width-1:0] indata,
	input indata_valid,
	input  indata_clk,

	output [data_width-1:0] outdata,
	output outdata_valid,
	input  outdata_clk,
	
	input  external_fifo_reset,

    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output [7:0] NUM_UARTS_HERE
	
);

logic main_uart_tx;

assign uart_tx = main_uart_tx;

assign NUM_UARTS_HERE = 1;




// Write Clock Domain
logic					capture_memory_clk;
logic					capture_memory_rst;
logic					capture_memory_lock;
logic [SZ_DATA-1:0] 	capture_memory_d;
logic					capture_memory_trigger;
logic					capture_memory_release_req;
logic [SZ_MEM-1:0] 	    capture_memory_num_pre_fill;
logic [SZ_MEM-1:0] 	    capture_memory_num_post_fill;
logic					capture_memory_ready;
logic					capture_memory_triggered;
logic [SZ_CNT-1:0]		capture_memory_count;

// Read Clock Domain
logic					   capture_memory_rd_clk;
logic [SZ_MEM-1:0]		   capture_memory_rd_addr;
logic [SZ_DATA-1:0] 	   capture_memory_rd_q;

							  
fmem 
#(
.MEM_DEPTH(MEM_DEPTH),
.SZ_DATA  (SZ_DATA)
)
fmem_inst(
	.clk            (capture_memory_clk             ),
	.rst            (capture_memory_rst             ),
	.d              (capture_memory_d               ),					// Input data
	.trigger        (capture_memory_trigger         ),			// Trigger event, sets end point and stalls recording
	.triggered      (capture_memory_triggered       ),
	.lock           (capture_memory_lock            ),				// Stops us from releasing the latest trigger (hold for read)
	.ready          (capture_memory_ready           ), 			// Waveform available (filled buffer)
	.release_req    (capture_memory_release_req     ),	// Release triggered waveforms, allowing us to recapture		
	.num_pre_fill   (capture_memory_num_pre_fill    ),	// Number of data points before trigger to keep
	.num_post_fill  (capture_memory_num_post_fill   ),	// Number of data points after trigger to keep
	.count          (capture_memory_count           ),
	
	// Read Signals
	.rd_clk         (capture_memory_rd_clk   ),
	.rd_addr        (capture_memory_rd_addr  ),
	.rd_q           (capture_memory_rd_q     )
);

							  
							  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 3;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 5;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0 ;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 0;
			
			/* dummy wishbone interface definitions */		
			wishbone_interface 
			#(
			   .num_address_bits(32), 
			   .num_data_bits(32)
			)
			status_wishbone_interface_pins();
						
			wishbone_interface 
			#(
			   .num_address_bits(32), 
			   .num_data_bits(32)
			)
			control_wishbone_interface_pins();
			
			
			
			uart_regfile_interface 
			#(                                                                                                     
			.DATA_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       ),
			.DESC_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       ),
			.NUM_OF_CONTROL_REGS                          (STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 ),
			.NUM_OF_STATUS_REGS                           (STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  ),
			.INIT_ALL_CONTROL_REGS_TO_DEFAULT             (STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    ),
			.CONTROL_REGS_DEFAULT_VAL                     (STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            ),
			.USE_AUTO_RESET                               (STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      ),
			.CLOCK_SPEED_IN_HZ                            (STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   ),
			.UART_BAUD_RATE_IN_HZ                         (STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                ),
			.ENABLE_CONTROL_WISHBONE_INTERFACE            (STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   ),
			.ENABLE_STATUS_WISHBONE_INTERFACE             (STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    ),
			.DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  )
				
			)
			uart_regfile_interface_pins();

	        assign uart_regfile_interface_pins.display_name         = uart_name;
			assign uart_regfile_interface_pins.num_secondary_uarts  = UART_NUM_SECONDARY_UARTS;
			assign uart_regfile_interface_pins.is_secondary_uart    = UART_IS_SECONDARY_UART;
			assign uart_regfile_interface_pins.address_of_this_uart = UART_ADDRESS_OF_THIS_UART;
			assign uart_regfile_interface_pins.rxd = uart_rx;
			assign main_uart_tx = uart_regfile_interface_pins.txd;
			assign uart_regfile_interface_pins.clk       = UART_REGFILE_CLK;
			assign uart_regfile_interface_pins.reset     = 1'b0;
			assign uart_regfile_interface_pins.user_type = UART_REGFILE_TYPE;	
			
			uart_controlled_register_file_w_interfaces
			#(
			 .DATA_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                      ),
			 .DESC_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                      ),
			 .NUM_OF_CONTROL_REGS                          (STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                ),
			 .NUM_OF_STATUS_REGS                           (STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                 ),
			 .INIT_ALL_CONTROL_REGS_TO_DEFAULT             (STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT   ),
			 .CONTROL_REGS_DEFAULT_VAL                     (STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL           ),
			 .USE_AUTO_RESET                               (STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                     ),
			 .CLOCK_SPEED_IN_HZ                            (STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                  ),
			 .UART_BAUD_RATE_IN_HZ                         (STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ               ),
			 .ENABLE_CONTROL_WISHBONE_INTERFACE            (STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE  ),
			 .ENABLE_STATUS_WISHBONE_INTERFACE             (STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE   ),
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS)
			)		
			control_and_status_regfile
			(
			  .uart_regfile_interface_pins(uart_regfile_interface_pins),
			  .status_wishbone_interface_pins (status_wishbone_interface_pins ), 
			  .control_wishbone_interface_pins(control_wishbone_interface_pins)			  
			);
			
	
			genvar sreg_count;
			genvar creg_count;
			
			generate
					for ( sreg_count=0; sreg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS; sreg_count++)
					begin : clear_status_descs
						  assign uart_regfile_interface_pins.status_omit_desc[sreg_count] = OMIT_STATUS_REG_DESCRIPTIONS;
					end
					
						
					for (creg_count=0; creg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS; creg_count++)
					begin : clear_control_descs
						  assign uart_regfile_interface_pins.control_omit_desc[creg_count] = OMIT_CONTROL_REG_DESCRIPTIONS;
					end
			endgenerate
			
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  32'h12345678;
    assign uart_regfile_interface_pins.control_desc[0]               = "ctrlAlive";
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 32;		

    assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  0;
    assign uart_regfile_interface_pins.control_desc[1]               = "InjectDiffErrors";
    assign inject_error_bus_raw     = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = parity_width;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  USE_EVEN_PARITY_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[2]               = "UseEvenParity";
    assign use_even_parity_raw     = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 1;	
	
	assign uart_regfile_interface_pins.status[0] = 32'h12345678;
	assign uart_regfile_interface_pins.status_desc[0]    ="StatusAlive";	

	assign uart_regfile_interface_pins.status[1] = synced_to_uart_domain_received_parity_out;
	assign uart_regfile_interface_pins.status_desc[1]    ="RecvdParituy";
	
	assign uart_regfile_interface_pins.status[2] = synced_to_uart_domain_calculated_parity_out;
	assign uart_regfile_interface_pins.status_desc[2]    ="CalcParity";
	
	assign uart_regfile_interface_pins.status[3] = synced_to_uart_domain_calculated_parity_difference;
	assign uart_regfile_interface_pins.status_desc[3]    ="ParityDifference";	
	
	assign uart_regfile_interface_pins.status[4] = {mcp_synch_error_signal_bus_aready, mcp_synch_error_signal_bus_bvalid, mcp_synch_to_data_clk_aready, mcp_synch_to_data_clk_bvalid};
	assign uart_regfile_interface_pins.status_desc[4]    ="mcp_blk_status";
			
 endmodule
 
`default_nettype wire