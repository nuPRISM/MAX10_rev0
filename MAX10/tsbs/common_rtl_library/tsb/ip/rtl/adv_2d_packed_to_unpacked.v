module adv_2d_packed_to_unpacked
#(
parameter numelements_out = 8,
parameter num_bits_per_elements_out = 8,
parameter numbits_in = num_bits_per_elements_out*numelements_out,
parameter start_index_in = 0,
parameter start_index_out = 0
)
(
input logic [numbits_in-1:0] in_packed,
output logic  [num_bits_per_elements_out-1:0] out_unpacked[numelements_out]
);

genvar i;
generate  
            for (i = 0; i < numbits_in/num_bits_per_elements_out; i++)
			begin : repackage_in_unpacked
			      assign out_unpacked[start_index_out+i][num_bits_per_elements_out-1:0] = in_packed[start_index_in+(i+1)*num_bits_per_elements_out-1 -: num_bits_per_elements_out]; 
			end
endgenerate

endmodule