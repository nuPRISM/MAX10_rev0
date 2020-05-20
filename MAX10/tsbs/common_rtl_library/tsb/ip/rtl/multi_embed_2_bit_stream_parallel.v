`default_nettype none
import math_func_package::*;
`include "embedded_2_bit_serial_data_interface.v"

module multi_embed_2_bit_stream_parallel
#(
parameter num_data_streams = 4,
parameter parallel_data_width = 16,
parameter counter_width = math_func_package::my_clog2(parallel_data_width) + 1,
parameter num_parallel_2_bit_chunks = 4
)
(
input [parallel_data_width-1:0] parallel_data[num_data_streams],
input clk,
input clock_enable,
embedded_2_bit_serial_data_interface embedded_2_bit_serial_data_interface_pins,
output reg [counter_width-1:0] bit_counter,
input MSB_first
);

reg [parallel_data_width-1:0] current_parallel_data[num_data_streams];

genvar i;
genvar current_stream;
generate 
 
		        always_ff @(posedge clk)
				begin
				     if (clock_enable)
					 begin
				       if (MSB_first)
					   begin
						   if ((bit_counter == (num_parallel_2_bit_chunks-1)) || (bit_counter > parallel_data_width - 1) || (bit_counter ==  0))
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
				end		 

                always_ff @(posedge clk)
				begin
				     if (clock_enable)
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
				end
				
		 for (current_stream = 0; current_stream < num_data_streams; current_stream++)
		 begin : per_stream
				for (i = 0; i < num_parallel_2_bit_chunks; i = i + 1)
				begin : generate_2_bit_chunks
					always_ff @(posedge clk)
					begin
					      if (clock_enable)
						  begin
								  if (MSB_first)
								  begin
										embedded_2_bit_serial_data_interface_pins.serial_data[current_stream][i] <= current_parallel_data[current_stream][bit_counter - i];
										embedded_2_bit_serial_data_interface_pins.serial_sop [current_stream][i] <= (i == 0) ? (bit_counter  == (parallel_data_width - 1)) : 1'b0;
								  end else
								  begin
										embedded_2_bit_serial_data_interface_pins.serial_data[current_stream][i] <= current_parallel_data[current_stream][bit_counter + i];
										embedded_2_bit_serial_data_interface_pins.serial_sop [current_stream][i] <= (i == 0) ? (bit_counter == 0) : 1'b0;						  
								  end
						  end
					end
				end
		end
endgenerate




endmodule

`default_nettype wire