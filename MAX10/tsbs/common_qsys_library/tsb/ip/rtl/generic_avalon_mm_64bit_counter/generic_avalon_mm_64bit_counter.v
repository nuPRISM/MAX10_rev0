module generic_avalon_mm_64bit_counter
(
 input	clk,
 input reset,
 input read_now,
 input write_now,
 input [0:0] address,
 output reg [31:0] read_data,
 input [31:0] write_data,
 output reg [63:0] the_counter=0
);

reg [63:0] snapshot_reg=0;

always @(posedge clk or posedge reset)
begin
     if (reset)
	 begin
	  the_counter <= 0;
	 end
	 else
	 begin
           the_counter <= the_counter+64'b1;
	  end
end


always @(posedge clk)
begin
     if (write_now)
     begin
          snapshot_reg <= the_counter;
     end
end

always @(posedge clk)
begin
     if (read_now)
	  begin
	     if (address == 1'b0)
	     begin
	          read_data <= snapshot_reg[31:0];
	     end else
	     begin
	          read_data <= snapshot_reg[63:32];
	     end
	 end
end

endmodule
