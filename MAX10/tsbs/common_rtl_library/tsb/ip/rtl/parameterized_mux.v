module parameterized_mux (outdata, sel, indata);

parameter width = 8; // number of bits wide
parameter number_of_inputs = 4; // number of inputs
parameter number_of_select_lines = 2; // number of select lines

localparam total_num_of_input_bits= number_of_inputs * width;

input [total_num_of_input_bits-1:0] indata;
input [number_of_select_lines-1:0] sel;
output [width-1:0] outdata;

integer i;
reg[width-1:0] tmp, outdata; // tmp will be use to minimize events

always @*
begin
	for(i=0; i < width; i = i + 1) // for bits in the width
	tmp[i] = indata[width*sel + i];
	outdata = tmp;
end

endmodule