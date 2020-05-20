

module spi_oe_gen_for_ad9253_3wire_interface
(
input ssel_n,
input sclk,
input wire mosi,
output wire miso,
output reg s_oe_n,
output wire sdata,
input wire sdata_in,
output reg is_read_op = 0,
output reg [7:0] clk_count = 0
) /* synthesis black_box */;



always @(posedge sclk or posedge ssel_n)
begin 
     if (ssel_n)
	 begin
		  is_read_op <= 0;
		  clk_count <= 0;
	 end else
	 begin
	      if (clk_count == 0)
		  begin //stop counting once R/W bit is reached		        
				is_read_op <= sdata;
		  end
		  clk_count <= clk_count + 1;
	 end
end


always @(negedge sclk or posedge ssel_n)
begin 
     if (ssel_n)
	 begin
	      s_oe_n <= 0;
		 
	 end else
	 begin
		  if ((clk_count >= 16) & is_read_op)
		  begin
		  	     s_oe_n <= 1; //read operation
		  end else
		  begin
		  	     s_oe_n <= 0;  //write operation or operation type has not been determined yet
		  end 
    end
end

assign sdata = mosi; //only reaches ADC if output is enabled
assign miso = s_oe_n ?  sdata_in : 1'b0;
 
endmodule



