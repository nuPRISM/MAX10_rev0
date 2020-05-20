module adv_2d_unpacked_to_packed
#(
parameter numelements_in = 8,
parameter num_bits_per_elements_in = 8,
parameter numbits_out = num_bits_per_elements_in*numelements_in,
parameter start_index_in = 0,
parameter start_index_out = 0
)
(
input logic  [num_bits_per_elements_in-1:0] in_unpacked[numelements_in],
output logic [numbits_out-1:0] out_packed
);

genvar i;
generate  
            for (i = 0; i < numbits_out/num_bits_per_elements_in; i++)
			begin : repackage_in_unpacked
			      assign out_packed[start_index_out+(i+1)*num_bits_per_elements_in-1 -: num_bits_per_elements_in] = in_unpacked[start_index_in+i][num_bits_per_elements_in-1:0];
			end
endgenerate

endmodule