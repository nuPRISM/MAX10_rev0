module fixed_delay_by_shiftreg
#(
  parameter width = 8,
  parameter delay_val=22
 )
(
 input [width-1:0] indata,
 output logic [width-1:0] outdata,
 output reg [width-1:0] delay_regs[delay_val],
 input clk
);
 
 
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

always_comb
begin
    outdata = delay_regs[delay_val-1];
end

endmodule
 