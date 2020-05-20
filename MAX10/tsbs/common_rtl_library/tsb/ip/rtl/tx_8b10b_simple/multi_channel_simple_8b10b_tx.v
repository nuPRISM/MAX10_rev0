`default_nettype none
module multi_channel_simple_8b10b_tx
#( 
 parameter device_family = "Cylcone III",
 parameter numchannels=2,
 parameter num_data_output_fifo_locations = 16,
 parameter input_to_output_bitwidth_ratio = 4,
 parameter input_data_bits_per_channel = 32,
 parameter out_data_bits_per_channel = input_data_bits_per_channel/input_to_output_bitwidth_ratio,
 parameter control_chars_width = 8,
 parameter control_char_fifo_depth = 64,
 parameter synchronizer_depth = 2
) (
			
			input [control_chars_width-1:0] padding_char[numchannels],

			//FIFO side from the ~7 Mhz
			input wrclk_fifo_xcvr,
			input wrreq_fifo_xcvr,
			input [input_data_bits_per_channel-1:0] data_fifo_xcvr[numchannels],
			output [input_data_bits_per_channel*numchannels-1:0] data_fifo_xcvr_flattened,
			output full_fifo_xcvr,
			output rd_full_fifo_xcvr,
			
			input wrclk_fifo_character_queue[numchannels],
			input wrreq_fifo_character_queue[numchannels],
			input [control_chars_width-1:0] data_fifo_character_queue[numchannels],			
			output full_fifo_character_queue[numchannels],
			input control_fifo_aclr,
			input data_fifo_aclr,
			input enable_auto_data_fifo_aclr,
			
			//system clk
			input fsm_clk,//
			input data_output_clk,
			output [9:0]tbi_encoder[numchannels],
			output [15:0] fsm_state,
			output busy,
			output enable_data_out,
			output [31:0] fifo_xcvr_wrusedw,
			
			//debug output
			output logic fifo_read_xcvr_sig,
			output logic fifo_empty_xcvr_sig,
			output logic auto_data_fifo_aclr,
			output logic [out_data_bits_per_channel*numchannels-1:0]  data_fifo_xcvr_sig,
			output logic [out_data_bits_per_channel-1:0] data_fifo_xcvr_fifo_q[numchannels],

			output logic  [control_chars_width-1:0] data_fifo_character_queue_out[numchannels],
			output logic fifo_read_character_queue_sig[numchannels],
			output logic fifo_empty_character_queue_sig[numchannels],
			output logic is_control_char,
			output logic is_padding_char[numchannels],
			output logic [7:0] from_FSM2_8b10[numchannels],
			output reg  [7:0] actual_uncoded_8b10b_out[numchannels],
			output reg actual_is_padding_char[numchannels],
			output reg actual_is_control_char			
);



wire sync_data_output_clk;
async_trap_and_reset data_output_clk_2_6x_clk_sync
(
	.async_sig(data_output_clk) ,	// input  async_sig_sig
	.outclk(fsm_clk) ,	// input  outclk_sig
	.out_sync_sig(sync_data_output_clk) ,	// output  out_sync_sig_sig
	.auto_reset(1'b1) ,	// input  auto_reset_sig
	.reset(1'b1) 	// input  reset_sig
);


generate

         genvar current_channel3, permutation_assembly_index;

              for (permutation_assembly_index = 0; permutation_assembly_index < input_to_output_bitwidth_ratio; permutation_assembly_index = permutation_assembly_index + 1)
			  begin : permute_input_to_data_fifo			 
		           for (current_channel3 = 0; current_channel3 < numchannels; current_channel3 = current_channel3 + 1)
		           begin : per_channel_data_fifo_assignments
			             assign data_fifo_xcvr_flattened[(permutation_assembly_index)*(numchannels*out_data_bits_per_channel)+((current_channel3+1)*out_data_bits_per_channel)-1 -: out_data_bits_per_channel] 
					                                = data_fifo_xcvr[current_channel3][(permutation_assembly_index+1)*out_data_bits_per_channel-1 -: out_data_bits_per_channel];
				   end
			  end
endgenerate
		     


generate
         genvar current_channel;
		 for (current_channel = 0; current_channel < numchannels; current_channel = current_channel + 1)
		 begin : per_channel_fifo_assignments		 
			  
		      assign data_fifo_xcvr_fifo_q[current_channel] =  data_fifo_xcvr_sig[(current_channel+1)*out_data_bits_per_channel-1 -: out_data_bits_per_channel];
			  
				parameterized_daq_fifo
				#(
				.device_family(device_family),
				.num_output_locations(control_char_fifo_depth),
				.input_to_output_ratio(1),
				.num_output_bits(control_chars_width),
				.use_better_metastability_performance(0)
				)
				character_control_queue
				 (
				.data       ( data_fifo_character_queue[current_channel]),
				.rdclk      ( fsm_clk ),
				.rdreq      ( fifo_read_character_queue_sig[current_channel] ),
				.wrclk      ( wrclk_fifo_character_queue[current_channel] ),
				.wrreq      ( wrreq_fifo_character_queue[current_channel] ),
				.q          ( data_fifo_character_queue_out[current_channel] ),
				.rdempty    ( fifo_empty_character_queue_sig[current_channel] ),
				.rdfull     ( ),
				.wrempty    ( ),
				.wrfull     ( full_fifo_character_queue[current_channel] ),
				.wrusedw    ( ),
				.aclr       ( control_fifo_aclr )
				);	
		end
endgenerate

logic enable_auto_data_fifo_aclr_synced;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
doublesync_enable_auto_data_fifo_aclr
(
.indata (enable_auto_data_fifo_aclr),
.outdata(enable_auto_data_fifo_aclr_synced),
.clk(wrclk_fifo_xcvr)
);
								
always_ff @(posedge  wrclk_fifo_xcvr)
begin
		 if (full_fifo_xcvr && enable_auto_data_fifo_aclr_synced)
		 begin
                auto_data_fifo_aclr <= 1;
         end else
         begin
                auto_data_fifo_aclr <= 0;
         end         
end
		 
parameterized_daq_fifo
#(
.device_family(device_family),
.num_output_locations(num_data_output_fifo_locations),
.input_to_output_ratio(input_to_output_bitwidth_ratio),
.num_output_bits(out_data_bits_per_channel*numchannels),
.use_better_metastability_performance(0)
)
data_fifo
 (
.data       ( data_fifo_xcvr_flattened ),
.rdclk      ( fsm_clk ),
.rdreq      ( fifo_read_xcvr_sig ),
.wrclk      ( wrclk_fifo_xcvr ),
.wrreq      ( wrreq_fifo_xcvr ),
.q          ( data_fifo_xcvr_sig ),
.rdempty    ( fifo_empty_xcvr_sig ),
.rdfull     ( rd_full_fifo_xcvr ),
.wrempty    ( ),
.wrfull     ( full_fifo_xcvr ),
.wrusedw    ( fifo_xcvr_wrusedw ),
.aclr       ( data_fifo_aclr  || auto_data_fifo_aclr)
);	



control_8b10b_simple_tx 
#(
.numchannels(numchannels)
)
control_8b10b_simple_tx_inst
(
	.clk_fsm(fsm_clk) ,	// input  clk__sig
	.sending_clk_sync(sync_data_output_clk),
	//XCVR FIFO SIDE
	.data_fifo_xcvr(data_fifo_xcvr_fifo_q) ,	// input [7:0] data_fifo_xcvr_sig
	.fifo_empty_xcvr(fifo_empty_xcvr_sig) ,	// input  fifo_empty_xcvr_sig
	.fifo_read_xcvr(fifo_read_xcvr_sig) ,	// output  fifo_read_xcvr_sig
	
	//CHARACTER CONTROL FIFO SIDE
	.data_fifo_uart(data_fifo_character_queue_out) ,	// input [7:0] data_fifo_uart_sig
	.fifo_empty_uart(fifo_empty_character_queue_sig) ,	// input  fifo_empty_uart_sig
	.fifo_read_uart(fifo_read_character_queue_sig) ,	// output  fifo_read_uart_sig
    .padding_char(padding_char),
    .is_padding_char (is_padding_char),
	//TO 8b10Encoder
	.data_8b10(from_FSM2_8b10) ,	// output [8:0] to_8b10_sig
	.is_control_char(is_control_char) ,	// output  is_control_char_sig
	.enable_data_out(enable_data_out) ,	// output  valid_data_sig
	.state(fsm_state),
	.busy(busy) 	// output  busy_sig
);

always @(posedge data_output_clk)
begin
    actual_is_control_char    <= is_control_char;
end

generate
         genvar current_channel2;
		 for (current_channel2 = 0; current_channel2 < numchannels; current_channel2 = current_channel2 + 1)
		 begin : per_channel_8b10b_out_assignments		   
				
				always @(posedge data_output_clk)
                begin
					 actual_uncoded_8b10b_out [current_channel2] <= from_FSM2_8b10 [current_channel2];					
					 actual_is_padding_char   [current_channel2] <= is_padding_char[current_channel2];
				end

				encoder_8b10b 
				encoder_8b10b_inst
				(
					.reset(1'b0) ,	// input  reset_sig
					.SBYTECLK(data_output_clk) ,	// normal clock
					.K(actual_is_control_char) ,	// input  K_sig
					.ebi(actual_uncoded_8b10b_out[current_channel2]) ,	// input [7:0] ebi_sig
					.tbi(tbi_encoder[current_channel2]) ,	// output [9:0] tbi_sig
					.disparity() 	// output  disparity_sig
				); 
        end
endgenerate	
	
endmodule
`default_nettype wire