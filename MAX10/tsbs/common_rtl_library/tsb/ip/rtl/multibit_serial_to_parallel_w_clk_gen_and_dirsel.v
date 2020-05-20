module multibit_serial_to_parallel_w_clk_gen_and_dirsel
(
parallel_out, 
serial_in, 
clock_in,
clock_out,
clk_counter,
dir
);

 `include "log2_function.v"
  parameter serial_width=8;
  parameter parallel_ratio = 12;
  parameter USE_CLOCK_IN_NEGEDGE_TO_GENERATE_CLOCK_OUT = 1;
  parameter INITIAL_VALUE_OF_CLOCK_OUT = 0;
  parameter counter_width = log2(parallel_ratio)+1;

  
   output      [parallel_ratio*serial_width-1:0]    parallel_out;
   output reg  [counter_width-1:0]  clk_counter = 0;
   input        [serial_width-1:0]         serial_in;   
   input                            clock_in;
   output  reg 	                    clock_out = INITIAL_VALUE_OF_CLOCK_OUT;
   input                            dir;
   
generate
			if (USE_CLOCK_IN_NEGEDGE_TO_GENERATE_CLOCK_OUT)
			begin
					always @(negedge clock_in)
					begin
					     if ((clk_counter >= parallel_ratio/2-1) && (clk_counter < parallel_ratio-1))
						 begin
						      clk_counter <= clk_counter + 1;
							  clock_out <= !INITIAL_VALUE_OF_CLOCK_OUT;
						 end else 
						 begin
								 if (clk_counter >= parallel_ratio-1)
								 begin 									   
									   clk_counter <= 0;
									   clock_out <= INITIAL_VALUE_OF_CLOCK_OUT;									   
								 end else
								 begin
								      clk_counter <= clk_counter + 1;
									  clock_out <= clock_out;
								 end
						 end
					end
			end
			else
			begin
					always @(posedge clock_in)
					begin
					      if ((clk_counter >= parallel_ratio/2-1) && (clk_counter < parallel_ratio-1))
						 begin
						      clk_counter <= clk_counter + 1;
							  clock_out <= !INITIAL_VALUE_OF_CLOCK_OUT;
						 end else 
						 begin
								 if (clk_counter >= parallel_ratio-1)
								 begin 									   
									   clk_counter <= 0;
									   clock_out <= INITIAL_VALUE_OF_CLOCK_OUT;									   
								 end else
								 begin
								      clk_counter <= clk_counter + 1;
									  clock_out <= clock_out;
								 end
						 end
					end
			end
endgenerate
   
multibit_serial_to_parallel_with_clk_convert_and_dirsel
#(
 .width(serial_width),
 .SIZE(parallel_ratio)
)
multibit_serial_to_parallel_with_clk_convert_and_dirsel_inst
(
.parallel_out(parallel_out), 
.serial_in(serial_in), 
.shift_enable(1'b1),
.clock_in(clock_in),
.clock_out(clock_out),
.dir(dir)
);
 
		
endmodule
