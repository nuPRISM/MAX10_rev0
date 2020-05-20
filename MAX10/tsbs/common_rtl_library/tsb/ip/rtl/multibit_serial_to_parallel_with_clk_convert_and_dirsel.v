module multibit_serial_to_parallel_with_clk_convert_and_dirsel
#(
  parameter width=8,
  parameter SIZE = 12
  )
(
parallel_out, 
serial_in, 
shift_enable,
clock_in,
clock_out,
dir
);
 
   output [SIZE*width-1:0]    parallel_out;
   input       [width-1:0]         serial_in;
   input                shift_enable;
   input                clock_in;
   input						clock_out;
   input dir;
 
   reg [SIZE*width-1:0] parallel_out=0, parallel_out_raw=0;
 
   always @(posedge clock_in) 
	begin
      if (shift_enable)
       parallel_out_raw <= dir ? {serial_in,parallel_out_raw[SIZE*width-1:width]} :  {parallel_out_raw[SIZE*width-width-1:0],serial_in};
   end
 
   always @(posedge clock_out)
	   parallel_out <= parallel_out_raw;
		
endmodule