module multibit_serial_to_parallel_same_clk_with_valid
(
parallel_out, 
out_valid,
serial_in, 
in_valid,
clock,
clk_counter,
dir,
parallel_out_raw
);
`include "log2_function.v"

  parameter serial_width=8;
  parameter parallel_ratio = 12;
  parameter counter_width = log2(parallel_ratio)+1;
 
   output  reg [parallel_ratio*serial_width-1:0]    parallel_out=0;
   output  reg [parallel_ratio*serial_width-1:0] parallel_out_raw=0;

   output  reg  [counter_width-1:0]  clk_counter = 0;
   output  reg   out_valid = 0;
   input        [serial_width-1:0]         serial_in;   
      input                in_valid;

   input                            clock;
   input                            dir;
 
   always @(posedge clock)
   begin  
         if (in_valid)
		 begin
			 if (clk_counter < parallel_ratio-1)
			 begin
				  clk_counter <= clk_counter + 1;
				  out_valid <= 0;
			 end else 
			 begin
				  clk_counter <= 0;
				  out_valid <= 1;
			 end
		 end
	end
	
  always @(posedge clock) 
  begin
      if (in_valid)
	   begin
       parallel_out_raw <= dir ? {serial_in,parallel_out_raw[parallel_ratio*serial_width-1:serial_width]} :  {parallel_out_raw[parallel_ratio*serial_width-serial_width-1:0],serial_in};
	  end
  end
 
  always @(posedge clock)
  begin
       if (out_valid)
	   begin
	        parallel_out <= parallel_out_raw;
	   end
  end
endmodule