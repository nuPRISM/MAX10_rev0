
`include "fft_support_pkg.v"
import fft_support_pkg::*;

module delay_fft_data 
#(
parameter delay_val,
parameter numchannels,
parameter bits_per_packet

)
(
interface indata,
interface outdata,
input [$clog2(delay_val)-1:0] delay_select,
input clk
);

genvar i;
generate
			for (i = 0; i < numchannels; i++)
			begin  : delay_per_channel           
			
			
					simple_variable_delay_by_shiftreg
					#(
					  .width(bits_per_packet),
					  .delay_val(delay_val)
					)
					fixed_delay_by_shiftreg_inst
					(
					 .indata(indata.packet[i]),
					 .outdata(outdata.packet[i]),
					 .output_sel(delay_select),
					 .clk
					 ); 		
			
			/*
					fixed_delay_by_shiftreg
					#(
					  .width(bits_per_packet),
					  .delay_val(delay_val)
					)
					fixed_delay_by_shiftreg_inst
					(
					 .indata(indata.packet[i]),
					 .outdata(outdata.packet[i]),
					 .clk
					);
					*/
			end
endgenerate


endmodule