
`default_nettype none
`include "interface_defs.v"
`include "global_project_defines.v"
`include "utility_defines.v"

import uart_regfile_types::*;

module multi_spi_slave_w_uart
#(
parameter NUM_STREAMS                                     ,
parameter PARALLEL_OUTPUT_DATA_WIDTH = 32,
parameter CLOG2_PARALLEL_OUTPUT_DATA_WIDTH_PLUS_1=$clog2(PARALLEL_OUTPUT_DATA_WIDTH)+1,
parameter [0:0] COMPILE_TEST_SIGNALS = 0,
parameter [0:0] COMPILE_STREAM_SPECIFIC_STATUS_REGS = 1,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter transaction_counter_width = 32,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_spirecv"},
parameter UART_REGFILE_TYPE = uart_regfile_types::EMBED_2_BIT_SERIAL_DATA_UART_REGFILE,
parameter synchronizer_depth = 3,
parameter [NUM_STREAMS-1:0] DEFAULT_SELECT_TEST_DATA = 0,
parameter DEFAULT_SELECT_RAMP_TEST = 0
)
(

    multi_spi_interface multi_spi_interface_pins,
    output logic [PARALLEL_OUTPUT_DATA_WIDTH-1:0] parallel_data[NUM_STREAMS],
	output logic [CLOG2_PARALLEL_OUTPUT_DATA_WIDTH_PLUS_1-1:0] num_bits_received[NUM_STREAMS],
    output logic [transaction_counter_width-1:0] num_transactions_recorded[NUM_STREAMS],
	input outdata_clk,
 
    input  UART_REGFILE_CLK,
	input  RESET_FOR_UART_REGFILE_CLK,
    input spi_sm_clk,
	input fast_spi_master_2x_clk,

	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output logic    [7:0] NUM_UARTS_HERE
	
);
    
	
logic [PARALLEL_OUTPUT_DATA_WIDTH-1:0] parallel_data_test[NUM_STREAMS];
logic [PARALLEL_OUTPUT_DATA_WIDTH-1:0] parallel_data_test_raw[NUM_STREAMS];
logic [PARALLEL_OUTPUT_DATA_WIDTH-1:0] actual_parallel_data[NUM_STREAMS];
logic [PARALLEL_OUTPUT_DATA_WIDTH-1:0] parallel_data_raw[NUM_STREAMS];
logic [PARALLEL_OUTPUT_DATA_WIDTH-1:0] parallel_counter_test_data[NUM_STREAMS];
logic [PARALLEL_OUTPUT_DATA_WIDTH-1:0] parallel_test_data_to_spi_master[NUM_STREAMS];
logic start_spi_seq_test_master;

logic [NUM_STREAMS-1:0] select_test_data     ;
logic [NUM_STREAMS-1:0] select_test_data_raw ;
logic [15:0] test_spi_master_state;
logic [NUM_STREAMS-1:0] test_master_spi_clk;
logic [NUM_STREAMS-1:0] test_master_spi_csn;
logic [NUM_STREAMS-1:0] test_master_spi_mosi;
logic  slow_test_master_spi_clk;
logic  slow_test_master_spi_csn;
logic [NUM_STREAMS-1:0] slow_test_master_spi_mosi;
logic [NUM_STREAMS-1:0] fast_test_master_spi_clk;
logic [NUM_STREAMS-1:0] fast_test_master_spi_csn;
logic [NUM_STREAMS-1:0] fast_test_master_spi_mosi;
logic [NUM_STREAMS-1:0] fast_test_master_spi_clk_raw;
logic [NUM_STREAMS-1:0] fast_test_master_spi_csn_raw;
logic [NUM_STREAMS-1:0] fast_test_master_spi_mosi_raw;
logic [NUM_STREAMS-1:0] di_req_o;
logic [NUM_STREAMS-1:0] start_fast_spi_seq_test_master;
logic [NUM_STREAMS-1:0] is_available;
logic [NUM_STREAMS-1:0] choose_ramp_test_sigmal;
logic [NUM_STREAMS-1:0] sel_spi_master_input;
logic [NUM_STREAMS-1:0] select_fast_spi_master_test;
assign NUM_UARTS_HERE = 1;

logic [PARALLEL_OUTPUT_DATA_WIDTH-1:0] parallel_data_on_spi_sm_clk[NUM_STREAMS];
logic valid_on_spi_sm_clk[NUM_STREAMS];
logic [PARALLEL_OUTPUT_DATA_WIDTH-1:0] parallel_data_to_status[NUM_STREAMS];
logic parallel_data_to_status_valid[NUM_STREAMS];


genvar current_stream;
generate
			for (current_stream = 0; current_stream < NUM_STREAMS; current_stream++)
			begin : spi_slave_instances
					dummy_spi_slave_tester #(
						  .N_BITS(PARALLEL_OUTPUT_DATA_WIDTH)
					)
					dummy_spi_slave_tester_inst
					(
							/* input                      */ .clkin(spi_sm_clk),   // clock input
							/* input                      */ .rst_n(1'b1),    // reset_in N
							/* input  	                  */ .cs(sel_spi_master_input ? test_master_spi_csn[current_stream] : multi_spi_interface_pins.cs[current_stream]),       // spi cs
							/* input                      */ .sclk(sel_spi_master_input ? test_master_spi_clk[current_stream] :  multi_spi_interface_pins.sclk[current_stream]),    // spi clock input
							/* input                      */ .mosi(sel_spi_master_input ? test_master_spi_mosi[current_stream] : multi_spi_interface_pins.mosi[current_stream]),    // spi slave input
							/* output reg [N_BITS-1:0]    */ .data(parallel_data_on_spi_sm_clk[current_stream]),     //data output 
							/* output reg [5:0]           */ .n_bits_data(num_bits_received[current_stream]),      //N bits received in transaction 
							/* output logic               */ .valid(valid_on_spi_sm_clk[current_stream]),      //valid data output
							/* input 	                  */ .cpol(multi_spi_interface_pins.cpol[current_stream]),//this should be set to 0
							/* input 	                  */ .cpha(multi_spi_interface_pins.cpha[current_stream]),
							                                 .state(),
							/* output                     */ .finish()
					);
					
					always_ff @(posedge UART_REGFILE_CLK)
					begin
					         parallel_counter_test_data[current_stream] <= parallel_counter_test_data[current_stream] + 1;
                    end
			
					assign parallel_test_data_to_spi_master[current_stream] = choose_ramp_test_sigmal[current_stream] ? parallel_counter_test_data[current_stream] : parallel_data_test_raw[current_stream];
					
					my_multibit_clock_crosser_optimized_for_altera
					#(
					  .DATA_WIDTH(PARALLEL_OUTPUT_DATA_WIDTH) 
					)
					sync_parallel_data_to_outdata_clk
					(
					   .in_clk(spi_sm_clk),
					   .in_valid(valid_on_spi_sm_clk[current_stream]),
					   .in_data(parallel_data_on_spi_sm_clk[current_stream]),
					   .out_clk(outdata_clk),
					   .out_valid(),
					   .out_data(parallel_data_raw[current_stream])
					 );
				
   				    my_multibit_clock_crosser_optimized_for_altera
					#(
					  .DATA_WIDTH(PARALLEL_OUTPUT_DATA_WIDTH) 
					)
					sync_parallel_data_to_uart_regfile_clk
					(
					   .in_clk(spi_sm_clk),
					   .in_valid(valid_on_spi_sm_clk[current_stream]),
					   .in_data(parallel_data_on_spi_sm_clk[current_stream]),
					   .out_clk(UART_REGFILE_CLK),
					   .out_valid(parallel_data_to_status_valid[current_stream]),
					   .out_data(parallel_data_to_status[current_stream])
					 );
					 
					 always_ff @(posedge UART_REGFILE_CLK)
					 begin
					      if (parallel_data_to_status_valid[current_stream])
						  begin
					           num_transactions_recorded[current_stream] <= num_transactions_recorded[current_stream] + 1;
					      end					 
					 end
					
			end
endgenerate



generate
    if (COMPILE_TEST_SIGNALS)
	begin
					for (current_stream = 0; current_stream < NUM_STREAMS; current_stream++)
							begin : spi_fast_master_instance

										
										fast_spi_master
										#(
										.SPI_2X_CLK_DIV(1)
										)
										fast_spi_master_inst
										(
											.sclk_i(fast_spi_master_2x_clk) ,	// input  sclk_i_sig
											.pclk_i(UART_REGFILE_CLK) ,	// input  pclk_i_sig
											.rst_i(1'b0) ,	// input  rst_i_sig
											.spi_ssel_o(fast_test_master_spi_csn_raw[current_stream] ) ,	// output  spi_ssel_o_sig
											.spi_sck_o (fast_test_master_spi_clk_raw[current_stream] ) ,	// output  spi_sck_o_sig
											.spi_mosi_o(fast_test_master_spi_mosi_raw[current_stream]) ,	// output  spi_mosi_o_sig
											.spi_miso_i(1'b0) ,	// input  spi_miso_i_sig
											.di_i(parallel_test_data_to_spi_master[current_stream]) ,	// input [n-1:0] di_i_sig
											.di_req_o(di_req_o[current_stream]) ,	// input [n-1:0] di_i_sig
											.is_available(is_available[current_stream]),
											.wren_i(start_fast_spi_seq_test_master[current_stream]) ,	// input  wren_i_sig
											.wr_ack_o() 	// output  wr_ack_o_sig
										);		

										always_ff @(posedge fast_spi_master_2x_clk)
										begin //outputs of fast_spi_master module are glitchy, fix it
										       fast_test_master_spi_csn[current_stream]   <=  fast_test_master_spi_csn_raw[current_stream]   ;
										       fast_test_master_spi_clk[current_stream]   <=  fast_test_master_spi_clk_raw[current_stream]   ;
										       fast_test_master_spi_mosi[current_stream]  <=  fast_test_master_spi_mosi_raw[current_stream]  ;
										end
																			
										 async_trap_and_reset_gen_1_pulse_robust 
										 #(.synchronizer_depth(synchronizer_depth))
										 async_trap_generate_wren_strobe
										 (
										 .async_sig(start_spi_seq_test_master & (di_req_o[current_stream] | is_available[current_stream])), 
										 .outclk(UART_REGFILE_CLK), 
										 .out_sync_sig(start_fast_spi_seq_test_master[current_stream]), 
										 .auto_reset(1'b1), 
										 .reset(1'b1)
										 );
												
					
					
					
                                        always_comb
										begin
										      if (select_fast_spi_master_test[current_stream])
											  begin
											        test_master_spi_csn[current_stream]  = fast_test_master_spi_csn[current_stream] ;
													test_master_spi_clk[current_stream]  = fast_test_master_spi_clk[current_stream] ;
													test_master_spi_mosi[current_stream] = fast_test_master_spi_mosi[current_stream];													
											  end else
											  begin
											        test_master_spi_csn[current_stream]  = slow_test_master_spi_csn ;
												    test_master_spi_clk[current_stream]  = slow_test_master_spi_clk ;
												    test_master_spi_mosi[current_stream] = slow_test_master_spi_mosi[current_stream];												
											  end
										end										
	                       end
	
	
                         write_bit_seq_to_spi
                         #(
                           .num_adcs(NUM_STREAMS),
                           .numbits_spi(PARALLEL_OUTPUT_DATA_WIDTH),
                           .numbits_counter(8),
                           .shift_out_msb_first(1),
                           .return_read_data(0)
                         )
						 spi_seq_test_master
                         (
                        /* input  logic */               .start(start_spi_seq_test_master),
                        /* input  logic */               .enable(1'b1),
                        /* input  logic */               .reset(1'b0),
                        /* input  logic */               .clk   (UART_REGFILE_CLK),
                        /* output logic */               .finish(),
                                                         .write_data(parallel_test_data_to_spi_master),
                                                         .read_data(),
                       /* output reg [15:0]           */ .state(test_spi_master_state),
                       /* output logic                */ .spi_clk(slow_test_master_spi_clk),
                       /* output logic                */ .spi_csn(slow_test_master_spi_csn),
                       /* input  logic [num_adcs-1:0] */ .spi_miso(),
                       /* output  logic [num_adcs-1:0]*/ .spi_mosi(slow_test_master_spi_mosi)
                         
                         );
						 
    end
endgenerate
				  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			        
			`define num_stream_specific_control_regs    (1)
			`define num_stream_specific_status_regs     (3)
			`define first_stream_specific_control_reg   (5)
			`define first_stream_specific_status_reg    (2)
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

	assign uart_regfile_interface_pins.control_regs_default_vals[0]  = DEFAULT_SELECT_TEST_DATA;
    assign uart_regfile_interface_pins.control_desc[0]               = "sel_test_data";
	assign select_test_data_raw  	                                 = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = NUM_STREAMS;		

	assign uart_regfile_interface_pins.control_regs_default_vals[1]  = 0;
    assign uart_regfile_interface_pins.control_desc[1]               = "start_spi_master";
	assign start_spi_seq_test_master  	                             = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 1;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  = DEFAULT_SELECT_RAMP_TEST;
    assign uart_regfile_interface_pins.control_desc[2]               = "sel_ramp_test";
	assign choose_ramp_test_sigmal  	                             = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = NUM_STREAMS;		
	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[3]  = 0;
    assign uart_regfile_interface_pins.control_desc[3]               = "sel_spi_mastr_in";
	assign sel_spi_master_input  	                                  = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = NUM_STREAMS;		
		
	assign uart_regfile_interface_pins.control_regs_default_vals[4]  = 0;
    assign uart_regfile_interface_pins.control_desc[4]               = "sel_fast_spi_mst";
	assign select_fast_spi_master_test  	                         = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = NUM_STREAMS;		
	
	genvar current_data_stream;

		generate
	        if (COMPILE_TEST_SIGNALS)
			begin
					for (current_data_stream = 0; current_data_stream < NUM_STREAMS; current_data_stream++)
					begin : make_per_stream_control_regs
							wire [7:0] stream_char1 = ((current_data_stream/10)+ZERO_IN_ASCII);
							wire [7:0] stream_char2 = ((current_data_stream % 10)+ZERO_IN_ASCII);
							wire [7:0] current_stream_num = current_data_stream;
						
							wire [39:0] index_string = {stream_char1,stream_char2};
							assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_data_stream,0)]  = current_stream_num;
							assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_data_stream,0)]               = {"test_data_",index_string};
							assign parallel_data_test_raw[current_data_stream]                                                          = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_data_stream,0)];
							assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_data_stream,0)]      = `MIN(PARALLEL_OUTPUT_DATA_WIDTH,STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES*8);																				
					
					
							my_multibit_clock_crosser_optimized_for_altera
							#(
							  .DATA_WIDTH(PARALLEL_OUTPUT_DATA_WIDTH) 
							)
							mcp_parallel_data_test
							(
							   .in_clk(UART_REGFILE_CLK),
							   .in_valid(1'b1),
							   .in_data(parallel_data_test_raw[current_data_stream]),
							   .out_clk(outdata_clk),
							   .out_valid(),
							   .out_data(parallel_data_test[current_data_stream])
							 );	

			 
							always_comb
							begin
								   if (select_test_data[current_data_stream])
								   begin
								        parallel_data[current_data_stream] =  parallel_data_test[current_data_stream];
								   end else
								   begin
								        parallel_data[current_data_stream] =  parallel_data_raw[current_data_stream];								   
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
				     .out_clk(outdata_clk),
				     .out_valid(),
				     .out_data(select_test_data)
				);					
				
					
			end else
			begin
			        assign parallel_data = parallel_data_raw;
			
			end
	endgenerate
	
	
	
	
	assign uart_regfile_interface_pins.status[0] =	test_spi_master_state;
	assign uart_regfile_interface_pins.status_desc[0] =  "spi_master_state";
	
	assign uart_regfile_interface_pins.status[1] =	{test_master_spi_mosi,2'b0,test_master_spi_clk,test_master_spi_csn};
	assign uart_regfile_interface_pins.status_desc[1] =  "spi_master_sigs";
	
	
	generate
					if (COMPILE_STREAM_SPECIFIC_STATUS_REGS)
					begin
							for (current_data_stream = 0; current_data_stream < NUM_STREAMS; current_data_stream++)
							begin : make_test_status_registers
									wire [7:0] char1 = ((current_data_stream/10)+ZERO_IN_ASCII);
									wire [7:0] char2 = ((current_data_stream % 10)+ZERO_IN_ASCII);
									assign uart_regfile_interface_pins.status[`current_status_reg_num(current_data_stream,0)] =	parallel_data_to_status[current_data_stream];
									assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_data_stream,0)] =  {"parallel_data",char1,char2};
									
									assign uart_regfile_interface_pins.status[`current_status_reg_num(current_data_stream,1)] =	num_bits_received[current_data_stream];
									assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_data_stream,1)] =  {"num_bits_recv",char1,char2};

									assign uart_regfile_interface_pins.status[`current_status_reg_num(current_data_stream,2)] =	num_transactions_recorded[current_data_stream];
									assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_data_stream,2)] =  {"num_transact",char1,char2};
							end
					end
	endgenerate

	
 endmodule

`default_nettype wire
