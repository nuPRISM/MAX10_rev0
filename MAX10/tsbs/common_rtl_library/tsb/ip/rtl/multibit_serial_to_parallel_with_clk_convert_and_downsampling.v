module multibit_serial_to_parallel_with_clk_convert_and_downsampling
#(
  parameter width=8,
  parameter SIZE = 12,
  parameter downsample_counter_width = 8
  )
(
parallel_out, 
serial_in, 
clock_in,
clock_out,
downsample_rate
);
 
   output [SIZE*width-1:0]    parallel_out;
   input       [width-1:0]         serial_in;
   input                      clock_in;
   input						clock_out;
   input  [downsample_counter_width-1:0]  downsample_rate;
 
   reg [SIZE*width-1:0] parallel_out=0, parallel_out_raw=0;
     wire shift_enable;
	 
	 
    reg [downsample_counter_width-1:0] downsample_counter = 0;
    always @(posedge clock_in)
    begin
     	if  (downsample_counter >= downsample_rate-1)
	    	downsample_counter <= 0;
	    else
		    downsample_counter <= downsample_counter + 1;
     end

	 assign shift_enable = (downsample_rate == 1) ? 1'b1 : (downsample_counter == (downsample_rate-1)); //enable shift only when downsampling
  	 
     always @(posedge clock_in) 
	 begin
        if (shift_enable)
         parallel_out_raw <= {parallel_out_raw[SIZE*width-width-1:0],serial_in};
     end
 
     always @(posedge clock_out)
	   parallel_out <= parallel_out_raw;
		
endmodule