`default_nettype none
`include "fft_support_pkg.v"
import fft_support_pkg::*;

module convert_fft_data_to_float 
#(
parameter numchannels,
parameter bits_per_packet
)
(
fft_source_avalon_st data_from_fft,
output complex_float float_data_from_fft[numchannels],
input reset,
input clk
);

genvar i;
generate
         for (i = 0; i < numchannels; i++)
		 begin : convert_channel
				convert_16bit_fixed_to_floating convert_fft_fixed_to_float_real (
						.clk    (clk),    //    clk.clk
						.areset (reset), // areset.reset
						.a      (data_from_fft.packet[i].complex_data.real_component),      //      a.a
						.q      (float_data_from_fft[i].float_real)       //      q.q
					);



				convert_16bit_fixed_to_floating convert_fft_fixed_to_float_imag (
						.clk    (clk),    //    clk.clk
						.areset (reset), // areset.reset
						.a(data_from_fft.packet[i].complex_data.imag_component),      //      a.a
						.q(float_data_from_fft[i].float_imag)       //      q.q
					);
		end
endgenerate



endmodule
`default_nettype wire