`include "math_func_package.v"

module variable_delay_by_shiftreg
#(parameter width = 8,
  parameter delay_val=22,
  parameter extract_tap_every = 4,
  parameter number_of_extract_taps = delay_val/extract_tap_every,
  parameter log2_num_of_extract_taps = my_clog2(number_of_extract_taps)
)
(
 input [width-1:0] indata,
 output logic [width-1:0] outdata,
 output logic [width-1:0] alternate_outputs[number_of_extract_taps:0],
 input [log2_num_of_extract_taps-1:0] output_sel,
 input clk
 );
 
 
 
 reg [width-1:0] delay_regs[delay_val];
 
 assign alternate_outputs[0] = delay_regs[delay_val-1];
 
 always_comb
 begin
       for (integer j = 1; j <= number_of_extract_taps; j++)
	   begin
	        alternate_outputs[number_of_extract_taps-j+1] = delay_regs[((j-1)*extract_tap_every)+1];
	   end
 end
 
 always @(posedge clk)
 begin
      delay_regs[0] <= indata;
 end
 
 always @(posedge clk)
 begin
      integer i;
      for (i=1; i<delay_val; i++)
	  begin
	        delay_regs[i]<= delay_regs[i-1];
	  end
end

always @(posedge clk)
begin
    outdata <= alternate_outputs[output_sel];
end

endmodule
 