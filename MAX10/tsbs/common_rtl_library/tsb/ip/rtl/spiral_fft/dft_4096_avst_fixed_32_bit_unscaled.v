
`define SPIRAL_FFT_ENCAPSULATING_MODULE_NAME dft_4096_avst_fixed_32_bit_unscaled_bedrock
//`define SPIRAL_FFT_DFT_INTERNAL_MODULE_NAME  dft_4096_fixed_32_bit_unscaled_iter_j
`define SPIRAL_FFT_DFT_INTERNAL_MODULE_NAME  dft_4096_fixed_32_bit_unscaled_iter_d
`include "generic_4samples_per_clk_spiral_fft.v"

`define SPIRAL_FFT_ENCAPSULATING_MODULE_NAME dft_4096_avst_fixed_32_bit_unscaled_bedrock_streaming
//`define SPIRAL_FFT_DFT_INTERNAL_MODULE_NAME  dft_4096_fixed_32_bit_unscaled_stream_j
`define SPIRAL_FFT_DFT_INTERNAL_MODULE_NAME  dft_4096_fixed_32_bit_unscaled_stream_d
`include "generic_4samples_per_clk_spiral_fft.v"
`include "math_func_package.v"
`default_nettype none
module dft_4096_avst_fixed_32_bit_unscaled
#(
parameter NUM_COUNTER_BITS = 16    ,
parameter NUM_FFT_SAMPLES  = 4096    ,
parameter NUMBITS_DATA  = 32       ,
parameter ENABLE_KEEPS = 0         ,
parameter NUM_SAMPLES_PER_CLOCK = 4,
parameter math_func_package::FFT_IMPLEMENTATION_METHOD_ENUM_TYPE FFT_IMPLEMENTATION_METHOD
)
(
input clk,
input reset,
input in_sop,
input in_valid, //assumes continuous valid from sop to eop, inclusive
output out_sop,
output out_eop,
output out_valid,
input  [NUMBITS_DATA-1:0] real_data_in [NUM_SAMPLES_PER_CLOCK],
input  [NUMBITS_DATA-1:0] imag_data_in [NUM_SAMPLES_PER_CLOCK],
output [NUMBITS_DATA-1:0] real_data_out[NUM_SAMPLES_PER_CLOCK],
output [NUMBITS_DATA-1:0] imag_data_out[NUM_SAMPLES_PER_CLOCK],
output logic [NUM_COUNTER_BITS-1:0] current_sample_count,
output logic [NUM_COUNTER_BITS-1:0] current_input_sample_count,
input  [NUM_COUNTER_BITS-1:0] zero_pad_count_threshold,
output logic debug_next_in,
output logic debug_next_out
);

import math_func_package::*;

generate
			if (FFT_IMPLEMENTATION_METHOD == SPIRAL_FFT_UNSCALED_32BIT_4096_STREAMING_FFT)
			begin
					dft_4096_avst_fixed_32_bit_unscaled_bedrock_streaming
					#(
					.NUM_COUNTER_BITS     (NUM_COUNTER_BITS     ), 
					.NUM_FFT_SAMPLES      (NUM_FFT_SAMPLES      ), 
					.NUMBITS_DATA         (NUMBITS_DATA         ),     
					.ENABLE_KEEPS         (ENABLE_KEEPS         ),     
					.NUM_SAMPLES_PER_CLOCK(NUM_SAMPLES_PER_CLOCK)
					)
					dft_4096_avst_fixed_32_bit_unscaled_bedrock_inst
					(
					.*
					);
			end
			
			
			if (FFT_IMPLEMENTATION_METHOD == SPIRAL_FFT_UNSCALED_32BIT_4096_ITERATIVE_FFT)
			begin			   
					dft_4096_avst_fixed_32_bit_unscaled_bedrock
					#(
					.NUM_COUNTER_BITS     (NUM_COUNTER_BITS     ), 
					.NUM_FFT_SAMPLES      (NUM_FFT_SAMPLES      ), 
					.NUMBITS_DATA         (NUMBITS_DATA         ),     
					.ENABLE_KEEPS         (ENABLE_KEEPS         ),     
					.NUM_SAMPLES_PER_CLOCK(NUM_SAMPLES_PER_CLOCK)
					)
					dft_4096_avst_fixed_32_bit_unscaled_bedrock_inst
					(
					.*
					);
			end
endgenerate

endmodule
`default_nettype wire
