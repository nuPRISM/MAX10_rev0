module unsigned_B_bits_from_A_signed_bits #(parameter WidthA = 8, 
parameter WidthB = 12) (input [WidthA-1:0] inbus, output [WidthB-1:0] outbus);

localparam WidthB_minus1 = WidthB-1;
localparam constant_1 = 1'b1;
localparam constant_0 = 1'b0;
wire [WidthB-1:0] DC_offset = {constant_0,{WidthB_minus1{constant_1}}};

wire [WidthB-1:0] sign_extended_input;

sign_extend_and_amplify #(.indata_width(WidthA),
.outdata_width(WidthB)) sign_extend_and_amplify_inst
(.indata(inbus), 
.outdata(sign_extended_input));

generate
			if (WidthB <= WidthA)
				assign  outbus = {~inbus[WidthA-1],inbus[WidthA-2 -: (WidthB-1)]};
			else
			begin
				 assign  outbus = {(~sign_extended_input[WidthB-1]),sign_extended_input[WidthB-2:0]};
			end
endgenerate

endmodule