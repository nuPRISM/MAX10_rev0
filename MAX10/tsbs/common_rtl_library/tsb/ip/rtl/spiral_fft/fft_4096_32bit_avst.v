`default_nettype none
`include "fft_support_pkg.v"
`include "interface_defs.v"
`include "math_func_package.v"
import fft_support_pkg::*;

module fft_4096_32bit_avst 
#(
parameter NUM_STREAMS,
parameter NUM_SAMPLES_PER_CLOCK,
parameter fft_output_bits_per_component = 32,
parameter fft_input_bits_per_component  = 14,
parameter fft_input_bit_padded_length_per_component = 16,
parameter input_bits_to_shift_left = fft_input_bit_padded_length_per_component-fft_input_bits_per_component,
parameter ENABLE_KEEPS = 0,
parameter CONNECT_CLOCK_TO_OUTPUT_INTERFACE = 1,
parameter math_func_package::FFT_IMPLEMENTATION_METHOD_ENUM_TYPE FFT_IMPLEMENTATION_METHOD[NUM_STREAMS]
)
(
multiple_synced_st_streaming_interfaces                        avst_indata,
multiple_synced_st_streaming_interfaces_w_independent_controls fft_complex_avst_outdata,
output logic [fft_output_bits_per_component-1:0] real_data_in [NUM_STREAMS][NUM_SAMPLES_PER_CLOCK],
output logic [fft_output_bits_per_component-1:0] imag_data_in [NUM_STREAMS][NUM_SAMPLES_PER_CLOCK],
output logic [fft_output_bits_per_component-1:0] actual_real_data_in [NUM_STREAMS][NUM_SAMPLES_PER_CLOCK],
output logic [fft_output_bits_per_component-1:0] actual_imag_data_in [NUM_STREAMS][NUM_SAMPLES_PER_CLOCK],
output logic [fft_output_bits_per_component-1:0] real_data_out[NUM_STREAMS][NUM_SAMPLES_PER_CLOCK],
output logic [fft_output_bits_per_component-1:0] imag_data_out[NUM_STREAMS][NUM_SAMPLES_PER_CLOCK],
input invert_bypass_imag,
input select_bypass,
input reverse_input_sample_order,
input [31:0] zero_pad_count_threshold,
input reset,
input clk
);

logic out_sop[NUM_STREAMS];
logic out_eop[NUM_STREAMS];
logic out_valid[NUM_STREAMS];
	  
genvar current_stream;
genvar current_sample_index;
generate

         if (CONNECT_CLOCK_TO_OUTPUT_INTERFACE)
		 begin
		       assign fft_complex_avst_outdata.clk = avst_indata.clk;
		 end		 
		 
         for (current_stream = 0; current_stream < NUM_STREAMS; current_stream++)
		 begin : go_over_streams
		        always_ff @(posedge clk)
                begin						
					    fft_complex_avst_outdata.sop[current_stream] <= out_sop[current_stream];
					    fft_complex_avst_outdata.eop[current_stream] <= out_eop[current_stream];
					    fft_complex_avst_outdata.valid[current_stream] <= out_valid[current_stream];
				end

		        for (current_sample_index = 0; current_sample_index < NUM_SAMPLES_PER_CLOCK; current_sample_index++)
    		    begin : go_over_samples_per_clock
			              //shift left 14-bit input data to form 16 bit data, then sign extend to 32 bits
			             logic sign_of_current_data;
						 assign sign_of_current_data = avst_indata.data[current_stream][(current_sample_index*fft_input_bit_padded_length_per_component)+fft_input_bits_per_component-1];
			  			 assign real_data_in [current_stream][current_sample_index] = {{(fft_output_bits_per_component-fft_input_bit_padded_length_per_component){sign_of_current_data}},(avst_indata.data[current_stream][(current_sample_index+1)*fft_input_bit_padded_length_per_component-1 -: fft_input_bit_padded_length_per_component] << input_bits_to_shift_left)};			 
			  			 assign imag_data_in [current_stream][current_sample_index] = 0;		  
                         
						 always_ff @(posedge clk)
                         begin						
			  			       fft_complex_avst_outdata.data[current_stream][(2*fft_output_bits_per_component*(current_sample_index+1))-1 -: (2*fft_output_bits_per_component)] <= 
							                    select_bypass ? {invert_bypass_imag ? ~actual_real_data_in[current_stream][current_sample_index] : actual_real_data_in[current_stream][current_sample_index],actual_real_data_in[current_stream][current_sample_index]} 
															   : {imag_data_out[current_stream][current_sample_index],real_data_out[current_stream][current_sample_index]};
			  			 end                                                                                                                                                                                                                                                                                                 
		        end
				
			   logic actual_sop;
			   logic actual_valid;
			   
			 			
				always_ff @(posedge clk)
                begin						
					    actual_sop   <= avst_indata.sop;											 
					    actual_valid <= avst_indata.valid;											 
				end
				
				always_ff @(posedge clk)
                begin	
				       for (int i = 0; i < NUM_SAMPLES_PER_CLOCK; i++)
					   begin
					        actual_real_data_in [current_stream][i] <= reverse_input_sample_order ?  real_data_in [current_stream][NUM_SAMPLES_PER_CLOCK-1-i] : real_data_in [current_stream][i];
							actual_imag_data_in [current_stream][i] <= reverse_input_sample_order ?  imag_data_in [current_stream][NUM_SAMPLES_PER_CLOCK-1-i] : imag_data_in [current_stream][i];							
					   end					
				end
				
				
				case (FFT_IMPLEMENTATION_METHOD[current_stream])
				SPIRAL_FFT_UNSCALED_32BIT_4096_STREAMING_FFT, SPIRAL_FFT_UNSCALED_32BIT_4096_ITERATIVE_FFT:
										begin
											dft_4096_avst_fixed_32_bit_unscaled
											#(
											.FFT_IMPLEMENTATION_METHOD(FFT_IMPLEMENTATION_METHOD[current_stream])
											)
											dft_4096_avst_fixed_32_bit_unscaled_inst
											(
											.clk(clk),
											.reset  (reset),
											.in_sop   (actual_sop),
											.in_valid (actual_valid),
											.out_sop(out_sop[current_stream]),
											.out_eop(out_eop[current_stream]),
											.out_valid    (out_valid[current_stream]),
											.real_data_in (actual_real_data_in [current_stream]),
											.imag_data_in (actual_imag_data_in [current_stream]),
											.real_data_out(real_data_out[current_stream]),
											.imag_data_out(imag_data_out[current_stream]),
											.zero_pad_count_threshold(zero_pad_count_threshold)
											);	
										end	
										
			SPIRAL_FFT_UNSCALED_32BIT_8192_STREAMING_FFT:
										begin
											dft_8192_avst_fixed_32_bit_unscaled
											#(
											.FFT_IMPLEMENTATION_METHOD(FFT_IMPLEMENTATION_METHOD[current_stream])
											)
											dft_8192_avst_fixed_32_bit_unscaled_inst
											(
											.clk(clk),
											.reset  (reset),
											.in_sop   (actual_sop),
											.in_valid (actual_valid),
											.out_sop(out_sop[current_stream]),
											.out_eop(out_eop[current_stream]),
											.out_valid    (out_valid[current_stream]),
											.real_data_in (actual_real_data_in [current_stream]),
											.imag_data_in (actual_imag_data_in [current_stream]),
											.real_data_out(real_data_out[current_stream]),
											.imag_data_out(imag_data_out[current_stream]),
											.zero_pad_count_threshold(zero_pad_count_threshold)
											);	
										end	
										
										SPIRAL_FFT_SCALED_16BIT_8192_STREAMING_D_FFT, SPIRAL_FFT_SCALED_16BIT_8192_STREAMING_J_FFT:
										begin
													         logic [15:0] raw_real_data_out[NUM_STREAMS][NUM_SAMPLES_PER_CLOCK];											
                                 logic [15:0] raw_imag_data_out[NUM_STREAMS][NUM_SAMPLES_PER_CLOCK];
					
											dft_8192_avst_fixed_16_bit_scaled
											#(
											.FFT_IMPLEMENTATION_METHOD(FFT_IMPLEMENTATION_METHOD[current_stream])
											)
											dft_8192_avst_fixed_16_bit_scaled_inst
											(
											.clk(clk),
											.reset  (reset),
											.in_sop   (actual_sop),
											.in_valid (actual_valid),
											.out_sop(out_sop[current_stream]),
											.out_eop(out_eop[current_stream]),
											.out_valid    (out_valid[current_stream]),
											.real_data_in (actual_real_data_in [current_stream]),
											.imag_data_in (actual_imag_data_in [current_stream]),
											.real_data_out(raw_real_data_out[current_stream]),
											.imag_data_out(raw_imag_data_out[current_stream]),
											.zero_pad_count_threshold(zero_pad_count_threshold)
											);	
											
											for (current_sample_index = 0; current_sample_index < NUM_SAMPLES_PER_CLOCK; current_sample_index++)
											begin : pad_out_values_to_output_width2
													assign real_data_out[current_stream][current_sample_index] = {{(fft_output_bits_per_component - 16) {raw_real_data_out[current_stream][current_sample_index][15]}},raw_real_data_out[current_stream][current_sample_index]};
													assign imag_data_out[current_stream][current_sample_index] = {{(fft_output_bits_per_component - 16) {raw_imag_data_out[current_stream][current_sample_index][15]}},raw_imag_data_out[current_stream][current_sample_index]};
											end
											
										end	
										
				SPIRAL_FFT_SCALED_16BIT_4096_STREAMING_FFT, SPIRAL_FFT_SCALED_16BIT_4096_ITERATIVE_FFT:
								begin
								         logic [15:0] raw_real_data_out[NUM_STREAMS][NUM_SAMPLES_PER_CLOCK];											
                                 logic [15:0] raw_imag_data_out[NUM_STREAMS][NUM_SAMPLES_PER_CLOCK];
											
											dft_4096_avst_fixed_16_bit_scaled
											#(
											.FFT_IMPLEMENTATION_METHOD(FFT_IMPLEMENTATION_METHOD[current_stream])
											)
											dft_4096_avst_fixed_16_bit_scaled_inst
											(
											.clk(clk),
											.reset  (reset),
											.in_sop   (actual_sop),
											.in_valid (actual_valid),
											.out_sop(out_sop[current_stream]),
											.out_eop(out_eop[current_stream]),
											.out_valid    (out_valid[current_stream]),
											.real_data_in (actual_real_data_in [current_stream]),
											.imag_data_in (actual_imag_data_in [current_stream]),
											.real_data_out(raw_real_data_out[current_stream]),
											.imag_data_out(raw_imag_data_out[current_stream]),
											.zero_pad_count_threshold(zero_pad_count_threshold)
											);	
																				
											for (current_sample_index = 0; current_sample_index < NUM_SAMPLES_PER_CLOCK; current_sample_index++)
											begin : pad_out_values_to_output_width
													assign real_data_out[current_stream][current_sample_index] = {{(fft_output_bits_per_component - 16) {raw_real_data_out[current_stream][current_sample_index][15]}},raw_real_data_out[current_stream][current_sample_index]};
													assign imag_data_out[current_stream][current_sample_index] = {{(fft_output_bits_per_component - 16) {raw_imag_data_out[current_stream][current_sample_index][15]}},raw_imag_data_out[current_stream][current_sample_index]};
											end
											
										end
               endcase										
		 end
endgenerate

		 



endmodule
`default_nettype wire