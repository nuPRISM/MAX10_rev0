`default_nettype none
`include "fft_support_pkg.v"
import fft_support_pkg::*;

module radix4_stage1_butterfly_fp_input 
#(
parameter pipeline_match_delay_val,
parameter numchannels,
parameter bits_per_packet,
parameter num_phase_bits  = 24, 
parameter num_output_bits = 16,
parameter ENABLE_KEEPS = 1
)
(
fft_source_float_avalon_st indata,
output logic [31:0] sample_since_reset_count[numchannels],
input logic [num_phase_bits-1:0] phi_inc_i[numchannels],
output logic [num_output_bits-1:0] sine_waveform_out[numchannels],
output logic [num_output_bits-1:0] cosine_waveform_out[numchannels],
output complex_float butterfly_out_Yr_plus_WN_2r_Gr,
output complex_float butterfly_out_Yr_minus_WN_2r_Gr,
output complex_float butterfly_out_WN_r_Zr_plus_WN_3r_Hr,
output complex_float butterfly_out_WN_r_Zr_minus_WN_3r_Hr,
input logic [$clog2(pipeline_match_delay_val)-1:0] pipeline_delay,
input reset,
input clk
);

fft_source_float_avalon_st 
#(
.numchannels(indata.get_numchannels())
)
delayed_fft_data();

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float float_data_from_fft[numchannels];
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float twiddle_factor[numchannels];
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float post_twiddle_mult[numchannels];

delay_fft_data 
#(
.delay_val(pipeline_match_delay_val),
.numchannels(numchannels),
.bits_per_packet(bits_per_packet)
)
delay_fft_data_to_match_dds
(
.indata,
.outdata(delayed_fft_data),
.delay_select(pipeline_delay),
.clk
);

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [numchannels-1:0] dds_reset_n;


genvar i;
generate
		for (i = 0; i < numchannels; i++)
		begin : per_channel_dds

		always_ff @(posedge clk)
		begin
				dds_reset_n[i] <= !((indata.packet[i].sop && indata.packet[i].valid) || reset);
		end
		/*				
		if (i == 0)
		begin
		           assign sine_waveform_out[i] = 0;
				   assign cosine_waveform_out[i] = {1'b0,{(num_output_bits-1){1'b1}}};
		end else
		begin	
      */		
						advanced_dds
						#(
						.num_phase_bits(num_phase_bits), 
						.num_output_bits(num_output_bits),
						.initial_phase_value(0)
						)
						advanced_dds_inst
						(
						 .clk,
						 .reset_n(dds_reset_n[i]),
						 .clken(indata.packet[i].valid),
						 .phi_inc_i(phi_inc_i[i]),
						 .sine_waveform_out  (sine_waveform_out[i]),
						 .cosine_waveform_out(cosine_waveform_out[i]),
						 .sample_since_reset_count(sample_since_reset_count[i])
						);
	   /*
		end
		*/
		    convert_16bit_fixed_to_floating convert_fft_fixed_to_float_real (
						.clk    (clk),    //    clk.clk
						.areset (reset), // areset.reset
						.a      (cosine_waveform_out[i]),      //      a.a
						.q      (twiddle_factor[i].float_real)       //      q.q
					);

		
			convert_16bit_fixed_to_floating convert_fft_fixed_to_float_imag (
						.clk    (clk),    //    clk.clk
						.areset (reset), // areset.reset
						.a(sine_waveform_out[i]),      //      a.a
						.q(twiddle_factor[i].float_imag)       //      q.q
					);
					
					
					
						fp_complex_mult multiply_by_twiddle_factor (
							.clk,    //    clk.clk
							.areset (reset), // areset.reset
							.a      (twiddle_factor[i].float_real),      //      a.a
							.b      (twiddle_factor[i].float_imag),      //      b.b
							.q      (post_twiddle_mult[i].float_real),      //      q.q
							.c      (delayed_fft_data.packet[i].complex_data.real_component),      //      c.c
							.d      (delayed_fft_data.packet[i].complex_data.imag_component),      //      d.d
							.r      (post_twiddle_mult[i].float_imag)       //      r.r
						);

		end
endgenerate
		



/////////////////////////////////////
//
//
//        Yr + WN^2r*Gr
//
//
//


	fp_adder make_Yr_plus_WN_2r_Gr_real (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (post_twiddle_mult[0].float_real),      //      a.a
		.b      (post_twiddle_mult[2].float_real),      //      b.b
		.q      (butterfly_out_Yr_plus_WN_2r_Gr.float_real)       //      q.q
	);


	fp_subtract make_Yr_plus_WN_2r_Gr_imag (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
	    .a      (post_twiddle_mult[0].float_imag),      //      a.a
		.b      (post_twiddle_mult[2].float_imag),      //      b.b
		.q      (butterfly_out_Yr_plus_WN_2r_Gr.float_imag)       //      q.q
	);

/////////////////////////////////////
//
//
//        Yr - WN^2r*Gr
//
//
//


	fp_subtract make_Yr_minus_WN_2r_Gr_real (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (post_twiddle_mult[0].float_real),      //      a.a
		.b      (post_twiddle_mult[2].float_real),      //      b.b
		.q      (butterfly_out_Yr_minus_WN_2r_Gr.float_real)       //      q.q
	);

	fp_subtract make_Yr_minus_WN_2r_Gr_imag (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (post_twiddle_mult[0].float_imag),      //      a.a
		.b      (post_twiddle_mult[2].float_imag),      //      b.b
		.q      (butterfly_out_Yr_minus_WN_2r_Gr.float_imag)       //      q.q
	);


/////////////////////////////////////
//
//
//       WN^r*Zr+WN^3r*Hr
//
//
//


	fp_adder make_Yr_WN_r_Zr_plus_WN_3r_Hr_real (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (post_twiddle_mult[1].float_real),      //      a.a
		.b      (post_twiddle_mult[3].float_real),      //      b.b
		.q      (butterfly_out_WN_r_Zr_plus_WN_3r_Hr.float_real)       //      q.q
	);


	fp_subtract make_WN_r_Zr_plus_WN_3r_Hr_imag (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
	    .a      (post_twiddle_mult[1].float_imag),      //      a.a
		.b      (post_twiddle_mult[3].float_imag),      //      b.b
		.q      (butterfly_out_WN_r_Zr_plus_WN_3r_Hr.float_imag)       //      q.q
	);

/////////////////////////////////////
//
//
//       WN^r*Zr-WN^3r*Hr
//
//
//


	fp_subtract make_WN_r_Zr_minus_WN_3r_Hr_real (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (post_twiddle_mult[1].float_real),      //      a.a
		.b      (post_twiddle_mult[3].float_real),      //      b.b
		.q      (butterfly_out_WN_r_Zr_minus_WN_3r_Hr.float_real)       //      q.q
	);

	fp_subtract make_WN_r_Zr_minus_WN_3r_Hr_imag (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (post_twiddle_mult[1].float_imag),      //      a.a
		.b      (post_twiddle_mult[3].float_imag),      //      b.b
		.q      (butterfly_out_WN_r_Zr_minus_WN_3r_Hr.float_imag)       //      q.q
	);



endmodule
`default_nettype wire