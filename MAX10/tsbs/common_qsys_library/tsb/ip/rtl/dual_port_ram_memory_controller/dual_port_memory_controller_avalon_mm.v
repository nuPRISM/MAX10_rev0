module dual_port_memory_controller_avalon_mm 
#(
parameter num_addr_bits = 12
)
(
 input	clk,
 input read_now,
 input write_now,
 input [num_addr_bits-1:0] address,
 output reg [31:0] read_data,
 input  [31:0] write_data,
 output [num_addr_bits-1:0] addr_to_dp_ram,
 input  [31:0] data_from_dp_ram,
 output  [31:0] data_to_dp_ram,
 output clk_to_dp_ram,
 output write_en,
 output read_en,
 input reset_n
);

assign clk_to_dp_ram = clk;
assign addr_to_dp_ram = address;

assign read_en = read_now;
assign write_en = write_now;

always @(posedge clk or negedge reset_n)
begin
     if (!reset_n) 
	 begin
	 end else
	 begin
			 if (read_now)
			 begin
				   read_data <= data_from_dp_ram;
			 end
	 end
end

assign data_to_dp_ram = write_data;

endmodule
