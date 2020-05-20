`default_nettype none
`include "fft_support_pkg.v"
import fft_support_pkg::*;

module convert_multiple_float_to_16bit_fixed 
#(
parameter numchannels,
parameter numbits_fixed = 16
)
(
input logic [31:0] in_float[numchannels],
output logic [numbits_fixed-1:0] out_fixed[numchannels],
input reset,
input clk
);

genvar i;
generate
         for (i = 0; i < numchannels; i++)
		 begin : convert_channel
				convert_floating_to_16bit_fixed convert_float_to_fixed (
						.clk    (clk),    //    clk.clk
						.areset (reset), // areset.reset
						.a(in_float[i]),      //      a.a
						.q(out_fixed[i])       //      q.q
					);
		end
endgenerate

endmodule
`default_nettype wire