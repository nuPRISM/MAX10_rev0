import math_func_package::*;

module embed_into_2_bit_stream
#(
parameter parallel_data_width = 16,
parameter counter_width = math_func_package::my_clog2(parallel_data_width) + 1,
parameter MSB_first = 1'b1
)
(
input [parallel_data_width-1:0] parallel_data,
input clk,
output logic serial_data,
output logic serial_sop,
output reg [counter_width-1:0] bit_counter
);

reg [parallel_data_width-1:0] current_parallel_data;

generate 
           if (MSB_first)
		   begin
		        always_ff @(posedge clk)
				begin
					   if ((bit_counter == 0) || (bit_counter > parallel_data_width - 1))
					   begin
							 bit_counter <= parallel_data_width - 1;
					   end else
					   begin
							bit_counter <= bit_counter - 1;
					   end
				end		   
				
				always_ff @(posedge clk)
				begin
					 serial_data <= current_parallel_data[bit_counter];
					 serial_sop <= (bit_counter == (parallel_data_width - 1));
				end
				
				always_ff @(posedge clk)
				begin
					 if (bit_counter == 0)
					 begin
						  current_parallel_data <=  parallel_data;
					 end
				end

		   end else
		   begin
		   
				always_ff @(posedge clk)
				begin
					   if (bit_counter >= (parallel_data_width - 1))
					   begin
							 bit_counter <= 0;
					   end else
					   begin
							bit_counter <= bit_counter + 1;
					   end
				end
				
				always_ff @(posedge clk)
				begin
					 serial_data <= current_parallel_data[bit_counter];
					 serial_sop <= (bit_counter == 0);
				end
				
				always_ff @(posedge clk)
				begin
					 if (bit_counter == (parallel_data_width - 1))
					 begin
						  current_parallel_data <=  parallel_data;
					 end
				end

            end
endgenerate




endmodule