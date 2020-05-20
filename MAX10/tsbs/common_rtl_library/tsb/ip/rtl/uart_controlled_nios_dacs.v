
`default_nettype none
`include "interface_defs.v"

import uart_regfile_types::*;

module uart_controlled_nios_dacs
#(
parameter  [7:0] ENABLE_CONTROL_WISHBONE_INTERFACE = 1'b0,
parameter  [7:0] ENABLE_STATUS_WISHBONE_INTERFACE  = 1'b0,
parameter Synchronize_Capture_Both_GP_FIFOs_DEFAULT = 1,
parameter [0:0] COMPILE_TEST_SIGNAL_DDS = 0,
parameter [7:0] TEST_SIGNAL_DDS_NUM_PHASE_BITS = 24,
parameter TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD = {5'b0,1'b1,{(TEST_SIGNAL_DDS_NUM_PHASE_BITS-10){1'b0}},1'b1},
parameter num_dac_channels = in_data_bits/out_data_bits,
parameter [15:0] in_data_bits   = 16,
parameter [15:0] out_data_bits  = 16,
parameter num_locations_in_fifo = 16384,
parameter [15:0] num_words_bits = $clog2(num_locations_in_fifo),
parameter num_output_locations_in_fifo = num_locations_in_fifo*in_data_bits/out_data_bits,
parameter [15:0] num_output_words_bits = $clog2(num_output_locations_in_fifo),
parameter DEFAULT_CHANNEL_TO_DAC0 = 0,
parameter DEFAULT_CHANNEL_TO_DAC1 = 0,
parameter [15:0] ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS = out_data_bits,
parameter ENABLE_KEEPS = 0,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_NiosDAC"},
parameter UART_REGFILE_TYPE = uart_regfile_types::NIOS_DACS_STANDALONE_REGFILE,
parameter [0:0]    IGNORE_TIMING_TO_READ_LD = 1'b0,
parameter [0:0] USE_GENERIC_ATTRIBUTE_FOR_READ_LD = 1'b0,
parameter GENERIC_ATTRIBUTE_FOR_READ_LD = "ERROR",
parameter change_format_default = 0,
parameter [0:0]  WISHBONE_INTERFACE_IS_PART_OF_BRIDGE = 1'b0,
parameter [31:0] WISHBONE_CONTROL_BASE_ADDRESS        = 0,
parameter [31:0] WISHBONE_STATUS_BASE_ADDRESS         = 0,
parameter [7:0] STATUS_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter [7:0] CONTROL_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter [7:0] NUM_OF_NIOS_DACS = 2,
parameter [7:0] PACKET_WORD_COUNTER_WIDTH = 32,
parameter [7:0] PACKET_COUNT_COUNTER_WIDTH = 32,
parameter [0:0] ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION  = 0,
parameter [0:0] USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter [0:0] SUPPORT_INPUT_DESCRIPTIONS = 1,
parameter NUM_BITS_MEM_FILE_INDEX_REGISTER = 32,
parameter [NUM_BITS_MEM_FILE_INDEX_REGISTER-1:0] MEM_FILE_INDEX_DEFAULT = 16'h0100,
parameter HW_TRIGGER_CTRL_DEFAULT = 32'h18,
parameter [0:0] ENABLE_HW_TRIGGER_INTERFACE = 1,
parameter [NUM_OF_NIOS_DACS-1:0] NIOS_DAC_FIFO_IS_DUMMY = 0,
parameter DAC0_DECIMATION_RATIO_DEFAULT = 0,
parameter DAC1_DECIMATION_RATIO_DEFAULT = 0,
parameter NUM_BITS_DECIMATION_COUNTER = 16,
parameter synchronizer_depth = 3,
parameter [0:0] ENABLE_STREAMING_TO_EXTERNAL_MEMORY = 0,
parameter [0:0] USE_ONLY_CLOCK_0_FOR_DATA_CLOCKS = ENABLE_STREAMING_TO_EXTERNAL_MEMORY ? 1'b1 : 1'b0,
parameter DEFAULT_ACTUAL_NUM_OF_DATA_VALUES_TO_ACQUIRE = num_output_locations_in_fifo,
parameter ALIVE_CNT_WIDTH = 32,
parameter DEFAULT_CONST_TEST_DATA0 = 16'h1234,
parameter DEFAULT_CONST_TEST_DATA1 = 16'h5678,
parameter USE_BIGGER_EQUAL_TEST_AS_EXTRA_SAFETY_FOR_PACKET_WORD_COUNT = 1'b0,
parameter add_extra_pipelining_for_test_signals = 1,
parameter DECIMATION_CONTROL_DEFAULT = 0
)
(
	input  CLKIN,
	input  RESET_FOR_CLKIN,
	
	multi_dac_interface nios_dac_pins,
	multi_data_acq_fifo_interface data_acq_fifo_interface,
	multiple_avalon_st_streaming_interfaces_w_independent_clocks avst_out,
	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output [7:0] NUM_UARTS_HERE,
    wishbone_interface status_wishbone_interface_pins,
    wishbone_interface control_wishbone_interface_pins,
	
	input async_hw_trigger,
	output actual_hw_trigger,
	input external_hw_trigger_reset,
    output logic [in_data_bits-1:0]  test_selected_data[NUM_OF_NIOS_DACS],
	output logic [NUM_OF_NIOS_DACS-1:0] HW_Trigger_Has_Happened,
	output logic [NUM_OF_NIOS_DACS-1:0] synced_to_CLKIN_HW_Trigger_Has_Happened,
	output logic [NUM_OF_NIOS_DACS-1:0] hw_trigger_with_sop_interrupt,
	output logic [NUM_OF_NIOS_DACS-1:0] hw_trigger_with_eop_interrupt,
	output logic [NUM_OF_NIOS_DACS-1:0] eop_interrupt,
	output logic [NUM_OF_NIOS_DACS-1:0] sop_interrupt,
	input logic [NUM_BITS_DECIMATION_COUNTER-1:0] external_sample_acquisition_decimation,
    output logic [PACKET_WORD_COUNTER_WIDTH-1:0] measured_time_between_triggers[NUM_OF_NIOS_DACS]      

	
);
assign NUM_UARTS_HERE = 1;
logic [NUM_OF_NIOS_DACS-1:0] edge_detected_in_HW_Trigger_Has_Happened;
logic [1:0] lower_2_bits_HW_Trigger_Has_Happened;
logic [1:0] lower_2_bits_NIOS_DAC_FIFO_IS_DUMMY;
logic [NUM_BITS_DECIMATION_COUNTER-1:0]  raw_decimation_ratio[NUM_OF_NIOS_DACS];
(* altera_attribute = {"-name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -to [get_keepers {*uart_controlled_nios_dacs:*|decimation_ratio*}]\" "} *)  logic [NUM_BITS_DECIMATION_COUNTER-1:0] decimation_ratio[NUM_OF_NIOS_DACS];
logic select_external_decimation_ratio;

logic [in_data_bits-1:0]  constant_test_data[NUM_OF_NIOS_DACS];

assign lower_2_bits_HW_Trigger_Has_Happened = HW_Trigger_Has_Happened;
assign lower_2_bits_NIOS_DAC_FIFO_IS_DUMMY  = NIOS_DAC_FIFO_IS_DUMMY;


multiple_avalon_st_streaming_interfaces_w_independent_clocks 
#(
.num_channels        (avst_out.get_num_channels()       ),
.num_data_bits       (avst_out.get_num_data_bits()      ),
.num_bits_per_symbol (avst_out.get_num_bits_per_symbol()),
.num_error_bits      (avst_out.get_num_error_bits()     )
)
avst_out_raw();


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Macro definitions  
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`define current_subrange(chan) ((chan)*out_data_bits+ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS-1):((chan)*out_data_bits)

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//     Wire and register definitions
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////

	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire Synchronize_Capture_Both_GP_FIFOs;
	
	
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [in_data_bits-1:0] data_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [31:0] in_port_to_the_GP_FIFO_Flags[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [NUM_OF_NIOS_DACS-1:0] rdempty_from_the_GP_FIFO;
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  rdfull_from_the_GP_FIFO[NUM_OF_NIOS_DACS];
   	                     wire  wrclk_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [NUM_OF_NIOS_DACS-1:0] wrempty_from_the_GP_FIFO;
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  wrfull_from_the_GP_FIFO[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  wrreq_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  actual_wrreq_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  wrreq_enable[NUM_OF_NIOS_DACS];
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  DAC_data_valid[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [NUM_OF_NIOS_DACS-1:0] out_port_from_the_GP_FIFO_Control[7:0];
	
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [31:0] q_from_the_GP_FIFO[NUM_OF_NIOS_DACS];
     (* keep = 1, preserve = 1, altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) wire rdclk_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
	
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire rdreq_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [num_words_bits-1:0] wrusedw_from_the_GP_FIFO[NUM_OF_NIOS_DACS];
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [num_output_words_bits-1:0] rdusedw_from_the_GP_FIFO[NUM_OF_NIOS_DACS];

	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire synced_out_port_from_the_All_GP_FIFO_Control_0_to_FIFO_write_domain[NUM_OF_NIOS_DACS];
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire synced_out_port_from_GP_FIFO_Control_0_to_this_FIFO_only[NUM_OF_NIOS_DACS];

	
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire synced_Synchronize_Capture_Both_GP_FIFOs_to_FIFO_write_domain[NUM_OF_NIOS_DACS];
   
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [1:0] change_DAC_format;
			
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits-1:0]  DAC_MUXED_OUT_raw[NUM_OF_NIOS_DACS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits:0]  DAC_MUXED_OUT_raw2[NUM_OF_NIOS_DACS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits:0]  DAC_MUXED_OUT[NUM_OF_NIOS_DACS];
     
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [in_data_bits:0]    registered_selected_data[NUM_OF_NIOS_DACS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [in_data_bits:0]    clock_crossed_registered_selected_data[NUM_OF_NIOS_DACS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [in_data_bits-1:0]    simple_count[NUM_OF_NIOS_DACS]; 

	 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [ALIVE_CNT_WIDTH-1:0]    raw_alive_cnt[NUM_OF_NIOS_DACS]; 
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic    [ALIVE_CNT_WIDTH-1:0]    alive_cnt[NUM_OF_NIOS_DACS]; 
	
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)	logic      select_test_dds[NUM_OF_NIOS_DACS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [2:0] select_test_dds_signal[NUM_OF_NIOS_DACS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [2:0] actual_select_test_dds_signal[NUM_OF_NIOS_DACS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic select_constant_output[NUM_OF_NIOS_DACS];
	    
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0]	test_dds_phi_inc_i[NUM_OF_NIOS_DACS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic output_test_signal_as_unsigned[NUM_OF_NIOS_DACS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic actual_output_test_signal_as_unsigned[NUM_OF_NIOS_DACS];
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) reg [NUM_OF_NIOS_DACS-1:0] fifo_acquiring_now_as_part_of_general_acquire =0;
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)   logic HW_trigger_override;
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] hw_trigger_received;
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic hw_trigger_reset;
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic test_hw_trigger;
      (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic auto_hw_trigger_reset_enable;
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] actual_hw_trigger_reset;     
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] actual_hw_trigger_reset_raw;     
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] actual_hw_trigger_synced_to_write_clk;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [7:0] state[NUM_OF_NIOS_DACS];      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [7:0] clock_crossed_state[NUM_OF_NIOS_DACS];      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] running_time_between_triggers[NUM_OF_NIOS_DACS];      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] packet_word_counter[NUM_OF_NIOS_DACS];      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] last_packet_word_count[NUM_OF_NIOS_DACS];      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] synced_last_packet_word_count[NUM_OF_NIOS_DACS];      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] packet_counter[NUM_OF_NIOS_DACS];      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] synced_packet_counter[NUM_OF_NIOS_DACS];      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [PACKET_WORD_COUNTER_WIDTH-1:0] synced_packet_word_counter[NUM_OF_NIOS_DACS];   
       (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [PACKET_WORD_COUNTER_WIDTH-1:0] actual_num_locations_in_fifo;	  
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] reset_packet_word_counter   ;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] reset_hw_trigger_for_external_memory       ;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] allow_hw_trigger_for_external_memory       ;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] reset_hw_trigger_for_external_memory_raw   ;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] allow_hw_trigger_for_external_memory_raw   ;  
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] increase_packet_word_counter;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] allow_avst_out_valid;      
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] packet_in_progress;      
 
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic hw_trigger_is_allowed;
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic allow_hw_trigger;
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic enable_packet_streaming_to_memory;
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] synced_enable_packet_streaming_to_memory;
	  (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] synced_enable_packet_streaming_to_memory_raw;
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic sop_state_machine_reset;
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [NUM_OF_NIOS_DACS-1:0] synced_sop_state_machine_reset;
	  
	   assign actual_hw_trigger = (async_hw_trigger | test_hw_trigger) & hw_trigger_is_allowed;
			
      generate
					if (ENABLE_STREAMING_TO_EXTERNAL_MEMORY)						  
					begin
						 assign hw_trigger_is_allowed = ((&allow_hw_trigger_for_external_memory) & allow_hw_trigger);
					end else
					begin
	   assign hw_trigger_is_allowed = ((&rdempty_from_the_GP_FIFO) & allow_hw_trigger);
				    end
		endgenerate
	
	   genvar current_subword;
	   genvar current_nios_dac;
	   genvar current_bit;
	   generate
	
			if (COMPILE_TEST_SIGNAL_DDS)
			begin : generate_test_dds_signal
							 parallel_dds_test_signal_generation
							 #(
								.use_explicit_blockram(USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS),
								.TEST_SIGNAL_DDS_NUM_PHASE_BITS(TEST_SIGNAL_DDS_NUM_PHASE_BITS),
								.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION(ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION),
								.NUM_NET_OUTPUT_BITS_PER_CHANNEL(ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS),
								.NUM_GROSS_OUTPUT_BITS_PER_CHANNEL(out_data_bits),
								.NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL(num_dac_channels),
								.TOTAL_OUTPUT_BITS(in_data_bits),
								.NUM_TEST_CHANNELS(NUM_OF_NIOS_DACS),
								.add_extra_pipelining(add_extra_pipelining_for_test_signals)
							  )
							  parallel_dds_test_signal_generation_inst 
							  (
								.clk(nios_dac_pins.selected_clk_to_dac),
								.generated_parallel_test_signal(test_selected_data),
								.dds_phase_word(test_dds_phi_inc_i),
								.select_test_signal('{actual_select_test_dds_signal[0][1:0],actual_select_test_dds_signal[1][1:0]}),
								.output_unsigned_signal(actual_output_test_signal_as_unsigned)
							  );
						
						  for (current_nios_dac = 0; current_nios_dac < NUM_OF_NIOS_DACS; current_nios_dac++)
						  begin : per_nios_dac								  
										  always @(posedge nios_dac_pins.selected_clk_to_dac[current_nios_dac])
										  begin												
                                                  simple_count[current_nios_dac] <=  simple_count[current_nios_dac]  + 1;
										  end						
										  
										  always @(posedge nios_dac_pins.selected_clk_to_dac[current_nios_dac])
										  begin												
										           if ( select_test_dds[current_nios_dac] )
												   begin
												             
															                                    case (actual_select_test_dds_signal[current_nios_dac])
																								3'b000, 3'b001, 3'b010, 3'b011 :  registered_selected_data[current_nios_dac] <= {1'b1,test_selected_data[current_nios_dac]};
																								3'b100 : registered_selected_data[current_nios_dac] <= {1'b1,constant_test_data[current_nios_dac]} ;
															                                    3'b101 : registered_selected_data[current_nios_dac] <= {1'b1,simple_count[current_nios_dac]};
																								3'b110 : registered_selected_data[current_nios_dac] <= {1'b1, ((((!USE_ONLY_CLOCK_0_FOR_DATA_CLOCKS) || (USE_ONLY_CLOCK_0_FOR_DATA_CLOCKS && (current_nios_dac == 0)))) ? packet_counter[current_nios_dac] :  packet_counter[0])};
																								3'b111 : registered_selected_data[current_nios_dac] <= {1'b1,simple_count[current_nios_dac] + constant_test_data[current_nios_dac]};
																								endcase
												   end else 
												   begin
        												      registered_selected_data[current_nios_dac] <=    {nios_dac_pins.valid_to_dac[current_nios_dac],nios_dac_pins.selected_channel_to_dac[current_nios_dac]};
												   end
																								
										  end	

										  	
								doublesync_no_reset #(.synchronizer_depth(2))  //syncing is mainly for timing analysis, don't care about metastability
								sync_output_test_signal_as_unsigned
								(
								.indata(output_test_signal_as_unsigned[current_nios_dac]),
								.outdata(actual_output_test_signal_as_unsigned[current_nios_dac]),
								.clk(nios_dac_pins.selected_clk_to_dac[current_nios_dac])
								);
								
								for ( current_bit = 0; current_bit < 3; current_bit++)
								begin : sync_select_test_dds_signal_for_timing_analysis
										doublesync_no_reset #(.synchronizer_depth(2)) //syncing is mainly for timing analysis, don't care about metastability
										sync_select_test_dds_signal
										(
										.indata(select_test_dds_signal[current_nios_dac][current_bit]),
										.outdata(actual_select_test_dds_signal[current_nios_dac][current_bit]),
										.clk(nios_dac_pins.selected_clk_to_dac[current_nios_dac])
										);
								end
																  
						  end
			end else
			begin
			     for (current_nios_dac = 0; current_nios_dac < NUM_OF_NIOS_DACS; current_nios_dac++)
				 begin : per_nios_dac								  
									  always_ff @(posedge nios_dac_pins.selected_clk_to_dac[current_nios_dac])
									  begin												
											   registered_selected_data[current_nios_dac] <= {nios_dac_pins.valid_to_dac[current_nios_dac],nios_dac_pins.selected_channel_to_dac[current_nios_dac]};
									  end						
				 end
			end	
	endgenerate

	
	

	//====================================================================================
   //
   //   Now connect GP FIFOs to DACs
   //
   //====================================================================================
       
    	generate
 		                 for (current_nios_dac = 0; current_nios_dac < NUM_OF_NIOS_DACS; current_nios_dac++)
						  begin : per_nios_dac	
						  
						          always_ff @(posedge wrclk_to_the_GP_FIFO[current_nios_dac])
								  begin
									     decimation_ratio[current_nios_dac] <= select_external_decimation_ratio ? external_sample_acquisition_decimation : raw_decimation_ratio[current_nios_dac];
								  end
						  
							    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
								//
								//      Clock crossing between control and fifo
								//
								/////////////////////////////////////////////////////////////////////////////////////////////////////////////
								
									my_multibit_clock_crosser_optimized_for_altera
									#(
									  .DATA_WIDTH(in_data_bits+1),
									  .FORWARD_SYNC_DEPTH(synchronizer_depth),
									  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
									)
									mcp_registered_selected_data
									(
									   .in_clk(wrclk_to_the_GP_FIFO[current_nios_dac]),
									   .in_valid(1'b1),
									   .in_data(registered_selected_data[current_nios_dac]),
									   .out_clk(CLKIN),
									   .out_valid(),
									   .out_data(clock_crossed_registered_selected_data[current_nios_dac])
									 );	 
														 
								always_ff @(posedge nios_dac_pins.selected_clk_to_dac[current_nios_dac])
								begin
								      raw_alive_cnt[current_nios_dac] <=  raw_alive_cnt[current_nios_dac] + 1;
								end
								
								my_multibit_clock_crosser_optimized_for_altera
								#(
								  .DATA_WIDTH(ALIVE_CNT_WIDTH),
								  .FORWARD_SYNC_DEPTH(synchronizer_depth),
								  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
								)
								mcp_alive_cnt
								(
								   .in_clk(nios_dac_pins.selected_clk_to_dac[current_nios_dac]),
								   .in_valid(1'b1),
								   .in_data(raw_alive_cnt[current_nios_dac]),
								   .out_clk(CLKIN),
								   .out_valid(),
								   .out_data(alive_cnt[current_nios_dac])
								);	 
								
								
	
								doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
								sync_out_Synchronize_Capture_Both_GP_FIFOs_to_FIFOs
								(
								.indata(Synchronize_Capture_Both_GP_FIFOs),
								.outdata(synced_Synchronize_Capture_Both_GP_FIFOs_to_FIFO_write_domain[current_nios_dac]),
								.clk(wrclk_to_the_GP_FIFO[current_nios_dac])
								);
								                             								
								doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
								sync_out_port_from_the_All_GP_FIFO_Control_0_to_FIFO_write_domain
								(
								.indata(&out_port_from_the_GP_FIFO_Control[0][NUM_OF_NIOS_DACS-1:0]),
								.outdata(synced_out_port_from_the_All_GP_FIFO_Control_0_to_FIFO_write_domain[current_nios_dac]),
								.clk(wrclk_to_the_GP_FIFO[current_nios_dac])
								);
								
								                           								
							
								
								
								always @(posedge wrclk_to_the_GP_FIFO[current_nios_dac])
								begin
								     if (synced_out_port_from_the_All_GP_FIFO_Control_0_to_FIFO_write_domain[current_nios_dac])
								     begin 
									      fifo_acquiring_now_as_part_of_general_acquire[current_nios_dac] <= 1; //started aquire
								     end else 
									 begin
									       if (fifo_acquiring_now_as_part_of_general_acquire[current_nios_dac] && (synced_out_port_from_GP_FIFO_Control_0_to_this_FIFO_only[current_nios_dac]))
										   begin
										        fifo_acquiring_now_as_part_of_general_acquire[current_nios_dac] <= 1; //continuing to acquire as part of general acquire										   
										   end else
										   begin
										        fifo_acquiring_now_as_part_of_general_acquire[current_nios_dac] <= 0;
										   end									 
									 end									 																		 
								end
								
								doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
								sync_out_port_from_GP_FIFO_Control_0_to_this_FIFO_only
								(
								.indata(out_port_from_the_GP_FIFO_Control[0][current_nios_dac]),
								.outdata(synced_out_port_from_GP_FIFO_Control_0_to_this_FIFO_only[current_nios_dac]),
								.clk(wrclk_to_the_GP_FIFO[current_nios_dac])
								);
										
								assign wrreq_to_the_GP_FIFO[current_nios_dac] = 	 HW_trigger_override ? (hw_trigger_received[current_nios_dac] & DAC_data_valid[current_nios_dac]) : (synced_Synchronize_Capture_Both_GP_FIFOs_to_FIFO_write_domain[current_nios_dac] ? 
																					(fifo_acquiring_now_as_part_of_general_acquire[current_nios_dac] & DAC_data_valid[current_nios_dac] ): 
																					(DAC_data_valid[current_nios_dac] & synced_out_port_from_GP_FIFO_Control_0_to_this_FIFO_only[current_nios_dac]));
						        
								/////////////////////////////////////////////////////////////////////////////////////////////////////////////
								//
								//     FIFO Connection to interface
								//
								/////////////////////////////////////////////////////////////////////////////////////////////////////////////
							
								assign data_acq_fifo_interface.data [current_nios_dac]    =  data_to_the_GP_FIFO [current_nios_dac];
			                    assign data_acq_fifo_interface.rdclk[current_nios_dac]    =  rdclk_to_the_GP_FIFO[current_nios_dac];
			                    assign data_acq_fifo_interface.rdreq[current_nios_dac]    =  rdreq_to_the_GP_FIFO[current_nios_dac];
			                    assign data_acq_fifo_interface.wrclk[current_nios_dac]    =  wrclk_to_the_GP_FIFO[current_nios_dac];
								
								always @(posedge wrclk_to_the_GP_FIFO[current_nios_dac])
								begin
								     actual_wrreq_to_the_GP_FIFO[current_nios_dac] <= wrreq_enable[current_nios_dac] & wrreq_to_the_GP_FIFO[current_nios_dac];
								end
								
			                    assign data_acq_fifo_interface.wrreq[current_nios_dac]    =  actual_wrreq_to_the_GP_FIFO[current_nios_dac];
			                    assign q_from_the_GP_FIFO      [current_nios_dac]         =  data_acq_fifo_interface.q       [current_nios_dac];
			                    assign rdempty_from_the_GP_FIFO[current_nios_dac]         =  data_acq_fifo_interface.rdempty [current_nios_dac];
			                    assign rdfull_from_the_GP_FIFO [current_nios_dac]         =  data_acq_fifo_interface.rdfull  [current_nios_dac];
			                    assign wrempty_from_the_GP_FIFO[current_nios_dac]         =  data_acq_fifo_interface.wrempty [current_nios_dac];
			                    assign wrfull_from_the_GP_FIFO [current_nios_dac]         =  data_acq_fifo_interface.wrfull  [current_nios_dac];
			                    assign wrusedw_from_the_GP_FIFO[current_nios_dac]         =  data_acq_fifo_interface.wrusedw [current_nios_dac];
			                    assign rdusedw_from_the_GP_FIFO[current_nios_dac]         =  data_acq_fifo_interface.rdusedw [current_nios_dac];

								assign rdreq_to_the_GP_FIFO[current_nios_dac] = out_port_from_the_GP_FIFO_Control[1][current_nios_dac];
								assign rdclk_to_the_GP_FIFO[current_nios_dac] = out_port_from_the_GP_FIFO_Control[4][current_nios_dac];
													  
						  
	                            assign in_port_to_the_GP_FIFO_Flags[current_nios_dac] = {
	                                                 3'b0,rdempty_from_the_GP_FIFO[current_nios_dac], 
	                                                 3'b0,rdfull_from_the_GP_FIFO[current_nios_dac], 
													 3'b0,wrempty_from_the_GP_FIFO[current_nios_dac], 
													 3'b0,wrfull_from_the_GP_FIFO[current_nios_dac], 
													 {{(16-num_output_words_bits){1'b0}},
													 rdusedw_from_the_GP_FIFO[current_nios_dac]}
													};
						  
						        assign data_to_the_GP_FIFO[current_nios_dac] = DAC_MUXED_OUT[current_nios_dac][in_data_bits-1:0];
								
								if ((!USE_ONLY_CLOCK_0_FOR_DATA_CLOCKS) || (USE_ONLY_CLOCK_0_FOR_DATA_CLOCKS && (current_nios_dac == 0)))
								begin
	                                  assign wrclk_to_the_GP_FIFO[current_nios_dac] = nios_dac_pins.selected_clk_to_dac[current_nios_dac];
  	  	                              assign DAC_data_valid[current_nios_dac] = DAC_MUXED_OUT[current_nios_dac][in_data_bits];
								end else
								begin
								      assign wrclk_to_the_GP_FIFO[current_nios_dac] = nios_dac_pins.selected_clk_to_dac[0];   
									  assign DAC_data_valid[current_nios_dac] = DAC_MUXED_OUT[0][in_data_bits];
								end
								
						  
										for (current_subword = 0; current_subword < num_dac_channels; current_subword++)
										begin : change_to_signed_or_unsigned
												controlled_unsigned_to_signed_or_vice_versa
												#(
												.width(ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS)
												)
												change_encoding_dac
												(
												.in(registered_selected_data[current_nios_dac][`current_subrange(current_subword)]),
												.out(DAC_MUXED_OUT_raw[current_nios_dac][`current_subrange(current_subword)]),
												.change_format(change_DAC_format[current_nios_dac])
												);
										 end
										
										 always @(posedge nios_dac_pins.selected_clk_to_dac[current_nios_dac])
										 begin												
										       DAC_MUXED_OUT_raw2[current_nios_dac] <= {registered_selected_data[current_nios_dac][in_data_bits],DAC_MUXED_OUT_raw[current_nios_dac]};
										       DAC_MUXED_OUT[current_nios_dac] <=  DAC_MUXED_OUT_raw2[current_nios_dac];
										 end	

										if (ENABLE_STREAMING_TO_EXTERNAL_MEMORY)						  
										begin
										       
																						
												mod_m_counter_var_m_w_en
												 #(
													.N(NUM_BITS_DECIMATION_COUNTER) // number of bits in counter              
												 )
												 decimate_write_request_counter
												 (
													.M(decimation_ratio[current_nios_dac]),
													.clk(wrclk_to_the_GP_FIFO[current_nios_dac]), 
													.enable(DAC_data_valid[current_nios_dac]),
													.reset(1'b0),
													.max_tick(wrreq_enable[current_nios_dac]),
													.q()
												 );
																				
												localparam idle              = 8'b0000_0000;
												localparam wait_for_sop      = 8'b0011_0001;
												localparam wait_for_eop      = 8'b0001_0010;
												
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
												   .in_data(actual_num_locations_in_fifo-1),
												   .out_clk(wrclk_to_the_GP_FIFO[current_nios_dac]),
												   .out_valid(),
												   .out_data(packet_word_counter_limit)
												);
														
												if ((!USE_ONLY_CLOCK_0_FOR_DATA_CLOCKS) || (USE_ONLY_CLOCK_0_FOR_DATA_CLOCKS && (current_nios_dac == 0)))
												begin
												
														doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
														sync_sop_state_machine_reset
														(
														.indata(sop_state_machine_reset),
														.outdata(synced_sop_state_machine_reset[current_nios_dac]),
														.clk(wrclk_to_the_GP_FIFO[current_nios_dac])
														);
														
														doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
														sync_enable_packet_streaming_to_memory
														(
														.indata(enable_packet_streaming_to_memory || HW_Trigger_Has_Happened[current_nios_dac]),
														.outdata(synced_enable_packet_streaming_to_memory_raw[current_nios_dac]),
														.clk(wrclk_to_the_GP_FIFO[current_nios_dac])
														);
														
														edge_detect_and_hold
														edge_detect_and_hold_enable_packet_streaming_to_memory(
														/*input */   .in_signal(synced_enable_packet_streaming_to_memory_raw[current_nios_dac]), 
														/*input */   .reset(avst_out_raw.sop[current_nios_dac] || synced_sop_state_machine_reset[current_nios_dac]), 
														/* output */ .edge_received(synced_enable_packet_streaming_to_memory[current_nios_dac]), 
														/*input */   .clk(wrclk_to_the_GP_FIFO[current_nios_dac]));
														
														
														
														assign reset_packet_word_counter   [current_nios_dac] = !state[current_nios_dac][4];
														assign increase_packet_word_counter[current_nios_dac] = avst_out_raw.valid[current_nios_dac] & state[current_nios_dac][4];
														assign allow_avst_out_valid        [current_nios_dac] = state[current_nios_dac][4];
														assign packet_in_progress          [current_nios_dac] = state[current_nios_dac][4];
												        assign reset_hw_trigger_for_external_memory_raw[current_nios_dac] = state[current_nios_dac][5];
														assign allow_hw_trigger_for_external_memory_raw[current_nios_dac] = !state[current_nios_dac][4];
												
														always_ff @(posedge wrclk_to_the_GP_FIFO[current_nios_dac])
														begin
															  if (reset_packet_word_counter[current_nios_dac])
															  begin 
																   packet_word_counter[current_nios_dac] <= 0;
															  end else
															  begin		
																  if (increase_packet_word_counter[current_nios_dac])
																  begin														  
																		packet_word_counter[current_nios_dac] <= packet_word_counter[current_nios_dac] + 1;
																  end
															  end
														end
														
																										
														always_ff @(posedge wrclk_to_the_GP_FIFO[current_nios_dac])
														begin
															  if (synced_sop_state_machine_reset[current_nios_dac])
															  begin
																	state[current_nios_dac] <= idle;
															  end else
															  begin
																  
																	case (state[current_nios_dac])
																	idle : if (synced_enable_packet_streaming_to_memory[current_nios_dac])
																		   begin
																				 state[current_nios_dac] <= wait_for_sop;
																		   end
																		   
																	wait_for_sop : if (avst_out_raw.valid[current_nios_dac])
																				   begin
																						state[current_nios_dac] <= wait_for_eop;
																				   end
																				   
																	wait_for_eop : if (USE_BIGGER_EQUAL_TEST_AS_EXTRA_SAFETY_FOR_PACKET_WORD_COUNT)
																						begin 
																						     if ((packet_word_counter[current_nios_dac] >= packet_word_counter_limit) && avst_out_raw.valid[current_nios_dac])
																				   begin
																						state[current_nios_dac] <= idle;																
																				   end					
																					   end else
																						begin
																						     if ((packet_word_counter[current_nios_dac] == packet_word_counter_limit) && avst_out_raw.valid[current_nios_dac])
																							  begin
																										state[current_nios_dac] <= idle;																
																							  end																											
																						end
																	endcase										
															  end
														end
														
														always_ff @(posedge wrclk_to_the_GP_FIFO[current_nios_dac])
														begin
															   if (avst_out.eop[current_nios_dac])
															   begin
																	 packet_counter[current_nios_dac] <= packet_counter[current_nios_dac] + 1;
															   end															   
														end

														
														always_ff @(posedge wrclk_to_the_GP_FIFO[current_nios_dac])
														begin
															   if (avst_out_raw.eop[current_nios_dac])
															   begin
																	 last_packet_word_count[current_nios_dac] <= packet_word_counter[current_nios_dac];
															   end															   
														end

														my_multibit_clock_crosser_optimized_for_altera
														#(
														  .DATA_WIDTH(PACKET_WORD_COUNTER_WIDTH),
														  .FORWARD_SYNC_DEPTH(synchronizer_depth),
														  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
														)
														mcp_synch_packet_word_counter
														(
														   .in_clk(wrclk_to_the_GP_FIFO[current_nios_dac]),
														   .in_valid(1'b1),
														   .in_data(packet_word_counter[current_nios_dac]),
														   .out_clk(CLKIN),
														   .out_valid(),
														   .out_data(synced_packet_word_counter[current_nios_dac])
														 );
													 	 
												    	my_multibit_clock_crosser_optimized_for_altera
														#(
														  .DATA_WIDTH(PACKET_WORD_COUNTER_WIDTH),
														  .FORWARD_SYNC_DEPTH(synchronizer_depth),
														  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
														)
														mcp_synch_last_packet_word_count
														(
														   .in_clk(wrclk_to_the_GP_FIFO[current_nios_dac]),
														   .in_valid(1'b1),
														   .in_data(last_packet_word_count[current_nios_dac]),
														   .out_clk(CLKIN),
														   .out_valid(),
														   .out_data(synced_last_packet_word_count[current_nios_dac])
														 );
														 
														 my_multibit_clock_crosser_optimized_for_altera
														#(
														  .DATA_WIDTH(PACKET_COUNT_COUNTER_WIDTH),
														  .FORWARD_SYNC_DEPTH(synchronizer_depth),
														  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
														)
														mcp_synch_packet_counter
														(
														   .in_clk(wrclk_to_the_GP_FIFO[current_nios_dac]),
														   .in_valid(1'b1),
														   .in_data(packet_counter[current_nios_dac]),
														   .out_clk(CLKIN),
														   .out_valid(),
														   .out_data(synced_packet_counter[current_nios_dac])
														 );														
														
													    my_multibit_clock_crosser_optimized_for_altera
														#(
														  .DATA_WIDTH(8),
														  .FORWARD_SYNC_DEPTH(synchronizer_depth),
														  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
														)
														mcp_state
														(
														   .in_clk(wrclk_to_the_GP_FIFO[current_nios_dac]),
														   .in_valid(1'b1),
														   .in_data(state[current_nios_dac]),
														   .out_clk(CLKIN),
														   .out_valid(),
														   .out_data(clock_crossed_state[current_nios_dac])
														 );	 
															
														
													    doublesync_no_reset 
													    #(
													     .synchronizer_depth(synchronizer_depth)
													     )
													     sync_HW_Trigger_Has_Happened
													     (
													     .indata(HW_Trigger_Has_Happened[current_nios_dac]),
													     .outdata(synced_to_CLKIN_HW_Trigger_Has_Happened[current_nios_dac]),
													     .clk(CLKIN)
													     );
											 
														measure_time_between_triggers
														#(
														.COUNTER_WIDTH(PACKET_WORD_COUNTER_WIDTH)
														)
														measure_time_between_triggers_inst
														(
														.trigger(synced_to_CLKIN_HW_Trigger_Has_Happened[current_nios_dac]),
														.time_between_triggers(measured_time_between_triggers[current_nios_dac]),
														.clk(CLKIN),
														.reset(1'b0),
														//debugging outputs
														.edge_detected_in_trigger(edge_detected_in_HW_Trigger_Has_Happened[current_nios_dac]),
														.running_time_between_triggers(running_time_between_triggers[current_nios_dac])
														);	
												 		
														assign avst_out_raw.data[current_nios_dac]   = data_to_the_GP_FIFO[current_nios_dac];
														assign avst_out_raw.valid[current_nios_dac]  = allow_avst_out_valid[current_nios_dac] & DAC_data_valid[current_nios_dac] & wrreq_enable[current_nios_dac];
														assign avst_out_raw.clk[current_nios_dac]    = wrclk_to_the_GP_FIFO[current_nios_dac];																						
														assign avst_out_raw.sop[current_nios_dac]    = ((packet_word_counter[current_nios_dac] == 0) && (state[current_nios_dac]  == wait_for_sop) &&  avst_out_raw.valid[current_nios_dac]); //glitchy but OK because avalon-ST
														assign avst_out_raw.eop[current_nios_dac]    = ((packet_word_counter[current_nios_dac] == packet_word_counter_limit) && (state[current_nios_dac]  == wait_for_eop) &&  avst_out_raw.valid[current_nios_dac]); //glitchy but OK because avalon-ST											
													
												end else
												begin
												 	    assign avst_out_raw.data[current_nios_dac]   = data_to_the_GP_FIFO[current_nios_dac];
														assign avst_out_raw.valid[current_nios_dac]  = allow_avst_out_valid[0] & DAC_data_valid[0] & wrreq_enable[0];
														assign avst_out_raw.clk[current_nios_dac]    = wrclk_to_the_GP_FIFO[0];																						
														assign avst_out_raw.sop[current_nios_dac]    = ((packet_word_counter[0] == 0) && (state[0] == wait_for_sop) &&  avst_out_raw.valid[0]); //glitchy but OK because avalon-ST
														assign avst_out_raw.eop[current_nios_dac]    = ((packet_word_counter[0] == packet_word_counter_limit) && (state[0]  == wait_for_eop) &&  avst_out_raw.valid[0]); //glitchy but OK because avalon-ST											
											            assign allow_hw_trigger_for_external_memory_raw[current_nios_dac]  = allow_hw_trigger_for_external_memory_raw[0];
														assign reset_hw_trigger_for_external_memory_raw[current_nios_dac]  = reset_hw_trigger_for_external_memory_raw[0];
												end
												 
												 assign avst_out.clk[current_nios_dac] =  avst_out_raw.clk[current_nios_dac];

												 always_ff @(posedge wrclk_to_the_GP_FIFO[current_nios_dac])
												 begin
														avst_out.data[current_nios_dac]  <= avst_out_raw.data[current_nios_dac]; 
														avst_out.valid[current_nios_dac] <= avst_out_raw.valid[current_nios_dac];		
														avst_out.sop[current_nios_dac]   <= avst_out_raw.sop[current_nios_dac]; 
														avst_out.eop[current_nios_dac]   <= avst_out_raw.eop[current_nios_dac]; 
														hw_trigger_with_eop_interrupt[current_nios_dac] <= avst_out_raw.eop[current_nios_dac] & HW_Trigger_Has_Happened[current_nios_dac]; 
														hw_trigger_with_sop_interrupt[current_nios_dac] <= avst_out_raw.sop[current_nios_dac] & HW_Trigger_Has_Happened[current_nios_dac]; 
												 end												 																					

                                                 assign eop_interrupt[current_nios_dac] = avst_out.eop[current_nios_dac];
                                                 assign sop_interrupt[current_nios_dac] = avst_out.sop[current_nios_dac];
		 
												 assign actual_hw_trigger_reset_raw[current_nios_dac] = hw_trigger_reset | (auto_hw_trigger_reset_enable & reset_hw_trigger_for_external_memory[current_nios_dac]) | external_hw_trigger_reset;
												 
												 doublesync_no_reset #(
												 .synchronizer_depth(synchronizer_depth)
												 )
												 sync_actual_hw_trigger_reset
												 (
												 .indata(actual_hw_trigger_reset_raw[current_nios_dac]),
												 .outdata(actual_hw_trigger_reset[current_nios_dac]),
												 .clk(wrclk_to_the_GP_FIFO[current_nios_dac])
												 );
												 
												 doublesync_no_reset #(
												 .synchronizer_depth(synchronizer_depth)
												 )
												 sync_reset_hw_trigger_for_external_memory
												 (
												 .indata(reset_hw_trigger_for_external_memory_raw[current_nios_dac]),
												 .outdata(reset_hw_trigger_for_external_memory[current_nios_dac]),
												 .clk(wrclk_to_the_GP_FIFO[current_nios_dac])
												 );
												 
												 doublesync_no_reset #(
												 .synchronizer_depth(synchronizer_depth)
												 )
												 sync_allow_hw_trigger_for_external_memory
												 (
												 .indata(allow_hw_trigger_for_external_memory_raw[current_nios_dac]),
												 .outdata(allow_hw_trigger_for_external_memory[current_nios_dac]),
												 .clk(wrclk_to_the_GP_FIFO[current_nios_dac])
												 );																								
												 
												 async_trap_and_reset_gen_1_pulse_robust 
												 async_trap_actual_hw_trigger
												 (
												 .async_sig(actual_hw_trigger), 
												 .outclk(wrclk_to_the_GP_FIFO[current_nios_dac]), 
												 .out_sync_sig(actual_hw_trigger_synced_to_write_clk[current_nios_dac]), 
												 .auto_reset(1'b0), 
												 .reset(!actual_hw_trigger_reset[current_nios_dac])
												 );
												 
												 async_event_request_handler   	
												 async_event_request_handler_inst
												 (
													/*input  */ .driver_clk(wrclk_to_the_GP_FIFO[current_nios_dac]),
													/*input  */ .event_request_from_driver(actual_hw_trigger_synced_to_write_clk[current_nios_dac]),
													/*output */ .event_request_to_event_buffer_synced_to_driver_clk(hw_trigger_received[current_nios_dac]),
													/*output */ .reset_event_request_from_event_buffer_synced_to_driver_clk(),
													
													/*input  */ .event_buffer_clk(wrclk_to_the_GP_FIFO[current_nios_dac]),
													/*output */ .event_request_to_event_buffer(HW_Trigger_Has_Happened[current_nios_dac]),
													/*input  */ .reset_event_request_from_event_buffer(actual_hw_trigger_reset[current_nios_dac])
												 );	
																				 
						 
									end	else
									begin
			                                assign actual_hw_trigger_reset[current_nios_dac] = hw_trigger_reset | (auto_hw_trigger_reset_enable & rdreq_to_the_GP_FIFO[current_nios_dac]);

											 mod_m_counter_var_m_w_en
											 #(
												.N(NUM_BITS_DECIMATION_COUNTER) // number of bits in counter              
											 )
											 decimate_write_request_counter
											 (
												.M(decimation_ratio[current_nios_dac]),
												.clk(wrclk_to_the_GP_FIFO[current_nios_dac]), 
												.enable(wrreq_to_the_GP_FIFO[current_nios_dac]),
												.reset(1'b0),
												.max_tick(wrreq_enable[current_nios_dac]),
												.q()
											 );
								   
											async_event_request_handler   	
											async_event_request_handler_inst
											(
												/*input  */ .driver_clk(wrclk_to_the_GP_FIFO[current_nios_dac]),
												/*input  */ .event_request_from_driver(actual_hw_trigger /*actual_hw_trigger_synced_to_write_clk[current_nios_dac]*/),
												/*output */ .event_request_to_event_buffer_synced_to_driver_clk(hw_trigger_received[current_nios_dac]),
												/*output */ .reset_event_request_from_event_buffer_synced_to_driver_clk(),
												
												/*input  */ .event_buffer_clk(CLKIN),
												/*output */ .event_request_to_event_buffer(HW_Trigger_Has_Happened[current_nios_dac]),
												/*input  */ .reset_event_request_from_event_buffer(actual_hw_trigger_reset[current_nios_dac])
											);	
									
									end										 
							end
		endgenerate    								  
										  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 20;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 31;			
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
			
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  32'h12345678;
    assign uart_regfile_interface_pins.control_desc[0]               = "ctrlAlive";
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 32;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  DEFAULT_CHANNEL_TO_DAC0;
    assign uart_regfile_interface_pins.control_desc[1]               = "SelChanToDAC0";
    assign nios_dac_pins.select_channel_to_dac[0]                      = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 16;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  DEFAULT_CHANNEL_TO_DAC1;
    assign uart_regfile_interface_pins.control_desc[2]               = "SelChanToDAC1";
    assign nios_dac_pins.select_channel_to_dac[1]                      = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 16;		
	 

    assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  change_format_default;
    assign uart_regfile_interface_pins.control_desc[3]               = "Change_DAC_FMT";
    assign change_DAC_format                                         = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = 2;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[4]  =  Synchronize_Capture_Both_GP_FIFOs_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[4]               = "Sync_FIFO_Capt";
    assign Synchronize_Capture_Both_GP_FIFOs                     = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = 1;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[5]  =  0;
    assign uart_regfile_interface_pins.control_desc[5]               = "FIFOctrl0";
    assign {out_port_from_the_GP_FIFO_Control[7][0],
	        out_port_from_the_GP_FIFO_Control[6][0],
			out_port_from_the_GP_FIFO_Control[5][0],
			out_port_from_the_GP_FIFO_Control[4][0],
			out_port_from_the_GP_FIFO_Control[3][0],
			out_port_from_the_GP_FIFO_Control[2][0],
			out_port_from_the_GP_FIFO_Control[1][0],
			out_port_from_the_GP_FIFO_Control[0][0]}                     = uart_regfile_interface_pins.control[5];
    assign uart_regfile_interface_pins.control_regs_bitwidth[5]      = 8;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[6]  =  0;
    assign uart_regfile_interface_pins.control_desc[6]               = "FIFOctrl1";
    assign {out_port_from_the_GP_FIFO_Control[7][1],
            out_port_from_the_GP_FIFO_Control[6][1],
    		out_port_from_the_GP_FIFO_Control[5][1],
    		out_port_from_the_GP_FIFO_Control[4][1],
    		out_port_from_the_GP_FIFO_Control[3][1],
    		out_port_from_the_GP_FIFO_Control[2][1],
    		out_port_from_the_GP_FIFO_Control[1][1],
    		out_port_from_the_GP_FIFO_Control[0][1]} = uart_regfile_interface_pins.control[6];
    assign uart_regfile_interface_pins.control_regs_bitwidth[6]      = 8;		
	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[7]  =  TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD;
    assign uart_regfile_interface_pins.control_desc[7]               = "DAC0_TESTDDS_PHI";
    assign test_dds_phi_inc_i[0]                     = uart_regfile_interface_pins.control[7];
    assign uart_regfile_interface_pins.control_regs_bitwidth[7]      = TEST_SIGNAL_DDS_NUM_PHASE_BITS;		
	
	 assign uart_regfile_interface_pins.control_regs_default_vals[8]  =  TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD;
    assign uart_regfile_interface_pins.control_desc[8]               = "DAC1_TESTDDS_PHI";
    assign test_dds_phi_inc_i[1]                     = uart_regfile_interface_pins.control[8];
    assign uart_regfile_interface_pins.control_regs_bitwidth[8]      = TEST_SIGNAL_DDS_NUM_PHASE_BITS;				
	
	 assign uart_regfile_interface_pins.control_regs_default_vals[9]  =  0;
    assign uart_regfile_interface_pins.control_desc[9]               = "test_signal_ctl0";
    assign {output_test_signal_as_unsigned[0],select_test_dds_signal[0][2:0],  select_test_dds[0]}  = uart_regfile_interface_pins.control[9];
    assign uart_regfile_interface_pins.control_regs_bitwidth[9]      = 5;				
	
	 assign uart_regfile_interface_pins.control_regs_default_vals[10]  =  0;
    assign uart_regfile_interface_pins.control_desc[10]               = "test_signal_ctl1";
    assign {output_test_signal_as_unsigned[1],select_test_dds_signal[1][2:0],  select_test_dds[1]}  = uart_regfile_interface_pins.control[10];
    assign uart_regfile_interface_pins.control_regs_bitwidth[10]      = 5;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[11]  =  HW_TRIGGER_CTRL_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[11]               = "HW_Trigger_CTRL";
    assign {allow_hw_trigger,auto_hw_trigger_reset_enable,test_hw_trigger,hw_trigger_reset,HW_trigger_override}  = uart_regfile_interface_pins.control[11];
    assign uart_regfile_interface_pins.control_regs_bitwidth[11]      = 8;	
		
	assign uart_regfile_interface_pins.control_regs_default_vals[12]  =  DAC0_DECIMATION_RATIO_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[12]               = "dac0_decimation";
    assign raw_decimation_ratio[0]  = uart_regfile_interface_pins.control[12];
    assign uart_regfile_interface_pins.control_regs_bitwidth[12]      = NUM_BITS_DECIMATION_COUNTER;	
		
	assign uart_regfile_interface_pins.control_regs_default_vals[13]  =  DAC1_DECIMATION_RATIO_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[13]               = "dac1_decimation";
    assign raw_decimation_ratio[1] = uart_regfile_interface_pins.control[13];
    assign uart_regfile_interface_pins.control_regs_bitwidth[13]      = NUM_BITS_DECIMATION_COUNTER;	
	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[14]  =  0;
    assign uart_regfile_interface_pins.control_desc[14]               = "StreamToMemCtrl";
    assign {sop_state_machine_reset,enable_packet_streaming_to_memory} = uart_regfile_interface_pins.control[14];
    assign uart_regfile_interface_pins.control_regs_bitwidth[14]      = 16;	
	
		
	assign uart_regfile_interface_pins.control_regs_default_vals[15]  =  DEFAULT_ACTUAL_NUM_OF_DATA_VALUES_TO_ACQUIRE;
    assign uart_regfile_interface_pins.control_desc[15]               = "actual_num_locs";
    assign actual_num_locations_in_fifo = uart_regfile_interface_pins.control[15];
    assign uart_regfile_interface_pins.control_regs_bitwidth[15]      = 32;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[16]  =  MEM_FILE_INDEX_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[16]               = "mem_file_index";
    //assign mem_file_index = uart_regfile_interface_pins.control[16];
    assign uart_regfile_interface_pins.control_regs_bitwidth[16]      = NUM_BITS_MEM_FILE_INDEX_REGISTER;	
	
    assign uart_regfile_interface_pins.control_regs_default_vals[17]  =  DEFAULT_CONST_TEST_DATA0;
    assign uart_regfile_interface_pins.control_desc[17]               = "const_test_data0";
    assign constant_test_data[0] = uart_regfile_interface_pins.control[17];
    assign uart_regfile_interface_pins.control_regs_bitwidth[17]      = in_data_bits;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[18]  =  DEFAULT_CONST_TEST_DATA1;
    assign uart_regfile_interface_pins.control_desc[18]               = "const_test_data1";
    assign constant_test_data[1] = uart_regfile_interface_pins.control[18];
    assign uart_regfile_interface_pins.control_regs_bitwidth[18]      = in_data_bits;	
	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[19]  =  DECIMATION_CONTROL_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[19]               = "decimation_ctrl";
    assign select_external_decimation_ratio = uart_regfile_interface_pins.control[19];
    assign uart_regfile_interface_pins.control_regs_bitwidth[19]      = 1;	
	
	
	
	assign uart_regfile_interface_pins.status[0] = fifo_acquiring_now_as_part_of_general_acquire;
	assign uart_regfile_interface_pins.status_desc[0]    ="AcqAsPartOfGen";	
	
	assign uart_regfile_interface_pins.status[1] = in_port_to_the_GP_FIFO_Flags[0];
	assign uart_regfile_interface_pins.status_desc[1]    ="fifo0Flags";
	
	assign uart_regfile_interface_pins.status[2] = in_port_to_the_GP_FIFO_Flags[1];
	assign uart_regfile_interface_pins.status_desc[2]    ="fifo1Flags";
	
	assign uart_regfile_interface_pins.status[3] = q_from_the_GP_FIFO[0];
	 assign uart_regfile_interface_pins.status_desc[3]    ="fifo0q";
		
    assign uart_regfile_interface_pins.status[4] = q_from_the_GP_FIFO[1];
	 assign uart_regfile_interface_pins.status_desc[4]    ="fifo1q";
	
    assign uart_regfile_interface_pins.status[5] = {nios_dac_pins.get_num_selection_bits(),in_data_bits};
	 assign uart_regfile_interface_pins.status_desc[5]    ="in_data_bits";
	
    assign uart_regfile_interface_pins.status[6] = {nios_dac_pins.get_actual_num_selections(),out_data_bits};
	 assign uart_regfile_interface_pins.status_desc[6]    ="out_data_bits";
	
    assign uart_regfile_interface_pins.status[7] = {ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS,num_words_bits};
	 assign uart_regfile_interface_pins.status_desc[7]    ="num_words_bits";
	 
    assign uart_regfile_interface_pins.status[8] = {
	                                               /* 25 */  USE_ONLY_CLOCK_0_FOR_DATA_CLOCKS,
	                                               /* 24 */  ENABLE_STREAMING_TO_EXTERNAL_MEMORY,
	                                              /*23:22*/  lower_2_bits_NIOS_DAC_FIFO_IS_DUMMY,
	                                             /*21 */     USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS,
												/* 20:19 */  lower_2_bits_HW_Trigger_Has_Happened,
	                                             /* 18 */    COMPILE_TEST_SIGNAL_DDS,
	                                             /* 17 */    ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION,
	                                             /* 16 */    ENABLE_HW_TRIGGER_INTERFACE,
												/*15:8 */	 NUM_OF_NIOS_DACS,
	                                            /* 7:0 */    TEST_SIGNAL_DDS_NUM_PHASE_BITS};
	 assign uart_regfile_interface_pins.status_desc[8]    ="TestDDSParams";
	 
	 generate
			 if (SUPPORT_INPUT_DESCRIPTIONS)
			 begin
						 assign uart_regfile_interface_pins.status[9] = nios_dac_pins.dac_descriptions[0][nios_dac_pins.select_channel_to_dac[0]][127 -: 32];
						 assign uart_regfile_interface_pins.status_desc[9]    ="ChanDesc0_127_96";
						 assign uart_regfile_interface_pins.status[10] = nios_dac_pins.dac_descriptions[0][nios_dac_pins.select_channel_to_dac[0]][95 -: 32];
						 assign uart_regfile_interface_pins.status_desc[10]    ="ChanDesc0_95_64";
						 assign uart_regfile_interface_pins.status[11] = nios_dac_pins.dac_descriptions[0][nios_dac_pins.select_channel_to_dac[0]][63 -: 32];
						 assign uart_regfile_interface_pins.status_desc[11]    ="ChanDesc0_63_32";
						 assign uart_regfile_interface_pins.status[12] = nios_dac_pins.dac_descriptions[0][nios_dac_pins.select_channel_to_dac[0]][31 -: 32];
						 assign uart_regfile_interface_pins.status_desc[12]    ="ChanDesc0_31_0";

						 assign uart_regfile_interface_pins.status[13] = nios_dac_pins.dac_descriptions[1][nios_dac_pins.select_channel_to_dac[1]][127 -: 32];
						 assign uart_regfile_interface_pins.status_desc[13]    ="ChanDesc1_127_96";
						 assign uart_regfile_interface_pins.status[14] = nios_dac_pins.dac_descriptions[1][nios_dac_pins.select_channel_to_dac[1]][95 -: 32];
						 assign uart_regfile_interface_pins.status_desc[14]    ="ChanDesc1_95_64";
						 assign uart_regfile_interface_pins.status[15] = nios_dac_pins.dac_descriptions[1][nios_dac_pins.select_channel_to_dac[1]][63 -: 32];
						 assign uart_regfile_interface_pins.status_desc[15]    ="ChanDesc1_63_32";
						 assign uart_regfile_interface_pins.status[16] = nios_dac_pins.dac_descriptions[1][nios_dac_pins.select_channel_to_dac[1]][31 -: 32];
						 assign uart_regfile_interface_pins.status_desc[16]    ="ChanDesc1_31_0";
			 end
	 endgenerate
	 generate
	            if (ENABLE_STREAMING_TO_EXTERNAL_MEMORY)						  
				begin
								assign uart_regfile_interface_pins.status[17] =packet_in_progress;
								assign uart_regfile_interface_pins.status_desc[17]    ="packet_in_prog";
								
								if (!USE_ONLY_CLOCK_0_FOR_DATA_CLOCKS)
								begin
								     assign uart_regfile_interface_pins.status[18] =	synced_packet_word_counter[0];
								     assign uart_regfile_interface_pins.status_desc[18] = "packet_word_cnt";	

                                    assign uart_regfile_interface_pins.status[20] =	synced_packet_counter[0];
								    assign uart_regfile_interface_pins.status_desc[20] = "packet_cnt";									
								end else
								begin								    
									assign uart_regfile_interface_pins.status[18] =	synced_packet_word_counter[0];
									assign uart_regfile_interface_pins.status_desc[18] = "packet_word_cnt0";
									
									assign uart_regfile_interface_pins.status[19] =	synced_packet_word_counter[1];
									assign uart_regfile_interface_pins.status_desc[19] = "packet_word_cnt1";
									
									assign uart_regfile_interface_pins.status[20] =	synced_packet_counter[0];
								    assign uart_regfile_interface_pins.status_desc[20] = "packet_cnt0";
									
									assign uart_regfile_interface_pins.status[21] =	synced_packet_counter[1];
								    assign uart_regfile_interface_pins.status_desc[21] = "packet_cnt1";
								end							
				end
	endgenerate

	assign uart_regfile_interface_pins.status[22] =	clock_crossed_registered_selected_data[0];
	assign uart_regfile_interface_pins.status_desc[22] = "data_in0";
	
	assign uart_regfile_interface_pins.status[23] =	clock_crossed_registered_selected_data[1];
	assign uart_regfile_interface_pins.status_desc[23] = "data_in1";
	
	assign uart_regfile_interface_pins.status[24] =	alive_cnt[0];
	assign uart_regfile_interface_pins.status_desc[24] = "alive_cnt0";
	
    assign uart_regfile_interface_pins.status[25] =	alive_cnt[1];
	assign uart_regfile_interface_pins.status_desc[25] = "alive_cnt1";
		
	assign uart_regfile_interface_pins.status[26] =	synced_last_packet_word_count[0];
	assign uart_regfile_interface_pins.status_desc[26] = "last_pkt_wrds0";
	
    assign uart_regfile_interface_pins.status[27] =	synced_last_packet_word_count[1];
	assign uart_regfile_interface_pins.status_desc[27] = "last_pkt_wrds1";

	assign uart_regfile_interface_pins.status[28] =	clock_crossed_state[0];
	assign uart_regfile_interface_pins.status_desc[28] = "state0";
	
	assign uart_regfile_interface_pins.status[29] =	clock_crossed_state[1];
	assign uart_regfile_interface_pins.status_desc[29] = "state1";
		
	assign uart_regfile_interface_pins.status[30] =	measured_time_between_triggers[0];
	assign uart_regfile_interface_pins.status_desc[30] = "time_btween_trig";
			/*
	assign uart_regfile_interface_pins.status[31] =	decimation_ratio[0];
	assign uart_regfile_interface_pins.status_desc[31] = "actual_dec_ratio";
	*/
 endmodule
 `default_nettype wire
 