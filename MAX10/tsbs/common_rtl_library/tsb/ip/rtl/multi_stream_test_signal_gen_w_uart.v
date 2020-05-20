
`default_nettype none
`include "interface_defs.v"

import uart_regfile_types::*;

module multi_stream_test_signal_gen_w_uart
#(
parameter  [7:0] ENABLE_CONTROL_WISHBONE_INTERFACE = 1'b0,
parameter  [7:0] ENABLE_STATUS_WISHBONE_INTERFACE  = 1'b0,
parameter [0:0] COMPILE_TEST_SIGNALS = 1,
parameter [0:0] COMPILE_STREAM_SPECIFIC_STATUS_REGS = 1,
parameter [7:0] TEST_SIGNAL_DDS_NUM_PHASE_BITS = 24,
parameter TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD = {5'b0,1'b1,{(TEST_SIGNAL_DDS_NUM_PHASE_BITS-10){1'b0}},1'b1},
parameter bitwidth_ratio = in_data_bits/out_data_bits,
parameter [15:0] in_data_bits   = 16,
parameter [15:0] out_data_bits  = 16,
parameter [15:0] ACTUAL_BITWIDTH_OF_STREAMS = out_data_bits,
parameter ENABLE_KEEPS = 0,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_tstsigs"},
parameter UART_REGFILE_TYPE = uart_regfile_types::MULTI_TEST_SIGNAL_GENERATOR_UART_REGFILE,
parameter [0:0] IGNORE_TIMING_TO_READ_LD = 1'b0,
parameter [0:0] USE_GENERIC_ATTRIBUTE_FOR_READ_LD = 1'b0,
parameter GENERIC_ATTRIBUTE_FOR_READ_LD = "ERROR",
parameter [0:0]  WISHBONE_INTERFACE_IS_PART_OF_BRIDGE = 1'b0,
parameter [31:0] WISHBONE_CONTROL_BASE_ADDRESS        = 0,
parameter [31:0] WISHBONE_STATUS_BASE_ADDRESS         = 0,
parameter [7:0] STATUS_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter [7:0] CONTROL_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter [7:0] NUM_OF_DATA_STREAMS = 2,
parameter [0:0] ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION  = 0,
parameter [0:0] USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter synchronizer_depth = 3,
parameter DEFAULT_CONST_TEST_DATA0 = 16'h1234,
parameter DEFAULT_CONST_TEST_DATA1 = 16'h5678,
parameter [0:0] add_extra_pipelining_for_test_signals = 1'b1,
parameter [0:0] USER_INPUT_INTERFACE_FOR_CLOCK_SOURCE = 1'b0,
parameter [0:0] DEFINE_WISHBONE_INTERFACES_IF_NOT_ENABLED = 1'b1,
parameter add_extra_pipelining_for_test_signal_constants_from_uart = 0
)
(
	input  CLKIN,
	input  RESET_FOR_CLKIN,
	
	
	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output [7:0] NUM_UARTS_HERE,
    wishbone_interface status_wishbone_interface_pins,
    wishbone_interface control_wishbone_interface_pins,
	
    input data_clk,
    multi_data_stream_interface input_streams_interface_pins,
    multi_data_stream_interface output_streams_interface_pins,
	output logic [in_data_bits-1:0]  out_signals[NUM_OF_DATA_STREAMS],
	output logic                     out_signals_valid[NUM_OF_DATA_STREAMS],
	output logic                     out_signals_superframe_start_n[NUM_OF_DATA_STREAMS]
		
);

assign NUM_UARTS_HERE = 1;

logic clk;
generate 
          if (USER_INPUT_INTERFACE_FOR_CLOCK_SOURCE)
		  begin
		  		assign clk = input_streams_interface_pins.clk;
		  end else
		  begin
		        assign clk = data_clk;
		  end
endgenerate

generate
        if (DEFINE_WISHBONE_INTERFACES_IF_NOT_ENABLED)
		begin
		     wishbone_interface #(.num_address_bits(32), .num_data_bits(32)) status_wishbone_interface_pins();
             wishbone_interface #(.num_address_bits(32), .num_data_bits(32)) control_wishbone_interface_pins();
		end
endgenerate

logic reset_test_generator;	
logic reset_test_generator_raw;
	

doublesync_no_reset 
#(
 .synchronizer_depth(synchronizer_depth)
 )
sync_reset_test_generator
(
 .indata(reset_test_generator_raw),
 .outdata(reset_test_generator),
 .clk(clk)
);

	
	
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//     Wire and register definitions
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////

     
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [in_data_bits+1:0]    registered_selected_data[NUM_OF_DATA_STREAMS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [in_data_bits+1:0]    clock_crossed_registered_selected_data[NUM_OF_DATA_STREAMS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic                        output_test_signal_as_unsigned[NUM_OF_DATA_STREAMS];

      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic select_test_dds[NUM_OF_DATA_STREAMS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [2:0] select_test_dds_signal[NUM_OF_DATA_STREAMS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic select_constant_output[NUM_OF_DATA_STREAMS];
	    
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0]	test_dds_phi_inc_i[NUM_OF_DATA_STREAMS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [out_data_bits-1:0]  constant_test_data[NUM_OF_DATA_STREAMS];

	  
		
		multi_stream_test_generator
		#(
		.COMPILE_TEST_SIGNAL_DDS                       (COMPILE_TEST_SIGNALS                   ),
		.TEST_SIGNAL_DDS_NUM_PHASE_BITS                (TEST_SIGNAL_DDS_NUM_PHASE_BITS            ),
		.TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD            (TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD        ),
		.bitwidth_ratio                                (bitwidth_ratio                            ),
		.in_data_bits                                  (in_data_bits                              ),
		.out_data_bits                                 (out_data_bits                             ),
		.ACTUAL_BITWIDTH_OF_STREAMS                    (ACTUAL_BITWIDTH_OF_STREAMS                ),
		.ENABLE_KEEPS                                  (ENABLE_KEEPS                              ),
		.NUM_OF_DATA_STREAMS                           (NUM_OF_DATA_STREAMS                       ),
		.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION      (ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION  ),
		.USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS     (USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS ),
		.synchronizer_depth                            (synchronizer_depth                        ),
		.add_extra_pipelining_for_test_signals         (add_extra_pipelining_for_test_signals     ),
		.NUM_BITS_TEST_SIGNAL_SELECTION                (3)
		)
		multi_stream_test_generator_inst
		(
			.clk,	
			.reset(reset_test_generator),
			.input_streams_interface_pins,
			.select_test_dds,
			//.test_selected_data,
			.select_test_dds_signal,
			.output_test_signal_as_unsigned,
			.test_dds_phi_inc_i,
			.constant_test_data,
			.registered_selected_data
		);
       
assign output_streams_interface_pins.valid = out_signals_valid[0];
assign output_streams_interface_pins.superframe_start_n = out_signals_superframe_start_n[0];
assign output_streams_interface_pins.clk   = clk;

genvar current_data_stream;
generate
			 for (current_data_stream = 0; current_data_stream < NUM_OF_DATA_STREAMS; current_data_stream++)
			  begin : per_stream
						
						assign out_signals[current_data_stream]  = registered_selected_data[current_data_stream][in_data_bits-1:0];
						assign out_signals_valid[current_data_stream]  = registered_selected_data[current_data_stream][in_data_bits];
						assign out_signals_superframe_start_n[current_data_stream]  = registered_selected_data[current_data_stream][in_data_bits+1];
						
						assign output_streams_interface_pins.data[current_data_stream] = out_signals[current_data_stream];
					    assign output_streams_interface_pins.desc[current_data_stream] = input_streams_interface_pins.desc[current_data_stream];
					
						my_multibit_clock_crosser_optimized_for_altera
						#(
						  .DATA_WIDTH(in_data_bits+2),
						  .FORWARD_SYNC_DEPTH(synchronizer_depth),
						  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
						)
						mcp_registered_selected_data
						(
						   .in_clk(clk),
						   .in_valid(1'b1),
						   .in_data(registered_selected_data[current_data_stream]),
						   .out_clk(CLKIN),
						   .out_valid(),
						   .out_data(clock_crossed_registered_selected_data[current_data_stream])
						 );	 					
								
				end
endgenerate
	 
											  
										  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	        
			`define num_stream_specific_control_regs    (3)
			`define num_stream_specific_status_regs     (1)
			`define first_stream_specific_control_reg   (2)
			`define first_stream_specific_status_reg    (5)
			localparam ZERO_IN_ASCII = 48;
			
	        `define current_ctrl_reg_num(x,y) ((((x)*`num_stream_specific_control_regs+`first_stream_specific_control_reg))+(y))
			`define current_status_reg_num(x,y) (((x)*`num_stream_specific_status_regs+`first_stream_specific_status_reg) + (y))
					
					
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = COMPILE_TEST_SIGNALS ? `current_ctrl_reg_num(NUM_OF_DATA_STREAMS-1,`num_stream_specific_control_regs-1) + 1 : `first_stream_specific_control_reg + 1;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = COMPILE_STREAM_SPECIFIC_STATUS_REGS ?  `current_status_reg_num( NUM_OF_DATA_STREAMS-1, `num_stream_specific_status_regs - 1) + 1 : `first_stream_specific_status_reg;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = ENABLE_CONTROL_WISHBONE_INTERFACE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = ENABLE_STATUS_WISHBONE_INTERFACE ;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 1;
			
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
			assign uart_regfile_interface_pins.clk       = CLKIN;
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
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS),
			 .USE_GENERIC_ATTRIBUTE_FOR_READ_LD            (USE_GENERIC_ATTRIBUTE_FOR_READ_LD),
             .GENERIC_ATTRIBUTE_FOR_READ_LD                (GENERIC_ATTRIBUTE_FOR_READ_LD),
			 .STATUS_WISHBONE_NUM_ADDRESS_BITS             (STATUS_WISHBONE_NUM_ADDRESS_BITS),
             .CONTROL_WISHBONE_NUM_ADDRESS_BITS            (CONTROL_WISHBONE_NUM_ADDRESS_BITS),
			 .WISHBONE_INTERFACE_IS_PART_OF_BRIDGE         (WISHBONE_INTERFACE_IS_PART_OF_BRIDGE ),
             .WISHBONE_CONTROL_BASE_ADDRESS        	       (WISHBONE_CONTROL_BASE_ADDRESS        ),	 
             .WISHBONE_STATUS_BASE_ADDRESS         	       (WISHBONE_STATUS_BASE_ADDRESS         )	 
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
				assign uart_regfile_interface_pins.control_desc[0]               = "global_ctrl";
				assign {reset_test_generator_raw}  = uart_regfile_interface_pins.control[0];
				assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 16;	
					
						
						
				generate
						if (COMPILE_TEST_SIGNALS)
						begin
								for (current_data_stream = 0; current_data_stream < NUM_OF_DATA_STREAMS; current_data_stream++)
								begin : make_test_control_registers
										wire [7:0] char1 = ((current_data_stream/10)+ZERO_IN_ASCII);
										wire [7:0] char2 = ((current_data_stream % 10)+ZERO_IN_ASCII);
										assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_data_stream,0)]  =  TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD;
										assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_data_stream,0)]               = {"test_dds_phi_",char1,char2};
										if (add_extra_pipelining_for_test_signal_constants_from_uart)
										begin
										      always_ff @(posedge clk)
											  begin
										            test_dds_phi_inc_i[current_data_stream] <= uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_data_stream,0)];
											  end
										end else
										begin
										       assign test_dds_phi_inc_i[current_data_stream] = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_data_stream,0)];
										end
										assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_data_stream,0)]      = TEST_SIGNAL_DDS_NUM_PHASE_BITS;		
										
										 assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_data_stream,1)]  =  0;
										assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_data_stream,1)]               = {"testsignalctl_",char1,char2};
										assign {output_test_signal_as_unsigned[current_data_stream],select_test_dds_signal[current_data_stream][2:0],  select_test_dds[current_data_stream]}  = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_data_stream,1)];
										assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_data_stream,1)]      = 5;				
										
										assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_data_stream,2)]  =  DEFAULT_CONST_TEST_DATA0;
										assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_data_stream,2)]               = {"ConstTestData",char1,char2};
										if (add_extra_pipelining_for_test_signal_constants_from_uart)
										begin
										      always_ff @(posedge clk)
											  begin
											       constant_test_data[current_data_stream] <= uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_data_stream,2)];
											  end
										end else
										begin
										       assign constant_test_data[current_data_stream] = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_data_stream,2)];
										end
										assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_data_stream,2)]      = out_data_bits;	
								end
						end
				endgenerate
	
	
    assign uart_regfile_interface_pins.status[0] = {in_data_bits};
	assign uart_regfile_interface_pins.status_desc[0]    ="in_data_bits";
	
    assign uart_regfile_interface_pins.status[1] = {out_data_bits};
	assign uart_regfile_interface_pins.status_desc[1]    ="out_data_bits";
	
    assign uart_regfile_interface_pins.status[2] = {ACTUAL_BITWIDTH_OF_STREAMS};
	assign uart_regfile_interface_pins.status_desc[2]    ="actual_bitwidth_of_streams";
	 
    assign uart_regfile_interface_pins.status[3] = {
		                                         /*10 */     USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS,
	                                             /* 9 */    COMPILE_TEST_SIGNALS,
	                                             /* 8 */    ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION,
	                                            /* 7:0 */    TEST_SIGNAL_DDS_NUM_PHASE_BITS
												};
    assign uart_regfile_interface_pins.status_desc[3]    ="TestDDSParams";

	assign uart_regfile_interface_pins.status[4] =	 NUM_OF_DATA_STREAMS;
	assign uart_regfile_interface_pins.status_desc[4]    ="NUM_DATA_STREAMS";
				    
		
	generate
					if (COMPILE_STREAM_SPECIFIC_STATUS_REGS)
					begin
							for (current_data_stream = 0; current_data_stream < NUM_OF_DATA_STREAMS; current_data_stream++)
							begin : make_test_status_registers
									wire [7:0] char1 = ((current_data_stream/10)+ZERO_IN_ASCII);
									wire [7:0] char2 = ((current_data_stream % 10)+ZERO_IN_ASCII);
									assign uart_regfile_interface_pins.status[`current_status_reg_num(current_data_stream,0)] =	clock_crossed_registered_selected_data[current_data_stream];
									assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_data_stream,0)] = {"valid_and_data",char1,char2};
							end
					end
	endgenerate
	
 endmodule
 `default_nettype wire
 