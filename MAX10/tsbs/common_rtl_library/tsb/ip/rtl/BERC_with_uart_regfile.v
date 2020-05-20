
module BERC_with_uart_regfile
#(
parameter [47:0] BERC_bits_to_count_default = 48'd10000, 
parameter [47:0] BERC_initial_throwaway_limit_default = BERC_bits_to_count_default/8,
parameter frame_width = 10,
parameter number_of_inwidths_in_corr_length = 6,
parameter Parallel_BERC_input_width = 10,
parameter [31:0] BERC_Gone_Into_Lock_Threshold_default = (number_of_inwidths_in_corr_length-1)*Parallel_BERC_input_width*14/16,
parameter [31:0] BERC_Gone_Out_of_Lock_Threshold_default = (number_of_inwidths_in_corr_length-1)*Parallel_BERC_input_width*11/16,
parameter corr_phases_input_width = frame_width,
parameter [15:0] corr_reg_length = number_of_inwidths_in_corr_length*Parallel_BERC_input_width,
parameter corr_count_bits = 8,
parameter bit_count_reg_width = 32,
parameter default_offset_of_BERC_error_measurment = 0,
parameter use_default_offset_of_BERC_error_measurment = 1,
parameter CLOCK_SPEED_IN_HZ = 50000000,
parameter UART_BAUD_RATE_IN_HZ = 115200,
parameter [15:0] Output_DATA_CAPTURE_FIFO_WIDTH = 16,
parameter [7:0] Num_of_input_channels = 1,
parameter [7:0] Default_Channel = 0,
parameter transpose_refseq_default = 1,
parameter transpose_inseq_default = 1,
parameter try_align_default = 1,
parameter ref_data_source_default = 0,
parameter frame_wait_between_aligns_default = 15,
parameter [0:0] USE_MINIMALIST_REGFILES             = 0,
parameter [0:0] USE_MINIMALIST_REGFILE_DESCRIPTIONS = 0,
parameter [0:0] USE_INCREASING_INDICES_INPUT_DATA_ARRAY = 0,
parameter [0:0] ENABLE_BERC_PN_SEQUENCE_FUNCTIONALITY = 0,
parameter synchronizer_depth = 3,
parameter ENABLE_KEEPS = 0

)
( 
 input  sm_clk,
 input  frame_in_clk,
 input  [frame_width-1:0] frame_in_data[Num_of_input_channels-1:0],
 input  [frame_width-1:0] frame_in_data_increasing_indices[Num_of_input_channels],
 output request_adc_realign,
 output [Output_DATA_CAPTURE_FIFO_WIDTH-1:0] data_to_the_Output_Signal_Capture_FIFO,
 output wrclk_to_the_Output_Signal_Capture_FIFO,
 input [Parallel_BERC_input_width-1:0] external_ref_sequence_from_pattern_RAM,    
 input [Parallel_BERC_input_width-1:0] pattern_to_output_for_atrophied_generation,
 input [frame_width-1:0]               info_only_base_frame_pattern_to_output_for_atrophied_generation,
 input [127:0] DISPLAY_NAME,
 output logic [$clog2(frame_width)-1:0] frame_select_offset,
 input disable_realign_adc_request,
  output logic [$clog2(Num_of_input_channels)-1:0] chosen_frame_channel_index,
 input rxd,
 output txd,
 input wire [7:0] NUM_SECONDARY_UARTS,
 input wire [7:0] ADDRESS_OF_THIS_UART,
 input wire IS_SECONDARY_UART,
 output wire [7:0] NUM_OF_UARTS_HERE 
);

`ifdef SOFTWARE_IS_QUARTUS
import uart_regfile_types::*;
`else
`include "uart_regfile_types.v"
`endif

//`define keep 
`define keep (* keep = 1, preserve = 1 *) 

assign NUM_OF_UARTS_HERE = 1;

	function automatic int log2 (input int n);
						if (n <=1) return 1; // abort function
						log2 = 0;
						while (n > 1) begin
						n = n/2;
						log2++;
						end
						endfunction
						
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [Parallel_BERC_input_width-1:0] actual_BERC_current_compared_bit;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [Parallel_BERC_input_width-1:0] actual_BERC_current_bit_is_error;	
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [corr_count_bits-1:0]           BERC_in_lock_phase;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [corr_count_bits-1:0]           BERC_in_lock_current_max_correlation;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                                 BERC_Parallel_LFSR_finish;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                                 raw_BERC_Parallel_LFSR_finish;
 	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  								BERC_new_output_bit_is_ready;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [bit_count_reg_width-1:0] BERC_initial_throwaway_limit;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [bit_count_reg_width-1:0] BERC_bits_to_count;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [corr_reg_length-1:0]     input_bits_reg; 
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [corr_reg_length-1:0]     ref_bits_reg; 
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  BERC_done_with_initial_buffer;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [Parallel_BERC_input_width-1:0] raw_BERC_coded_input_seq_bit_in, BERC_coded_input_seq_bit_in,  BERC_actual_bit_input_to_correlate;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [Parallel_BERC_input_width*corr_count_bits-1:0] BERC_current_corr;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [Parallel_BERC_input_width:0]        BERC_gone_into_lock_phases;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire raw_BERC_indata_clk;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire BERC_indata_clk;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire BERC_ref_data_clk;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire BERC_corr_output_reg_clk;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire reset_ber_meter;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire active_high_BERC_RESET_signal;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire   BERC_reset;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire 								BERC_is_locked;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [31:0] 						BERC_state;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [Parallel_BERC_input_width:0]        BERC_gone_out_of_lock_phases;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire 								BERC_error_count_ready;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)                     wire [31:0] BERC_Gone_Out_of_Lock_Threshold; 
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) 				 wire [31:0] BERC_Gone_Into_Lock_Threshold;
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [Parallel_BERC_input_width-1:0] BERC_raw_ref_seq_in, 
	                                        BERC_ref_seq_in, 
											BERC_input_seq_bit_in;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)   wire [7:0] choose_input_channel;

	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [31:0] offset_of_BERC_error_measurment;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [bit_count_reg_width-1:0] BERC_number_of_locked_values;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) reg [63:0] 							BERC_Measurement_Count = 0;
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [15:0] input_frames_to_wait_between_realigns;
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [7:0] DATA_SOURCE_CONTROL;
	 
	parameter [15:0] division_param_for_BERC_inclk_generation = (Parallel_BERC_input_width/frame_width/2)-1;
	wire raw_raw_BERC_indata_clk;
	wire transpose_BERC_ref_seq;
    wire transpose_BERC_inseq;
	wire try_to_align_correlation;	
	reg [31:0] bit_slip_requests = 0;
	wire extended_req_bit_slip;
	wire request_input_bit_slip;
	wire request_input_bit_slip_raw;
	wire BERC_error_count_ready_edge_detected;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  reg [63:0] total_cumulative_error_count;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  reg [63:0] cumulative_error_count_since_reset;	
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  reg [63:0] total_cumulative_bit_count;
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  reg [63:0] cumulative_bit_count_since_reset;
	
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [bit_count_reg_width-1:0] BERC_num_errors_detected;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [bit_count_reg_width-1:0] corr_init_counter;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire [bit_count_reg_width-1:0] num_bits_counted;
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  wire request_input_bit_slip_edge_detected;

	 
	 assign frame_select_offset =  BERC_in_lock_phase;
	 assign chosen_frame_channel_index = choose_input_channel;
	 
     integer i;
		 
	reg [frame_width-1:0] chosen_input_frame_data;
	
	generate 
				if (USE_INCREASING_INDICES_INPUT_DATA_ARRAY)
				begin
							always @(posedge frame_in_clk)
							begin
								 chosen_input_frame_data <= frame_in_data_increasing_indices[choose_input_channel];
							end

				end else
				begin
							always @(posedge frame_in_clk)
							begin
								 chosen_input_frame_data <= frame_in_data[choose_input_channel];
							end
				end
	endgenerate
	
	integer j;
	always @(posedge BERC_ref_data_clk)
	for (j=0; j<Parallel_BERC_input_width; j++)
	begin : transpose_BERC_raw_ref_seq_in
	     BERC_ref_seq_in[j] <= transpose_BERC_ref_seq ? BERC_raw_ref_seq_in[Parallel_BERC_input_width-j-1] : BERC_raw_ref_seq_in[j];
	end
	
	
	Divisor_frecuencia
	#(.Bits_counter(16))
	Generate_BERC_inclk
	 (	
	  .CLOCK(!frame_in_clk),
      .TIMER_OUT(raw_raw_BERC_indata_clk),
	  .Comparator(division_param_for_BERC_inclk_generation)
	 );
	
	generate
			if (Parallel_BERC_input_width == frame_width)
			begin
					 assign raw_raw_BERC_indata_clk = frame_in_clk;
					 assign raw_BERC_coded_input_seq_bit_in = chosen_input_frame_data;
			end else
			begin
					multibit_serial_to_parallel_with_clk_convert_and_downsampling
					 #(
					 .width(frame_width),
					 .SIZE(Parallel_BERC_input_width/frame_width),
					 .downsample_counter_width(8)
					 ) 
					Convert_to_parallel_input_of_BER_meter
					(
					.parallel_out(raw_BERC_coded_input_seq_bit_in), 
					.serial_in(chosen_input_frame_data), 
					.clock_in(frame_in_clk),
					.clock_out(raw_raw_BERC_indata_clk),
					.downsample_rate(1'b1)
					);	  
					
			end
	endgenerate
	
	logic start_parallel_bit_stream_generator_fast;
	logic [7:0] parallel_bit_stream_generator_fast_wait_count;
	
	
	parallel_bit_stream_generator_fast
	#(
	.output_width(Parallel_BERC_input_width)
	//	.log2_output_width(log2_Parallel_BERC_input_width)
	)
	Refseq_Parallel_bit_stream_generator_module_inst
	(
	.clk(sm_clk),
	.start(start_parallel_bit_stream_generator_fast),
	.out_bit_stream(BERC_raw_ref_seq_in),
	.sel_output_bitstream(DATA_SOURCE_CONTROL),
	.external_sequence(external_ref_sequence_from_pattern_RAM),
	.do_not_transpose_output_data(0),
	.reset(0),
	.wait_count(parallel_bit_stream_generator_fast_wait_count),
	.pattern_to_output_for_atrophied_generation(pattern_to_output_for_atrophied_generation),
	.finish(raw_BERC_Parallel_LFSR_finish)
	);
			
	
    edge_detector 
	make_start_parallel_bit_stream_generator_fast
	(
	 .insignal (BERC_ref_data_clk), 
	 .outsignal(start_parallel_bit_stream_generator_fast), 
	 .clk      (sm_clk)
	);
	
	assign BERC_Parallel_LFSR_finish = raw_BERC_Parallel_LFSR_finish;
	
	/*
async_trap_and_reset_gen_1_pulse_robust 
 make_BERC_Parallel_LFSR_finish
 (
 .async_sig(raw_BERC_Parallel_LFSR_finish), 
 .outclk(sm_clk), 
 .out_sync_sig(BERC_Parallel_LFSR_finish), 
 .auto_reset(1'b1), 
 .reset(1'b1)
 );
 */
 
	
    assign 	BERC_coded_input_seq_bit_in = raw_BERC_coded_input_seq_bit_in;
    assign  raw_BERC_indata_clk = raw_raw_BERC_indata_clk;

edge_detector 
error_count_read_edge_detector
(
 .insignal (BERC_error_count_ready), 
 .outsignal(BERC_error_count_ready_edge_detected), 
 .clk      (sm_clk)
);
	
	
   always @ (posedge raw_BERC_indata_clk)
   begin
        BERC_actual_bit_input_to_correlate <= BERC_coded_input_seq_bit_in;
   end
  
 
	 always @ (posedge sm_clk)
	 begin
	     if (BERC_error_count_ready_edge_detected)
		 begin
	 	      BERC_Measurement_Count <= BERC_Measurement_Count + 1;
		 end
	 end	 
	 
	 always @ (posedge sm_clk)
	 begin 
	      if (BERC_error_count_ready_edge_detected)
		  begin
	           total_cumulative_error_count <= total_cumulative_error_count + BERC_num_errors_detected;
	           total_cumulative_bit_count <= total_cumulative_bit_count + BERC_bits_to_count;
		  end
	 end
		 
	 always @ (posedge sm_clk or posedge active_high_BERC_RESET_signal)
	 begin 
	       if (active_high_BERC_RESET_signal)
		   begin
		         cumulative_error_count_since_reset <= 0;
		         cumulative_bit_count_since_reset <= 0;
		   end else
		   begin
		        if (BERC_error_count_ready_edge_detected)
				begin
	              cumulative_error_count_since_reset <= cumulative_error_count_since_reset + BERC_num_errors_detected;
	              cumulative_bit_count_since_reset <= cumulative_bit_count_since_reset + BERC_bits_to_count;
				end
		   end
	 end
		 

	 wire auto_reset, actual_reset_ber_meter;

	generate_one_shot_pulse 
	#(.num_clks_to_wait(2))  
	generate_auto_reset
	(
	.clk(sm_clk), 
	.oneshot_pulse(auto_reset)
	);		 
		 
		 
	assign actual_reset_ber_meter = reset_ber_meter || auto_reset;
		 
	 async_trap_and_reset make_BERC_reset_signal(
					 .async_sig(actual_reset_ber_meter),
					 .outclk(~sm_clk), 
					 .out_sync_sig(active_high_BERC_RESET_signal), 				  
					 .auto_reset(1'b1), 
					 .reset(1'b1));
						
				
	 assign BERC_reset                = ~active_high_BERC_RESET_signal;

	
	assign BERC_indata_clk = raw_BERC_indata_clk;
	
    always @(posedge BERC_indata_clk)
    for (i=0; i<Parallel_BERC_input_width; i++)
    begin 
    	 BERC_input_seq_bit_in[i] <=  transpose_BERC_inseq ? BERC_actual_bit_input_to_correlate[Parallel_BERC_input_width-i-1] : BERC_actual_bit_input_to_correlate[i];
    end

	
	async_trap_and_reset 
	make_extended_req_bit_slip
	(
	.async_sig(request_input_bit_slip), 
	.outclk(frame_in_clk), 
	.out_sync_sig(extended_req_bit_slip), 
	.auto_reset(1'b1), 
	.reset(1'b1)
	);

	assign request_adc_realign = extended_req_bit_slip;
	
	
	edge_detector 
	request_input_bit_slip_edge_detector
	(
	 .insignal (request_input_bit_slip), 
	 .outsignal(request_input_bit_slip_edge_detected), 
	 .clk      (sm_clk)
	);
	
	
	always @(posedge sm_clk or negedge BERC_reset)
    begin	
	      if (!BERC_reset)
		  begin
		       bit_slip_requests <= 0;
		  end else
		  begin
		        if (request_input_bit_slip_edge_detected)
				begin
	                 bit_slip_requests <= bit_slip_requests + 1;
				end
		  end
	end
	
	
	parallel_dual_corr_ber_controller
	#(
	.input_width(Parallel_BERC_input_width),
	.corr_phases_input_width(corr_phases_input_width),
	.number_of_inwidths_in_corr_length(number_of_inwidths_in_corr_length),
	.corr_count_bits(corr_count_bits),
	.bit_count_reg_width(bit_count_reg_width),
	.compile_dual_corr(0),
	.use_default_offset_of_BERC_error_measurment(use_default_offset_of_BERC_error_measurment),
	.default_offset_of_BERC_error_measurment(default_offset_of_BERC_error_measurment),

	//dummy parameters
	.frame_delay_to_aux_corr(0),
	.aux_corr_delay_extract_tap_every(8),
    .aux_corr_log2_num_of_extract_taps(4)
	)
	Parallel_Corr_BER_Controller_inst
	(
		.enabled(1'b1),
		.is_locked(BERC_is_locked),
		.sm_clk(sm_clk),
		.Gone_Into_Lock_Threshold(BERC_Gone_Into_Lock_Threshold),
		.Gone_Out_of_Lock_Threshold(BERC_Gone_Out_of_Lock_Threshold),
		//.aux_Gone_Into_Lock_Threshold(aux_BERC_Gone_Into_Lock_Threshold),
		//.aux_Gone_Out_of_Lock_Threshold(aux_BERC_Gone_Out_of_Lock_Threshold),
		.reset(BERC_reset),
		.indata_clk(BERC_indata_clk),
		.input_seq_bit_in(BERC_input_seq_bit_in),
		.ref_seq_in(BERC_ref_seq_in),
		.ref_data_clk(BERC_ref_data_clk),
		.corr_output_reg_clk(BERC_corr_output_reg_clk),
		.current_corr(BERC_current_corr),
		.num_errors_detected(BERC_num_errors_detected),
		.number_of_locked_values(BERC_number_of_locked_values),
		.bits_to_count(BERC_bits_to_count),
		.error_count_ready(BERC_error_count_ready),
		.state(BERC_state),
		.input_bits_reg(input_bits_reg),
		.ref_bits_reg(ref_bits_reg),
		.gone_into_lock_phases(BERC_gone_into_lock_phases),
		.gone_out_of_lock_phases(BERC_gone_out_of_lock_phases),
		//.correlation_phases_count(correlation_phases_count),
		//.current_max_corr(current_max_corr),
		//.current_max_corr_index(current_max_corr_index),
		.regd_current_frame_error_count (actual_BERC_current_bit_is_error),
		.regd_current_compared_bits		(actual_BERC_current_compared_bit),	
		.in_lock_phase(BERC_in_lock_phase),
		.in_lock_current_max_correlation(BERC_in_lock_current_max_correlation),
		.ref_data_ready(BERC_Parallel_LFSR_finish),
		.new_output_bit_is_ready(BERC_new_output_bit_is_ready),
		.initial_throwaway_limit(BERC_initial_throwaway_limit),
		.done_with_initial_buffer(BERC_done_with_initial_buffer),
		.enable_dual_corr(1'b0),
		.select_aux_corr_delay(1'b0),
		.enable_conservative_lock_phase_switching(1'b0),
		.fix_aux_correlator_phase(1'b0),
		.offset_of_error_counting_subrange(offset_of_BERC_error_measurment),
		.disable_lock_detection(1'b0),
		.request_input_bit_slip(request_input_bit_slip_raw),
		.try_to_align_correlation(try_to_align_correlation),
		.input_frames_to_wait_between_realigns(input_frames_to_wait_between_realigns),
		.corr_init_counter(corr_init_counter),
		.num_bits_counted(num_bits_counted)
	);	
	
	assign request_input_bit_slip = disable_realign_adc_request ? 0 : request_input_bit_slip_raw;
		
    /////////////////// Output Signal Capture FIFO ///////////////////////
	assign data_to_the_Output_Signal_Capture_FIFO = BERC_input_seq_bit_in;
	assign wrclk_to_the_Output_Signal_Capture_FIFO = BERC_indata_clk;
    /////////////////////////////////////////////////////////////////////
	
	//==========================================================================================================
	//
	// Register File
	//
	//==========================================================================================================
	
	 parameter regfile_data_numbytes        =    8;
	 parameter regfile_data_width           =    8*regfile_data_numbytes;
	 parameter regfile_desc_numbytes        =    16;
	 parameter regfile_desc_width           =    8*regfile_desc_numbytes;
	 parameter num_of_regfile_control_regs  =   16;
	 parameter num_of_regfile_status_regs   =   32;
			
	 wire [3:0] regfile_main_sm;
	 wire [2:0] regfile_tx_sm;
	 wire [7:0] regfile_command_count;
			
	 wire [regfile_data_width-1:0] regfile_control_regs_default_vals[num_of_regfile_control_regs-1:0];
	 wire [regfile_data_width-1:0] regfile_control[num_of_regfile_control_regs-1:0];
	 wire [regfile_data_width-1:0] regfile_control_bitwidth[num_of_regfile_control_regs-1:0];
	 wire [regfile_data_width-1:0] regfile_status[num_of_regfile_status_regs-1:0];
	 wire [regfile_desc_width-1:0] regfile_control_desc[num_of_regfile_control_regs-1:0];
	 wire [regfile_desc_width-1:0] regfile_status_desc [num_of_regfile_status_regs-1:0];
		
	 	
	 // Experimental UART
				

	 //Regfile CONTROL
	 assign regfile_control_desc[0] = "REGALIVE";
	 assign regfile_control_regs_default_vals[0]  =  64'hfedcba9876543210;
	 assign regfile_control_bitwidth[0] = 64;
	 
	 assign regfile_control_desc[1] = "Try_Align";
	 assign regfile_control_regs_default_vals[1]  =  try_align_default;
     assign try_to_align_correlation = regfile_control[1][0];
 	 assign regfile_control_bitwidth[1] = 1;

	 
	 assign regfile_control_desc[2] = "Transpose RefSeq";
	 assign regfile_control_regs_default_vals[2]  =  transpose_refseq_default;
     assign transpose_BERC_ref_seq = regfile_control[2][0];
	 assign regfile_control_bitwidth[2] = 1;
	 
	 
	 assign regfile_control_desc[3] = "Transpose InSeq";
	 assign regfile_control_regs_default_vals[3]  =  transpose_inseq_default;
     assign transpose_BERC_inseq = regfile_control[3][0];
	 assign regfile_control_bitwidth[3] = 1;
	 
	 assign regfile_control_desc[4] = "offset error cnt";
	 assign regfile_control_regs_default_vals[4]  =  default_offset_of_BERC_error_measurment;
     assign offset_of_BERC_error_measurment = regfile_control[4];
	 assign regfile_control_bitwidth[4] = 16;

	 	 
	 assign regfile_control_desc[5] = "frms_wait_align";
	 assign regfile_control_regs_default_vals[5]  =  frame_wait_between_aligns_default;
     assign input_frames_to_wait_between_realigns = regfile_control[5];	 
	 assign regfile_control_bitwidth[5] = 16;

	 
	 assign regfile_control_desc[6]               = "BitsToCnt";
	 assign regfile_control_regs_default_vals[6]  =  BERC_bits_to_count_default;
     assign BERC_bits_to_count                    = regfile_control[6];
 	 assign regfile_control_bitwidth[6]           = $size(BERC_bits_to_count);
	 
	 assign  regfile_control_desc[8]               = "throwawayNumbits";
	 assign  regfile_control_regs_default_vals[8]  =  BERC_initial_throwaway_limit_default;
     assign  BERC_initial_throwaway_limit          = regfile_control[8];
	 assign regfile_control_bitwidth[8]           = $size(BERC_initial_throwaway_limit);
	 	 
	 assign regfile_control_desc[10] = "IntoLckThr";
	 assign regfile_control_regs_default_vals[10]  =  BERC_Gone_Into_Lock_Threshold_default;
     assign BERC_Gone_Into_Lock_Threshold = regfile_control[10];
	  assign regfile_control_bitwidth[10]  = 32;
	 
	 assign regfile_control_desc[11] = "OutLckThr";
	 assign regfile_control_regs_default_vals[11] =  BERC_Gone_Out_of_Lock_Threshold_default;
     assign BERC_Gone_Out_of_Lock_Threshold =  regfile_control[11];
	 
	 
	 assign regfile_control_desc[12] = "ResetBerMeter";
	 assign regfile_control_regs_default_vals[12] =  0;
     assign reset_ber_meter =  regfile_control[12];
	 assign regfile_control_bitwidth[12] = 1;	
	 
	 assign regfile_control_desc[13] = "RefDataSrc";
	 assign regfile_control_regs_default_vals[13] =  ref_data_source_default;
     assign DATA_SOURCE_CONTROL =  regfile_control[13][7:0];
	 assign regfile_control_bitwidth[13] = 8;
	 
	 assign regfile_control_desc[14] = "InputChanSel";
	 assign regfile_control_regs_default_vals[14] =  Default_Channel;
     assign choose_input_channel =  regfile_control[14][7:0];
	 assign regfile_control_bitwidth[14] = 8;
	 
	 assign regfile_control_desc[15] = "wait_cnt";
	 assign regfile_control_regs_default_vals[15] =  8;
     assign parallel_bit_stream_generator_fast_wait_count =  regfile_control[15];
	 assign regfile_control_bitwidth[15] = 8;
	 
	 
	 //Regfile Status
	 assign regfile_status_desc[0] = "Into Lock THR";
	 assign regfile_status[0] = BERC_Gone_Into_Lock_Threshold;
	 	 
	 assign regfile_status_desc[1] = "Out of Lock THR";
	 assign regfile_status[1] = BERC_Gone_Out_of_Lock_Threshold;
	 
     assign regfile_status_desc[2] = "RefSeq";
	 assign regfile_status[2] = BERC_ref_seq_in;
	 	 					
     assign regfile_status_desc[3] = "Current Corr";
	 assign regfile_status[3] = BERC_current_corr;
		
     assign regfile_status_desc[4] = "InLckPhses";
	 assign regfile_status[4] = BERC_gone_into_lock_phases;
	 					
     assign regfile_status_desc[5] = "OutLckPhses";
	 assign regfile_status[5] = BERC_gone_out_of_lock_phases;	 	
		
     assign regfile_status_desc[6] = "InLckPhase";
	 assign regfile_status[6] = BERC_in_lock_phase;
	 										
     assign regfile_status_desc[7] = "InLckMaxCorr";
	 assign regfile_status[7] = BERC_in_lock_current_max_correlation;
	 					
     assign regfile_status_desc[8] = "OutLckPhs";
	 assign regfile_status[8] = BERC_gone_out_of_lock_phases;
	 					 	
     assign regfile_status_desc[9] = "req_inp_bit_slip";
	 assign regfile_status[9] = request_input_bit_slip;
	 					 			 					 	
     assign regfile_status_desc[10] = "bit_slip_requests";
	 assign regfile_status[10] = bit_slip_requests;
	 					 	
     assign regfile_status_desc[11] = "BERC_state";
	 assign regfile_status[11] = BERC_state;
	 	
	 assign regfile_status_desc[12] = "curr_comp_bits";
	 assign regfile_status[12]      = actual_BERC_current_compared_bit;		
	     			
     assign regfile_status_desc[13] = "inbtsreg";
	 assign regfile_status[13] = input_bits_reg;
	 	
     assign regfile_status_desc[14] = "curr_frame_error_cnt";
	 assign regfile_status[14]     = actual_BERC_current_bit_is_error;		
	 						
     assign regfile_status_desc[15] = "refbtsreg";
	 assign regfile_status[15] = ref_bits_reg;
	 		
	 assign regfile_status_desc[16] = "BERMeasCnt";
	 assign regfile_status[16] = BERC_Measurement_Count;
	 		
     assign regfile_status_desc[17] = "BERNumErrs";
	 assign regfile_status[17] = BERC_num_errors_detected;
								
     assign regfile_status_desc[18] = "BERCisLocked";
	 assign regfile_status[18] = BERC_is_locked;
	 		
     assign regfile_status_desc[19] = "BERNumLckd";
	 assign regfile_status[19] = BERC_number_of_locked_values;
	 
     assign regfile_status_desc[20] = "ErrCountSinceRST";
	 assign regfile_status[20] = cumulative_error_count_since_reset;
	 
     assign regfile_status_desc[21] = "TotalCumulErrCnt";
	 assign regfile_status[21] = total_cumulative_error_count;
	 		  			
     assign regfile_status_desc[22] = "NumInputChannels";
	 assign regfile_status[22] = Num_of_input_channels;
	 		  			
     assign regfile_status_desc[23] = "frame_width";
	 assign regfile_status[23] = frame_width;
	 		  			
     assign regfile_status_desc[24] = "InWidth";
	 assign regfile_status[24] = Parallel_BERC_input_width;
	 		  									
     assign regfile_status_desc[25] = "NumWidthsInCorr";
	 assign regfile_status[25] = number_of_inwidths_in_corr_length;
	 		  			
	 assign regfile_status_desc[26] = "BaseFrmRefPatt";
	 assign regfile_status[26] = info_only_base_frame_pattern_to_output_for_atrophied_generation;
	 		
     assign regfile_status_desc[27] = "BitCountSinceRST";
	 assign regfile_status[27] = cumulative_bit_count_since_reset;
	 
     assign regfile_status_desc[28] = "TotalCumulBitCnt";
	 assign regfile_status[28] = total_cumulative_bit_count;
	 		  			  			
							 
     assign regfile_status_desc[29] = "corr_init_counter";
	 assign regfile_status[29] = corr_init_counter;
	 		  			  			
												 
     assign regfile_status_desc[30] = "num_bits_counted";
	 assign regfile_status[30] = num_bits_counted;
	 		  			  			
						
						
     wire regfile_control_rd_error;
	 wire regfile_control_async_reset = 1'b0;
	 wire regfile_control_wr_error;
	 wire regfile_control_transaction_error;
			
		uart_controlled_register_file_ver3
		#( 
		  .NUM_OF_CONTROL_REGS  (num_of_regfile_control_regs),
		  .NUM_OF_STATUS_REGS   (num_of_regfile_status_regs),
		  .DATA_WIDTH_IN_BYTES  (regfile_data_numbytes),
		  .DESC_WIDTH_IN_BYTES  (regfile_desc_numbytes),
		  .INIT_ALL_CONTROL_REGS_TO_DEFAULT (1'b0),  
		  .CONTROL_REGS_DEFAULT_VAL         (0),
		  .CLOCK_SPEED_IN_HZ(CLOCK_SPEED_IN_HZ),
          .UART_BAUD_RATE_IN_HZ(UART_BAUD_RATE_IN_HZ)
		)
		BERC_Control_Regfile
		(	
		 .CLK              (sm_clk),
		 .REG_ACTIVE_HIGH_ASYNC_RESET(regfile_control_async_reset),
		 .CONTROL          (regfile_control),
		 .STATUS           (regfile_status),
		 .CONTROL_INIT_VAL (regfile_control_regs_default_vals),
		 .CONTROL_DESC     (regfile_control_desc),
		 .CONTROL_BITWIDTH (regfile_control_bitwidth),
		 .STATUS_DESC      (regfile_status_desc),
		 .TRANSACTION_ERROR(regfile_control_transaction_error),
		 .WR_ERROR         (regfile_control_wr_error),
		 .RD_ERROR         (regfile_control_rd_error),
		 .DISPLAY_NAME     (DISPLAY_NAME),
		 
`ifdef SOFTWARE_IS_QUARTUS
   .USER_TYPE        (uart_regfile_types::BERC_CTRL_UART_REGFILE),
`else
   .USER_TYPE        (BERC_CTRL_UART_REGFILE),
`endif
      
		 
		 //UART
		 .uart_active_high_async_reset(1'b0),
		 .rxd(rxd),
		 .txd(txd),
		 
		 .NUM_SECONDARY_UARTS   (NUM_SECONDARY_UARTS  ),
         .ADDRESS_OF_THIS_UART  (ADDRESS_OF_THIS_UART ),
         .IS_SECONDARY_UART     (IS_SECONDARY_UART    ),
		 
		 //UART DEBUG
		 .main_sm               (regfile_main_sm),
		 .tx_sm                 (regfile_tx_sm),
		 .command_count         (regfile_command_count)
		  
		);
		
endmodule
