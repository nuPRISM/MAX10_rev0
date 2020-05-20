`default_nettype none
`include "fft_support_pkg.v"
`include "interface_defs.v"
import fft_support_pkg::*;

module generate_fft_bypass_float
#(
parameter numchannels,
parameter stream_index,
parameter input_bits_to_shift_left
)
(
multiple_synced_st_streaming_interfaces avst_indata,
output complex_float float_bypass_data[numchannels],
input invert_imag,
input reset,
input clk
);



genvar i;
generate
       for (i = 0; i < numchannels; i++)
		 begin : convert_channel
      		logic [15:0] data_to_send_to_bypass;
	         assign data_to_send_to_bypass = (avst_indata.data[stream_index][(i+1)*16-1 -: 16] << input_bits_to_shift_left);
				convert_16bit_fixed_to_floating convert_fft_fixed_to_float_real (
						.clk    (clk),    //    clk.clk
						.areset (reset), // areset.reset
						.a      (data_to_send_to_bypass),      //      a.a
						.q      (float_bypass_data[i].float_real)       //      q.q
					);



				convert_16bit_fixed_to_floating convert_fft_fixed_to_float_imag (
						.clk    (clk),    //    clk.clk
						.areset (reset), // areset.reset
						.a(invert_imag ? ~data_to_send_to_bypass : data_to_send_to_bypass),      //      a.a
						.q(float_bypass_data[i].float_imag)       //      q.q
					);
		end
endgenerate



endmodule
`default_nettype wire