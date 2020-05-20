
`default_nettype none
`include "interface_defs.v"
`include "global_project_defines.v"
`include "embedded_2_bit_serial_data_interface.v"
`include "utility_defines.v"

import uart_regfile_types::*;

module add_emb_data_to_avst_w_uart
#(
parameter NUM_STREAMS                                     ,
parameter JESD_S                                          = 0,
parameter JESD_M                                          = 0,
parameter N                                          ,
parameter N_PRIME                                    ,
parameter JESD_TL_DATA_BUS_WIDTH                          = 0,
parameter NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK           ,
parameter JESD_NUM_LINKS                                  = 0,
parameter EMBEDDED_SERIAL_DATA_PARALLEL_INPUT_WIDTH,
parameter SUPPORT_PACKETS,
parameter [0:0] USE_ADD_GENERIC_EMBEDDED_DATA_TO_AVST = 1'b0,
parameter [0:0] COMPILE_TEST_SIGNALS = 0,
parameter [0:0] COMPILE_STREAM_SPECIFIC_STATUS_REGS = 1,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [7:0] word_counter_width = 32,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_embsdat"},
parameter UART_REGFILE_TYPE = uart_regfile_types::EMBED_2_BIT_SERIAL_DATA_UART_REGFILE,
parameter synchronizer_depth = 3,
parameter [0:0] DO_SERIAL_EMBEDDING_DEFAULT = 1'b0,
parameter [0:0] DO_SERIAL_EMBEDDING_VIA_MSB_DEFAULT = 1'b0,
parameter [0:0] EMBED_SERIAL_DATA_IN_MSB_FIRST_ORDER_DEFAULT = 1'b0,
parameter [NUM_STREAMS-1:0] DEFAULT_SELECT_TEST_DATA = 0,
parameter EMBED_DUMMY_ZEROES_ONLY = 0
)
(
    input [EMBEDDED_SERIAL_DATA_PARALLEL_INPUT_WIDTH-1:0] parallel_data[NUM_STREAMS],
	input parallel_data_clk,
    interface avst_in_streams_interface_pins,
    interface avst_out_streams_interface_pins,

    input  UART_REGFILE_CLK,
	input  RESET_FOR_UART_REGFILE_CLK,


	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output logic    [7:0] NUM_UARTS_HERE
	
);
    
	
logic [EMBEDDED_SERIAL_DATA_PARALLEL_INPUT_WIDTH-1:0] parallel_data_test[NUM_STREAMS];
logic [EMBEDDED_SERIAL_DATA_PARALLEL_INPUT_WIDTH-1:0] parallel_data_test_raw[NUM_STREAMS];
logic [EMBEDDED_SERIAL_DATA_PARALLEL_INPUT_WIDTH-1:0] actual_parallel_data[NUM_STREAMS];
logic [EMBEDDED_SERIAL_DATA_PARALLEL_INPUT_WIDTH-1:0] clock_crossed_actual_parallel_data[NUM_STREAMS];

logic do_serial_embedding;
logic embed_input_as_msb;
logic do_serial_embedding_raw;
logic embed_input_as_msb_raw ;
logic embed_serial_data_msb_first ;
logic embed_serial_data_msb_first_raw ;
logic [NUM_STREAMS-1:0] select_test_data     ;
logic [NUM_STREAMS-1:0] select_test_data_raw ;

logic data_clk;

assign data_clk = avst_in_streams_interface_pins.clk;

assign NUM_UARTS_HERE = 1;

embedded_2_bit_serial_data_interface 
#(
.num_data_streams(NUM_STREAMS),
.num_parallel_2_bit_chunks(NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK)
)
embedded_2_bit_serial_data_interface_pins();

genvar current_data_stream;
generate
      
					for (current_data_stream = 0; current_data_stream < NUM_STREAMS; current_data_stream++)
				 begin : clock_cross_parallel_data_to_data_clk
						    if (EMBED_DUMMY_ZEROES_ONLY)
							 begin
						          assign clock_crossed_actual_parallel_data[current_data_stream] = 0;
							 end else
							 begin
												my_multibit_clock_crosser_optimized_for_altera
												#(
												  .DATA_WIDTH(EMBEDDED_SERIAL_DATA_PARALLEL_INPUT_WIDTH) 
												)
												mcp_parallel_data_to_data_clk
												(
													.in_clk(parallel_data_clk),
													.in_valid(1'b1),
													.in_data(actual_parallel_data[current_data_stream]),
													.out_clk(data_clk),
													.out_valid(),
													.out_data(clock_crossed_actual_parallel_data[current_data_stream])
												 );	
									 end
				 end
		 
endgenerate
logic clock_enable_multi_embed_2_bit_stream_parallel;

generate
		if (SUPPORT_PACKETS)
		begin
				assign clock_enable_multi_embed_2_bit_stream_parallel = avst_in_streams_interface_pins.ready & avst_in_streams_interface_pins.valid;
		end
		else
		begin
				assign clock_enable_multi_embed_2_bit_stream_parallel = 1;
		end
endgenerate


		
multi_embed_2_bit_stream_parallel
#(
.num_data_streams(NUM_STREAMS),
.parallel_data_width (EMBEDDED_SERIAL_DATA_PARALLEL_INPUT_WIDTH),
.num_parallel_2_bit_chunks(NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK)
)
multi_embed_2_bit_stream_parallel_inst
(
.parallel_data(clock_crossed_actual_parallel_data),
.clk(data_clk),
.embedded_2_bit_serial_data_interface_pins,
.clock_enable(clock_enable_multi_embed_2_bit_stream_parallel),
.MSB_first(embed_serial_data_msb_first)
);

add_generic_embedded_data_to_avst
#(
.NUM_STREAMS                          (NUM_STREAMS                          ),
.N                                    (N                                    ),
.N_PRIME                              (N_PRIME                              ),
.NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK(NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK),
.SUPPORT_PACKETS(SUPPORT_PACKETS)					
)
add_embedded_data_to_avst_inst
(
.avst_in_streams_interface_pins,
.embedded_2_bit_serial_data_interface_pins,
.avst_out_streams_interface_pins,
.do_serial_embedding,
.embed_input_as_msb
);
		

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_do_serial_embedding_to_data_clk
(
.indata(do_serial_embedding_raw),
.outdata(do_serial_embedding),
.clk(data_clk)
);		
					
doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_embed_input_as_msb_to_data_clk
(
.indata(embed_input_as_msb_raw),
.outdata(embed_input_as_msb),
.clk(data_clk)
);		
					
					
doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_embed_serial_data_msb_first_to_data_clk
(
.indata(embed_serial_data_msb_first_raw),
.outdata(embed_serial_data_msb_first),
.clk(data_clk)
);		
										  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			        
			`define num_stream_specific_control_regs    (1)
			`define num_stream_specific_status_regs     (1)
			`define first_stream_specific_control_reg   (2)
			`define first_stream_specific_status_reg    (0)
			localparam ZERO_IN_ASCII = 48;
			
	        `define current_ctrl_reg_num(x,y) ((((x)*`num_stream_specific_control_regs+`first_stream_specific_control_reg))+(y))
		 	`define current_status_reg_num(x,y) (((x)*`num_stream_specific_status_regs+`first_stream_specific_status_reg) + (y))
					
					

		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = COMPILE_TEST_SIGNALS ? `current_ctrl_reg_num(NUM_STREAMS-1,`num_stream_specific_control_regs-1) + 1 : `first_stream_specific_control_reg;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = COMPILE_STREAM_SPECIFIC_STATUS_REGS ?  `current_status_reg_num( NUM_STREAMS-1, `num_stream_specific_status_regs - 1) + 1 : `first_stream_specific_status_reg;					
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
			
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  {EMBED_SERIAL_DATA_IN_MSB_FIRST_ORDER_DEFAULT,DO_SERIAL_EMBEDDING_VIA_MSB_DEFAULT,DO_SERIAL_EMBEDDING_DEFAULT};
    assign uart_regfile_interface_pins.control_desc[0]               = "embed_ctrl";
	assign {embed_serial_data_msb_first_raw,embed_input_as_msb_raw,do_serial_embedding_raw}  	= uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 3;	
	
    assign uart_regfile_interface_pins.control_regs_default_vals[1]  = DEFAULT_SELECT_TEST_DATA;
    assign uart_regfile_interface_pins.control_desc[1]               = "sel_test_data";
	assign select_test_data_raw  	                                 = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = NUM_STREAMS;		


		generate
	        if (COMPILE_TEST_SIGNALS)
			begin
					for (current_data_stream = 0; current_data_stream < NUM_STREAMS; current_data_stream++)
					begin : make_per_stream_control_regs
							wire [7:0] stream_char1 = ((current_data_stream/10)+ZERO_IN_ASCII);
							wire [7:0] stream_char2 = ((current_data_stream % 10)+ZERO_IN_ASCII);
							wire [7:0] current_stream_num = current_data_stream;
						
							wire [15:0] index_string = {stream_char1,stream_char2};
							assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_data_stream,0)]  = current_stream_num;
							assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_data_stream,0)]               = {"test_data_",index_string};
							assign parallel_data_test_raw[current_data_stream]                                                          = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_data_stream,0)];
							assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_data_stream,0)]      = `MIN(EMBEDDED_SERIAL_DATA_PARALLEL_INPUT_WIDTH,STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES*8);																				
					
					
							my_multibit_clock_crosser_optimized_for_altera
							#(
							  .DATA_WIDTH(EMBEDDED_SERIAL_DATA_PARALLEL_INPUT_WIDTH) 
							)
							mcp_parallel_data_test
							(
							   .in_clk(UART_REGFILE_CLK),
							   .in_valid(1'b1),
							   .in_data(parallel_data_test_raw[current_data_stream]),
							   .out_clk(parallel_data_clk),
							   .out_valid(),
							   .out_data(parallel_data_test[current_data_stream])
							 );	

			 
							always_ff @(posedge parallel_data_clk)
							begin
								   if (select_test_data[current_data_stream])
								   begin
								        actual_parallel_data[current_data_stream] <=  parallel_data_test[current_data_stream];
								   end else
								   begin
								        actual_parallel_data[current_data_stream] <=  parallel_data[current_data_stream];								   
								   end					
							end												
					end
					
					my_multibit_clock_crosser_optimized_for_altera
				    #(
				      .DATA_WIDTH(NUM_STREAMS) 
				    )
				    mcp_select_test_data
				    (
				       .in_clk(UART_REGFILE_CLK),
				       .in_valid(1'b1),
				       .in_data(select_test_data_raw),
				       .out_clk(parallel_data_clk),
				       .out_valid(),
				       .out_data(select_test_data)
				     );					
				
					
			end else
			begin
			        assign actual_parallel_data = parallel_data;
			
			end
	endgenerate
	
	
	generate
					if (COMPILE_STREAM_SPECIFIC_STATUS_REGS)
					begin
							for (current_data_stream = 0; current_data_stream < NUM_STREAMS; current_data_stream++)
							begin : make_test_status_registers
									wire [7:0] char1 = ((current_data_stream/10)+ZERO_IN_ASCII);
									wire [7:0] char2 = ((current_data_stream % 10)+ZERO_IN_ASCII);
									assign uart_regfile_interface_pins.status[`current_status_reg_num(current_data_stream,0)] =	actual_parallel_data[current_data_stream];
									assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_data_stream,0)] =  {"ser_data_",char1,char2};
							end
					end
	endgenerate

	
 endmodule

`default_nettype wire
