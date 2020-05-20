`default_nettype none
import math_func_package::*;

module embed_into_2_bit_stream_parallel
#(
parameter parallel_data_width = 16,
parameter counter_width = math_func_package::my_clog2(parallel_data_width) + 1,
parameter num_parallel_2_bit_chunks = 4
)
(
input [parallel_data_width-1:0] parallel_data,
input clk,
output logic [num_parallel_2_bit_chunks-1 : 0] serial_data,
output logic [num_parallel_2_bit_chunks-1 : 0] serial_sop,
output reg [counter_width-1:0] bit_counter,
input MSB_first
);

reg [parallel_data_width-1:0] current_parallel_data;

genvar i;
generate 
         
		        always_ff @(posedge clk)
				begin
				       if (MSB_first)
					   begin
						   if ((bit_counter == (num_parallel_2_bit_chunks-1)) || (bit_counter > parallel_data_width - 1))
						   begin
								 bit_counter <= parallel_data_width - 1;
						   end else
						   begin
								bit_counter <= bit_counter - num_parallel_2_bit_chunks;
						   end
					   end else 
					   begin
							   if (bit_counter >= (parallel_data_width - num_parallel_2_bit_chunks))
							   begin
									 bit_counter <= 0;
							   end else
							   begin
									bit_counter <= bit_counter + num_parallel_2_bit_chunks;
							   end					   
					   end
				end		   
				
				for (i = 0; i < num_parallel_2_bit_chunks; i = i + 1)
				begin : generate_2_bit_chunks
					always_ff @(posedge clk)
					begin
					      if (MSB_first)
						  begin
						        serial_data[i] <= current_parallel_data[bit_counter - i];
						        serial_sop[i] <= (i == 0) ? (bit_counter  == (parallel_data_width - 1)) : 1'b0;
						  end else
						  begin
						  			 serial_data[i] <= current_parallel_data[bit_counter + i];
					                 serial_sop[i] <= (i == 0) ? (bit_counter == 0) : 1'b0;						  
						  end
					end
				end
				
				always_ff @(posedge clk)
				begin
				     if (MSB_first) 
					 begin
						 if (bit_counter == (num_parallel_2_bit_chunks-1))
						 begin
							  current_parallel_data <=  parallel_data;
						 end
					 end else
					 begin					 
							 if (bit_counter == (parallel_data_width - num_parallel_2_bit_chunks))
							 begin
								  current_parallel_data <=  parallel_data;							
					         end
					 end
				end
endgenerate




endmodule
`default_nettype wire