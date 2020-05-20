
`default_nettype none
`include "interface_defs.v"
`include "math_func_package.v"
import uart_regfile_types::*;
import math_func_package::*;

module multi_stream_packetizer
#(
parameter [7:0] ENABLE_CONTROL_WISHBONE_INTERFACE = 1'b0,
parameter [7:0] ENABLE_STATUS_WISHBONE_INTERFACE  = 1'b0,
parameter [0:0] COMPILE_TEST_SIGNALS = 0,
parameter [0:0] COMPILE_STREAM_SPECIFIC_STATUS_REGS = 1,
parameter [7:0] TEST_SIGNAL_DDS_NUM_PHASE_BITS = 24,
parameter [7:0] NUM_OF_DATA_STREAMS = 2,
parameter TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD = {5'b0,1'b1,{(TEST_SIGNAL_DDS_NUM_PHASE_BITS-10){1'b0}},1'b1},
parameter bitwidth_ratio = in_data_bits/out_data_bits,
parameter [15:0] in_data_bits   = 16,
parameter [15:0] out_data_bits  = 16,
parameter [15:0] num_words_bits = out_data_bits,
parameter [15:0] ACTUAL_BITWIDTH_OF_STREAMS = out_data_bits,
parameter [15:0] POST_PROCESSED_ACTUAL_BITWIDTH_OF_STREAMS = ACTUAL_BITWIDTH_OF_STREAMS;
parameter [15:0] POST_PROCESSED_NUM_OF_STREAMS             = NUM_OF_DATA_STREAMS;
parameter ENABLE_KEEPS = 0,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_NiosDAC"},
parameter UART_REGFILE_TYPE = uart_regfile_types::MULTI_STREAM_PACKETIZER_UART_REGFILE,
parameter [0:0]    IGNORE_TIMING_TO_READ_LD = 1'b0,
parameter [0:0] USE_GENERIC_ATTRIBUTE_FOR_READ_LD = 1'b0,
parameter GENERIC_ATTRIBUTE_FOR_READ_LD = "ERROR",
parameter change_format_default = 0,
parameter [0:0]  WISHBONE_INTERFACE_IS_PART_OF_BRIDGE = 1'b0,
parameter [31:0] WISHBONE_CONTROL_BASE_ADDRESS        = 0,
parameter [31:0] WISHBONE_STATUS_BASE_ADDRESS         = 0,
parameter [7:0] STATUS_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter [7:0] CONTROL_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter [7:0] PACKET_WORD_COUNTER_WIDTH = 32,
parameter [0:0] ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION  = 0,
parameter [0:0] USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter [0:0] SUPPORT_INPUT_DESCRIPTIONS = 1,
parameter NUM_BITS_MEM_FILE_INDEX_REGISTER = 32,
parameter [NUM_BITS_MEM_FILE_INDEX_REGISTER-1:0] MEM_FILE_INDEX_DEFAULT = 16'h0100,
parameter HW_TRIGGER_CTRL_DEFAULT = 32'h0,
parameter DECIMATION_RATIO_DEFAULT = 0,
parameter NUM_BITS_DECIMATION_COUNTER = 16,
parameter synchronizer_depth = 3,
parameter DEFAULT_ACTUAL_NUM_OF_DATA_VALUES_TO_ACQUIRE = 2**20,
parameter ALIVE_CNT_WIDTH = 32,
parameter DEFAULT_CONST_TEST_DATA0 = 16'h1234,
parameter DEFAULT_CONST_TEST_DATA1 = 16'h5678,
parameter USE_BIGGER_EQUAL_TEST_AS_EXTRA_SAFETY_FOR_PACKET_WORD_COUNT = 1'b0,
parameter add_extra_pipelining_for_test_signals = 1,
parameter add_extra_pipelining_for_test_signal_constants_from_uart = 0,
parameter DECIMATION_CONTROL_DEFAULT = 0,
parameter [POST_PROCESSED_ACTUAL_BITWIDTH_OF_STREAMS-1:0] DATA_BIT_MASK_DEFAULT = {POST_PROCESSED_ACTUAL_BITWIDTH_OF_STREAMS{1'b1}},
parameter POST_PROCESSED_BITWIDTH_RATIO = bitwidth_ratio,
parameter math_format_type MATH_FORMAT_DEFAULT = TWOS_COMPLEMENT_FORMAT_ENUM_VAL,
parameter support_supersample_frames = 0,
parameter device_family = "Cyclone V",
parameter [0:0] DELAY_INPUT_TO_BE_ABLE_TO_ACQUIRE_PRE_TRIGGER_DATA = 1'b0,
parameter [31:0] NUM_OF_CLOCK_CYCLES_TO_DELAY_INPUT = 256
)
(
	input  CLKIN,
	input  RESET_FOR_CLKIN,
	
	multi_data_stream_interface input_streams_interface_pins,
	multiple_synced_st_streaming_interfaces avst_out,
	output uart_tx,
	input  uart_rx,
	
    input logic       UART_IS_SECONDARY_UART,
    input logic [7:0] UART_NUM_SECONDARY_UARTS,
    input logic [7:0] UART_ADDRESS_OF_THIS_UART,
	output [7:0] NUM_UARTS_HERE,
    wishbone_interface status_wishbone_interface_pins,
    wishbone_interface control_wishbone_interface_pins,
	
	input async_hw_trigger,
	output actual_hw_trigger,
	input external_hw_trigger_reset,
    output logic [in_data_bits-1:0]  test_selected_data[NUM_OF_DATA_STREAMS],
	output logic HW_Trigger_Has_Happened,
	output logic synced_to_CLKIN_HW_Trigger_Has_Happened,
	output logic hw_trigger_with_sop_interrupt,
	output logic hw_trigger_with_eop_interrupt,
	output logic eop_interrupt,
	output logic sop_interrupt,
	input logic  [NUM_BITS_DECIMATION_COUNTER-1:0] external_sample_acquisition_decimation,
    output logic [PACKET_WORD_COUNTER_WIDTH-1:0] measured_time_between_triggers,
    output logic [ACTUAL_BITWIDTH_OF_STREAMS-1:0] data_bit_mask	
);
assign NUM_UARTS_HERE = 1;
logic [NUM_OF_DATA_STREAMS-1:0] edge_detected_in_HW_Trigger_Has_Happened;
logic [1:0] lower_2_bits_HW_Trigger_Has_Happened;
logic [1:0] lower_2_bits_NIOS_DAC_FIFO_IS_DUMMY;
logic [NUM_BITS_DECIMATION_COUNTER-1:0]  raw_decimation_ratio;
(* altera_attribute = {"-name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -to [get_keepers {*uart_controlled_nios_dacs:*|decimation_ratio*}]\" "} *)  logic [NUM_BITS_DECIMATION_COUNTER-1:0] decimation_ratio;
logic select_external_decimation_ratio;

logic [out_data_bits-1:0]  constant_test_data[NUM_OF_DATA_STREAMS];

assign lower_2_bits_HW_Trigger_Has_Happened = {2{HW_Trigger_Has_Happened}};
logic clk;

assign clk = input_streams_interface_pins.clk;
logic reset_test_generator;
logic reset_test_generator_raw;

multiple_synced_st_streaming_interfaces
#( 
	  .num_channels        (avst_out.get_num_channels()       ),
	  .num_data_bits       (avst_out.get_num_data_bits()      ),
	  .num_bits_per_symbol (avst_out.get_num_bits_per_symbol()),
	  .num_error_bits      (avst_out.get_num_error_bits()     )
 )																																								
internal_avst_in(),
actual_internal_avst_in();

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Macro definitions  
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`define current_subrange(chan) ((chan)*out_data_bits+ACTUAL_BITWIDTH_OF_STREAMS-1):((chan)*out_data_bits)

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//     Wire and register definitions
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits-1:0] data_to_the_GP_FIFO[NUM_OF_DATA_STREAMS];
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  DAC_data_valid[NUM_OF_DATA_STREAMS];
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  local_superframe_start_n[NUM_OF_DATA_STREAMS];
	
 
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [NUM_OF_DATA_STREAMS-1:0] change_DAC_format;
			
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits-1:0]  DAC_MUXED_OUT_raw[NUM_OF_DATA_STREAMS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits+1:0]  DAC_MUXED_OUT_raw2[NUM_OF_DATA_STREAMS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits+1:0]  DAC_MUXED_OUT[NUM_OF_DATA_STREAMS];
     
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [in_data_bits+1:0]    registered_selected_data[NUM_OF_DATA_STREAMS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [in_data_bits+1:0]    clock_crossed_registered_selected_data[NUM_OF_DATA_STREAMS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [in_data_bits-1:0]    simple_count[NUM_OF_DATA_STREAMS]; 

	 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [ALIVE_CNT_WIDTH-1:0]    raw_alive_cnt; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [ALIVE_CNT_WIDTH-1:0]    alive_cnt; 
	
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic      select_test_dds[NUM_OF_DATA_STREAMS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [2:0] select_test_dds_signal[NUM_OF_DATA_STREAMS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic select_constant_output[NUM_OF_DATA_STREAMS];
	    
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0]	test_dds_phi_inc_i[NUM_OF_DATA_STREAMS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic output_test_signal_as_unsigned[NUM_OF_DATA_STREAMS];
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic HW_trigger_override;
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic hw_trigger_reset;
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic test_hw_trigger;
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic auto_hw_trigger_reset_enable;
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [7:0] state;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [7:0] clock_crossed_state;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] running_time_between_triggers;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] packet_word_counter;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] last_packet_word_count;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] synced_last_packet_word_count;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] packet_counter;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] synced_packet_counter;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] synced_packet_word_counter;   
       (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [PACKET_WORD_COUNTER_WIDTH-1:0] actual_num_locations_in_fifo;	  
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic packet_in_progress;      
 
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic allow_hw_trigger;
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic enable_packet_streaming_to_memory;
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)   logic sop_state_machine_reset;
	 
	 		
		logic [15:0] controlled_post_processed_actual_bitwidth;
		logic [15:0] controlled_math_format;
	 
	 
	   always_ff @(posedge clk)
		begin
				if (avst_out.eop)
				begin
					 packet_counter <= packet_counter + 1;
				end															   
		end


			
		assign internal_avst_in.valid              = DAC_data_valid[0];
		assign internal_avst_in.superframe_start_n = local_superframe_start_n[0];
		assign internal_avst_in.clk                = clk;
	  
	  
	  
	   assign actual_hw_trigger = (async_hw_trigger | test_hw_trigger) & allow_hw_trigger;
		
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
		.PACKET_WORD_COUNTER_WIDTH                     (PACKET_WORD_COUNTER_WIDTH                 ),
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
			.test_selected_data,
			.packet_counter,
			.select_test_dds_signal,
			.output_test_signal_as_unsigned,
			.test_dds_phi_inc_i,
			.constant_test_data,
			.registered_selected_data
		);
       
genvar current_subword;
genvar current_data_stream;
generate
 		                 for (current_data_stream = 0; current_data_stream < NUM_OF_DATA_STREAMS; current_data_stream++)
						  begin : per_nios_dac	
						  
						      	assign internal_avst_in.data[current_data_stream]  =  data_to_the_GP_FIFO[current_data_stream];
		
						      
						  
							    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
								//
								//      Clock crossing between control and fifo
								//
								/////////////////////////////////////////////////////////////////////////////////////////////////////////////
								
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
									   .in_data({actual_internal_avst_in.valid, actual_internal_avst_in.data[current_data_stream][in_data_bits-1:0]}/*registered_selected_data[current_data_stream]*/),
									   .out_clk(CLKIN),
									   .out_valid(),
									   .out_data(clock_crossed_registered_selected_data[current_data_stream])
									 );	 
														 
								
								
						              assign data_to_the_GP_FIFO[current_data_stream] = DAC_MUXED_OUT[current_data_stream][in_data_bits-1:0];
						
								
									  assign DAC_data_valid[current_data_stream] = DAC_MUXED_OUT[0][in_data_bits];
									  assign local_superframe_start_n[current_data_stream] = DAC_MUXED_OUT[0][in_data_bits+1];
								
										for (current_subword = 0; current_subword < bitwidth_ratio; current_subword++)
										begin : change_to_signed_or_unsigned
												controlled_unsigned_to_signed_or_vice_versa
												#(
												.width(ACTUAL_BITWIDTH_OF_STREAMS)
												)
												change_encoding_dac
												(
												.in(registered_selected_data[current_data_stream][`current_subrange(current_subword)]),
												.out(DAC_MUXED_OUT_raw[current_data_stream][`current_subrange(current_subword)]),
												.change_format(change_DAC_format[current_data_stream])
												);
										 end
										
										 always @(posedge clk)
										 begin												
										       DAC_MUXED_OUT_raw2[current_data_stream] <= {registered_selected_data[current_data_stream][in_data_bits+1:in_data_bits],DAC_MUXED_OUT_raw[current_data_stream]};
										       DAC_MUXED_OUT[current_data_stream] <=  DAC_MUXED_OUT_raw2[current_data_stream];
										 end	
				end
endgenerate
		


always_ff @(posedge clk)
begin
     decimation_ratio <= select_external_decimation_ratio ? external_sample_acquisition_decimation : raw_decimation_ratio;
end		
 
always_ff @(posedge clk)
begin
      raw_alive_cnt <=  raw_alive_cnt + 1;
end

my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(ALIVE_CNT_WIDTH),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_alive_cnt
(
   .in_clk(clk),
   .in_valid(1'b1),
   .in_data(raw_alive_cnt),
   .out_clk(CLKIN),
   .out_valid(),
   .out_data(alive_cnt)
);	 

				
logic [PACKET_WORD_COUNTER_WIDTH-1:0] packet_word_counter_limit;												
												 
my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(PACKET_WORD_COUNTER_WIDTH),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_synch_packet_word_counter_limit
(
   .in_clk(CLKIN),
   .in_valid(1'b1),
   .in_data((actual_num_locations_in_fifo >> $clog2(bitwidth_ratio))-1),
   .out_clk(clk),
   .out_valid(),
   .out_data(packet_word_counter_limit)
);

generate
				if (DELAY_INPUT_TO_BE_ABLE_TO_ACQUIRE_PRE_TRIGGER_DATA) 
				begin
							multiple_synced_st_streaming_interfaces_delay_line 
							#(
							.device_family                                   (device_family                     ),
							.NUM_OF_CLOCK_CYCLES_TO_DELAY_INPUT              (NUM_OF_CLOCK_CYCLES_TO_DELAY_INPUT),
							.CONNECT_CLOCK_OF_OUTPUT_INTERFACE_TO_INPUT_CLOCK(1'b1                              )
							)
							multiple_synced_st_streaming_interfaces_delay_line_inst
							(
							.input_streams_interface_pins(internal_avst_in),
							.output_streams_interface_pins(actual_internal_avst_in),
							.async_clear_fifo(1'b0)
							);
				end else
				begin
					  assign actual_internal_avst_in.data                 =  internal_avst_in.data ;
					  assign actual_internal_avst_in.valid                =  internal_avst_in.valid                  ;
					  assign actual_internal_avst_in.superframe_start_n   =  internal_avst_in.superframe_start_n     ;
					  assign actual_internal_avst_in.clk                  =  internal_avst_in.clk                    ;
				end
endgenerate				
			
			
triggered_packetizer
#(
.ENABLE_KEEPS(ENABLE_KEEPS),
.synchronizer_depth(synchronizer_depth),
.NUM_BITS_DECIMATION_COUNTER(NUM_BITS_DECIMATION_COUNTER),
.PACKET_WORD_COUNTER_WIDTH(PACKET_WORD_COUNTER_WIDTH),
.USE_BIGGER_EQUAL_TEST_AS_EXTRA_SAFETY_FOR_PACKET_WORD_COUNT(USE_BIGGER_EQUAL_TEST_AS_EXTRA_SAFETY_FOR_PACKET_WORD_COUNT),
.support_supersample_frames(support_supersample_frames)
)
triggered_packetizer_inst
(
	.avst_out(avst_out),
	.avst_in (actual_internal_avst_in ),
	.decimation_ratio(decimation_ratio),
	.clk(clk),
	.enable_packet_streaming_to_memory,
	.packet_word_counter_limit,		
	.sop_state_machine_reset,	
	.HW_Trigger_Has_Happened                    (HW_Trigger_Has_Happened),
	.hw_trigger_reset,
	.auto_hw_trigger_reset_enable,
	.hw_trigger_with_sop_interrupt              (hw_trigger_with_sop_interrupt),
	.hw_trigger_with_eop_interrupt              (hw_trigger_with_eop_interrupt),
	.eop_interrupt                              (eop_interrupt),
	.sop_interrupt                              (sop_interrupt),
	.packet_word_counter                        (packet_word_counter),    
	.last_packet_word_count                     (last_packet_word_count),
	.packet_in_progress                         (packet_in_progress),
	.actual_hw_trigger	
);												


my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(PACKET_WORD_COUNTER_WIDTH),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_synch_packet_word_counter
(
   .in_clk(clk),
   .in_valid(1'b1),
   .in_data(packet_word_counter),
   .out_clk(CLKIN),
   .out_valid(),
   .out_data(synced_packet_word_counter)
 );
	 
my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(PACKET_WORD_COUNTER_WIDTH),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_synch_last_packet_word_count
(
   .in_clk(clk),
   .in_valid(1'b1),
   .in_data(last_packet_word_count),
   .out_clk(CLKIN),
   .out_valid(),
   .out_data(synced_last_packet_word_count)
);
 
my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(PACKET_WORD_COUNTER_WIDTH),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_synch_packet_counter
(
   .in_clk(clk),
   .in_valid(1'b1),
   .in_data(packet_counter),
   .out_clk(CLKIN),
   .out_valid(),
   .out_data(synced_packet_counter)
 );														

   my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(8),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_state
(
   .in_clk(clk),
   .in_valid(1'b1),
   .in_data(state),
   .out_clk(CLKIN),
   .out_valid(),
   .out_data(clock_crossed_state)
 );	 
	
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

doublesync_no_reset 
#(
 .synchronizer_depth(synchronizer_depth)
 )
sync_HW_Trigger_Has_Happened
(
 .indata(HW_Trigger_Has_Happened),
 .outdata(synced_to_CLKIN_HW_Trigger_Has_Happened),
 .clk(CLKIN)
);

measure_time_between_triggers
#(
.COUNTER_WIDTH(PACKET_WORD_COUNTER_WIDTH)
)
measure_time_between_triggers_inst
(
.trigger(synced_to_CLKIN_HW_Trigger_Has_Happened),
.time_between_triggers(measured_time_between_triggers),
.clk(CLKIN),
.reset(1'b0),
//debugging outputs
.edge_detected_in_trigger(edge_detected_in_HW_Trigger_Has_Happened),
.running_time_between_triggers(running_time_between_triggers)
);	

											  
										  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	        
			`define num_stream_specific_control_regs    (3)
			`define num_stream_specific_status_regs     (1)
			`define first_stream_specific_control_reg   (10)
			`define first_stream_specific_status_reg    (15)
			
			localparam ZERO_IN_ASCII = 48;
			
	      `define current_ctrl_reg_num(x,y) ((((x)*`num_stream_specific_control_regs+`first_stream_specific_control_reg))+(y))
			`define current_status_reg_num(x,y) (((x)*`num_stream_specific_status_regs+`first_stream_specific_status_reg) + (y))
					
					
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = COMPILE_TEST_SIGNALS ? `current_ctrl_reg_num(NUM_OF_DATA_STREAMS-1,`num_stream_specific_control_regs-1) + 1 : `first_stream_specific_control_reg;
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
			 .USE_GENERIC_ATTRIBUTE_FOR_READ_LD(USE_GENERIC_ATTRIBUTE_FOR_READ_LD),
             .GENERIC_ATTRIBUTE_FOR_READ_LD(GENERIC_ATTRIBUTE_FOR_READ_LD),
			 .STATUS_WISHBONE_NUM_ADDRESS_BITS(STATUS_WISHBONE_NUM_ADDRESS_BITS),
             .CONTROL_WISHBONE_NUM_ADDRESS_BITS(CONTROL_WISHBONE_NUM_ADDRESS_BITS),
			 .WISHBONE_INTERFACE_IS_PART_OF_BRIDGE  (WISHBONE_INTERFACE_IS_PART_OF_BRIDGE ),
             .WISHBONE_CONTROL_BASE_ADDRESS        	(WISHBONE_CONTROL_BASE_ADDRESS        ),	 
             .WISHBONE_STATUS_BASE_ADDRESS         	(WISHBONE_STATUS_BASE_ADDRESS         )	 
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
			
	
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  change_format_default;
    assign uart_regfile_interface_pins.control_desc[0]               = "Change_DAC_FMT";
    assign change_DAC_format                                         = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = NUM_OF_DATA_STREAMS;			  	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  HW_TRIGGER_CTRL_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[1]               = "HW_Trigger_CTRL";
    assign {reset_test_generator_raw,select_external_decimation_ratio,allow_hw_trigger,auto_hw_trigger_reset_enable,test_hw_trigger,hw_trigger_reset,HW_trigger_override}  = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 16;	
		
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  DECIMATION_RATIO_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[2]               = "decimation_ratio";
    assign raw_decimation_ratio  = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = NUM_BITS_DECIMATION_COUNTER;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  0;
    assign uart_regfile_interface_pins.control_desc[3]               = "StreamToMemCtrl";
    assign {sop_state_machine_reset,enable_packet_streaming_to_memory} = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = 16;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[4]  =  DEFAULT_ACTUAL_NUM_OF_DATA_VALUES_TO_ACQUIRE;
    assign uart_regfile_interface_pins.control_desc[4]               = "actual_num_locs";
    assign actual_num_locations_in_fifo = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = 32;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[5]  =  MEM_FILE_INDEX_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[5]               = "mem_file_index";
    
    assign uart_regfile_interface_pins.control_regs_bitwidth[5]      = NUM_BITS_MEM_FILE_INDEX_REGISTER;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[6]  =  DATA_BIT_MASK_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[6]               = "data_bit_mask";
	assign data_bit_mask = uart_regfile_interface_pins.control[6];
    assign uart_regfile_interface_pins.control_regs_bitwidth[6]      = POST_PROCESSED_ACTUAL_BITWIDTH_OF_STREAMS;	
		
	assign uart_regfile_interface_pins.control_regs_default_vals[7]  =  POST_PROCESSED_ACTUAL_BITWIDTH_OF_STREAMS;
    assign uart_regfile_interface_pins.control_desc[7]               = "ctrlld_bitwidth";
	assign controlled_post_processed_actual_bitwidth = uart_regfile_interface_pins.control[7];
    assign uart_regfile_interface_pins.control_regs_bitwidth[7]      = 16;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[8]  =  MATH_FORMAT_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[8]               = "ctrlld_format";
	assign controlled_math_format                                    = uart_regfile_interface_pins.control[8];
    assign uart_regfile_interface_pins.control_regs_bitwidth[8]      = 8;	
	
	
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
	
    assign uart_regfile_interface_pins.status[2] = {ACTUAL_BITWIDTH_OF_STREAMS,num_words_bits};
	 assign uart_regfile_interface_pins.status_desc[2]    ="num_words_bits";
	 
    assign uart_regfile_interface_pins.status[3] = {
	                                              /*28*/     DELAY_INPUT_TO_BE_ABLE_TO_ACQUIRE_PRE_TRIGGER_DATA,
	                                              /*27:24 */ MATH_FORMAT_DEFAULT,	                                               
	                                              /*23:22 */ lower_2_bits_NIOS_DAC_FIFO_IS_DUMMY,
	                                             /*21 */     USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS,
												/* 20:19 */  lower_2_bits_HW_Trigger_Has_Happened,
	                                             /* 18 */    COMPILE_TEST_SIGNALS,
	                                             /* 17 */    ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION,
	                                             /* 16 */   /* ENABLE_HW_TRIGGER_INTERFACE */ 1'b1,
												/*15:8 */	 NUM_OF_DATA_STREAMS,
	                                            /* 7:0 */    TEST_SIGNAL_DDS_NUM_PHASE_BITS};
    assign uart_regfile_interface_pins.status_desc[3]    ="TestDDSParams";

	assign uart_regfile_interface_pins.status[4] =packet_in_progress;
	assign uart_regfile_interface_pins.status_desc[4]    ="packet_in_prog";
				    
	assign uart_regfile_interface_pins.status[5] =	synced_packet_word_counter;
	assign uart_regfile_interface_pins.status_desc[5] = "packet_word_cnt";
		
	assign uart_regfile_interface_pins.status[6] =	synced_packet_counter;
	assign uart_regfile_interface_pins.status_desc[6] = "packet_cnt";									
	
	assign uart_regfile_interface_pins.status[7] =	alive_cnt;
	assign uart_regfile_interface_pins.status_desc[7] = "alive_cnt";
		
	assign uart_regfile_interface_pins.status[8] =	synced_last_packet_word_count;
	assign uart_regfile_interface_pins.status_desc[8] = "last_pkt_wrds";

	assign uart_regfile_interface_pins.status[9] =	clock_crossed_state;
	assign uart_regfile_interface_pins.status_desc[9] = "state";
		
	assign uart_regfile_interface_pins.status[10] =	measured_time_between_triggers;
	assign uart_regfile_interface_pins.status_desc[10] = "time_btween_trig";
	
	assign uart_regfile_interface_pins.status[11] =	decimation_ratio;
	assign uart_regfile_interface_pins.status_desc[11] = "actual_dec_ratio";
			
	assign uart_regfile_interface_pins.status[12] =	POST_PROCESSED_ACTUAL_BITWIDTH_OF_STREAMS;
	assign uart_regfile_interface_pins.status_desc[12] = "post_actual_bitwidth";
	
	assign uart_regfile_interface_pins.status[13] =	POST_PROCESSED_NUM_OF_STREAMS;
	assign uart_regfile_interface_pins.status_desc[13] = "post_num_streams";		
	
	assign uart_regfile_interface_pins.status[14] =	POST_PROCESSED_BITWIDTH_RATIO;
	assign uart_regfile_interface_pins.status_desc[14] = "post_bit_ratio";	
	
	generate
					if (COMPILE_STREAM_SPECIFIC_STATUS_REGS)
					begin
							for (current_data_stream = 0; current_data_stream < NUM_OF_DATA_STREAMS; current_data_stream++)
							begin : make_test_status_registers
									wire [7:0] char1 = ((current_data_stream/10)+ZERO_IN_ASCII);
									wire [7:0] char2 = ((current_data_stream % 10)+ZERO_IN_ASCII);
									assign uart_regfile_interface_pins.status[`current_status_reg_num(current_data_stream,0)][30:0] =	clock_crossed_registered_selected_data[current_data_stream][in_data_bits-1:0];
									assign uart_regfile_interface_pins.status[`current_status_reg_num(current_data_stream,0)][31]  =	clock_crossed_registered_selected_data[current_data_stream][in_data_bits];
									assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_data_stream,0)] =  {"valid_and_data",char1,char2};
							end
					end
	endgenerate
	
 endmodule
 `default_nettype wire
 