`default_nettype none
module adc_deserializer_with_uart
#(
parameter enable_DPA = 0,
parameter NUM_ADC_CHANNELS_PER_FMC = 24,
parameter ADC_BITWIDTH = 12,
parameter COMM_LINK_BITWIDTH = ADC_BITWIDTH,
parameter CLOCK_SPEED_IN_HZ = 50000000,
parameter UART_BAUD_RATE_IN_HZ = 115200,
parameter FMC1_Special_case = 0,
parameter DEFAULT_PATTERN_FOR_SIMULATED_ADC_DATA = 32'h4F,
parameter DEFAULT_BitReversedOutput = 0,
parameter default_frame_channel_index = 21,
parameter USE_HYBRID_DEFRAME_SCHEME = 0,
parameter USE_MINIMALIST_REGFILES             = 0,
parameter USE_MINIMALIST_REGFILE_DESCRIPTIONS = 0,
parameter lock_wait_8b10b_num_bits = 8,
parameter [lock_wait_8b10b_num_bits-1:0] default_wait_8b10b = 50
)
( 
 input  sm_clk,
 input  wire [NUM_ADC_CHANNELS_PER_FMC-1:0]  rx_in,
 output [COMM_LINK_BITWIDTH-1:0] outdata[NUM_ADC_CHANNELS_PER_FMC-1:0],
 output logic [ADC_BITWIDTH-1:0] alternate_outdata[NUM_ADC_CHANNELS_PER_FMC-1:0],
 output logic [ADC_BITWIDTH-1:0] alternate_outdata_raw[NUM_ADC_CHANNELS_PER_FMC-1:0],
 output [COMM_LINK_BITWIDTH-1:0] outdata_raw[NUM_ADC_CHANNELS_PER_FMC-1:0],
 output logic [(2*COMM_LINK_BITWIDTH)-1:0] alternate_double_frame_width_raw_outdata[NUM_ADC_CHANNELS_PER_FMC-1:0],
 output outdata_clk,
 input rx_inclock,
 input [$clog2(COMM_LINK_BITWIDTH)-1:0] chosen_frame_channel_index,
 input [$clog2(COMM_LINK_BITWIDTH)-1:0] frame_offset_select, 
 input request_adc_realign,
 input [127:0] DISPLAY_NAME,
 input aux_rx_inclock,
 input rxd,
 output txd,
 input wire [7:0] NUM_SECONDARY_UARTS,
 input wire [7:0] ADDRESS_OF_THIS_UART,
 input wire       IS_SECONDARY_UART 
);

logic [$clog2(COMM_LINK_BITWIDTH)-1:0]  actual_frame_offset_select;
import uart_regfile_types::*;

parameter log2_NUM_ADC_CHANNELS_PER_FMC = $clog2(NUM_ADC_CHANNELS_PER_FMC);
parameter synchronizer_depth = 3;

wire	         pll_areset;
wire	         [NUM_ADC_CHANNELS_PER_FMC-1:0]  rx_channel_data_align;
wire	         rx_locked;
wire	         [NUM_ADC_CHANNELS_PER_FMC*COMM_LINK_BITWIDTH/2-1:0] rx_out;
wire	         rx_outclock;
wire             [COMM_LINK_BITWIDTH-1:0] simulated_input_frame_lvds_adc_data;
wire             [log2_NUM_ADC_CHANNELS_PER_FMC-1:0] current_channel_to_look_at;
wire             [NUM_ADC_CHANNELS_PER_FMC-1:0]  choose_simulation_data;
wire             transpose_frame_rx_out_bits;
wire             choose_manual_bit_realign;
wire             manual_bit_realign;
wire             BitReverseOutput;
	
parameter adc_deserializer_regfile_data_numbytes        =    4;
parameter adc_deserializer_regfile_data_width           =   8*adc_deserializer_regfile_data_numbytes;
parameter adc_deserializer_regfile_desc_numbytes        =   16;
parameter adc_deserializer_regfile_desc_width           =   8*adc_deserializer_regfile_desc_numbytes;
parameter num_of_adc_deserializer_regfile_control_regs  =   36;
parameter num_of_adc_deserializer_regfile_status_regs   =   96;

wire [adc_deserializer_regfile_data_width-1:0] adc_deserializer_regfile_control_regs_default_vals[num_of_adc_deserializer_regfile_control_regs-1:0];
wire [adc_deserializer_regfile_data_width-1:0] adc_deserializer_regfile_control_regs[num_of_adc_deserializer_regfile_control_regs-1:0];
wire [adc_deserializer_regfile_data_width-1:0] adc_deserializer_regfile_control_bitwidth[num_of_adc_deserializer_regfile_control_regs-1:0];

wire [adc_deserializer_regfile_data_width-1:0] adc_deserializer_regfile_status[num_of_adc_deserializer_regfile_status_regs-1:0];
wire [adc_deserializer_regfile_desc_width-1:0] adc_deserializer_regfile_control_desc[num_of_adc_deserializer_regfile_control_regs-1:0];
wire adc_deserializer_regfile_control_omit_desc[num_of_adc_deserializer_regfile_control_regs-1:0];
wire adc_deserializer_regfile_control_short_to_default[num_of_adc_deserializer_regfile_control_regs-1:0];
wire [adc_deserializer_regfile_desc_width-1:0] adc_deserializer_regfile_status_desc [num_of_adc_deserializer_regfile_status_regs-1:0];
wire adc_deserializer_regfile_status_omit_desc [num_of_adc_deserializer_regfile_status_regs-1:0];
wire adc_deserializer_regfile_status_omit [num_of_adc_deserializer_regfile_status_regs-1:0];


wire adc_deserializer_regfile_control_rd_error;
wire adc_deserializer_regfile_control_async_reset = 1'b0;
wire adc_deserializer_regfile_control_wr_error;
wire adc_deserializer_regfile_control_transaction_error;

wire [3:0] adc_deserializer_regfile_main_sm;
wire [2:0] adc_deserializer_regfile_tx_sm;
wire [7:0] adc_deserializer_regfile_command_count;


assign rx_channel_data_align[0] = choose_manual_bit_realign ? manual_bit_realign : request_adc_realign;
assign rx_channel_data_align[NUM_ADC_CHANNELS_PER_FMC-1:1] = {(NUM_ADC_CHANNELS_PER_FMC-1){rx_channel_data_align[0]}};

wire [NUM_ADC_CHANNELS_PER_FMC-1:0] rx_dpa_lock_reset_sig;
wire [NUM_ADC_CHANNELS_PER_FMC-1:0] rx_fifo_reset_sig;
wire [NUM_ADC_CHANNELS_PER_FMC-1:0] rx_reset_sig;
wire [NUM_ADC_CHANNELS_PER_FMC-1:0] rx_dpa_locked_sig;
wire rx_locked_bank1; 
wire rx_locked_bank6 ;



wire transpose_28bit_data_bits;
wire transpose_28bit_channel_data_halves;
wire ignore_disparity_err;
wire ignore_coding_err;
wire [lock_wait_8b10b_num_bits-1:0] lock_wait;
wire enable_8b_10b_lock_scan;	
wire enable_8b_10b_lock_scan_raw;

			 

wire [3:0] frame_select                               [NUM_ADC_CHANNELS_PER_FMC-1:0];
wire [27:0] raw_28_bit_data                           [NUM_ADC_CHANNELS_PER_FMC-1:0];
wire [NUM_ADC_CHANNELS_PER_FMC-1:0] decoder_control_character_detected ;
wire [NUM_ADC_CHANNELS_PER_FMC-1:0] coding_err                         ;
wire [NUM_ADC_CHANNELS_PER_FMC-1:0] disparity                          ;
wire [NUM_ADC_CHANNELS_PER_FMC-1:0] disparity_err                      ;
wire [NUM_ADC_CHANNELS_PER_FMC-1:0] is_locked_8b_10b                   ;
wire [lock_wait_8b10b_num_bits-1:0] lock_wait_counter [NUM_ADC_CHANNELS_PER_FMC-1:0];
wire [3:0] lock_wait_machine_state_num                [NUM_ADC_CHANNELS_PER_FMC-1:0];
wire [9:0] frame_region_8b_10b                        [NUM_ADC_CHANNELS_PER_FMC-1:0];
wire [7:0] decoded_8b_10b_data_fragment               [NUM_ADC_CHANNELS_PER_FMC-1:0];
wire [13:0] selected_data_out_14_bit                  [NUM_ADC_CHANNELS_PER_FMC-1:0];
wire [27:0] raw_raw_28_bit_data                       [NUM_ADC_CHANNELS_PER_FMC-1:0];
wire [3:0] decoder_pipeline_delay_of_bits_3_to_0      [NUM_ADC_CHANNELS_PER_FMC-1:0];
wire [NUM_ADC_CHANNELS_PER_FMC-1:0]  clear_scan_counter_8b_10b                       ;
wire [NUM_ADC_CHANNELS_PER_FMC-1:0]  inc_scan_counterm_8b_10b                        ;



	

generate
        if (COMM_LINK_BITWIDTH == 12) 
		begin
						if (FMC1_Special_case)
						begin
							 wire [13:0]  rx_in_bank1;
							 wire [9:0]  rx_in_bank6;
						
						
						  assign rx_in_bank1 = {rx_in[23:19],rx_in[15],rx_in[11:4]};
						  assign rx_in_bank6 = {rx_in[18:16],rx_in[14:12],rx_in[3:0]};

						  assign rx_locked = rx_locked_bank1 & rx_locked_bank6;
						  
						if (enable_DPA)
							begin
								adc_stratix_deserializer_with_dpa_14_channel	
								adc_stratix_deserializer_with_dpa_14_channel_inst (
								.pll_areset            ( pll_areset ),
								.rx_channel_data_align ( rx_channel_data_align[23 -: 14] ),
								.rx_in                 ( rx_in_bank1 ),
								.rx_inclock            ( rx_inclock ),
								.rx_locked             ( rx_locked_bank1 ),
								.rx_out                ( rx_out[$size(rx_out)-1 -: 14*ADC_BITWIDTH/2]),
								.rx_outclock           (  ),
								.rx_dpa_lock_reset     ( rx_dpa_lock_reset_sig[23 -: 14] ),
								.rx_fifo_reset         ( rx_fifo_reset_sig[23 -: 14] ),
								.rx_reset              ( rx_reset_sig[23 -: 14] ),
								.rx_dpa_locked         ( rx_dpa_locked_sig[23 -: 14] )
								);
								
								adc_stratix_deserializer_with_dpa_10_channel	
								adc_stratix_deserializer_with_dpa_10_channel_inst (
								.pll_areset            ( pll_areset ),
								.rx_channel_data_align ( rx_channel_data_align[9:0] ),
								.rx_in                 ( rx_in_bank6 ),
								.rx_inclock            ( rx_inclock ),
								.rx_locked             ( rx_locked_bank6 ),
								.rx_out                ( rx_out[10*ADC_BITWIDTH/2-1 : 0] ),
								.rx_outclock           ( rx_outclock ),
								.rx_dpa_lock_reset     ( rx_dpa_lock_reset_sig[9:0]),
								.rx_fifo_reset         ( rx_fifo_reset_sig[9:0]),
								.rx_reset              ( rx_reset_sig[9:0]),
								.rx_dpa_locked         ( rx_dpa_locked_sig[9:0])
								);
							end else
							begin
								adc_stratix_deserializer_14_channel	
								adc_stratix_deserializer_14_channel_inst (
								.pll_areset            ( pll_areset ),
								.rx_channel_data_align ( rx_channel_data_align ),
								.rx_in                 ( rx_in_bank1 ),
								.rx_inclock            ( rx_inclock ),
								.rx_locked             ( rx_locked ),
								.rx_out                ( rx_out ),
								.rx_outclock           ( rx_outclock )
								);
								
								adc_stratix_deserializer_10_channel	
								adc_stratix_deserializer_10_channel_inst (
								.pll_areset            ( pll_areset ),
								.rx_channel_data_align ( rx_channel_data_align ),
								.rx_in                 ( rx_in_bank6 ),
								.rx_inclock            ( rx_inclock ),
								.rx_locked             ( rx_locked ),
								.rx_out                ( rx_out ),
								.rx_outclock           ( rx_outclock )
								);
								
							end
						end else
						begin
							if (enable_DPA)
							begin
								adc_stratix_deserializer_with_dpa	
								adc_stratix_deserializer_inst (
								.pll_areset            ( pll_areset ),
								.rx_channel_data_align ( rx_channel_data_align ),
								.rx_in                 ( rx_in ),
								.rx_inclock            ( rx_inclock ),
								.rx_locked             ( rx_locked ),
								.rx_out                ( rx_out ),
								.rx_outclock           ( rx_outclock ),
								.rx_dpa_lock_reset     ( rx_dpa_lock_reset_sig ),
								.rx_fifo_reset         ( rx_fifo_reset_sig ),
								.rx_reset              ( rx_reset_sig ),
								.rx_dpa_locked         ( rx_dpa_locked_sig )
								);
							end else
							begin
								adc_stratix_deserializer	
								adc_stratix_deserializer_inst (
								.pll_areset            ( pll_areset ),
								.rx_channel_data_align ( rx_channel_data_align ),
								.rx_in                 ( rx_in ),
								.rx_inclock            ( rx_inclock ),
								.rx_locked             ( rx_locked ),
								.rx_out                ( rx_out ),
								.rx_outclock           ( rx_outclock )
								);
							end
						end
		end
		
		if (COMM_LINK_BITWIDTH == 14) 
		begin	
		     if (FMC1_Special_case)
			 begin
			 end else
			 begin
			     adc_stratix_deserializer_with_dpa_7_bits_24_channels	
				 adc_stratix_deserializer_inst (
				     .pll_areset            ( pll_areset ),
				     .rx_channel_data_align ( rx_channel_data_align ),
				     .rx_in                 ( rx_in ),
				     .rx_inclock            ( rx_inclock ),
				     .rx_locked             ( rx_locked ),
				     .rx_out                ( rx_out ),
				     .rx_outclock           ( rx_outclock ),
				     .rx_dpa_lock_reset     ( rx_dpa_lock_reset_sig ),
				     .rx_fifo_reset         ( rx_fifo_reset_sig ),
				     .rx_reset              ( rx_reset_sig ),
				     .rx_dpa_locked         ( rx_dpa_locked_sig )
				 );
			 end
		end
endgenerate
	
(* keep = 1, preserve = 1 *) reg outclk_div2;
always @(negedge rx_outclock)
begin
     outclk_div2 <= ~outclk_div2;
end



(* keep = 1, preserve = 1*) reg  [COMM_LINK_BITWIDTH/2-1:0]     raw_frame_data[NUM_ADC_CHANNELS_PER_FMC-1:0];
(* keep = 1, preserve = 1*) reg  [COMM_LINK_BITWIDTH/2-1:0]     possibly_transposed_raw_frame_data[NUM_ADC_CHANNELS_PER_FMC-1:0];
(* keep = 1, preserve = 1*) reg  [COMM_LINK_BITWIDTH-1:0]       frame_data_2X_bit[NUM_ADC_CHANNELS_PER_FMC-1:0];
(* keep = 1, preserve = 1*) reg  [COMM_LINK_BITWIDTH-1:0]       actual_frame_data_2X_bit[NUM_ADC_CHANNELS_PER_FMC-1:0];
(* keep = 1, preserve = 1*) wire [COMM_LINK_BITWIDTH-1:0]       reconstituted_frame_samples[NUM_ADC_CHANNELS_PER_FMC-1:0];
(* keep = 1, preserve = 1*) wire [COMM_LINK_BITWIDTH-1:0]       transposed_reconstituted_frame_samples[NUM_ADC_CHANNELS_PER_FMC-1:0];
(* keep = 1, preserve = 1*) reg  [COMM_LINK_BITWIDTH-1:0]       possibly_transposed_frame_data_2X_bit[NUM_ADC_CHANNELS_PER_FMC-1:0];
(* keep = 1, preserve = 1*) wire transpose_frame_halves;
(* keep = 1, preserve = 1*) wire xpose_frame_filling_direction;
(* keep = 1, preserve = 1*) wire alternate_frame_sync_transpose_frame_pattern;
(* keep = 1, preserve = 1*) wire alternate_frame_sync_transpose_2Xbit_channel_data_halves;
(* keep = 1, preserve = 1*) wire [$clog2(NUM_ADC_CHANNELS_PER_FMC)-1:0] frame_channel_index;
(* keep = 1, preserve = 1*) wire [1:0] choose_data_in_delay;


parameter start_adc_rxout_look_reg_index = 32;

genvar adc_channel_index;
generate				
        for (adc_channel_index = 0; adc_channel_index < NUM_ADC_CHANNELS_PER_FMC; adc_channel_index = adc_channel_index +1)
        begin : rx_out_to_status_reg
                  assign adc_deserializer_regfile_status[adc_channel_index+start_adc_rxout_look_reg_index] = rx_out[(adc_channel_index+1)*COMM_LINK_BITWIDTH/2-1 -: COMM_LINK_BITWIDTH/2];
				  wire [7:0] char1 = ((adc_channel_index/10)+48);
				  wire [7:0] char2 = ((adc_channel_index % 10)+48);
			      assign adc_deserializer_regfile_status_desc[adc_channel_index+start_adc_rxout_look_reg_index] = {"RxOutADCCh",char1,char2};
   		         
	              assign reconstituted_frame_samples[adc_channel_index] = {actual_frame_data_2X_bit[adc_channel_index][COMM_LINK_BITWIDTH-1:COMM_LINK_BITWIDTH/2],actual_frame_data_2X_bit[adc_channel_index][COMM_LINK_BITWIDTH/2-1:0]};
	              assign transposed_reconstituted_frame_samples[adc_channel_index] = {actual_frame_data_2X_bit[adc_channel_index][COMM_LINK_BITWIDTH/2-1:0],actual_frame_data_2X_bit[adc_channel_index][COMM_LINK_BITWIDTH-1:COMM_LINK_BITWIDTH/2]};
			     
			      always @(posedge rx_outclock)
			      begin
			         raw_frame_data[adc_channel_index] <= rx_out[(adc_channel_index+1)*COMM_LINK_BITWIDTH/2-1 -: COMM_LINK_BITWIDTH/2];
			      end
                 
			     
			     always @(posedge rx_outclock)
			     begin
					 for (int i = 0; i < COMM_LINK_BITWIDTH/2; i++)
					 begin
						   if (transpose_frame_rx_out_bits)
						   begin
								 possibly_transposed_raw_frame_data[adc_channel_index][i] <= raw_frame_data[adc_channel_index][COMM_LINK_BITWIDTH/2-1-i];
						   end else
						   begin 
								 possibly_transposed_raw_frame_data[adc_channel_index][i] <= raw_frame_data[adc_channel_index][i];
						   end			   
					 end
				end

				always @(posedge rx_outclock)
				begin
				     if (xpose_frame_filling_direction)
					 begin
	                      frame_data_2X_bit[adc_channel_index] <= {possibly_transposed_raw_frame_data[adc_channel_index],frame_data_2X_bit[adc_channel_index][COMM_LINK_BITWIDTH-1 -: COMM_LINK_BITWIDTH/2]};				 
					 end else
					 begin
					      frame_data_2X_bit[adc_channel_index] <= {frame_data_2X_bit[adc_channel_index][COMM_LINK_BITWIDTH/2-1:0],possibly_transposed_raw_frame_data[adc_channel_index]};
					 end
				end

				
				always @(posedge outclk_div2)
				begin
					   actual_frame_data_2X_bit[adc_channel_index] <= frame_data_2X_bit[adc_channel_index];
				end

				always @(posedge outclk_div2)
				begin
					 if (transpose_frame_halves)
					 begin
						  possibly_transposed_frame_data_2X_bit[adc_channel_index] <= transposed_reconstituted_frame_samples[adc_channel_index];
					 end else
					 begin
						  possibly_transposed_frame_data_2X_bit[adc_channel_index] <= reconstituted_frame_samples[adc_channel_index];
					 end
				end 

				assign outdata_raw[adc_channel_index] = choose_simulation_data[adc_channel_index] ? simulated_input_frame_lvds_adc_data : possibly_transposed_frame_data_2X_bit[adc_channel_index];

				always @(posedge outclk_div2)
				begin
				      if (BitReverseOutput)
					  begin
					       for (int i = 0; i < COMM_LINK_BITWIDTH; i++)
						   begin
					            outdata[adc_channel_index][i] <= outdata_raw[adc_channel_index][COMM_LINK_BITWIDTH-1-i];
                           end						   
					  end else
					  begin
						 outdata[adc_channel_index] <= outdata_raw[adc_channel_index];
					  end
				end										
           end

		   
endgenerate	

wire reverse_frame_select;
wire alternate_frame_sync_transpose_channel_data_halves   ,
     alternate_frame_sync_bitwise_transpose_before_4X_bits,
     alternate_frame_sync_bitwise_transpose_after_4X_bits ,
     alternate_frame_sync_bitwise_transpose_data_out;
	 
wire [$clog2(COMM_LINK_BITWIDTH)-1:0] ManualFrmOffset;
wire ManualFrmOffsetSel;
wire reset_8b10b_deframers_raw;
wire reset_8b10b_deframers;    
wire FrameClk;
assign FrameClk = outclk_div2;

wire [COMM_LINK_BITWIDTH-1:0] raw_frame_reg;
wire [COMM_LINK_BITWIDTH-1:0] frame_reg;
wire frame_data_valid;

generate
                if (COMM_LINK_BITWIDTH == 12)  
				begin
							if (USE_HYBRID_DEFRAME_SCHEME)
							begin

											always @(posedge outclk_div2)
											begin
											  if (ManualFrmOffsetSel)
											  begin 
												   actual_frame_offset_select <= ManualFrmOffset;
											  end else
											  begin
												   actual_frame_offset_select <= reverse_frame_select ? (COMM_LINK_BITWIDTH-1-frame_offset_select) : frame_offset_select;
											  end
											end

											multi_channel_12bit_reframer
											#(
											  .numchannels(NUM_ADC_CHANNELS_PER_FMC)
											)
											multi_channel_12bit_reframer_inst
											(
											 .deser_clk(rx_outclock),
											 .FrameClk(FrameClk),
											 .frame_select(actual_frame_offset_select),
											 //.data_in(possibly_transposed_raw_frame_data),
											 .data_in(outdata),
											 .data_out(alternate_outdata_raw),
											 .raw_24_bit_data(alternate_double_frame_width_raw_outdata),
											 .transpose_channel_data_halves     (alternate_frame_sync_transpose_channel_data_halves   ),
											 .bitwise_transpose_before_24_bits  (alternate_frame_sync_bitwise_transpose_before_4X_bits),
											 .bitwise_transpose_after_24_bits   (alternate_frame_sync_bitwise_transpose_after_4X_bits ),
											 .bitwise_transpose_data_out        (alternate_frame_sync_bitwise_transpose_data_out      )
											);
												
							end else
							begin	

											multi_channel_12bit_reframer_w_frame_recover
											#(
												  .numchannels(NUM_ADC_CHANNELS_PER_FMC)
											)
											multi_channel_12bit_reframer_w_frame_recover_inst
											(
											  .deser_clk(rx_outclock),
											  .FrameClk(FrameClk),
											  .frame_select(actual_frame_offset_select),
											  .data_in(possibly_transposed_raw_frame_data),
											  .data_out(alternate_outdata_raw),
											  .raw_24_bit_data(alternate_double_frame_width_raw_outdata),
											  .raw_frame_reg(raw_frame_reg),
											  .frame_reg(frame_reg),
											  .transpose_frame_pattern(alternate_frame_sync_transpose_frame_pattern),
											  .transpose_channel_data_halves(alternate_frame_sync_transpose_2Xbit_channel_data_halves),
											  .frame_channel_index(frame_channel_index),
											  .frame_data_valid(frame_data_valid),
											  .choose_data_in_delay(choose_data_in_delay)
											);
												
							end	
				
												//make sure chosen frame channel is raw
								//genvar chan_ind;
								//generate
								//        for (chan_ind = 0; chan_ind < NUM_ADC_CHANNELS_PER_FMC; chan_ind++)
								//		  begin : make_frame_channel_raw
								//		      always @(posedge outclk_div2)
								//			  begin
								//			    	if (chosen_frame_channel_index == chan_ind)
								//					begin
								//					     alternate_outdata[chan_ind] <= outdata[chan_ind]; //frame output is raw
								//					end else
								//					begin
								//					     alternate_outdata[chan_ind] <= alternate_outdata_raw[chan_ind];
								//					end
								//			  end
								//		end
								//endgenerate
								 always @(posedge FrameClk)
								 begin
										 alternate_outdata <= alternate_outdata_raw;
								 end

								 assign outdata_clk = FrameClk;
				end else
				begin //14 bit
				
								doublesync_no_reset 
								#(.synchronizer_depth(synchronizer_depth))
								doublesync_enable_8b_10b_lock_scan_to_FrameClk
								(
								.indata(enable_8b_10b_lock_scan_raw),
								.outdata(enable_8b_10b_lock_scan),
								.clk(FrameClk)
								);

								doublesync_no_reset 
								#(.synchronizer_depth(synchronizer_depth))
								doublesync_reset_8b10b_deframers_to_FrameClk
								(
								.indata (reset_8b10b_deframers_raw),
								.outdata(reset_8b10b_deframers    ),
								.clk(FrameClk)
								);
								
							    multi_channel_14bit_reframer_w_8b10b_decode
								#(
									  .numchannels(NUM_ADC_CHANNELS_PER_FMC),
									  .lock_wait_counter_bits(lock_wait_8b10b_num_bits)
								)
								multi_channel_14bit_reframer_w_8b10b_decode_inst
								(
								  .clk(FrameClk),
								  .reset(reset_8b10b_deframers),
								  .data_in(outdata),
								  .data_out(alternate_outdata_raw),
								  .transpose_28bit_data_bits(transpose_28bit_data_bits),
								  .transpose_channel_data_halves(transpose_28bit_channel_data_halves),
								  .ignore_disparity_err(ignore_disparity_err),
								  .ignore_coding_err(ignore_coding_err),
								  .lock_wait(lock_wait),
								  .enable_8b_10b_lock_scan(enable_8b_10b_lock_scan),
								  
								  
								  //debugging outputs                      (),
								  .frame_select                            (frame_select                          ),
								  .raw_28_bit_data                         (raw_28_bit_data                       ),
								  .decoder_control_character_detected      (decoder_control_character_detected    ),
								  .coding_err                              (coding_err                            ),
								  .disparity                               (disparity                             ),
								  .disparity_err                           (disparity_err                         ),
								  .is_locked_8b_10b                        (is_locked_8b_10b                      ),
								  .lock_wait_counter                       (lock_wait_counter                     ),
								  .lock_wait_machine_state_num             (lock_wait_machine_state_num           ),
								  .frame_region_8b_10b                     (frame_region_8b_10b                   ),
								  .decoded_8b_10b_data_fragment            (decoded_8b_10b_data_fragment          ),
								  .selected_data_out_14_bit                (selected_data_out_14_bit              ),
								  .raw_raw_28_bit_data                     (raw_raw_28_bit_data                   ),
								  .decoder_pipeline_delay_of_bits_3_to_0   (decoder_pipeline_delay_of_bits_3_to_0 ),
								  .clear_scan_counter_8b_10b               (clear_scan_counter_8b_10b             ),
								  .inc_scan_counterm_8b_10b                (inc_scan_counterm_8b_10b              )
								  
								);
				
								 always @(posedge FrameClk)
								 begin
										 alternate_outdata <= alternate_outdata_raw;
								 end

								 assign outdata_clk = FrameClk;
				
				end
endgenerate	


				
				
wire [31:0] error_count_8b10b;
wire [31:0] unlock_8b10b_event_recorded;
wire [NUM_ADC_CHANNELS_PER_FMC-1:0] enabled_channels_for_error_monitoring_8b10b;
wire enable_8b10b_error_monitoring;
wire enable_8b10b_error_monitoring_raw;
wire clear_8b10b_error_count;
wire clear_8b10b_error_count_raw;
wire actual_monitored_8b10b_error_signal;


doublesync_no_reset 
#(.synchronizer_depth(synchronizer_depth))
doublesync_enable_8b_10b_lock_scan_to_FrameClk
(
.indata(enable_8b10b_error_monitoring_raw),
.outdata(enable_8b10b_error_monitoring),
.clk(FrameClk)
);

doublesync_no_reset 
#(.synchronizer_depth(synchronizer_depth))
doublesync_clear_8b10b_error_count_to_FrameClk
(
.indata(clear_8b10b_error_count_raw),
.outdata(clear_8b10b_error_count),
.clk(FrameClk)
);

monitor_errors_in_channels
#(
.num_counter_bits(32),
.num_channels(NUM_ADC_CHANNELS_PER_FMC),
.saturation_limit({32{1'b1}})
)
monitor_errors_in_channels_inst
(
  .clk(FrameClk),
  .channel_error_signals(~is_locked_8b_10b),
  .saturated_sum(error_count_8b10b),
  .enabled_channels(enabled_channels_for_error_monitoring_8b10b),
  .count_enable(enable_8b10b_error_monitoring),
  .clear_counter(clear_8b10b_error_count),
  .actual_monitored_signal(actual_monitored_8b10b_error_signal)
);

record_events
#(
.numchannels(NUM_ADC_CHANNELS_PER_FMC)
)
record_events_inst 
(
.monitored_signals(~is_locked_8b_10b),
.clk(FrameClk),
.clear(clear_8b10b_error_count),
.event_recorded(unlock_8b10b_event_recorded)
);






assign adc_deserializer_regfile_control_regs_default_vals[0]  =  32'h5124654;

// Status
assign adc_deserializer_regfile_status[0] = 32'h54786854;
assign adc_deserializer_regfile_status_desc[0] = "ALIVE";

assign adc_deserializer_regfile_status[2] = 32'h54984089;
assign adc_deserializer_regfile_status[8] = {adc_deserializer_regfile_tx_sm,1'b0,adc_deserializer_regfile_main_sm,adc_deserializer_regfile_command_count,4'h5,1'b0,adc_deserializer_regfile_control_rd_error,adc_deserializer_regfile_control_wr_error,adc_deserializer_regfile_control_transaction_error};	
generate
		if (FMC1_Special_case)
		begin
				assign adc_deserializer_regfile_status[9] = rx_locked_bank1;
				assign adc_deserializer_regfile_status_desc[9] = "rx_locked_bank1";                                                   
				assign adc_deserializer_regfile_status[10] = rx_locked_bank6;
				assign adc_deserializer_regfile_status_desc[10] = "rx_locked_bank6";
        end
endgenerate

assign adc_deserializer_regfile_status[12] = raw_frame_data[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[12] = "raw_frame_data";

assign adc_deserializer_regfile_status[13] = possibly_transposed_raw_frame_data[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[13] = "pos_xposedfrdata";
			
assign adc_deserializer_regfile_status[14] = frame_data_2X_bit[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[14] = "framedata_2X_bit";
		
assign adc_deserializer_regfile_status[15] = actual_frame_data_2X_bit[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[15] = "actframedata";
			
assign adc_deserializer_regfile_status[16] = possibly_transposed_frame_data_2X_bit[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[16] = "pos_xposed2Xbfrm";
			
assign adc_deserializer_regfile_status[17] = outdata[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[17] = "actual_dataout";

assign adc_deserializer_regfile_status[18] = rx_dpa_locked_sig;
assign adc_deserializer_regfile_status_desc[18] = "rx_dpa_locked";

assign adc_deserializer_regfile_status[19] = alternate_double_frame_width_raw_outdata[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[19] = "alt4XbitOutdata";

assign adc_deserializer_regfile_status[20] = alternate_outdata_raw[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[20] = "alt_outdata_raw";

assign adc_deserializer_regfile_status[21] = alternate_outdata[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[21] = "altOudata";

assign adc_deserializer_regfile_status[22] = actual_frame_offset_select;
assign adc_deserializer_regfile_status_desc[22] = "ActFrmOffsetSel";

assign adc_deserializer_regfile_status[23] = frame_reg;
assign adc_deserializer_regfile_status_desc[23] = "FrmReg";

assign adc_deserializer_regfile_status[24] = raw_frame_reg;
assign adc_deserializer_regfile_status_desc[24] = "rawFrmReg";

assign adc_deserializer_regfile_status[25] = frame_data_valid;
assign adc_deserializer_regfile_status_desc[25] = "frame_data_valid";

assign adc_deserializer_regfile_status[64] = frame_select[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[64] = "frame_select";

assign adc_deserializer_regfile_status[65] = raw_28_bit_data[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[65] = "raw_28_bit_data";

assign adc_deserializer_regfile_status[66] = disparity_err;
assign adc_deserializer_regfile_status_desc[66] = "DecDisparityErr";

assign adc_deserializer_regfile_status[67] = decoder_control_character_detected;
assign adc_deserializer_regfile_status_desc[67] = "decCtrlCharDet";

assign adc_deserializer_regfile_status[68] = coding_err;
assign adc_deserializer_regfile_status_desc[68] = "dec_coding_err";

assign adc_deserializer_regfile_status[69] = disparity;
assign adc_deserializer_regfile_status_desc[69] = "dec_disparity";

assign adc_deserializer_regfile_status[70] = is_locked_8b_10b;
assign adc_deserializer_regfile_status_desc[70] = "is_locked_8b_10b";

assign adc_deserializer_regfile_status[71] = lock_wait_counter[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[71] = "lockWaitCounter";

assign adc_deserializer_regfile_status[72] = lock_wait_machine_state_num[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[72] = "LockWaitSM";

assign adc_deserializer_regfile_status[73] = frame_region_8b_10b[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[73] = "DecFrameReg8b10b";

assign adc_deserializer_regfile_status[74] = decoded_8b_10b_data_fragment[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[74] = "DecDatFrag8b10b";

assign adc_deserializer_regfile_status[75] = raw_raw_28_bit_data[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[75] = "rawRaw28bitData";

assign adc_deserializer_regfile_status[76] = decoder_pipeline_delay_of_bits_3_to_0[current_channel_to_look_at];
assign adc_deserializer_regfile_status_desc[76] = "DecPipeDel3to0";

assign adc_deserializer_regfile_status[77] = clear_scan_counter_8b_10b;
assign adc_deserializer_regfile_status_desc[77] = "decClrScanCount";

assign adc_deserializer_regfile_status[78] = inc_scan_counterm_8b_10b;
assign adc_deserializer_regfile_status_desc[78] = "decIncScanCount";

assign adc_deserializer_regfile_status[79] = error_count_8b10b;
assign adc_deserializer_regfile_status_desc[79] = "ErrorCount8b10b";

assign adc_deserializer_regfile_status[80] = actual_monitored_8b10b_error_signal;
assign adc_deserializer_regfile_status_desc[80] = "ActMon8b10bErr";

assign adc_deserializer_regfile_status[81] = unlock_8b10b_event_recorded;
assign adc_deserializer_regfile_status_desc[81] = "unlock8b10bevent";



// Control

assign BitReverseOutput = adc_deserializer_regfile_control_regs[2];
assign adc_deserializer_regfile_control_desc[2] = "BitReverseOutput";
assign adc_deserializer_regfile_control_regs_default_vals[2]  =  DEFAULT_BitReversedOutput;
assign adc_deserializer_regfile_control_bitwidth[2] = 1;

			
assign simulated_input_frame_lvds_adc_data = adc_deserializer_regfile_control_regs[3];
assign adc_deserializer_regfile_control_desc[3] = "Sim. ADC Data In";
assign adc_deserializer_regfile_control_regs_default_vals[3]  =  DEFAULT_PATTERN_FOR_SIMULATED_ADC_DATA;
assign adc_deserializer_regfile_control_bitwidth[3] = COMM_LINK_BITWIDTH;	
		
assign choose_simulation_data = adc_deserializer_regfile_control_regs[4];
assign adc_deserializer_regfile_control_desc[4] = "ChooseSimData";
assign adc_deserializer_regfile_control_regs_default_vals[4]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[4] = $bits(choose_simulation_data);
				
assign transpose_frame_halves = adc_deserializer_regfile_control_regs[5];
assign adc_deserializer_regfile_control_desc[5] = "xpose frame half";
assign adc_deserializer_regfile_control_regs_default_vals[5]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[5] = 1;

	
assign transpose_frame_rx_out_bits = adc_deserializer_regfile_control_regs[6];
assign adc_deserializer_regfile_control_desc[6] = "xpose_rx_out";
assign adc_deserializer_regfile_control_regs_default_vals[6]  =  32'h1;
assign adc_deserializer_regfile_control_bitwidth[6] = 1;
			
				
assign choose_manual_bit_realign = adc_deserializer_regfile_control_regs[8];
assign adc_deserializer_regfile_control_desc[8] = "chs man bit real";
assign adc_deserializer_regfile_control_regs_default_vals[8]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[8] = 1;
				
				
assign manual_bit_realign = adc_deserializer_regfile_control_regs[9];
assign adc_deserializer_regfile_control_desc[9] = "man. bit real";
assign adc_deserializer_regfile_control_regs_default_vals[9]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[9] = 1;
	
assign rx_dpa_lock_reset_sig = adc_deserializer_regfile_control_regs[10];
assign adc_deserializer_regfile_control_desc[10] = "rx_dpa_lock_rst";
assign adc_deserializer_regfile_control_regs_default_vals[10]  =  32'h0;							
				
				
assign rx_fifo_reset_sig = adc_deserializer_regfile_control_regs[11];
assign adc_deserializer_regfile_control_desc[11] = "rx_fifo_reset";
assign adc_deserializer_regfile_control_regs_default_vals[11]  =  32'h0;
			


assign rx_reset_sig = adc_deserializer_regfile_control_regs[12];
assign adc_deserializer_regfile_control_desc[12] = "rx_reset";
assign adc_deserializer_regfile_control_regs_default_vals[12]  =  32'h0;
											

assign pll_areset = adc_deserializer_regfile_control_regs[13];
assign adc_deserializer_regfile_control_desc[13] = "pll_areset";
assign adc_deserializer_regfile_control_regs_default_vals[13]  =  32'h0;
									
									
assign current_channel_to_look_at = adc_deserializer_regfile_control_regs[14];
assign adc_deserializer_regfile_control_desc[14] = "CurrChanToLook";
assign adc_deserializer_regfile_control_regs_default_vals[14]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[14]  = log2_NUM_ADC_CHANNELS_PER_FMC;
					
assign reverse_frame_select = adc_deserializer_regfile_control_regs[15];
assign adc_deserializer_regfile_control_desc[15] = "ReverseFrmSelect";
assign adc_deserializer_regfile_control_regs_default_vals[15]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[15]  = 1;
			
assign ManualFrmOffsetSel = adc_deserializer_regfile_control_regs[16];
assign adc_deserializer_regfile_control_desc[16] = "SelManFrmOffset";
assign adc_deserializer_regfile_control_regs_default_vals[16]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[16]  = 1;		

assign ManualFrmOffset = adc_deserializer_regfile_control_regs[17];
assign adc_deserializer_regfile_control_desc[17] = "ManFrmOffset";
assign adc_deserializer_regfile_control_regs_default_vals[17]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[17]  = $clog2(COMM_LINK_BITWIDTH);				
					

assign alternate_frame_sync_transpose_channel_data_halves = adc_deserializer_regfile_control_regs[18];
assign adc_deserializer_regfile_control_desc[18] = "Xpose4XbitHalves";
assign adc_deserializer_regfile_control_regs_default_vals[18]  =  32'h1;
assign adc_deserializer_regfile_control_bitwidth[18]  = 1;				
					

assign alternate_frame_sync_bitwise_transpose_before_4X_bits = adc_deserializer_regfile_control_regs[19];
assign adc_deserializer_regfile_control_desc[19] = "BitXposeBef4Xbit";
assign adc_deserializer_regfile_control_regs_default_vals[19]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[19]  = 1;				
					

assign alternate_frame_sync_bitwise_transpose_after_4X_bits = adc_deserializer_regfile_control_regs[20];
assign adc_deserializer_regfile_control_desc[20] = "BitXposeAft4Xbit";
assign adc_deserializer_regfile_control_regs_default_vals[20]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[20]  = 1;				
					

assign alternate_frame_sync_bitwise_transpose_data_out = adc_deserializer_regfile_control_regs[21];
assign adc_deserializer_regfile_control_desc[21] = "BitXpose2XbitOut";
assign adc_deserializer_regfile_control_regs_default_vals[21]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[21]  = $clog2(COMM_LINK_BITWIDTH);																			
						
						
assign xpose_frame_filling_direction = adc_deserializer_regfile_control_regs[22];
assign adc_deserializer_regfile_control_desc[22] = "xpose frame fill";
assign adc_deserializer_regfile_control_regs_default_vals[22]  =  32'h1;
assign adc_deserializer_regfile_control_bitwidth[22] = 1;

assign alternate_frame_sync_transpose_frame_pattern = adc_deserializer_regfile_control_regs[23];
assign adc_deserializer_regfile_control_desc[23] = "xps2XbitFrmPatt";
assign adc_deserializer_regfile_control_regs_default_vals[23]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[23] = 0;

assign alternate_frame_sync_transpose_2Xbit_channel_data_halves   = adc_deserializer_regfile_control_regs[24];
assign adc_deserializer_regfile_control_desc[24] = "xps2XbitChanHlfs";
assign adc_deserializer_regfile_control_regs_default_vals[24]  =  32'h1;
assign adc_deserializer_regfile_control_bitwidth[24] = 1;

assign frame_channel_index  = adc_deserializer_regfile_control_regs[25];
assign adc_deserializer_regfile_control_desc[25] = "selFrmChanIndex";
assign adc_deserializer_regfile_control_regs_default_vals[25]  =  default_frame_channel_index;
assign adc_deserializer_regfile_control_bitwidth[25] = $clog2(NUM_ADC_CHANNELS_PER_FMC);

assign choose_data_in_delay  = adc_deserializer_regfile_control_regs[26];
assign adc_deserializer_regfile_control_desc[26] = "chooseDataInDelay";
assign adc_deserializer_regfile_control_regs_default_vals[26]  =  32'h1;
assign adc_deserializer_regfile_control_bitwidth[26] = 2;

assign transpose_28bit_data_bits  = adc_deserializer_regfile_control_regs[27];
assign adc_deserializer_regfile_control_desc[27] = "xpose28databits";
assign adc_deserializer_regfile_control_regs_default_vals[27]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[27] = 1;

assign transpose_28bit_channel_data_halves  = adc_deserializer_regfile_control_regs[28];
assign adc_deserializer_regfile_control_desc[28] = "xpose28chanhalfs";
assign adc_deserializer_regfile_control_regs_default_vals[28]  =  32'h1;
assign adc_deserializer_regfile_control_bitwidth[28] = 1;

assign ignore_disparity_err  = adc_deserializer_regfile_control_regs[29];
assign adc_deserializer_regfile_control_desc[29] = "ig_disp_err";
assign adc_deserializer_regfile_control_regs_default_vals[29]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[29] = 1;


assign ignore_coding_err  = adc_deserializer_regfile_control_regs[30];
assign adc_deserializer_regfile_control_desc[30] = "ig_coding_err";
assign adc_deserializer_regfile_control_regs_default_vals[30]  =  32'h0;
assign adc_deserializer_regfile_control_bitwidth[30] = 1;

assign lock_wait  = adc_deserializer_regfile_control_regs[31];
assign adc_deserializer_regfile_control_desc[31] = "lock_wait";
assign adc_deserializer_regfile_control_regs_default_vals[31]  = default_wait_8b10b;
assign adc_deserializer_regfile_control_bitwidth[31] = lock_wait_8b10b_num_bits;


assign {reset_8b10b_deframers_raw,enable_8b_10b_lock_scan_raw}  = adc_deserializer_regfile_control_regs[32];
assign adc_deserializer_regfile_control_desc[32] = "rst_ena_8b10b_dec";
assign adc_deserializer_regfile_control_regs_default_vals[32]  = 32'h1;
assign adc_deserializer_regfile_control_bitwidth[32] = 2;



assign enabled_channels_for_error_monitoring_8b10b  = adc_deserializer_regfile_control_regs[33];
assign adc_deserializer_regfile_control_desc[33] = "monitored_8b10b";
assign adc_deserializer_regfile_control_regs_default_vals[33]  = 32'h3FFFFF;
assign adc_deserializer_regfile_control_bitwidth[33] = NUM_ADC_CHANNELS_PER_FMC;

assign {clear_8b10b_error_count_raw,enable_8b10b_error_monitoring_raw}  = adc_deserializer_regfile_control_regs[34];
assign adc_deserializer_regfile_control_desc[34] = "Ctrl8b10bErrCnt";
assign adc_deserializer_regfile_control_regs_default_vals[34]  = 32'h1;
assign adc_deserializer_regfile_control_bitwidth[34] = 2;

genvar curr_control_reg_index;
genvar curr_status_reg_index;
generate
             for (curr_control_reg_index = 0; curr_control_reg_index < num_of_adc_deserializer_regfile_control_regs; curr_control_reg_index++)
			 begin : possibly_omit_control_desc_and_short
			       assign adc_deserializer_regfile_control_short_to_default[curr_control_reg_index] = USE_MINIMALIST_REGFILES;
			       assign adc_deserializer_regfile_control_omit_desc[curr_control_reg_index] = USE_MINIMALIST_REGFILE_DESCRIPTIONS;			 
			 end
			 
			 for (curr_status_reg_index = 0; curr_status_reg_index < num_of_adc_deserializer_regfile_status_regs; curr_status_reg_index++)
			 begin : possibly_omit_status_desc_and_short
			       assign adc_deserializer_regfile_status_omit[curr_status_reg_index] = USE_MINIMALIST_REGFILES;
			       assign adc_deserializer_regfile_status_omit_desc[curr_status_reg_index] = USE_MINIMALIST_REGFILE_DESCRIPTIONS;			 
			 end			 			 
endgenerate					


uart_controlled_register_file_ver3
#( 
  .NUM_OF_CONTROL_REGS (num_of_adc_deserializer_regfile_control_regs),
  .NUM_OF_STATUS_REGS  (num_of_adc_deserializer_regfile_status_regs),
  .DATA_WIDTH_IN_BYTES(adc_deserializer_regfile_data_numbytes),
  .DESC_WIDTH_IN_BYTES(adc_deserializer_regfile_desc_numbytes),
  .INIT_ALL_CONTROL_REGS_TO_DEFAULT (1'b0),  
  .CONTROL_REGS_DEFAULT_VAL         (0),
  .CLOCK_SPEED_IN_HZ(CLOCK_SPEED_IN_HZ),
  .UART_BAUD_RATE_IN_HZ(UART_BAUD_RATE_IN_HZ)
)
adc_deser_uart_register_file
(	
 .DISPLAY_NAME(DISPLAY_NAME),
 .CLK (sm_clk),
 .REG_ACTIVE_HIGH_ASYNC_RESET(adc_deserializer_regfile_control_async_reset),
 .CONTROL(adc_deserializer_regfile_control_regs),
 .CONTROL_BITWIDTH(adc_deserializer_regfile_control_bitwidth),
 .STATUS(adc_deserializer_regfile_status),
 .CONTROL_INIT_VAL(adc_deserializer_regfile_control_regs_default_vals),
 .CONTROL_DESC(adc_deserializer_regfile_control_desc),
 .CONTROL_OMIT_DESC(adc_deserializer_regfile_control_omit_desc),
 .CONTROL_SHORT_TO_DEFAULT(adc_deserializer_regfile_control_short_to_default),
 .STATUS_DESC (adc_deserializer_regfile_status_desc),
 .STATUS_OMIT_DESC (adc_deserializer_regfile_status_omit_desc),
 .STATUS_OMIT (adc_deserializer_regfile_status_omit),
 .TRANSACTION_ERROR(adc_deserializer_regfile_control_transaction_error),
 .WR_ERROR(adc_deserializer_regfile_control_wr_error),
 .RD_ERROR(adc_deserializer_regfile_control_rd_error),
 .USER_TYPE(uart_regfile_types::DESERIALIZER_CTRL_UART_REGFILE),
 .NUM_SECONDARY_UARTS (NUM_SECONDARY_UARTS ),
 .ADDRESS_OF_THIS_UART(ADDRESS_OF_THIS_UART),
 .IS_SECONDARY_UART   (IS_SECONDARY_UART   ),
 
 //UART
 .uart_active_high_async_reset(1'b0),
 .rxd(rxd),
 .txd(txd),
 
 //UART DEBUG
 .main_sm               (adc_deserializer_regfile_main_sm),
 .tx_sm                 (adc_deserializer_regfile_tx_sm),
 .command_count         (adc_deserializer_regfile_command_count)
  
);
		
endmodule
`default_nettype wire