module make_parallel_alternating_output
#(
parameter width = 10,
parameter init_value = {(width/2){2'b10}}
)
(
 input start,
 input sm_clk,
 output [width-1:0] outdata,
 output finish
 );
 
 reg [width-1:0] internal_reg = init_value;
 always @(posedge start)
 begin
      if (!(((width+1)/2) == width/2))
	  begin
           internal_reg <= ~internal_reg; //odd number, so alternate
      end else
	  begin
	       internal_reg <= internal_reg; //even number, so don't alternate
	  end
 end
 
 
async_trap_and_reset 
make_finish_sig
(.async_sig(start), 
.outclk(sm_clk), 
.out_sync_sig(finish), 
.auto_reset(1'b1), 
.reset(1'b1));

 
 assign outdata = internal_reg;
 
 endmodule
 
 