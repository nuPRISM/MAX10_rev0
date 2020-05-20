`default_nettype none
`include "fft_support_pkg.v"
import fft_support_pkg::*;

module convert_float_to_magnitude_squared
#(
parameter num_arguments
)
(
input complex_float indata[num_arguments],
output logic [31:0] out_float[num_arguments],
input reset,
input clk
);


genvar i;
generate
		for (i = 0; i < num_arguments; i++)
		begin : per_channel_scalar_product
				scalar_product calc_mag_squared (
					.clk,    //    clk.clk
					.areset (reset), // areset.reset
					.q      (out_float[i]),      //      q.q
					.a0     (indata[i].float_real),     //     a0.a0
					.b0     (indata[i].float_real),     //     b0.b0
					.a1     (indata[i].float_imag),     //     a1.a1
					.b1     (indata[i].float_imag)      //     b1.b1
				);
       end
endgenerate

endmodule
`default_nettype wire