
module multi_channel_12bit_reframer_w_frame_recover
#(
      parameter numchannels = 2
)
(
  input deser_clk,
  output FrameClk,
  output [3:0] frame_select,
  input  [5:0] data_in[numchannels-1:0],
  output reg [11:0] data_out[numchannels-1:0],
  output reg [23:0] raw_24_bit_data[numchannels-1:0],
  output reg [11:0] raw_frame_reg = 0,
  output reg [11:0] frame_reg = 0,
  input transpose_frame_pattern,
  input transpose_channel_data_halves,
  input [$clog2(numchannels)-1:0] frame_channel_index,
  input [1:0] choose_data_in_delay,
  output frame_data_valid
);

reg [11:0] data_out_raw[numchannels-1:0];

reg [5:0] frame_channel_deser_output;
(* keep = 1, preserve = 1*)  reg deser_clk_div2 = 0;

always @(posedge deser_clk)
begin
      frame_channel_deser_output <= data_in[frame_channel_index];
end

reg  [5:0] actual_data_in[numchannels-1:0];
reg  [5:0] delayed_by_1clk_data_in [numchannels-1:0];
reg  [5:0] delayed_by_2clks_data_in[numchannels-1:0];
reg  [5:0] delayed_by_3clks_data_in[numchannels-1:0];


always @(posedge deser_clk)
begin
      delayed_by_1clk_data_in <= data_in;
      delayed_by_2clks_data_in <= delayed_by_1clk_data_in;
      delayed_by_3clks_data_in <= delayed_by_2clks_data_in;
	  
	  case (choose_data_in_delay)
	  2'b00 :  actual_data_in <= data_in;
	  2'b01 :  actual_data_in <= delayed_by_1clk_data_in;
	  2'b10 :  actual_data_in <= delayed_by_2clks_data_in;
	  2'b11 :  actual_data_in <= delayed_by_3clks_data_in;
	  endcase
end

			  always @(posedge deser_clk)
			  begin
			       if (transpose_frame_pattern)
				     raw_frame_reg <= {frame_channel_deser_output,raw_frame_reg[11:6]};
				   else
					 raw_frame_reg <= {raw_frame_reg[5:0],frame_channel_deser_output};
			  end 
			  
			  always @(posedge deser_clk_div2)
			  begin
			      frame_reg <= raw_frame_reg;			  
			  end
			  
			  wire [3:0] raw_frame_select;
			  
			  get_12bit_frame_transposition_value
			  get_12bit_frame_transposition_value_inst 
			  (
				.frame_reg_contents(frame_reg),
				.transposition_value(raw_frame_select),
				.is_valid(frame_data_valid)
			  ); 
			  
			  always @(negedge deser_clk)
			  begin
				   deser_clk_div2 <= ~deser_clk_div2;
				   
			  end
			  
			  assign FrameClk = deser_clk_div2;

			  always @(posedge FrameClk)
			  begin
			        frame_select <= raw_frame_select;
			  end
			  

			  genvar i;
			  generate
			              for (i = 0; i < numchannels; i++)
			              begin : reframe
			 	               regen_12bit_datastream
			 	               regen_12bit_datastream_inst
			 	               (
			 	                .raw_6bit_data(actual_data_in[i]),
			 	                .raw_24_bit_data(raw_24_bit_data[i]),
			 	                .selected_data(data_out_raw[i]),
			 	                .selection_index(frame_select),
			 	                .transpose_channel_data_halves(transpose_channel_data_halves),
			 	                .clk(deser_clk),
			 	                .clk_div2(FrameClk)
			 	               );			 
								
									 always @(posedge FrameClk)
									 begin		   
										data_out[i] <= data_out_raw[i];							  
									 end		
			              end				      					   
              endgenerate
endmodule

