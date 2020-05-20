module adv_unpacked_to_packed
#(
parameter numbits_in = 8,
parameter numbits_out = numbits_in,
parameter start_index_in = 0,
parameter start_index_out = 0
)
(
input logic in_unpacked[numbits_in],
output logic [numbits_out-1:0] out_packed
);

genvar i;
generate  
            for (i = 0; i < numbits_out; i++)
			begin : repackage_in_unpacked
			      assign out_packed[start_index_out+i] = in_unpacked[start_index_in+i];
			end
endgenerate

endmodule