`default_nettype none
`include "interface_defs.v"
//`include "keep_defines.v"
import uart_regfile_types::*;
	  
module multi_channel_2x_generic_parallelizer_w_uart_support
#(
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"Parall2x"},
parameter UART_REGFILE_TYPE = uart_regfile_types::GENERIC_PARELLELIZER_2X_REGFILE,
parameter [7:0] NUMBITS_DATAIN_FULL_WIDTH = 14,
parameter [7:0] NUM_DATA_CHANNELS = 2,
parameter [0:0] GENERATE_FRAME_CLOCK_ON_NEGEDGE = 1 ,
parameter [7:0] CHANNEL_TO_LOOK_AT_FOR_DEBUGGING = 0,
parameter DEFAULT_TRANSPOSE_CTRL = 0,
parameter DEFAULT_SIMULATED_FULL_FRAME_DATA = 14'h2FC0,
parameter DEFAULT_SIMULATED_HALF_FRAME_DATA = 7'h30,
parameter [0:0] GENERATE_DDS_TEST_SIGNALS = 1,
parameter [0:0] ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION  = 0,
parameter [0:0] USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter [7:0] TEST_SIGNAL_DDS_NUM_PHASE_BITS = 24,
parameter TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD = {5'b0,1'b1,{(TEST_SIGNAL_DDS_NUM_PHASE_BITS-10){1'b0}},1'b1},
parameter [7:0] ACTIVITY_MONITOR_NUMBITS = 32,
parameter [0:0] ALLOW_LOOK_AT_ALL_CHANNELS = 0,
parameter synchronizer_depth = 3
)
(
	input  UART_REGFILE_CLK,
	input  RESET_FOR_UART_REGFILE_CLK,
	
   input logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0] half_frame_data_in[NUM_DATA_CHANNELS],
   output logic [NUMBITS_DATAIN_FULL_WIDTH-1:0] outdata[NUM_DATA_CHANNELS],
   input  logic half_frame_clk,
   input  half_frame_clk_valid,
   output logic frame_clk,
   

	
	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output     [7:0] NUM_UARTS_HERE
	
);

assign NUM_UARTS_HERE = 1;

logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0] simulated_input_half_frame_data_in[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]   simulated_output_full_frame_data  [NUM_DATA_CHANNELS];
logic [NUM_DATA_CHANNELS-1:0] choose_output_frame_simulation_data;
logic [NUM_DATA_CHANNELS-1:0] choose_input_frame_simulation_data;
logic transpose_frame_rx_out_bits;
logic transpose_frame_halves;
logic xpose_frame_filling_direction;
logic BitReverseOutput;
logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0]     raw_frame_data[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0]     possibly_transposed_raw_frame_data[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       frame_data_2X_bit[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       actual_frame_data_2X_bit[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       reconstituted_frame_samples[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       transposed_reconstituted_frame_samples[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       possibly_transposed_frame_data_2X_bit[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       outdata_raw[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]   	debug_actual_frame_data_2X_bit;
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]  		debug_possibly_transposed_frame_data_2X_bit;
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]  	    debug_outdata;
logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0]     debug_raw_frame_data;
logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0]     debug_possibly_transposed_raw_frame_data;
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       debug_frame_data_2X_bit;  
logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0]     debug_simulated_input_half_frame_data_in;
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       debug_simulated_output_full_frame_data;
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0] generated_net_test_signal[NUM_DATA_CHANNELS];
logic [NUMBITS_DATAIN_FULL_WIDTH-1:0] raw_generated_net_test_signal[NUM_DATA_CHANNELS];
logic [2*NUMBITS_DATAIN_FULL_WIDTH-1:0] intermediate_test_data[NUM_DATA_CHANNELS];
logic [TEST_SIGNAL_DDS_NUM_PHASE_BITS:0] test_signal_generation_dds_phase_word;
logic [1:0] test_signal_generation_select_test_signal;	
logic [$clog2(NUMBITS_DATAIN_FULL_WIDTH)-1:0]  intermediate_frame_select;
logic [$clog2(NUM_DATA_CHANNELS)-1:0]  internalChannelToLookAt;
logic [$clog2(NUM_DATA_CHANNELS)-1:0]  actualChannelToLookAt;
logic [3*NUMBITS_DATAIN_FULL_WIDTH-1:0]  total_debug_frame_data;
logic [(2*(NUMBITS_DATAIN_FULL_WIDTH/2) + NUMBITS_DATAIN_FULL_WIDTH)-1:0]  total_debug_half_frame_data;
logic [NUM_DATA_CHANNELS-1:0] test_dds_signal_fill_dir_select;


wire [NUM_DATA_CHANNELS-1:0] select_dds_simulated_data;
reg [ACTIVITY_MONITOR_NUMBITS-1:0] frame_activity_monitor = 0;
reg [ACTIVITY_MONITOR_NUMBITS-1:0] half_frame_activity_monitor = 0;

always @(posedge frame_clk)
begin
     frame_activity_monitor <= frame_activity_monitor + 1;
end

always @(posedge half_frame_clk)
begin
     half_frame_activity_monitor <= half_frame_activity_monitor + 1;
end

generate
        if (ALLOW_LOOK_AT_ALL_CHANNELS)
		begin
		       assign actualChannelToLookAt = internalChannelToLookAt;
			   always @(posedge frame_clk) //add additional pipeline register
			   begin
			        total_debug_frame_data <= {
											   actual_frame_data_2X_bit[actualChannelToLookAt],
											   possibly_transposed_frame_data_2X_bit[actualChannelToLookAt],
											   outdata[actualChannelToLookAt]
											   };
			   end
			   always @(posedge half_frame_clk) //add additional pipeline register
			   begin
			        total_debug_half_frame_data <= {
											   raw_frame_data[actualChannelToLookAt],
											   possibly_transposed_raw_frame_data[actualChannelToLookAt],
											   frame_data_2X_bit[actualChannelToLookAt]											   
											   };
			   end
			   
		end else
		begin
		       assign actualChannelToLookAt = CHANNEL_TO_LOOK_AT_FOR_DEBUGGING;
			   
			   assign total_debug_frame_data = {
											   actual_frame_data_2X_bit[CHANNEL_TO_LOOK_AT_FOR_DEBUGGING],
											   possibly_transposed_frame_data_2X_bit[CHANNEL_TO_LOOK_AT_FOR_DEBUGGING],
											   outdata[CHANNEL_TO_LOOK_AT_FOR_DEBUGGING]
											   };
											   
			   assign total_debug_half_frame_data = {
											   raw_frame_data[CHANNEL_TO_LOOK_AT_FOR_DEBUGGING],
											   possibly_transposed_raw_frame_data[CHANNEL_TO_LOOK_AT_FOR_DEBUGGING],
											   frame_data_2X_bit[CHANNEL_TO_LOOK_AT_FOR_DEBUGGING]											   
											  };
		end
endgenerate


genvar channel_num;
generate
			if (GENERATE_DDS_TEST_SIGNALS)
			begin
					parallel_dds_test_signal_generation_one_channel_only
					#(
					.use_explicit_blockram(USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS),
					.TEST_SIGNAL_DDS_NUM_PHASE_BITS(TEST_SIGNAL_DDS_NUM_PHASE_BITS),
					.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION(ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION),
					.NUM_NET_OUTPUT_BITS_PER_CHANNEL(NUMBITS_DATAIN_FULL_WIDTH),
					.NUM_GROSS_OUTPUT_BITS_PER_CHANNEL(NUMBITS_DATAIN_FULL_WIDTH),
					.NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL(NUM_DATA_CHANNELS)
					)
					parallel_dds_test_signal_generation_one_channel_only_inst
					(
					 .clk(frame_clk),
					 .generated_net_test_signal(raw_generated_net_test_signal),
					 .dds_phase_word(test_signal_generation_dds_phase_word),
					 .select_test_signal(test_signal_generation_select_test_signal)
					);

					for (channel_num = 0; channel_num < NUM_DATA_CHANNELS; channel_num++)
					begin : generate_dds_test_data_in				
							always @(posedge frame_clk)
							begin
								 intermediate_test_data[channel_num] <= test_dds_signal_fill_dir_select[channel_num] ? {raw_generated_net_test_signal[channel_num],intermediate_test_data[channel_num][2*NUMBITS_DATAIN_FULL_WIDTH-1 : NUMBITS_DATAIN_FULL_WIDTH]} : {intermediate_test_data[channel_num][NUMBITS_DATAIN_FULL_WIDTH-1:0],raw_generated_net_test_signal[channel_num]};
							end

							data_chooser_according_to_frame_position 
							#(
							   .numbits_dataout(NUMBITS_DATAIN_FULL_WIDTH)
							 )
							data_chooser_according_to_frame_position_inst 
							(
							 .data_reg_contents(intermediate_test_data[channel_num]),
							 .selection_value(intermediate_frame_select),
							 .selected_data_reg_contents(generated_net_test_signal[channel_num]),
							 .clk(frame_clk)
							);
					end
			end
endgenerate

genvar i;
generate
		for (i = 0; i < NUM_DATA_CHANNELS; i++) 
		begin : make_simulated_input_half_frame_data_in
			  assign simulated_input_half_frame_data_in[i]  = 	debug_simulated_input_half_frame_data_in;			  
		end
		
		for (i = 0; i < NUM_DATA_CHANNELS; i++) 
		begin : make_simulated_output_full_frame_data 
		      always @(posedge frame_clk)
              begin			  
			       simulated_output_full_frame_data[i] <= select_dds_simulated_data[i] ? generated_net_test_signal[i] : debug_simulated_output_full_frame_data;
			  end
		end
endgenerate

multi_channel_2x_generic_parallelizer
#(
.NUMBITS_DATAIN_FULL_WIDTH       (NUMBITS_DATAIN_FULL_WIDTH       ),
.NUM_DATA_CHANNELS               (NUM_DATA_CHANNELS               ),
.GENERATE_FRAME_CLOCK_ON_NEGEDGE (GENERATE_FRAME_CLOCK_ON_NEGEDGE )
)
multi_channel_2x_generic_parallelizer_inst
(
   .*   
);

logic mcp_from_half_frame_clk_aready, mcp_from_half_frame_clk_bvalid, mcp_from_frame_clk_aready, mcp_from_frame_clk_bvalid;
logic mcp1_reset, mcp2_reset;


my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(3*NUMBITS_DATAIN_FULL_WIDTH),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth) 
)
mcp_from_frame_clk
(
   .in_clk(frame_clk),
   .in_valid(1'b1),
   .in_data(total_debug_frame_data),
   .out_clk(UART_REGFILE_CLK),
   .out_valid(mcp_from_frame_clk_bvalid),
   .out_data( {
				 debug_actual_frame_data_2X_bit,
				 debug_possibly_transposed_frame_data_2X_bit,
				 debug_outdata
			    })
 );


//mcp_blk 
//#(
//.width(3*NUMBITS_DATAIN_FULL_WIDTH),
//.generate_edge_reset(1)
//) 
//mcp_from_frame_clk
//(
///* output  logic */                 .aready  (mcp_from_frame_clk_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain (total_debug_frame_data),
///* input  logic */                  .asend   (1'b1),
///* input  logic */                  .aclk    (frame_clk),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   ({
//											   debug_actual_frame_data_2X_bit,
//											   debug_possibly_transposed_frame_data_2X_bit,
//											   debug_outdata
//											   }),
///* output  logic */                 .bvalid  (mcp_from_frame_clk_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (UART_REGFILE_CLK),
///* input  logic */                  .brst_n  (1'b1),
//									.a_reset_edge(half_frame_clk_valid || mcp1_reset),
//									.b_reset_edge(half_frame_clk_valid || mcp1_reset)
//
//);


my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH( 2*(NUMBITS_DATAIN_FULL_WIDTH/2) + NUMBITS_DATAIN_FULL_WIDTH) 
)
mcp_from_half_frame_clk
(
   .in_clk(half_frame_clk),
   .in_valid(1'b1),
   .in_data(total_debug_half_frame_data),
   .out_clk(UART_REGFILE_CLK),
   .out_valid(mcp_from_half_frame_clk_bvalid),
   .out_data( {
			   debug_raw_frame_data,
			   debug_possibly_transposed_raw_frame_data,
			   debug_frame_data_2X_bit
			  })
 );



//mcp_blk 
//#(
//.width( 2*(NUMBITS_DATAIN_FULL_WIDTH/2) + NUMBITS_DATAIN_FULL_WIDTH),
//.generate_edge_reset(1)
//) 
//mcp_from_half_frame_clk
//(
///* output  logic */                 .aready  (mcp_from_half_frame_clk_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain (total_debug_half_frame_data),
//											  
///* input  logic */                  .asend   (1'b1),
///* input  logic */                  .aclk    (half_frame_clk),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   ({
//											   debug_raw_frame_data,
//											   debug_possibly_transposed_raw_frame_data,
//											   debug_frame_data_2X_bit
//											   }),
///* output  logic */                 .bvalid  (mcp_from_half_frame_clk_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (UART_REGFILE_CLK),
///* input  logic */                  .brst_n  (1'b1),
//									.a_reset_edge(half_frame_clk_valid || mcp2_reset),
//									.b_reset_edge(half_frame_clk_valid || mcp2_reset)
//);

	
										  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 12;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 12;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0 ;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 1;
			
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
	
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  0;
    assign uart_regfile_interface_pins.control_desc[0]               = "ChooseInSimData";
    assign choose_input_frame_simulation_data = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = NUM_DATA_CHANNELS;		
		
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  0;
    assign uart_regfile_interface_pins.control_desc[1]               = "ChooseOutSimData";
    assign choose_output_frame_simulation_data = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = NUM_DATA_CHANNELS;		
	  

	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  DEFAULT_TRANSPOSE_CTRL;
    assign uart_regfile_interface_pins.control_desc[2]               = "Transpose_Ctrl";
    assign {transpose_frame_rx_out_bits,
			transpose_frame_halves,
			xpose_frame_filling_direction,
			BitReverseOutput}     = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 4;		

	assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  DEFAULT_SIMULATED_HALF_FRAME_DATA;
    assign uart_regfile_interface_pins.control_desc[3]               = "simHalfFrameDat";
    assign debug_simulated_input_half_frame_data_in     = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = NUMBITS_DATAIN_FULL_WIDTH/2;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[4]  =  DEFAULT_SIMULATED_FULL_FRAME_DATA;
    assign uart_regfile_interface_pins.control_desc[4]               = "simFullFrameDat";
    assign debug_simulated_output_full_frame_data     = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = NUMBITS_DATAIN_FULL_WIDTH;		
			  
	assign uart_regfile_interface_pins.control_regs_default_vals[5]  =  TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD;
    assign uart_regfile_interface_pins.control_desc[5]               = "test_dds_word";
    assign test_signal_generation_dds_phase_word     = uart_regfile_interface_pins.control[5];
    assign uart_regfile_interface_pins.control_regs_bitwidth[5]      = TEST_SIGNAL_DDS_NUM_PHASE_BITS;		
			  
	assign uart_regfile_interface_pins.control_regs_default_vals[6]  =  2; //sine wave
    assign uart_regfile_interface_pins.control_desc[6]               = "test_sig_sel";
    assign test_signal_generation_select_test_signal     = uart_regfile_interface_pins.control[6];
    assign uart_regfile_interface_pins.control_regs_bitwidth[6]      = 2;		
	
    assign uart_regfile_interface_pins.control_regs_default_vals[7]  =  0;
    assign uart_regfile_interface_pins.control_desc[7]               = "inter_frm_sel";
    assign intermediate_frame_select     = uart_regfile_interface_pins.control[7];
    assign uart_regfile_interface_pins.control_regs_bitwidth[7]      = $clog2(NUMBITS_DATAIN_FULL_WIDTH);		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[8]  =  0; 
    assign uart_regfile_interface_pins.control_desc[8]               = "sel_dds_sim_dat";
    assign select_dds_simulated_data     = uart_regfile_interface_pins.control[8];
    assign uart_regfile_interface_pins.control_regs_bitwidth[8]      = NUM_DATA_CHANNELS;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[9]  =  CHANNEL_TO_LOOK_AT_FOR_DEBUGGING;
    assign uart_regfile_interface_pins.control_desc[9]               = "CTRLChanLook";
    assign internalChannelToLookAt     = uart_regfile_interface_pins.control[9];
    assign uart_regfile_interface_pins.control_regs_bitwidth[9]      = $clog2(NUM_DATA_CHANNELS);		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[10]  =  0;
    assign uart_regfile_interface_pins.control_desc[10]               = "selTstDDSFillDir";
    assign test_dds_signal_fill_dir_select     = uart_regfile_interface_pins.control[10];
    assign uart_regfile_interface_pins.control_regs_bitwidth[10]      = NUM_DATA_CHANNELS;			
	
	assign uart_regfile_interface_pins.control_regs_default_vals[11]  =  0;
    assign uart_regfile_interface_pins.control_desc[11]               = "mcp_blk_rst";
    assign {mcp2_reset, mcp1_reset}     = uart_regfile_interface_pins.control[11];
    assign uart_regfile_interface_pins.control_regs_bitwidth[11]      = 2;		
	
	assign uart_regfile_interface_pins.status[0] = debug_actual_frame_data_2X_bit;
	assign uart_regfile_interface_pins.status_desc[0]    ="ActualFrm2xData";	

	assign uart_regfile_interface_pins.status[1] = debug_possibly_transposed_frame_data_2X_bit;
	assign uart_regfile_interface_pins.status_desc[1]    ="PosXposFrm2xData";
	
	assign uart_regfile_interface_pins.status[2] = debug_outdata;
	assign uart_regfile_interface_pins.status_desc[2]    ="debugOutdata";
	
	assign uart_regfile_interface_pins.status[3] = debug_raw_frame_data;
	assign uart_regfile_interface_pins.status_desc[3]    ="DebugRawFrmData";
		
    assign uart_regfile_interface_pins.status[4] = debug_possibly_transposed_raw_frame_data;
	assign uart_regfile_interface_pins.status_desc[4]    ="PosXposRawFrmDat";
	
	assign uart_regfile_interface_pins.status[5] = debug_frame_data_2X_bit;
	assign uart_regfile_interface_pins.status_desc[5]    ="DebugFrmData2x";
	
	assign uart_regfile_interface_pins.status[6] = 	{
	                                                 NUMBITS_DATAIN_FULL_WIDTH,
	                                                 NUM_DATA_CHANNELS,
	                                                 CHANNEL_TO_LOOK_AT_FOR_DEBUGGING,
													 TEST_SIGNAL_DDS_NUM_PHASE_BITS													
													 };
	assign uart_regfile_interface_pins.status_desc[6]    ="module_params1";

	assign uart_regfile_interface_pins.status[7] = 	half_frame_activity_monitor;
	assign uart_regfile_interface_pins.status_desc[7]    ="halfFrmActivity";
	
	assign uart_regfile_interface_pins.status[8] = 	frame_activity_monitor;
	assign uart_regfile_interface_pins.status_desc[8]    ="fullFrmActivity";
	
	assign uart_regfile_interface_pins.status[9] = 	actualChannelToLookAt;
	assign uart_regfile_interface_pins.status_desc[9]    ="ActualChanLookAt";
	
	assign uart_regfile_interface_pins.status[10] = {
	                                                 ALLOW_LOOK_AT_ALL_CHANNELS,
													 GENERATE_DDS_TEST_SIGNALS,
													 ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION,
													 GENERATE_FRAME_CLOCK_ON_NEGEDGE
													};

		assign uart_regfile_interface_pins.status_desc[10]    ="module_params2";
	
	
	
	 assign uart_regfile_interface_pins.status[11] = {
	                                                 mcp_from_half_frame_clk_aready, mcp_from_half_frame_clk_bvalid, mcp_from_frame_clk_aready, mcp_from_frame_clk_bvalid
													};

		assign uart_regfile_interface_pins.status_desc[11]    ="mcp_blk_status";
	
	

 endmodule
 
`default_nettype wire
