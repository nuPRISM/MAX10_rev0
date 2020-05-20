module get_new_value_from_ram_and_shift_out_multibit
#( 
parameter addr_width = 12, data_width = 64, outwidth = 16, log2_datawidth = 6
)
(
output reg [addr_width-1:0] addr_out,
input  [addr_width-1:0] addr_min,
input  [addr_width-1:0] addr_max,
output reg out_clk_to_ram,
input in_clk,
output reg [log2_datawidth:0] current_partial_count=0, //1 extra bit for good measure
output reg [outwidth-1:0] current_partial_index=0,
input [data_width-1:0] data_from_ram,
output reg [outwidth-1:0] data_out,
output reg [outwidth-1:0] raw_data_out,
input reset_n,
input reverse_partial_order,
input reverse_output_bit_order
);

always @(negedge in_clk or negedge reset_n) //trigger on negede so that out_clk never in phase with in_clk
begin
     if (!reset_n)
	 begin
	      current_partial_count <= 0;
		  out_clk_to_ram <= 0;
		  current_partial_index <= 0;
     end
	 else
	 begin
	      if (current_partial_count >= (data_width-outwidth))
		  begin
		       current_partial_count <= 0;
			   out_clk_to_ram <= 1;
			   current_partial_index <= 0;
		  end else
		  begin
  		      current_partial_count <= current_partial_count + outwidth;
			  out_clk_to_ram <= 0;
			  current_partial_index <= current_partial_index+1;
		  end
	 end
end

localparam num_outwidths_in_datawidth = data_width/outwidth;

always @(posedge in_clk)
begin
      raw_data_out <= reverse_partial_order ? data_from_ram[(num_outwidths_in_datawidth-current_partial_index)*outwidth-1 -: outwidth] : 
	                         data_from_ram[(current_partial_index+1)*outwidth-1 -: outwidth]; 
end
always @(posedge in_clk)
begin
     for (integer i = 0; i < outwidth; i++)
	 begin
	       data_out[i] <= reverse_output_bit_order ?  raw_data_out[outwidth-i-1] : raw_data_out[i];
	 end
end

always @(negedge out_clk_to_ram)
begin
     if (addr_out >= addr_max)
	 begin
		   addr_out <= addr_min;
	 end else
     begin	 
	  	   addr_out <= addr_out+1;
	 end	  
end

endmodule
