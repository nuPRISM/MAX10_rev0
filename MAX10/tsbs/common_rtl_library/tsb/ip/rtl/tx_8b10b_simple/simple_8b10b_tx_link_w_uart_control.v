`default_nettype none
module simple_8b10b_tx_link_w_uart_control
#(
parameter numchannels = 2,
parameter device_family = "Cylcone III", 
parameter num_data_output_fifo_locations = 16,
parameter input_to_output_bitwidth_ratio = 4,
parameter input_data_bits_per_channel = 32,
parameter out_data_bits_per_channel = input_data_bits_per_channel/input_to_output_bitwidth_ratio,
parameter control_chars_width = 8,
parameter control_char_fifo_depth = 64,
parameter channel_select_numbits = 8,

//UART definitions
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_tx8b10b"},
parameter UART_REGFILE_TYPE = uart_regfile_types::TX8B10B_SIMPLE_LINK_REGFILE,
parameter [0:0] ASSUME_ALL_INPUT_DATA_IS_VALID = 1,
parameter [channel_select_numbits-1:0] DEFAULT_CHANNEL_TO_LOOK_AT = 0
)
(
            input [control_chars_width-1:0] padding_char[numchannels],

			input data_in_clk,
			input data_in_enable,
			input [input_data_bits_per_channel-1:0] data_in[numchannels],
			
			input control_in_clk[numchannels],
			input control_in_enable[numchannels],
			input [control_chars_width-1:0] control_in[numchannels],			
			
			//system clk
			input  fsm_clk,
			input  data_output_clk,
			output [9:0] tbi_encoder[numchannels],
			
			input  UART_REGFILE_CLK,
			input  RESET_FOR_UART_REGFILE_CLK,
			
			output uart_tx,
			input  uart_rx,
			
			input wire       UART_IS_SECONDARY_UART,
			input wire [7:0] UART_NUM_SECONDARY_UARTS,
			input wire [7:0] UART_ADDRESS_OF_THIS_UART,
			output     [7:0] NUM_UARTS_HERE
			
			
			
			
);

assign NUM_UARTS_HERE = 1;

logic full_fifo_xcvr;
logic full_fifo_character_queue[numchannels];

logic busy;
logic enable_data_out;
logic fifo_read_xcvr_sig;
logic fifo_empty_xcvr_sig;
logic is_control_char;
logic actual_is_control_char;
logic fifo_read_character_queue_sig [numchannels];
logic fifo_empty_character_queue_sig[numchannels];
logic is_padding_char               [numchannels];
logic actual_is_padding_char        [numchannels];
logic [15:0] fsm_state;
logic [7:0] from_FSM2_8b10[numchannels];
logic [7:0] actual_uncoded_8b10b_out[numchannels];
logic [out_data_bits_per_channel*numchannels-1:0]  data_fifo_xcvr_sig;
logic [out_data_bits_per_channel-1:0] data_fifo_xcvr_fifo_q[numchannels];
logic [control_chars_width-1:0] data_fifo_character_queue_out[numchannels];	
logic [input_data_bits_per_channel*numchannels-1:0] data_fifo_xcvr_flattened;
logic [channel_select_numbits-1:0] current_channel;
logic data_fifo_aclr;
logic control_fifo_aclr;


logic fifo_status ;
logic [15:0]                                       chosen_fsm_state;
logic [7:0]                                        chosen_from_FSM2_8b10;
logic [7:0]                                        chosen_actual_uncoded_8b10b_out;
logic [out_data_bits_per_channel*numchannels-1:0]  chosen_data_fifo_xcvr_sig;
logic [out_data_bits_per_channel-1:0]              chosen_data_fifo_xcvr_fifo_q;
logic [control_chars_width-1:0]                    chosen_data_fifo_character_queue_out;	
logic rd_full_fifo_xcvr;
logic enable_auto_data_fifo_aclr;
logic [31:0] fifo_xcvr_wrusedw;
logic auto_data_fifo_aclr;


always @(posedge data_output_clk)
begin
      fifo_status <= {
	                  fifo_read_character_queue_sig [current_channel],
                      fifo_empty_character_queue_sig[current_channel] ,
                      is_padding_char               [current_channel] ,
                      actual_is_padding_char        [current_channel]
					 };
    chosen_from_FSM2_8b10                  <=  from_FSM2_8b10               [current_channel];
	chosen_actual_uncoded_8b10b_out        <=  actual_uncoded_8b10b_out     [current_channel];
	chosen_data_fifo_xcvr_fifo_q           <=  data_fifo_xcvr_fifo_q        [current_channel];			
    chosen_data_fifo_character_queue_out   <=  data_fifo_character_queue_out[current_channel];	
end








multi_channel_simple_8b10b_tx
#( 
 .device_family(device_family),
 .numchannels(numchannels),
 .num_data_output_fifo_locations(num_data_output_fifo_locations),
 .input_to_output_bitwidth_ratio(input_to_output_bitwidth_ratio),
 .input_data_bits_per_channel(input_data_bits_per_channel),
 .control_chars_width(control_chars_width),
 .control_char_fifo_depth (control_char_fifo_depth)
) 
multi_channel_simple_8b10b_tx_inst
(
  .wrclk_fifo_xcvr            (data_in_clk                  ),
  .wrreq_fifo_xcvr            (data_in_enable               ),
  .data_fifo_xcvr             (data_in                      ),
  .wrclk_fifo_character_queue (control_in_clk               ),
  .wrreq_fifo_character_queue (control_in_enable            ),
  .data_fifo_character_queue  (control_in                   ),	
  .*
);		

								  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 2;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 6;			
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

	        assign uart_regfile_interface_pins.display_name         = uart_name;
			assign uart_regfile_interface_pins.num_secondary_uarts  = UART_NUM_SECONDARY_UARTS;
			assign uart_regfile_interface_pins.is_secondary_uart    = UART_IS_SECONDARY_UART;
			assign uart_regfile_interface_pins.address_of_this_uart = UART_ADDRESS_OF_THIS_UART;
			assign uart_regfile_interface_pins.rxd = uart_rx;
			assign uart_tx = uart_regfile_interface_pins.txd;
			assign uart_regfile_interface_pins.clk                    = UART_REGFILE_CLK;
			assign uart_regfile_interface_pins.data_clk               = data_output_clk;
			assign uart_regfile_interface_pins.reset                  = 1'b0;
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
				
	assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  DEFAULT_CHANNEL_TO_LOOK_AT;
    assign uart_regfile_interface_pins.control_desc[0]               = "current_channel";
    assign current_channel                      = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = channel_select_numbits;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  0;
    assign uart_regfile_interface_pins.control_desc[1]               = "fifo_aclr";
    assign {enable_auto_data_fifo_aclr,control_fifo_aclr,data_fifo_aclr}                      = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 3;		
	  
	assign uart_regfile_interface_pins.status[0] = {
	                                                auto_data_fifo_aclr,
	                                                rd_full_fifo_xcvr,
													busy,
													enable_data_out,
													fifo_read_xcvr_sig,
													fifo_empty_xcvr_sig,
													is_control_char,
													actual_is_control_char
												   };	
	
	assign uart_regfile_interface_pins.status_desc[0]    ="global_signals";	

	assign uart_regfile_interface_pins.status[1]     = fsm_state;
	assign uart_regfile_interface_pins.status_desc[1]    ="fsm_state";	
	
	assign uart_regfile_interface_pins.status[2]     = {fifo_status,chosen_actual_uncoded_8b10b_out,chosen_from_FSM2_8b10};
	assign uart_regfile_interface_pins.status_desc[2]    ="fifo_status";	
	
	assign uart_regfile_interface_pins.status[3]     = chosen_data_fifo_xcvr_fifo_q;
	assign uart_regfile_interface_pins.status_desc[3]    ="data_fifo_q";	
	
	assign uart_regfile_interface_pins.status[4]     = chosen_data_fifo_character_queue_out;
	assign uart_regfile_interface_pins.status_desc[4]    ="control_fifo_q";	
		
	assign uart_regfile_interface_pins.status[5]     = fifo_xcvr_wrusedw;
	assign uart_regfile_interface_pins.status_desc[5]    ="fifo_data_wrusdw";	

endmodule
`default_nettype wire

