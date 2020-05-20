module mod_m_counter_var_m_w_en
   #(
    parameter N=32 // number of bits in counter              
   )
   (
    input [N-1:0] M,
    input  logic clk, 
	input logic reset,
	input logic enable,
    output logic max_tick,
    output logic [N-1:0] q
   );

   //signal declaration
   reg [N-1:0] r_reg;
   wire [N-1:0] r_next;

   // body
   // register
   always @(posedge clk, posedge reset)
   begin
	   if (reset)
	   begin
		     r_reg <= 0;
	   end else
	   begin
		  if (enable)
		  begin
			 r_reg <= r_next;
		  end
	   end
   end

   // next-state logic
   assign r_next = (M==0) ? 0 : ((r_reg >=(M-1)) ? 0 : r_reg + 1);
   // output logic
   assign q = r_reg;
   
   always @(posedge clk, posedge reset)
   begin
        if (reset)
	    begin
		      max_tick <= 0;
	    end else
		begin
				if (enable)
				begin
					 max_tick <= (M==0) ? 1 : ((r_reg >=(M-1)) ? 1'b1 : 1'b0);
				end
		end
   end
endmodule