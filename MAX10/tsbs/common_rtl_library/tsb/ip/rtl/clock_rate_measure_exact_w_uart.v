`default_nettype none
`include "interface_defs.v"
//`include "keep_defines.v"
import uart_regfile_types::*;
//import utilities::*;
	  
module clock_rate_measure_exact_w_uart
#(
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [7:0] word_counter_width = 32,
parameter [63:0]  prefix_uart_name = "undef",
parameter shortreal scaling_factor,
parameter [127:0] uart_name = {prefix_uart_name,"_RefMeas"},
parameter UART_REGFILE_TYPE = uart_regfile_types::CLOCK_MEASURE_EXACT_UART_REGFILE,
parameter NUM_CLOCKS = 4,
parameter bit [127:0] clk_names[NUM_CLOCKS],
parameter shortreal clk_expected_freqs[NUM_CLOCKS],
parameter synchronizer_depth = 3,
parameter DEFAULT_CLOCK_MEASUREMENT_INTERVAL_MILLISECONDS = 200

)
(
	input  UART_REGFILE_CLK,
	input  RESET_FOR_UART_REGFILE_CLK,
	
	input data_clk[NUM_CLOCKS],
	input [31:0] refclk_index,

	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output     [7:0] NUM_UARTS_HERE
	
);

assign NUM_UARTS_HERE = 1;
localparam ZERO_IN_ASCII = 48;
				
logic [NUM_CLOCKS-1:0] clear_clock_counter;
logic [NUM_CLOCKS-1:0] clear_clock_counter_raw;
logic [NUM_CLOCKS-1:0] transfer_counter_now;
logic capture_data_now_raw;
logic [NUM_CLOCKS-1:0] capture_data_now;

logic [word_counter_width-1:0]  total_input_word_counter[NUM_CLOCKS];
logic [word_counter_width-1:0]  captured_input_word_counter[NUM_CLOCKS];
logic [word_counter_width-1:0]  synced_captured_input_word_counter[NUM_CLOCKS];
logic [31:0]  clock_measurement_interval_milliseconds;

genvar i;
generate
			for (i = 0; i < NUM_CLOCKS; i++)
			begin : make_clock_counters
					doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
					doublesync_clear_clock_counter_to_data_clk
					(
					.indata(clear_clock_counter_raw[i]),
					.outdata(clear_clock_counter[i]),
					.clk(data_clk[i])
					);
					
					doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
					doublesync_capture_data_now_to_data_clk
					(
					.indata(capture_data_now_raw),
					.outdata(capture_data_now[i]),
					.clk(data_clk[i])
					);					
					
					edge_detect
					edge_detect_capture_data_now
					(
                    .in_signal(capture_data_now[i]), 
                    .edge_detect(transfer_counter_now[i]), 
                    .clk(data_clk[i])
				    );
              
                    always_ff @(posedge data_clk[i])
					begin
						  if (clear_clock_counter[i]) 
						  begin
							total_input_word_counter[i] <= 0;
						  end else
						  begin
						        if (transfer_counter_now[i]) 
								begin
								       total_input_word_counter[i] <= 0;					
								end else
								begin
								       total_input_word_counter[i] <= total_input_word_counter[i] + 1;	
								end
						  end     
					end
				    
					always_ff @(posedge data_clk[i])
					begin
						  if (clear_clock_counter[i]) 
						  begin
							   captured_input_word_counter[i] <= 0;
						  end else
						  begin  
						        if (transfer_counter_now[i]) 
								begin
								   	  captured_input_word_counter[i] <= total_input_word_counter[i];					
								end 
						  end     
					end
					
					my_multibit_clock_crosser_optimized_for_altera
					#(
					  .DATA_WIDTH(word_counter_width) 
					)
					mcp_captured_input_word_counter
					(
					   .in_clk(data_clk[i]),
					   .in_valid(1'b1),
					   .in_data(captured_input_word_counter[i]),
					   .out_clk(UART_REGFILE_CLK),
					   .out_valid(),
					   .out_data(synced_captured_input_word_counter[i])
					 );
					
			end
endgenerate
		
										  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam start_of_auto_regs = 3;

		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 3;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 2*NUM_CLOCKS+start_of_auto_regs;			
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
			assign uart_tx = uart_regfile_interface_pins.txd;
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
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS )
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
			
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  0;
    assign uart_regfile_interface_pins.control_desc[0]               = "ClrClkCntr";
	assign clear_clock_counter_raw                                   = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = NUM_CLOCKS;		
			
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  0;
    assign uart_regfile_interface_pins.control_desc[1]               = "capture_now";
	assign capture_data_now_raw                                      = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 1;				
	
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  DEFAULT_CLOCK_MEASUREMENT_INTERVAL_MILLISECONDS;
    assign uart_regfile_interface_pins.control_desc[2]               = "meas_time_ms";
	assign clock_measurement_interval_milliseconds                   = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 32;		
	
	
	assign uart_regfile_interface_pins.status[0] = NUM_CLOCKS;
	assign uart_regfile_interface_pins.status_desc[0]    ="Num_Clocks";	
	
	assign uart_regfile_interface_pins.status[1] = scaling_factor;
	assign uart_regfile_interface_pins.status_desc[1]    ="ScalingFactor";
		
	assign uart_regfile_interface_pins.status[2] = refclk_index;
	assign uart_regfile_interface_pins.status_desc[2]    ="refclk_index";
	
	
	generate	      
	      for (i = 0; i < NUM_CLOCKS; i++)
			begin	 : make_clock_counter_status_regs	
			       wire [7:0] char1 = ((i/10)+ZERO_IN_ASCII);
	             wire [7:0] char2 = ((i % 10)+ZERO_IN_ASCII);
	             assign uart_regfile_interface_pins.status[2*i+start_of_auto_regs] = synced_captured_input_word_counter[i];
	             assign uart_regfile_interface_pins.status_desc[2*i+start_of_auto_regs]    = clk_names[i];	
				    assign uart_regfile_interface_pins.status[2*i+ 1 + start_of_auto_regs] =  clk_expected_freqs[i];
	             assign uart_regfile_interface_pins.status_desc[2*i+1+start_of_auto_regs]    = {"Freq",char1,char2};	
			end
	endgenerate
	
 endmodule
 
`default_nettype wire
