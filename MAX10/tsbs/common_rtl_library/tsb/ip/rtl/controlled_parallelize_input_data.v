module controlled_parallelize_input_data
#(
parameter parallelization_ratio = 4,
parameter num_input_data_bits = 8,
parameter valid_output_word_counter_bits = 32,
parameter num_output_data_bits = parallelization_ratio*num_input_data_bits
)
(
input clk,
input logic [num_input_data_bits-1:0] data_in,
output reg [num_output_data_bits-1:0] data_out,
output reg [num_input_data_bits-1:0] output_regs[parallelization_ratio-1],
output reg [parallelization_ratio-1:0] current_byte_enable = 1,
output reg [valid_output_word_counter_bits-1:0] valid_data_word_count = 0,
input reset_byte_count,
input reset_valid_word_count,
input data_valid,
output new_data_word_ready_now
);

logic top_data_register_now;
assign top_data_register_now = !reset_byte_count && current_byte_enable[parallelization_ratio-1] && data_valid;

genvar i;
generate
for (i = 0; i < parallelization_ratio-1 ; i = i + 1)
		begin : make_output_regs
				always_ff @(posedge clk)
				begin
				      if (!reset_byte_count && current_byte_enable[i] && data_valid)
					  begin
					       output_regs[i] <= data_in;
					  end
					  
					  if (top_data_register_now)
					  begin
                           data_out[(i+1)*num_input_data_bits-1 -: num_input_data_bits]  <=  output_regs[i];
					  end
				end
		end
endgenerate 

always_ff @(posedge clk)
begin
      current_byte_enable <= ((current_byte_enable == 0) || reset_byte_count) ? 1 :  
	                         (data_valid ?  {current_byte_enable,current_byte_enable[parallelization_ratio-1]} : current_byte_enable);

end


always_ff @(posedge clk)
begin				    
	  if (top_data_register_now)
	  begin
           data_out[num_output_data_bits-1 -: num_input_data_bits]  <=  data_in;
	  end
end

always_ff @(posedge clk)
begin				    
	  if (top_data_register_now)
	  begin
           new_data_word_ready_now  <=  1;
	  end else
	  begin
           new_data_word_ready_now  <=  0;
	  end
end


always_ff @(posedge clk)
begin		
      if (reset_valid_word_count) 
	  begin
              valid_data_word_count<= 0;
	  end else
	  begin	  
			  if (top_data_register_now)
			  begin
				   valid_data_word_count <= valid_data_word_count + 1;
			  end
	  end	  
end

endmodule