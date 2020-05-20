`default_nettype none
module control_up_frame_buf
#(
	parameter bit [31:0] buf_addr[3] = '{ 32'h14000000, 32'h18000000, 32'h1C000000 },
	parameter bit [31:0] one_hot_indexed_buffer_addresses[8] = '{ 32'h14000000,
                                                                  32'h10000000,	
	                                                              32'h18000000, 
																  32'h10000000,
																  32'h1C000000, 
																  32'h10000000,
																  32'h10000000,
																  32'h10000000}
)

(
	input clk,
	input enable,
    output reg   [2:0] current_read_buf_index  = 0,
    output reg   [2:0] current_write_buf_index = 1,
	output logic [2:0]  next_write_buffer_location,
    output logic [31:0] next_write_buffer_address,
    output logic [31:0] next_read_buffer_address,
    input [31:0] current_read_buffer_addr,
	input [31:0] current_write_buffer_addr,

    input [31:0] last_read_buffer_addr,
    input [31:0] last_write_buffer_addr,
    input reader_is_currently_reading
	 
);

always @(posedge clk)
begin
     next_read_buffer_address <= last_write_buffer_addr;
end

always @(posedge clk)
begin
       for (int i = 0; i < 3; i++)
	   begin : set_next_buf_indices
	         current_read_buf_index[i]  <= (current_read_buffer_addr == buf_addr[i]);
	         current_write_buf_index[i] <= (current_write_buffer_addr == buf_addr[i]);			 
	   end
end

assign next_write_buffer_location = ~(current_read_buf_index ^ current_write_buf_index); //if there is more than one hot bit, maybe route to dummy buffer and discard

always @(posedge clk)
begin
     if (enable)
	 begin
		      if (reader_is_currently_reading)
			  begin
			       next_write_buffer_address <= one_hot_indexed_buffer_addresses[next_write_buffer_location];
			  end else 
			  begin
			       next_write_buffer_address <= last_read_buffer_addr;			  
			  end			  
     end	 
end



endmodule
`default_nettype wire