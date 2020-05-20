//`default_nettype none
module parallel_dual_corr_ber_controller
#(
parameter input_width = 10,
parameter corr_phases_input_width = input_width,
parameter number_of_inwidths_in_corr_length = 6,
parameter corr_reg_length = number_of_inwidths_in_corr_length*input_width, 
parameter corr_count_bits = 8,
parameter bit_count_reg_width = 32,
parameter frame_delay_to_aux_corr = 32,
parameter effective_dual_corr_length = (number_of_inwidths_in_corr_length+frame_delay_to_aux_corr+number_of_inwidths_in_corr_length)*input_width,
parameter aux_corr_delay_extract_tap_every = 8,
parameter aux_corr_log2_num_of_extract_taps = 3,
parameter compile_dual_corr = 1,
parameter default_offset_of_BERC_error_measurment = 0,
parameter use_default_offset_of_BERC_error_measurment = 0,
parameter use_SR_latch_emulation = 0
)
						( 
						  enabled,
    		     		  is_locked,
			   		      sm_clk,
			   		      Gone_Into_Lock_Threshold,
			   		      Gone_Out_of_Lock_Threshold,
						  aux_Gone_Into_Lock_Threshold,
			   		      aux_Gone_Out_of_Lock_Threshold,
			   		      reset,
						  indata_clk,
						  input_seq_bit_in,
						  ref_seq_in,
						  ref_data_clk,
						  corr_output_reg_clk,
						  current_corr,
						  num_errors_detected,
						  number_of_locked_values,
						  bits_to_count,
						  error_count_ready,
						  state,
						  regd_current_frame_error_count,
                          regd_current_compared_bits,
                          new_output_bit_is_ready,
						  ref_bits_reg, input_bits_reg,
						  gone_into_lock_phases,
						  gone_out_of_lock_phases,
						  correlation_phases_count,
						  current_max_corr,
						  current_max_corr_index,
						  in_lock_phase,
						  in_lock_current_max_correlation,
						  current_frame_is_slip,
						  ref_data_ready,
						  slip_count,
                          previous_in_lock_phase,
						  initial_throwaway_limit,
                          done_with_initial_buffer,
						  enable_dual_corr,
						  aux_in_lock_current_max_correlation,
						  aux_input_bits_reg,
						  aux_ref_bits_reg,
						  aux_gone_into_lock_phases,
						  aux_gone_out_of_lock_phases,
						  aux_correlation_phases_count,
						  aux_current_max_corr,
						  aux_current_max_corr_index,
						  aux_in_lock_phase,
						  aux_current_corr,
						  delayed_current_ref_bit,
						  delayed_input_seq_bit_in,
						  select_aux_corr_delay,
						  enable_conservative_lock_phase_switching,
						  fix_aux_correlator_phase,
						  offset_of_error_counting_subrange,
						  disable_lock_detection,
						  request_input_bit_slip,
						  try_to_align_correlation,
						  input_frames_to_wait_between_realigns,
						  corr_init_counter,
						  num_bits_counted

			   		);
					

input enabled;
output is_locked;
input sm_clk;
input [corr_count_bits-1:0]  Gone_Into_Lock_Threshold;
input [corr_count_bits-1:0]  Gone_Out_of_Lock_Threshold;
input [corr_count_bits-1:0]  aux_Gone_Into_Lock_Threshold;
input [corr_count_bits-1:0]  aux_Gone_Out_of_Lock_Threshold;
input reset;
input indata_clk;
input [input_width-1:0] input_seq_bit_in /* synthesis keep */;
input [input_width-1:0] ref_seq_in /* synthesis keep */;
output corr_init_counter;
input ref_data_ready /* synthesis keep */;
output ref_data_clk /* synthesis keep */;
output corr_output_reg_clk /* synthesis keep */;
output [corr_count_bits*(input_width+1)-1:0] current_corr /* synthesis keep */;
output [corr_count_bits*(input_width+1)-1:0] aux_current_corr /* synthesis keep */;
output reg [bit_count_reg_width-1:0] num_errors_detected /* synthesis preserve */;
output reg [bit_count_reg_width-1:0] slip_count;
output reg [bit_count_reg_width-1:0] number_of_locked_values /* synthesis preserve */;
input [bit_count_reg_width-1:0] bits_to_count;
input [bit_count_reg_width-1:0] initial_throwaway_limit;
output error_count_ready /* synthesis keep */;
output [22:0] state /* synthesis keep */;
output reg [input_width-1:0] regd_current_frame_error_count /* synthesis preserve */;
output reg [input_width-1:0] regd_current_compared_bits /* synthesis preserve */;
output new_output_bit_is_ready /* synthesis keep */;
output wire [corr_reg_length-1:0] input_bits_reg /* synthesis keep */;
output wire [corr_reg_length-1:0] ref_bits_reg /* synthesis keep */;
output wire [corr_phases_input_width-1:0]     gone_into_lock_phases/* synthesis keep */;
output wire [corr_phases_input_width-1:0]     gone_out_of_lock_phases/* synthesis keep */;
output wire [corr_count_bits-1:0] correlation_phases_count[corr_phases_input_width-1:0]/* synthesis keep */;
output wire [corr_count_bits-1:0] current_max_corr[corr_phases_input_width-1:0]/* synthesis keep */;
output wire [corr_count_bits-1:0] current_max_corr_index[corr_phases_input_width-1:0] /* synthesis keep */;
output wire [corr_count_bits-1:0] in_lock_phase /* synthesis keep */;

output wire [corr_reg_length-1:0] aux_input_bits_reg /* synthesis keep */;
output wire [corr_reg_length-1:0] aux_ref_bits_reg /* synthesis keep */;
output wire [corr_phases_input_width-1:0]     aux_gone_into_lock_phases/* synthesis keep */;
output wire [corr_phases_input_width-1:0]     aux_gone_out_of_lock_phases/* synthesis keep */;
output wire [corr_count_bits-1:0] aux_correlation_phases_count[corr_phases_input_width-1:0]/* synthesis keep */;
output wire [corr_count_bits-1:0] aux_current_max_corr[corr_phases_input_width-1:0]/* synthesis keep */;
output wire [corr_count_bits-1:0] aux_current_max_corr_index[corr_phases_input_width-1:0] /* synthesis keep */;
output wire [corr_count_bits-1:0] aux_in_lock_phase /* synthesis keep */;

output reg [corr_count_bits-1:0] previous_in_lock_phase=0 /* synthesis preserve */;
output wire [corr_count_bits-1:0] in_lock_current_max_correlation /* synthesis keep */;
output wire [corr_count_bits-1:0] aux_in_lock_current_max_correlation /* synthesis keep */;
output reg  [input_width-1:0] delayed_current_ref_bit;
output reg  [input_width-1:0] delayed_input_seq_bit_in;
input [aux_corr_log2_num_of_extract_taps-1:0] select_aux_corr_delay;
output reg current_frame_is_slip = 0;
output done_with_initial_buffer /* synthesis keep */;
input enable_dual_corr;
input enable_conservative_lock_phase_switching;
input fix_aux_correlator_phase;
input [corr_count_bits-1:0] offset_of_error_counting_subrange;
output num_bits_counted;
			 
						reg [bit_count_reg_width-1:0] num_bits_counted, raw_slip_count, raw_number_of_locked_values, raw_num_errors_detected ;
						reg  [input_width-1:0] current_indata_bit, current_ref_bit;

						
						wire reset_data_trap_signal;
						reg [bit_count_reg_width-1:0] corr_init_counter;
						wire new_indata_ready;
						logic [corr_count_bits-1:0] current_frame_error_count;
						input disable_lock_detection;
						output wire request_input_bit_slip;
						input try_to_align_correlation;
						input wire [15:0] input_frames_to_wait_between_realigns;

						
						
//==============================================
//
// State Machine Definitions
//
//==============================================															   
                                                    //09876543210_98765_43210_9876_543210
parameter idle 					                  =		25'b00000_00000_00000_0000_000000;
parameter general_reset 		                  =		25'b00000_00010_10100_0001_000001;	
parameter get_ref_data_for_init_corr_reg          =		25'b00000_00000_00000_0000_000010;	
parameter one_more_val_into_corr_reg              =		25'b00000_00000_00001_0000_000011;
parameter refclk_symmetry_pre_wait_state0         =     25'b00000_00000_00001_0010_000100; //special - increases corr_init_counter
parameter refclk_symmetry_pre_wait_state1         =     25'b00000_00000_00001_0000_000101;
parameter refclk_symmetry_pre_wait_state2         =     25'b00000_00000_00001_0000_000110;
parameter refclk_symmetry_pre_wait_state3         =     25'b00000_00000_00001_0000_000111;
parameter refclk_symmetry_pre_wait_state4         =     25'b00000_00000_00001_0000_001000;
parameter check_finish_init_corr_reg              =		25'b00000_00000_00000_0000_001001;
parameter refclk_symmetry_wait_state0             =     25'b00000_00000_00000_0000_001010;
parameter refclk_symmetry_wait_state1             =     25'b00000_00000_00000_0000_001011;
parameter refclk_symmetry_wait_state2             =     25'b00000_00000_00000_0000_001100;
parameter refclk_symmetry_wait_state3             =     25'b00000_00000_00000_0000_001101;
parameter refclk_symmetry_wait_state4             =     25'b00000_00000_00000_0000_001110;
parameter wait_for_new_data_while_unlocked        =     25'b00000_00000_01000_0100_001111;
parameter before_update_correlation_output        =     25'b00000_00101_00000_0000_010000;
parameter update_correlation_output               =     25'b00000_00000_00010_0000_010001;
parameter check_for_lock      			          = 	25'b00010_00000_00000_0000_010010;
parameter check_realign_wait_counter              =     25'b00000_00000_00000_0000_011110;
parameter inc_realign_wait_counter                =     25'b01000_00000_00000_0000_100000;
parameter request_rx_align_data_while_locked      =     25'b00100_00000_00000_0000_100001;
parameter reset_realign_wait_counter              =     25'b10000_00000_00000_0000_100010;
parameter advance_corr_count                      =		25'b00000_00000_00010_0000_010011;
parameter advance_ref_data                        =		25'b00000_00000_00001_0000_010100;
parameter advance_ref_data_wait_state0            =		25'b00000_00000_00001_0000_010101;
parameter advance_ref_data_wait_state1            =		25'b00000_00000_00001_0000_010110;
parameter we_are_locked                           =		25'b00000_00000_00000_1000_010111;
parameter update_before_get_new_ref_data          =     25'b00000_00101_00000_0000_011000;
parameter get_new_ref_data                        =		25'b00000_00000_00010_0000_011001;
parameter wait_for_new_data_under_lock            =		25'b00000_00000_01000_0000_011010;
parameter write_results_to_output                 =     25'b00000_11000_00000_0000_011011;
parameter reset_bit_counter_state                 =     25'b00001_00010_10100_0000_011100;
			

reg [24:0] state = idle;



wire reset_corr_init_counter = state[6];
wire inc_corr_init_counter = state[7];
wire set_lock_state_to_0 = state[8];
wire set_lock_state_to_1 = state[9];
assign ref_data_clk = state[10];
assign corr_output_reg_clk = state[11];
wire reset_raw_number_of_locked_values = state[12];
wire inc_raw_number_of_locked_values = state[13];						  
wire reset_number_of_bits_counted = state[14];
wire inc_number_of_bits_counted = state[15];
wire reset_number_of_errors_counted = state[16];
wire inc_number_of_errors_counted = state[17];	
wire latch_num_errors_detected = state[18];
wire latch_num_locked_values = state[19];	
assign error_count_ready = state[20];						  
assign reset_data_trap_signal = ~state[21];
assign request_input_bit_slip = state[22];
wire inc_realign_request_wait_counter            = state[23];
wire realign_request_wait_counter_reset_internal = state[24];

logic currently_locked;


generate
		if (use_SR_latch_emulation)
		begin
			 SR_latch currently_locked_SR_Latch(.set(set_lock_state_to_1),.reset(set_lock_state_to_0),.q(currently_locked));
		end
		else
		begin		  
		     reg raw_currently_locked = 0; //use this because "logic" initial values are ignored for some reason
			 assign currently_locked = raw_currently_locked;
		      always_ff @(posedge sm_clk or negedge reset)			 
			  begin
			       if (~reset)
				   begin
				        raw_currently_locked <= 0;
				   end else
				   begin
				        case ({set_lock_state_to_1,set_lock_state_to_0})
						2'b00 : raw_currently_locked <= raw_currently_locked;
						2'b01 : raw_currently_locked <= 0;
						2'b10 : raw_currently_locked <= 1;
						2'b11 : raw_currently_locked <= 0; //reset beats set
						endcase				   
				   end			  			  
			  end
		end
endgenerate

reg [15:0] realign_request_wait_counter = 0;

wire realign_request_wait_counter_reset = realign_request_wait_counter_reset_internal || (!reset);

always @(posedge sm_clk or posedge realign_request_wait_counter_reset)
begin
      if (realign_request_wait_counter_reset)
	  begin
	        realign_request_wait_counter <= 0;
	  end else
	  begin
	       if (inc_realign_request_wait_counter)
		   begin
	            realign_request_wait_counter <= realign_request_wait_counter + 1;
		   end
	  end
end
						
						
//==============================================
//
// Correlator Definition
//
//==============================================															   

Parallel_Basic_Corr_w_Slip_Adjust #(
.input_width(input_width),
.number_of_inwidths_in_corr_length(number_of_inwidths_in_corr_length),
.corr_count_bits(corr_count_bits)
)
sequence_correlator(
.indata_clk(indata_clk), 
.ref_data_clk(ref_data_clk), 
.output_reg_clk(corr_output_reg_clk), 
.input_seq_bit_in(input_seq_bit_in), 
.ref_seq_in(current_ref_bit), 
.current_corr(current_corr), 
.ref_bits_reg(ref_bits_reg), 
.input_bits_reg(input_bits_reg),
.reset(reset));   

async_trap_and_reset 
make_data_ready_signal
(.async_sig(indata_clk), 
.outclk(sm_clk), 
.out_sync_sig(new_indata_ready), 
.auto_reset(1'b0), 
.reset(reset_data_trap_signal));

always @ (posedge indata_clk)
begin
	   current_indata_bit <= input_seq_bit_in;
end

always @ (posedge ref_data_clk)
begin
     current_ref_bit <= ref_seq_in;
end

/* Calculate number of errors in current frame */
integer current_index_in_frame;
integer error_in_frame_running_count;
generate 
		            if (use_default_offset_of_BERC_error_measurment)
					begin
							always @*
							 begin  
								   error_in_frame_running_count=0; 
								   for (current_index_in_frame = 0; current_index_in_frame < input_width; current_index_in_frame++)
								   begin : compute_num_errs_in_frame
										
												  error_in_frame_running_count = error_in_frame_running_count + (input_bits_reg[current_index_in_frame+in_lock_phase+default_offset_of_BERC_error_measurment] ^ ref_bits_reg[current_index_in_frame+default_offset_of_BERC_error_measurment]);									   
								   end
								   current_frame_error_count = error_in_frame_running_count;
							end
					end else
					begin
							always @*
							 begin  
								   error_in_frame_running_count=0; 
								   for (current_index_in_frame = 0; current_index_in_frame < input_width; current_index_in_frame++)
								   begin : compute_num_errs_in_frame
													 error_in_frame_running_count = error_in_frame_running_count + (input_bits_reg[current_index_in_frame+in_lock_phase+offset_of_error_counting_subrange] ^ ref_bits_reg[current_index_in_frame+offset_of_error_counting_subrange]);		
								   end
								   current_frame_error_count = error_in_frame_running_count;
							end
					end
endgenerate
 							        	                  //4321098765432109876_543210

			
/* Determine lock status */

generate
         genvar i;
         for (i=0; i<corr_phases_input_width; i++)
		 begin : assign_corr_phases_and_lock_indications
		      assign correlation_phases_count[i] = current_corr[(i+1)*corr_count_bits-1 -: corr_count_bits] ;
		      assign gone_into_lock_phases[i] = (correlation_phases_count[i] > Gone_Into_Lock_Threshold);
		      assign gone_out_of_lock_phases[i] = (correlation_phases_count[i] < Gone_Out_of_Lock_Threshold);
		 end  
endgenerate

/* Determine Maximum Index */
assign current_max_corr[0] = correlation_phases_count[0];
assign current_max_corr_index[0] = 0;

generate
genvar j;
         for (j=1; j<corr_phases_input_width; j++)
         begin : find_max_correlation_phase
              assign current_max_corr[j] = (correlation_phases_count[j] > current_max_corr[j-1]) ?  correlation_phases_count[j] : current_max_corr[j-1];
			  assign current_max_corr_index[j] = (correlation_phases_count[j] > current_max_corr[j-1]) ?  j : current_max_corr_index[j-1];
         end
endgenerate

assign in_lock_current_max_correlation = current_max_corr[corr_phases_input_width-1];

//only change lock phase if the current lock phase is different than the current lock phase
assign in_lock_phase = enable_conservative_lock_phase_switching ? (((current_max_corr[previous_in_lock_phase]==in_lock_current_max_correlation) ? previous_in_lock_phase : current_max_corr_index[corr_phases_input_width-1])) : current_max_corr_index[corr_phases_input_width-1];

wire gone_into_lock;   
wire gone_out_of_lock; 

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Auxiliary Correlator
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

generate
         if (compile_dual_corr)
		 begin
					//==============================================
					// Correlator Definition
					//==============================================															   

					variable_delay_by_shiftreg
					#(
					.width(input_width),
					.delay_val(frame_delay_to_aux_corr),
					.extract_tap_every(aux_corr_delay_extract_tap_every),
					.log2_num_of_extract_taps(aux_corr_log2_num_of_extract_taps)
					)
					delay_input_data_to_aux_corr
					(
					.indata(input_seq_bit_in),
					.outdata(delayed_input_seq_bit_in),
					.output_sel(select_aux_corr_delay),
					.clk(indata_clk)
					);
					 

					variable_delay_by_shiftreg
					#(
					.width(input_width),
					.delay_val(frame_delay_to_aux_corr),
					.extract_tap_every(aux_corr_delay_extract_tap_every),
					.log2_num_of_extract_taps(aux_corr_log2_num_of_extract_taps)
					)
					delay_ref_data_to_aux_corr
					(
					.indata(current_ref_bit),
					.outdata(delayed_current_ref_bit),
					.output_sel(select_aux_corr_delay),
					.clk(ref_data_clk)
					);


					Parallel_Basic_Corr_w_Slip_Adjust #(
					.input_width(input_width),
					.number_of_inwidths_in_corr_length(number_of_inwidths_in_corr_length),
					.corr_count_bits(corr_count_bits)
					)
					aux_sequence_correlator(
					.indata_clk      (indata_clk), 
					.ref_data_clk    (ref_data_clk), 
					.output_reg_clk  (corr_output_reg_clk), 
					.input_seq_bit_in(delayed_input_seq_bit_in), 
					.ref_seq_in      (delayed_current_ref_bit), 
					.current_corr    (aux_current_corr), 
					.ref_bits_reg    (aux_ref_bits_reg), 
					.input_bits_reg  (aux_input_bits_reg),
					.reset(reset));

					/* Determine lock status */

					 genvar ii;
					 for (ii=0; ii<corr_phases_input_width; ii++)
					 begin : assign_aux_corr_phases_and_lock_indications
						  assign aux_correlation_phases_count[ii] = aux_current_corr[(ii+1)*corr_count_bits-1 -: corr_count_bits] ;
						  assign aux_gone_into_lock_phases[ii] = (aux_correlation_phases_count[ii] > aux_Gone_Into_Lock_Threshold);
						  assign aux_gone_out_of_lock_phases[ii] = (aux_correlation_phases_count[ii] < aux_Gone_Out_of_Lock_Threshold);
					 end  
					
					/* Determine Maximum Index */
					assign aux_current_max_corr[0] = aux_correlation_phases_count[0];
					assign aux_current_max_corr_index[0] = 0;

					genvar jj;
					 for (jj=1; jj<corr_phases_input_width; jj++)
					 begin : find_aux_max_correlation_phase
						  assign aux_current_max_corr[jj] = (aux_correlation_phases_count[jj] > aux_current_max_corr[jj-1]) ?  aux_correlation_phases_count[jj] : aux_current_max_corr[jj-1];
						  assign aux_current_max_corr_index[jj] = (aux_correlation_phases_count[jj] > aux_current_max_corr[jj-1]) ?  jj : aux_current_max_corr_index[jj-1];
					 end
			
					assign aux_in_lock_phase = fix_aux_correlator_phase ? in_lock_phase : aux_current_max_corr_index[corr_phases_input_width-1];
                    assign aux_in_lock_current_max_correlation = fix_aux_correlator_phase ? aux_correlation_phases_count[aux_in_lock_phase] : aux_current_max_corr[corr_phases_input_width-1];
					
					///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					//
					// Lock Detection Decision
					//
					///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

					assign gone_into_lock   = disable_lock_detection ?  1'b0 : (enable_dual_corr ? ((|gone_into_lock_phases) && (|aux_gone_into_lock_phases)) : (|gone_into_lock_phases));
					assign gone_out_of_lock = disable_lock_detection ?  1'b1 : (enable_dual_corr ? ((&gone_out_of_lock_phases) || (&aux_gone_out_of_lock_phases)): (&gone_out_of_lock_phases));
					
		      end else
			  begin
			        assign gone_into_lock   =  disable_lock_detection ? 1'b0 : (|gone_into_lock_phases);
					assign gone_out_of_lock =  disable_lock_detection ? 1'b1 : &gone_out_of_lock_phases;
			  end
endgenerate
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// End Lock Detection Decision
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


wire is_slipping =  is_locked && (!gone_out_of_lock) && (previous_in_lock_phase != in_lock_phase);

wire done_initializing_corr_register = (corr_init_counter >= (2*effective_dual_corr_length)); //flush ref sequence register for good measure
wire counted_all_bits = (num_bits_counted >= bits_to_count);

always @(posedge sm_clk or posedge reset_corr_init_counter)
begin 
	 if (reset_corr_init_counter)
	 begin
	 	  corr_init_counter <= 0;
 	 end else
	 begin	 	  
		  if (inc_corr_init_counter)
		  begin
		       corr_init_counter <= corr_init_counter + 1;
		  end		
	 end
end


always @(posedge sm_clk or negedge reset)
begin
	  if (!reset)
	  begin
	  		state <= idle;
	  end else
	  begin
	  		case (state) /*synthesis full_case*/
			idle : if (enabled)
						state <= general_reset;
				   else
				   	state <= idle;
				  
			general_reset : state <= get_ref_data_for_init_corr_reg;
			
			get_ref_data_for_init_corr_reg: state <= one_more_val_into_corr_reg;
			
			one_more_val_into_corr_reg : if (ref_data_ready)
			                                 state <= refclk_symmetry_pre_wait_state0;
			                            else
										     state <= one_more_val_into_corr_reg;
				  
			refclk_symmetry_pre_wait_state0: state	  <= refclk_symmetry_pre_wait_state1;
			refclk_symmetry_pre_wait_state1: state	  <= refclk_symmetry_pre_wait_state2;
			refclk_symmetry_pre_wait_state2: state	  <= refclk_symmetry_pre_wait_state3;
			refclk_symmetry_pre_wait_state3: state	  <= refclk_symmetry_pre_wait_state4;
		    refclk_symmetry_pre_wait_state4: state    <= check_finish_init_corr_reg;
										 				
			check_finish_init_corr_reg : if (done_initializing_corr_register)
											 state <= wait_for_new_data_while_unlocked;
										 else
											 state <= refclk_symmetry_wait_state0;
				  
			refclk_symmetry_wait_state0: state	  <= refclk_symmetry_wait_state1;
			refclk_symmetry_wait_state1: state	  <= refclk_symmetry_wait_state2;
			refclk_symmetry_wait_state2: state	  <= refclk_symmetry_wait_state3;
			refclk_symmetry_wait_state3: state	  <= refclk_symmetry_wait_state4;
		    refclk_symmetry_wait_state4: state    <= one_more_val_into_corr_reg;
			
			wait_for_new_data_while_unlocked : if (new_indata_ready)
																state <= before_update_correlation_output;
														   else 
																state <= wait_for_new_data_while_unlocked;
			before_update_correlation_output : state <= update_correlation_output;
			update_correlation_output : if (counted_all_bits) 
														state <= write_results_to_output;
												 else
												      state <= check_for_lock;
		    check_for_lock  : begin 
										   if (gone_into_lock & ~currently_locked)
										    begin
												state <= advance_corr_count;
											end
											else 
											begin
											   if (currently_locked & ~gone_out_of_lock)
											   begin
											        if (try_to_align_correlation && (in_lock_phase != 0))
													begin
													    state <=  check_realign_wait_counter;
													end else
													begin
							    		 			     state <= advance_ref_data;
													end
											   end else //we are unlocked
											   begin
										 	  		//state <= request_rx_align_data;
													state <= wait_for_new_data_while_unlocked;
											   end
											end
									end
			check_realign_wait_counter : if (realign_request_wait_counter >= input_frames_to_wait_between_realigns) 
			                             begin
										      state <= request_rx_align_data_while_locked;
										 end else
										 begin
			                                   state <= inc_realign_wait_counter;
										 end
										 
			inc_realign_wait_counter            : state <= advance_ref_data;
			request_rx_align_data_while_locked  : state <= reset_realign_wait_counter;
			reset_realign_wait_counter          : state <= advance_ref_data;
			advance_corr_count: state <= advance_ref_data;
			advance_ref_data: state <= advance_ref_data_wait_state0;
			advance_ref_data_wait_state0 :  state <= advance_ref_data_wait_state1;
			advance_ref_data_wait_state1 :  state <= we_are_locked;
			we_are_locked : state <= wait_for_new_data_under_lock;
			
			wait_for_new_data_under_lock : if (new_indata_ready)
											             state <= update_before_get_new_ref_data;
									              else 
									                   state <= wait_for_new_data_under_lock;	
													   
            update_before_get_new_ref_data: state <= get_new_ref_data;
			
	        get_new_ref_data : if (counted_all_bits) 
									state <= write_results_to_output;
							   else
								    state <= check_for_lock;
									
		    write_results_to_output : state <= reset_bit_counter_state;
			reset_bit_counter_state : state <= check_for_lock;
			endcase
			end

end


assign is_locked = currently_locked;

wire [bit_count_reg_width-1:0] next_raw_number_of_locked_values =  currently_locked ? raw_number_of_locked_values + input_width : raw_number_of_locked_values;
wire [bit_count_reg_width-1:0] num_bits_counted_next = num_bits_counted + input_width;
wire [bit_count_reg_width-1:0] raw_slip_count_next   =  is_slipping ? raw_slip_count + input_width : raw_slip_count;

reg [bit_count_reg_width-1:0] initial_throwaway_count = 0;

always @ (posedge sm_clk or posedge reset_number_of_bits_counted) 
begin 
     if  (reset_number_of_bits_counted)
	 begin
	      initial_throwaway_count <= 0;
	 end else
	 begin
	     if (inc_number_of_bits_counted)
		 begin
	          initial_throwaway_count <= initial_throwaway_count + input_width;
		 end
	 end
end

reg raw_done_with_initial_buffer = 0;

always @ (posedge sm_clk or posedge reset_number_of_bits_counted) 
begin 
     if  (reset_number_of_bits_counted)
	 begin
	      raw_done_with_initial_buffer <= 0;
	 end else
	 begin
	     if (inc_number_of_bits_counted)
		 begin
	          raw_done_with_initial_buffer <= (initial_throwaway_count >= initial_throwaway_limit);
		 end
	 end
end

assign done_with_initial_buffer = raw_done_with_initial_buffer || (initial_throwaway_limit == 0);

always @ (posedge sm_clk or posedge reset_number_of_bits_counted) 
begin 
     if  (reset_number_of_bits_counted)
	 begin
	      num_bits_counted <= 0;
		  raw_slip_count <= 0;
		  raw_number_of_locked_values <= 0;
		  
	 end else
	 begin
	      if (inc_number_of_bits_counted)
		  begin
		      if (done_with_initial_buffer)
			  begin
				  num_bits_counted <= num_bits_counted_next;
				  raw_slip_count <= raw_slip_count_next;
				  raw_number_of_locked_values <= next_raw_number_of_locked_values;
			  end
		  end
	 end
end
always @ (posedge sm_clk)
begin
     if (inc_number_of_bits_counted)
	 begin
	       previous_in_lock_phase <= in_lock_phase;
	 end
end   

always @ (posedge sm_clk or posedge reset_number_of_errors_counted) 
begin 
     if  (reset_number_of_errors_counted)
	 begin
	      raw_num_errors_detected <= 0;
	 end else
	 begin 
		 if (inc_number_of_errors_counted)
		 begin
				 if (done_with_initial_buffer)
				 begin
					  raw_num_errors_detected <= raw_num_errors_detected + current_frame_error_count;
				 end
		 end
	end
end

always @ (posedge sm_clk)
begin
     if (latch_num_errors_detected)
	 begin
         num_errors_detected <= raw_num_errors_detected;
	     slip_count <= raw_slip_count;
	 end
end

always @ (posedge sm_clk)
begin
     if (latch_num_locked_values)
	 begin
          number_of_locked_values <= raw_number_of_locked_values;
	 end
end
	  
always @ (posedge sm_clk)
begin
      if (inc_number_of_bits_counted)
	  begin
		  regd_current_frame_error_count <= current_frame_error_count;
		  regd_current_compared_bits    <= input_seq_bit_in;
		  current_frame_is_slip <= is_slipping;
	  end
end
	
assign new_output_bit_is_ready =	inc_number_of_bits_counted;
endmodule
									  
									    
									       





				









