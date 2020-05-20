`default_nettype none
`include "interface_defs.v"
//`include "keep_defines.v"
import uart_regfile_types::*;
	  
module monitor_errors_lt_and_st_w_uart_better_clocking
#(
parameter NUM_ERROR_CHANNELS = 32,
parameter DEFAULT_MONITORED_CHANNELS = 32'hFFFFFFFF,
parameter num_error_counter_bits = 32,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [7:0] word_counter_width = 32,
parameter [63:0]  prefix_uart_name = "undef",
parameter [63:0] postfix_uart_name = "ErrorMon",
parameter [127:0] default_uart_name = {prefix_uart_name,postfix_uart_name},
parameter UART_REGFILE_TYPE = uart_regfile_types::ERROR_MONITOR_REGFILE,
parameter [0:0] ASSUME_ALL_INPUT_DATA_IS_VALID = 1
)
(
	input  UART_REGFILE_CLK,
	input  RESET_FOR_UART_REGFILE_CLK,
	
	input data_clk,
	input [NUM_ERROR_CHANNELS-1:0] error_signal_bus,
	input indata_valid,

	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	 output      [7:0] NUM_UARTS_HERE,
	 input logic [63:0]  uart_name_variable_prefix
	
);

assign NUM_UARTS_HERE = 1;
				
logic [num_error_counter_bits-1:0] error_count;
logic [NUM_ERROR_CHANNELS-1:0] inject_error_bus;
logic [NUM_ERROR_CHANNELS-1:0] error_signal_bus_to_status;
logic [NUM_ERROR_CHANNELS-1:0] actual_error_signal_bus;
logic [NUM_ERROR_CHANNELS-1:0] event_recorded_bus;
logic [NUM_ERROR_CHANNELS-1:0] enabled_channels_for_error_monitoring_bus;
logic enable_error_monitoring;
logic actual_enable_error_monitoring;
logic clear_error_count;
logic actual_monitored_error_signal;
logic actual_indata_valid;
reg [word_counter_width-1:0]  input_word_counter = 0;
reg [word_counter_width-1:0]  total_input_word_counter = 0;

assign actual_indata_valid = ASSUME_ALL_INPUT_DATA_IS_VALID ? 1'b1 : indata_valid;

always @(posedge data_clk)
begin
      actual_error_signal_bus <=  inject_error_bus | error_signal_bus;
end

assign actual_enable_error_monitoring = enable_error_monitoring & actual_indata_valid; 


always_ff @(posedge data_clk)
begin
      if (clear_error_count) 
	  begin
	    input_word_counter <= 0;
		total_input_word_counter <= 0;
	  end else
	  begin
	        total_input_word_counter <= total_input_word_counter + 1;
	        if (actual_indata_valid)
			begin
	              input_word_counter <= input_word_counter + 1;		
			end
	  end     
end



monitor_errors_in_channels
#(
.num_counter_bits(num_error_counter_bits),
.num_channels(NUM_ERROR_CHANNELS),
.saturation_limit({num_error_counter_bits{1'b1}})
)
monitor_errors_in_channels_inst
(
  .clk(data_clk),
  .channel_error_signals(actual_error_signal_bus),
  .saturated_sum(error_count),
  .enabled_channels(enabled_channels_for_error_monitoring_bus),
  .count_enable(actual_enable_error_monitoring),
  .clear_counter(clear_error_count),
  .actual_monitored_signal(actual_monitored_error_signal)
);

record_events
#(
.numchannels(NUM_ERROR_CHANNELS)
)
record_events_inst 
(
.monitored_signals(actual_error_signal_bus),
.clk(data_clk),
.clear(clear_error_count),
.event_recorded(event_recorded_bus)
);

		  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 4;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 9;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0 ;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 0;
			localparam  UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK                        = 1;

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
			.DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  ),
			.UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK      (UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK                        )	
			)
			uart_regfile_interface_pins();

	        assign uart_regfile_interface_pins.display_name       = ((|uart_name_variable_prefix) != 0) ? {uart_name_variable_prefix,postfix_uart_name} : default_uart_name;
			assign uart_regfile_interface_pins.num_secondary_uarts  = UART_NUM_SECONDARY_UARTS;
			assign uart_regfile_interface_pins.is_secondary_uart    = UART_IS_SECONDARY_UART;
			assign uart_regfile_interface_pins.address_of_this_uart = UART_ADDRESS_OF_THIS_UART;
			assign uart_regfile_interface_pins.rxd = uart_rx;
			assign uart_tx = uart_regfile_interface_pins.txd;
			assign uart_regfile_interface_pins.clk       = UART_REGFILE_CLK;
			assign uart_regfile_interface_pins.reset     = 1'b0;
			assign uart_regfile_interface_pins.user_type = UART_REGFILE_TYPE;	
			assign uart_regfile_interface_pins.data_clk               = data_clk;

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
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS ),
 			 .UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK      (UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK                       )
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
	
		
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  DEFAULT_MONITORED_CHANNELS;
    assign uart_regfile_interface_pins.control_desc[1]               = "monitored_chans";
    assign enabled_channels_for_error_monitoring_bus                      = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = NUM_ERROR_CHANNELS;		
	  

	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  1;
    assign uart_regfile_interface_pins.control_desc[2]               = "ErrCntrCtrl";
    assign {clear_error_count,enable_error_monitoring}     = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 2;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  0;
    assign uart_regfile_interface_pins.control_desc[3]               = "InjectErrors";
    assign inject_error_bus                 = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = NUM_ERROR_CHANNELS;		
	  

	
	assign uart_regfile_interface_pins.status[0] = 32'h12345678;
	assign uart_regfile_interface_pins.status_desc[0]    ="StatusAlive";	

	assign uart_regfile_interface_pins.status[1] = error_count;
	assign uart_regfile_interface_pins.status_desc[1]    ="ErrorCount";
	
	assign uart_regfile_interface_pins.status[2] = actual_monitored_error_signal;
	assign uart_regfile_interface_pins.status_desc[2]    ="ActMonErrSig";
	
	assign uart_regfile_interface_pins.status[3] = event_recorded_bus;
	assign uart_regfile_interface_pins.status_desc[3]    ="event_recorded";
		
    assign uart_regfile_interface_pins.status[4] = NUM_ERROR_CHANNELS;
	assign uart_regfile_interface_pins.status_desc[4]    ="NUM_ERROR_CHANNELS";
	
	assign uart_regfile_interface_pins.status[5] = error_signal_bus;
	assign uart_regfile_interface_pins.status_desc[5]    ="Error_Signal_Bus";
		
	assign uart_regfile_interface_pins.status[6] = actual_error_signal_bus;
	assign uart_regfile_interface_pins.status_desc[6]    ="ActErrorSigBus";	
	
	assign uart_regfile_interface_pins.status[7] = input_word_counter;
	assign uart_regfile_interface_pins.status_desc[7]    ="InputWordCounter";
	
	assign uart_regfile_interface_pins.status[8] = total_input_word_counter;
	assign uart_regfile_interface_pins.status_desc[8]    ="TotalWordCounter";
		

 endmodule
 
`default_nettype wire
