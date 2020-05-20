`default_nettype none
`include "fft_support_pkg.v"
`include "interface_defs.v"
import fft_support_pkg::*;

module fft_via_dit_x4_fp 
#(
parameter pipeline_match_delay_val,
parameter delay_val_for_sop_eop_valid,
parameter fft_complex_avst_outdata_delay_val_for_sop_eop_valid = delay_val_for_sop_eop_valid,
parameter numchannels = 4,
parameter dds_num_phase_bits  = 24, 
parameter dds_num_output_bits = 16,
parameter fft_output_bits_per_component = 16,
parameter fft_input_bits_per_component = 14,
parameter fft_input_bit_padded_length_per_component = 16,
parameter num_output_bits_per_fixed_point_output = 16,
parameter stream_index,
parameter ENABLE_KEEPS = 1,
parameter input_bits_to_shift_left_for_bypass
)
(
output logic [31:0] sample_since_reset_count[numchannels],
input logic [dds_num_phase_bits-1:0] phi_inc_i[numchannels],
multiple_synced_st_streaming_interfaces avst_indata,
multiple_synced_st_streaming_interfaces fft_complex_avst_outdata,
input  logic [10:0] fftpts_in,
input logic [0:0] inverse,
input logic [$clog2(pipeline_match_delay_val)-1:0]    pipeline_delay,
input logic [$clog2(delay_val_for_sop_eop_valid)-1:0] ctrl_delay,
input fft_ready_override,
input fft_ready_override_value,
input invert_bypass_imag,
input select_float_bypass,
input reset,
input clk
);


(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float float_avst_input_data[numchannels];
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float float_avst_post_fft_data[numchannels];

fft_source_float_avalon_st 
#(
   .numchannels(numchannels)
)
fft_source_data(), fft_source_data_raw();

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float butterfly_out_Yr_plus_WN_2r_Gr;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float butterfly_out_Yr_minus_WN_2r_Gr;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float butterfly_out_WN_r_Zr_plus_WN_3r_Hr;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float butterfly_out_WN_r_Zr_minus_WN_3r_Hr;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float Xr;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float Xr_plus_N_div_4;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float Xr_plus_2N_div_4;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) complex_float Xr_plus_3N_div_4;

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] out_magnitude_squared_float[numchannels];

genvar i;
generate
		for (i = 0; i < numchannels; i++)
		begin : per_channel_fft
		       always_ff @(posedge clk)
			   begin
			         if (fft_ready_override)
					 begin
					      fft_source_data.packet[i].ready <= fft_ready_override_value;
					 end else
                     begin					 
							 if (avst_indata.sop && avst_indata.valid) begin
									 fft_source_data.packet[i].ready <= 1;
							 end else
							 begin
									 if (fft_source_data.packet[i].eop && fft_source_data.packet[i].valid)
									 begin
											fft_source_data.packet[i].ready <= 0;
									 end
							 end
					 end
			   end
			   
		//	   fft_1k 
		//	   fft_1k_inst (
		//		/* input  wire        */ .clk,          //    clk.clk
		//		/* input  wire        */ .reset_n(!reset),      //    rst.reset_n
		//		/* input  wire        */ .sink_valid(avst_indata.valid),   //   sink.sink_valid
		//		/* output wire        */ .sink_ready(/*avst_indata.ready*/),   //       .sink_ready
		//		/* input  wire [1:0]  */ .sink_error(/*avst_indata.error*/),   //       .sink_error
		//		/* input  wire        */ .sink_sop(avst_indata.sop),     //       .sink_sop
		//		/* input  wire        */ .sink_eop(avst_indata.eop),     //       .sink_eop
		//		/* input  wire [13:0] */ .sink_real(avst_indata.data[stream_index][(i*fft_input_bit_padded_length_per_component)+fft_input_bits_per_component-1 -: fft_input_bits_per_component]),    //       .sink_real
		//		/* input  wire [13:0] */ .sink_imag(0),    //       .sink_imag
		//		/* input  wire [10:0] */ .fftpts_in(fftpts_in),    //       .fftpts_in
		//		/* input  wire [0:0]  */ .inverse,      //       .inverse
		//		/* output wire        */ .source_valid(fft_source_data_raw.packet[i].valid                      ), // source.source_valid
		//		/* input  wire        */ .source_ready(fft_source_data_raw.packet[i].ready                      ), //       .source_ready
		//		/* output wire [1:0]  */ .source_error(fft_source_data_raw.packet[i].error                      ), //       .source_error
		//		/* output wire        */ .source_sop  (fft_source_data_raw.packet[i].sop                        ),   //       .source_sop
		//		/* output wire        */ .source_eop  (fft_source_data_raw.packet[i].eop                        ),   //       .source_eop
		//		/* output wire [15:0] */ .source_real (fft_source_data_raw.packet[i].complex_data.real_component),  //       .source_real
		//		/* output wire [15:0] */ .source_imag (fft_source_data_raw.packet[i].complex_data.imag_component),  //       .source_imag
		//		/* output wire [10:0] */ .fftpts_out  ()  //       .fftpts_out			
		//	);
			
			
			
			
			 fft_1k_fp 
			fft_1k_inst (
				/* input  wire        */ .clk           ,                  //    clk.clk
				/* input  wire        */ .reset_n(!reset)       ,              //    rst.reset_n
				/* input  wire        */ .sink_valid(avst_indata.valid)    ,           //   sink.sink_valid
				/* output wire        */ .sink_ready(/*avst_indata.ready*/)    ,           //       .sink_ready
				/* input  wire [1:0]  */ .sink_error(/*avst_indata.error*/)    ,           //       .sink_error
				/* input  wire        */ .sink_sop(avst_indata.sop)      ,             //       .sink_sop
				/* input  wire        */ .sink_eop(avst_indata.eop)      ,             //       .sink_eop
				/* input  wire [31:0] */ .sink_real(float_avst_input_data[i].float_real),                 //       .sink_real
				/* input  wire [31:0] */ .sink_imag(0)    ,            //       .sink_imag
				/* input  wire [10:0] */ .fftpts_in(fftpts_in)     ,            //       .fftpts_in
				/* output wire        */ .source_valid(fft_source_data_raw.packet[i].valid                      ), 
				/* input  wire        */ .source_ready(fft_source_data_raw.packet[i].ready                      ), 
				/* output wire [1:0]  */ .source_error(fft_source_data_raw.packet[i].error                      ), 
				/* output wire        */ .source_sop  (fft_source_data_raw.packet[i].sop                        ), 
				/* output wire        */ .source_eop  (fft_source_data_raw.packet[i].eop                        ), 
				/* output wire [31:0] */ .source_real (fft_source_data_raw.packet[i].complex_data.real_component), 
				/* output wire [31:0] */ .source_imag (fft_source_data_raw.packet[i].complex_data.imag_component), 
				/* output wire [10:0] */ .fftpts_out  ()           //       .fftpts_out
			);			
			
			always_comb
			begin
					fft_source_data.packet[i].valid                       = fft_source_data_raw.packet[i].valid &  fft_source_data.packet[i].ready  ;
					fft_source_data_raw.packet[i].ready                   = fft_source_data.packet[i].ready                                         ;
					fft_source_data.packet[i].error                       = fft_source_data_raw.packet[i].error                                     ;
					fft_source_data.packet[i].sop                         = fft_source_data_raw.packet[i].sop  &  fft_source_data.packet[i].ready   ;
					fft_source_data.packet[i].eop                         = fft_source_data_raw.packet[i].eop                                       ;
					fft_source_data.packet[i].complex_data.real_component = fft_source_data_raw.packet[i].complex_data.real_component               ;
					fft_source_data.packet[i].complex_data.imag_component = fft_source_data_raw.packet[i].complex_data.imag_component               ;
			end

			
	   end
	   
endgenerate

generate_fft_bypass_float
#(
.numchannels(numchannels),
.stream_index(stream_index),
.input_bits_to_shift_left(input_bits_to_shift_left_for_bypass)
)
generate_fft_bypass_float_inst
(
.avst_indata,
.float_bypass_data(float_avst_input_data),
.invert_imag(invert_bypass_imag),
.reset,
.clk
);

					

radix4_stage1_butterfly_fp_input
#(
.pipeline_match_delay_val(pipeline_match_delay_val),
.numchannels(numchannels),
.bits_per_packet(fft_source_data.get_bits_per_packet()),
.num_phase_bits (dds_num_phase_bits ), 
.num_output_bits(dds_num_output_bits),
.ENABLE_KEEPS(ENABLE_KEEPS)
)
radix4_stage1_butterfly_inst
(
.indata(fft_source_data),
//.sample_since_reset_count,
.phi_inc_i,
.sine_waveform_out  (),
.cosine_waveform_out(),
.butterfly_out_Yr_plus_WN_2r_Gr,
.butterfly_out_Yr_minus_WN_2r_Gr,
.butterfly_out_WN_r_Zr_plus_WN_3r_Hr,
.butterfly_out_WN_r_Zr_minus_WN_3r_Hr,
.pipeline_delay,
.reset,
.clk
);

radix4_stage2_butterfly 
radix4_stage2_butterfly_inst
(
.butterfly_out_Yr_plus_WN_2r_Gr,
.butterfly_out_Yr_minus_WN_2r_Gr,
.butterfly_out_WN_r_Zr_plus_WN_3r_Hr,
.butterfly_out_WN_r_Zr_minus_WN_3r_Hr,
.Xr,
.Xr_plus_N_div_4 ,
.Xr_plus_2N_div_4,
.Xr_plus_3N_div_4,
.reset,
.clk
);



convert_float_to_magnitude_squared
#(
.num_arguments(numchannels)
)
convert_float_to_magnitude_squared_inst
(
.indata('{Xr,Xr_plus_N_div_4,Xr_plus_2N_div_4,Xr_plus_3N_div_4}),
.out_float(out_magnitude_squared_float),
.reset,
.clk
);


generate
	   if (stream_index == 0)
	   begin		                      
					assign fft_complex_avst_outdata.clk = clk;			
	   end
endgenerate
	  
simple_variable_delay_by_shiftreg
#(
  .width(3),
  .delay_val(fft_complex_avst_outdata_delay_val_for_sop_eop_valid)
)
fft_complex_avst_outdata_fixed_delay_by_shiftreg_inst
(
  .indata({select_float_bypass ? avst_indata.valid: fft_source_data.packet[0].valid,
         select_float_bypass ? avst_indata.sop    : fft_source_data.packet[0].sop  ,
		 select_float_bypass ? avst_indata.eop    : fft_source_data.packet[0].eop   }),
  .outdata({fft_complex_avst_outdata.valid,fft_complex_avst_outdata.sop,fft_complex_avst_outdata.eop}),
  .output_sel(ctrl_delay),
  .clk
 ); 	
	  
	  
	  
always_ff @(posedge clk)
begin
/*      fft_complex_avst_outdata.data[0] <=  select_float_bypass? {float_avst_input_data[0].float_imag,float_avst_input_data[0].float_real} : {Xr.float_imag              ,Xr.float_real              };
      fft_complex_avst_outdata.data[1] <=  select_float_bypass? {float_avst_input_data[1].float_imag,float_avst_input_data[1].float_real}  : {Xr_plus_N_div_4.float_imag ,Xr_plus_N_div_4.float_real };
      fft_complex_avst_outdata.data[2] <=  select_float_bypass? {float_avst_input_data[2].float_imag,float_avst_input_data[2].float_real}    {Xr_plus_2N_div_4.float_imag,Xr_plus_2N_div_4.float_real};
      fft_complex_avst_outdata.data[3] <=  select_float_bypass? {float_avst_input_data[3].float_imag,float_avst_input_data[3].float_real} :  {Xr_plus_3N_div_4.float_imag,Xr_plus_3N_div_4.float_real};
*/
	  fft_complex_avst_outdata.data[0] <=  select_float_bypass ? {float_avst_input_data[0].float_imag,float_avst_input_data[0].float_real} : {Xr.float_imag              ,Xr.float_real              };
      fft_complex_avst_outdata.data[1] <= select_float_bypass ? {float_avst_input_data[1].float_imag,float_avst_input_data[1].float_real} : {Xr_plus_N_div_4.float_imag ,Xr_plus_N_div_4.float_real };
      fft_complex_avst_outdata.data[2] <= select_float_bypass ? {float_avst_input_data[2].float_imag,float_avst_input_data[2].float_real} : {Xr_plus_2N_div_4.float_imag,Xr_plus_2N_div_4.float_real};
      fft_complex_avst_outdata.data[3] <= select_float_bypass ? {float_avst_input_data[3].float_imag,float_avst_input_data[3].float_real} : {Xr_plus_3N_div_4.float_imag,Xr_plus_3N_div_4.float_real};

	  
	  
end



endmodule
`default_nettype wire