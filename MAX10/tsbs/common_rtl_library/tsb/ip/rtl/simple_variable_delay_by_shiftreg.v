`include "math_func_package.v"

module simple_variable_delay_by_shiftreg
#(parameter width = 8,
  parameter delay_val=22,
  parameter log2_num_of_taps = my_clog2(delay_val)
)
(
 input logic [width-1:0] indata,
 output logic [width-1:0] outdata,
 input [log2_num_of_taps-1:0] output_sel,
 input clk
 );
 
  
 reg [width-1:0] delay_regs[delay_val];
  
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
    outdata <= delay_regs[output_sel];
end

endmodule
 