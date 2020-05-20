module regen_12bit_datastream_from_12bit_frame
(
 input [11:0] raw_12bit_data,
 output logic [23:0]  raw_24_bit_data,
 output logic [11:0]  selected_data,
 input [3:0] selection_index,
 input clk,
 input transpose_channel_data_halves,
 input bitwise_transpose_before_24_bits,
 input bitwise_transpose_after_24_bits,
 input bitwise_transpose_data_out      
 );
 
 
 (* keep = 1 *) logic  [23:0] raw_24_bit_data_keeper;
 (* keep = 1 *) logic  [23:0] actual_24_bit_data_keeper;
 (* keep = 1 *) logic  [11:0] selected_data_raw;
 (* keep = 1 *) logic  [11:0] possibly_xposed_raw_12bit_data;
 
 assign raw_24_bit_data = actual_24_bit_data_keeper;
 
 always @(posedge clk)
begin
     if (!bitwise_transpose_before_24_bits)
	begin
         possibly_xposed_raw_12bit_data <= raw_12bit_data;
    end else
	begin
	     for (int i = 0; i < $size(raw_12bit_data); i++)
		 begin
		 		possibly_xposed_raw_12bit_data[i] <= raw_12bit_data[$size(raw_12bit_data)-1-i];
		 end	
	end
 end
 
 
always @(posedge clk)
begin
    if (transpose_channel_data_halves)
	   raw_24_bit_data_keeper <= {possibly_xposed_raw_12bit_data,raw_24_bit_data_keeper[23 -: 12]};
	else
       raw_24_bit_data_keeper <= {raw_24_bit_data_keeper[11:0], possibly_xposed_raw_12bit_data};
end 
 
 
  always @(posedge clk)
begin
     if (!bitwise_transpose_after_24_bits)
	begin
         actual_24_bit_data_keeper <= raw_24_bit_data_keeper;
    end else
	begin
	     for (int i = 0; i < $size(raw_24_bit_data_keeper); i++)
		 begin
		 		actual_24_bit_data_keeper[i] <= raw_24_bit_data_keeper[$size(raw_24_bit_data_keeper)-1-i];
		 end	
	end
 end
 
 
data_chooser_12bit_according_to_frame_position 
data_chooser_12bit_according_to_frame_position_inst 
(
 .data_reg_contents(actual_24_bit_data_keeper),
 .selection_value(selection_index),
 .selected_data_reg_contents(selected_data_raw),
 .clk(clk)
);

always @(posedge clk)
begin
    if (!bitwise_transpose_data_out)
	begin
         selected_data <= selected_data_raw;
    end else
	begin
	     for (int i = 0; i < $size(selected_data); i++)
		 begin
		 		  selected_data[i] <= selected_data_raw[$size(selected_data)-1-i];
		 end	
	end
end
endmodule
