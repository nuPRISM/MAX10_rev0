
module multi_channel_12bit_reframer
#(
      parameter numchannels = 2
)
(
input deser_clk,
input FrameClk,
input [3:0] frame_select,
//input [5:0] data_in[numchannels-1:0],
input [11:0] data_in[numchannels-1:0],
output reg [11:0] data_out[numchannels-1:0],
output reg [23:0] raw_24_bit_data[numchannels-1:0],
 input transpose_channel_data_halves,
 input bitwise_transpose_before_24_bits,
 input bitwise_transpose_after_24_bits,
 input bitwise_transpose_data_out     
);

reg [11:0] data_out_raw[numchannels-1:0];

      genvar i;
      generate	        
      					   for (i = 0; i < numchannels; i++)
      					   begin : reframe
      						    //regen_12bit_datastream
      						    //regen_12bit_datastream_inst
      						    //(
      						    // .raw_6bit_data(data_in[i]),
      						    // .raw_24_bit_data(raw_24_bit_data[i]),
      						    // .selected_data(data_out_raw[i]),
      						    // .selection_index(frame_select),
      						    // .transpose_channel_data_halves(transpose_channel_data_halves),
      						    // .clk(deser_clk),
      						    // .clk_div2(FrameClk)
      						    //);	
								 
								regen_12bit_datastream_from_12bit_frame
      						    regen_12bit_datastream_inst
      						    (
      						     .raw_12bit_data(data_in[i]),
      						     .raw_24_bit_data(raw_24_bit_data[i]),
      						     .selected_data(data_out_raw[i]),
      						     .selection_index(frame_select),
      						     .transpose_channel_data_halves     (transpose_channel_data_halves   ),
								 .bitwise_transpose_before_24_bits  (bitwise_transpose_before_24_bits),
								 .bitwise_transpose_after_24_bits   (bitwise_transpose_after_24_bits ),
								 .bitwise_transpose_data_out        (bitwise_transpose_data_out      ),								
      						     .clk(FrameClk)
      						    );	
								 
      						     always @(posedge FrameClk)
      					         begin		   
      						         data_out[i] <= data_out_raw[i];							  
      					         end	  		
      					   end      					   
      endgenerate
endmodule

