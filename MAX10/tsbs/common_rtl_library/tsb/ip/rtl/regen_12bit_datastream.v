module regen_12bit_datastream
(
 input [5:0] raw_6bit_data,
 output logic [23:0]  raw_24_bit_data,
 output wire [11:0]  selected_data,
 input [3:0] selection_index,
 input transpose_channel_data_halves,
 input clk,
 input clk_div2
);
 
 
 (* keep = 1 *) logic  [23:0] raw_24_bit_data_keeper;
 assign raw_24_bit_data = raw_24_bit_data_keeper;
 
always @(posedge clk)
begin
    if (transpose_channel_data_halves)
	   raw_24_bit_data_keeper <= {raw_6bit_data,raw_24_bit_data_keeper[23:6]};
	else
       raw_24_bit_data_keeper <= {raw_24_bit_data_keeper, raw_6bit_data};
end 
 
data_chooser_12bit_according_to_frame_position 
data_chooser_12bit_according_to_frame_position_inst 
(
 .data_reg_contents(raw_24_bit_data_keeper),
 .selection_value(selection_index),
 .selected_data_reg_contents(selected_data),
 .clk(clk_div2)
);

endmodule
