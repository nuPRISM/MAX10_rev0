

module mod_m_counter
   #(
      parameter M=10,
	  N=$clog2(M)
   )
   (
    input  logic clk, reset,
    output logic max_tick,
    output logic [N-1:0] q
   );

   //signal declaration
   reg [N-1:0] r_reg =0;
   logic [N-1:0] r_next;
   logic raw_max_tick;
   // body
   // register
   always @(posedge clk, posedge reset)
      if (reset)
         r_reg <= 0;
      else
         r_reg <= r_next;

   // next-state logic
   assign r_next = (r_reg==(M-1)) ? 0 : r_reg + 1;
   // output logic
   assign q = r_reg;
   assign raw_max_tick = (r_reg==(M-2)) ? 1'b1 : 1'b0;
   always @(posedge clk)
   begin
         max_tick <= raw_max_tick;
   end
endmodule