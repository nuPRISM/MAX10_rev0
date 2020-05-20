`default_nettype none
module simple_8b10b_rx_link_w_uart_control
#(
parameter numchannels = 2,
parameter channel_select_numbits = $clog2(numchannels),
parameter lock_wait_counter_bits = 9,
parameter num_bits_in_raw_frame = 8,
parameter num_bits_in_coded_frame = num_bits_in_raw_frame+2,
parameter output_data_parallelization_ratio = 4,
parameter valid_output_word_counter_bits = 32,
parameter TRANSPOSE_DEFAULT = 0,
parameter DEFAULT_LOCK_WAIT = 51,
parameter DEFAULT_ENABLE_8b10b_LOCK_SCAN = {numchannels{1'b1}},
parameter DEFAULT_IGNORE_DISP_ERR = {numchannels{1'b0}},
parameter DEFAULT_IGNORE_CODE_ERR = {numchannels{1'b0}},
parameter [0:0] COMPILE_ERROR_MONITORING = 1'b1,
//UART definitions
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0] postfix_uart_name = "_rx8b10b",
parameter [63:0] prefix_uart_name = "undef",
parameter [127:0] default_uart_name = {prefix_uart_name,postfix_uart_name},
parameter UART_REGFILE_TYPE = uart_regfile_types::RX8B10B_SIMPLE_LINK_REGFILE,
parameter [0:0] ASSUME_ALL_INPUT_DATA_IS_VALID = 1,
parameter [channel_select_numbits-1:0] DEFAULT_CHANNEL_TO_LOOK_AT = 0,
parameter [0:0] ASSUME_ALL_INPUT_DATA_IS_VALID_FOR_MONITORING = 0,
parameter  num_error_counter_bits = 32,
parameter NUM_ERROR_CHANNELS = numchannels,
parameter DEFAULT_MONITORED_CHANNELS = {numchannels{1'b1}},
parameter USE_DIFFERENT_CLOCK_FOR_MONITORING_CLOCK_UART = 1'b0
)
(
            input   frame_clk,
            input   data_out_parallel_clock,
			input   intermediate_clk,
            input   reset,
			input   [num_bits_in_coded_frame-1:0]     data_in[numchannels],
			output  [output_data_parallelization_ratio*num_bits_in_raw_frame-1:0] resynced_parallelized_data_out[numchannels],

			output logic [numchannels-1:0]                                             decoder_control_character_detected,
         output logic  [num_bits_in_raw_frame-1:0]                                  data_out[numchannels],

			input  UART_REGFILE_CLK,
			input  RESET_FOR_UART_REGFILE_CLK,
			input uart_active_high_async_reset,
			
			output uart_tx,
			input  uart_rx,
			
			input wire       UART_IS_SECONDARY_UART,
			input wire [7:0] UART_NUM_SECONDARY_UARTS,
			input wire [7:0] UART_ADDRESS_OF_THIS_UART,
			output     [7:0] NUM_UARTS_HERE,
			input logic [63:0]  uart_name_variable_prefix
			
			
			
);

localparam num_selection_bits = $clog2(num_bits_in_coded_frame);
logic [7:0] local_num_uarts_here[1];
logic error_monitor_uart_rxd;
assign NUM_UARTS_HERE = 1+ local_num_uarts_here[0];

//Control
  logic                                                                transpose_2x_coded_bit_data_bits;
  logic                                                                transpose_channel_data_halves;
  logic [numchannels-1:0]                                              ignore_disparity_err;
  logic [numchannels-1:0]                                              ignore_coding_err;
  logic [lock_wait_counter_bits-1:0]                                   lock_wait;
  logic [numchannels-1:0]                                              enable_8b_10b_lock_scan;
  logic [numchannels-1:0]                                              delay_data_out_for_lane_alignment;
  
 //Status
 
  logic [numchannels-1:0]                                             coding_err;
  logic [numchannels-1:0]                                             disparity;
  logic [numchannels-1:0]                                             disparity_err;  
  logic [numchannels-1:0]                                             clear_scan_counter_8b_10b;
  logic [numchannels-1:0]                                             inc_scan_counterm_8b_10b;
  
  logic  [num_selection_bits-1:0]                                     frame_select[numchannels];
  logic  [2*num_bits_in_coded_frame-1:0]                              raw_2x_coded_bit_data[numchannels];
  logic                                                               is_locked_8b_10b[numchannels];
  logic  [numchannels-1:0]                                            repackaged_is_locked_8b_10b;
  logic [lock_wait_counter_bits-1:0]                                  lock_wait_counter[numchannels];
  logic [3:0]                                                         lock_wait_machine_state_num[numchannels];
  
  logic [9:0]                                                         frame_region_8b_10b[numchannels];
  logic [7:0]                                                         decoded_8b_10b_data_fragment[numchannels];
  logic [num_bits_in_coded_frame-1:0]                                 selected_data_out[numchannels];
  logic [2*num_bits_in_coded_frame-1:0]                               raw_raw_2x_coded_bit_data[numchannels];
  logic [output_data_parallelization_ratio-1:0]                       parallelizer_current_byte_enable[numchannels];
  logic [output_data_parallelization_ratio*num_bits_in_raw_frame-1:0] parallelizer_total_output_reg[numchannels];
  logic [valid_output_word_counter_bits-1:0]                          valid_data_word_count[numchannels];
  
  //ignored status
  logic [num_bits_in_coded_frame-1:0]                                 decoder_pipeline_delay_of_uncoded_bits[numchannels];  
  logic [num_bits_in_raw_frame-1:0]                                   parallelizer_output_regs[numchannels][output_data_parallelization_ratio-1];
  logic [output_data_parallelization_ratio*num_bits_in_raw_frame-1:0] intermediate_data[numchannels];
  logic actual_ce_conv_up  [numchannels];
  logic actual_ce_conv_down[numchannels];
  logic [numchannels-1:0]  error_signal_bus;
  logic  pll_generated_20x_of_data_out_parallel_clock;
  logic  enable_clocking_of_output_data[numchannels];
  logic  new_data_word_ready_now[numchannels];
  logic [output_data_parallelization_ratio*num_bits_in_raw_frame-1:0] raw_resynced_parallelized_data_out[numchannels];

generate
			if (COMPILE_ERROR_MONITORING)
			begin  
					  always @(posedge frame_clk)
					  begin
							error_signal_bus <=  (((~ignore_disparity_err) & disparity_err) | ((~ignore_coding_err) & coding_err));
					  end                      

					  if (USE_DIFFERENT_CLOCK_FOR_MONITORING_CLOCK_UART)
					  begin
								monitor_errors_lt_and_st_w_uart_better_clocking
								#(
								.NUM_ERROR_CHANNELS(numchannels),
								.DEFAULT_MONITORED_CHANNELS({numchannels{1'b1}}),
								.num_error_counter_bits(num_error_counter_bits),
								.OMIT_CONTROL_REG_DESCRIPTIONS(OMIT_CONTROL_REG_DESCRIPTIONS ),
								.OMIT_STATUS_REG_DESCRIPTIONS (OMIT_STATUS_REG_DESCRIPTIONS  ),
								.UART_CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
								.REGFILE_BAUD_RATE(REGFILE_BAUD_RATE),
								.prefix_uart_name ({prefix_uart_name,"rx"}),
								.ASSUME_ALL_INPUT_DATA_IS_VALID(ASSUME_ALL_INPUT_DATA_IS_VALID_FOR_MONITORING)
								)
								monitor_errors_lt_and_st_w_uart_better_clocking_inst
								(
									.UART_REGFILE_CLK              (UART_REGFILE_CLK          ),
									.RESET_FOR_UART_REGFILE_CLK    (RESET_FOR_UART_REGFILE_CLK),
									
									.data_clk        (frame_clk),
									.error_signal_bus(error_signal_bus),
									.indata_valid    (1'b1),

											
									/*output */.uart_tx( error_monitor_uart_rxd   ),
									/*input  */.uart_rx(uart_rx),
									.uart_name_variable_prefix(uart_name_variable_prefix),
											
									.UART_IS_SECONDARY_UART   (1),
									.UART_NUM_SECONDARY_UARTS (0),
									.UART_ADDRESS_OF_THIS_UART(UART_ADDRESS_OF_THIS_UART + 1),
									.NUM_UARTS_HERE           (local_num_uarts_here[0])
									
								);
								
						end else
						begin
								monitor_errors_lt_and_st_w_uart
								#(
								.NUM_ERROR_CHANNELS(numchannels),
								.DEFAULT_MONITORED_CHANNELS({numchannels{1'b1}}),
								.num_error_counter_bits(num_error_counter_bits),
								.OMIT_CONTROL_REG_DESCRIPTIONS(OMIT_CONTROL_REG_DESCRIPTIONS ),
								.OMIT_STATUS_REG_DESCRIPTIONS (OMIT_STATUS_REG_DESCRIPTIONS  ),
								.UART_CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
								.REGFILE_BAUD_RATE(REGFILE_BAUD_RATE),
								.prefix_uart_name ({prefix_uart_name,"rx"}),
								.ASSUME_ALL_INPUT_DATA_IS_VALID(ASSUME_ALL_INPUT_DATA_IS_VALID_FOR_MONITORING)
								)
								monitor_errors_lt_and_st_w_uart_inst
								(
									.UART_REGFILE_CLK              (UART_REGFILE_CLK          ),
									.RESET_FOR_UART_REGFILE_CLK    (RESET_FOR_UART_REGFILE_CLK),
									
									.data_clk        (frame_clk),
									.error_signal_bus(error_signal_bus),
									.indata_valid    (1'b1),

											.uart_active_high_async_reset(uart_active_high_async_reset),
									/*output */.uart_tx( error_monitor_uart_rxd   ),
									/*input  */.uart_rx(uart_rx),
									.uart_name_variable_prefix(uart_name_variable_prefix),
											
									.UART_IS_SECONDARY_UART   (1),
									.UART_NUM_SECONDARY_UARTS (0),
									.UART_ADDRESS_OF_THIS_UART(UART_ADDRESS_OF_THIS_UART + 1),
									.NUM_UARTS_HERE           (local_num_uarts_here[0])
									
								);
								
						end
			end else
			begin
				 assign local_num_uarts_here[0] = 0;
				 assign error_monitor_uart_rxd = 1;
			end
endgenerate  

 multi_channel_8b10b_rx_w_parallelizer
#(
.numchannels(numchannels),
.lock_wait_counter_bits(lock_wait_counter_bits),
.num_bits_in_raw_frame(num_bits_in_raw_frame),
.num_bits_in_coded_frame(num_bits_in_coded_frame),
.output_data_parallelization_ratio(output_data_parallelization_ratio),
.valid_output_word_counter_bits(valid_output_word_counter_bits)
)
multi_channel_8b10b_rx_w_parallelizer_inst
(
.*,
   .fixed_delay_data_out_prior_to_lane_alignment(),
   .fixed_delay_decoder_control_character_detected()
);
  
repackage_unpacked_to_packed  #(.numbits(numchannels)) repackage_is_locked_8b_10b (.in_unpacked(is_locked_8b_10b), .out_packed(repackaged_is_locked_8b_10b));

  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam first_per_channel_status_index = 7;
	        localparam num_status_regs_per_channel = 16;
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 6;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = first_per_channel_status_index+num_status_regs_per_channel*numchannels-1;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0;
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

	        assign uart_regfile_interface_pins.display_name         = ((|uart_name_variable_prefix) != 0) ? {uart_name_variable_prefix,postfix_uart_name} : default_uart_name;
			assign uart_regfile_interface_pins.num_secondary_uarts  = UART_NUM_SECONDARY_UARTS;
			assign uart_regfile_interface_pins.is_secondary_uart    = UART_IS_SECONDARY_UART;
			assign uart_regfile_interface_pins.address_of_this_uart = UART_ADDRESS_OF_THIS_UART;
			assign uart_regfile_interface_pins.rxd = uart_rx;
			assign uart_tx = uart_regfile_interface_pins.txd & error_monitor_uart_rxd;
			assign uart_regfile_interface_pins.clk                    = UART_REGFILE_CLK;
			assign uart_regfile_interface_pins.data_clk               = frame_clk;
			assign uart_regfile_interface_pins.reset                  = RESET_FOR_UART_REGFILE_CLK;
			assign uart_regfile_interface_pins.uart_active_high_async_reset  = uart_active_high_async_reset;
			assign uart_regfile_interface_pins.user_type              = UART_REGFILE_TYPE;	
			
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
			  .uart_regfile_interface_pins(uart_regfile_interface_pins        ),
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
				
	assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  TRANSPOSE_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[0]               = "transpose";
    assign {transpose_2x_coded_bit_data_bits,transpose_channel_data_halves}    = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 2;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  DEFAULT_IGNORE_DISP_ERR;
    assign uart_regfile_interface_pins.control_desc[1]               = "ignore_disp_err";
    assign ignore_disparity_err                      = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = numchannels;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  DEFAULT_IGNORE_CODE_ERR;
    assign uart_regfile_interface_pins.control_desc[2]               = "ignore_code_err";
    assign ignore_coding_err                      = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = numchannels;		
	  	 
		 	 
	assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  DEFAULT_LOCK_WAIT;
    assign uart_regfile_interface_pins.control_desc[3]               = "lock_wait";
    assign lock_wait                      = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = lock_wait_counter_bits;		

		 	 
	assign uart_regfile_interface_pins.control_regs_default_vals[4]  =  DEFAULT_ENABLE_8b10b_LOCK_SCAN;
    assign uart_regfile_interface_pins.control_desc[4]               = "enable_8b10b_lock";
    assign enable_8b_10b_lock_scan                      = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = numchannels;		
	  	 
			 	 
	assign uart_regfile_interface_pins.control_regs_default_vals[5]  =  0;
    assign uart_regfile_interface_pins.control_desc[5]               = "delay_lane";
    assign delay_data_out_for_lane_alignment                      = uart_regfile_interface_pins.control[5];
    assign uart_regfile_interface_pins.control_regs_bitwidth[5]      = numchannels;		
	  	  	
		 
		 
	assign uart_regfile_interface_pins.status[0] = decoder_control_character_detected;	
	assign uart_regfile_interface_pins.status_desc[0]    ="ctrl_char_det";	

	assign uart_regfile_interface_pins.status[1]     = coding_err;
	assign uart_regfile_interface_pins.status_desc[1]    ="coding_err";	
	
	assign uart_regfile_interface_pins.status[2]     = disparity;
	assign uart_regfile_interface_pins.status_desc[2]    ="disparity";	
	
	assign uart_regfile_interface_pins.status[3]     = disparity_err;
	assign uart_regfile_interface_pins.status_desc[3]    ="disparity_err";	
	
	assign uart_regfile_interface_pins.status[4]     = clear_scan_counter_8b_10b;
	assign uart_regfile_interface_pins.status_desc[4]    ="clr_scan_8b_10b";	
	
	assign uart_regfile_interface_pins.status[5]     = inc_scan_counterm_8b_10b;
	assign uart_regfile_interface_pins.status_desc[5]    ="inc_scan_8b_10b";	
	
	assign uart_regfile_interface_pins.status[6]     = repackaged_is_locked_8b_10b;
	assign uart_regfile_interface_pins.status_desc[6]    ="is_locked_8b_10b";	
	

	
	genvar current_channel;
	generate
	         for (current_channel = 0; current_channel < numchannels; current_channel++)
			 begin : generate_phase_dependent_registers	
                  wire [15:0] current_channel_num_ascii = {math_func_package::get_second_digit_as_ascii(current_channel),math_func_package::get_first_digit_as_ascii(current_channel)};			 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  0]  = frame_select                     [current_channel]; 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  1]  = data_out                         [current_channel]; 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  2]  = raw_2x_coded_bit_data            [current_channel]; 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  3]  = lock_wait_counter                [current_channel]; 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  4]  = lock_wait_machine_state_num      [current_channel];			  
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  5]  = frame_region_8b_10b              [current_channel]; 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  6]  = decoded_8b_10b_data_fragment     [current_channel]; 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  7]  = selected_data_out                [current_channel]; 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  8]  = parallelizer_current_byte_enable [current_channel]; 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  9] = parallelizer_total_output_reg    [current_channel]; 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel + 10] = valid_data_word_count            [current_channel]; 
				  assign uart_regfile_interface_pins.status[first_per_channel_status_index + current_channel*num_status_regs_per_channel + 11]  = resynced_parallelized_data_out        [current_channel]; 

				  
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  0] = {"frame_sel"      , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  1] = {"data_out_dec"   , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  2] = {"raw2xcodeddata" , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  3] = {"lockwaitctr"    , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  4] = {"lockwaitstate"  , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  5] = {"FrmRegn8b_10b"  , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  6] = {"dec8b10bfrag"   , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  7] = {"sel_dat_out"    , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  8] = {"ParCurByteEn"   , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel +  9] = {"ParTotOutReg"    , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel + 10] = {"validWrdCnt"    , current_channel_num_ascii } ;
				   assign uart_regfile_interface_pins.status_desc[first_per_channel_status_index + current_channel*num_status_regs_per_channel + 11] = {"resyncParDataOut"    , current_channel_num_ascii } ;
             end
	endgenerate
	

endmodule
`default_nettype wire

