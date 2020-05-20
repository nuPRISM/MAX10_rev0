module repackage_unpacked_to_packed
#(
parameter numbits = 8
)
(
input logic in_unpacked[numbits],
output logic [numbits-1:0] out_packed
);

genvar i;
generate  
            for (i = 0; i < numbits; i++)
			begin : repackage_in_unpacked
			      assign out_packed[i] = in_unpacked[i];
			end
endgenerate

endmodule