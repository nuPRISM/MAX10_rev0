module pn_gen_lfsr_w_lfsr_output(clk, pn_out, srl_i);

// LFSR length (ie, number of storage elements)
parameter Width = 17;

// Parameratize I LFSR taps.
// I channel LFSR has two taps.
// I(x) = X**17 + X**5 + 1
parameter I_tap1 = 0;
parameter I_tap2 = 5;

// Ports
input  clk;
output  pn_out;


// I  channel ////////////////////
output reg [Width-1:0] srl_i = 1; //initialize reg to nonzero value
wire lfsr_in_i, par_fdbk_i;

assign   pn_out = srl_i[I_tap1];
assign   par_fdbk_i = srl_i[I_tap2] ^ srl_i[I_tap1];
assign   lfsr_in_i = par_fdbk_i;

 always @(posedge clk)  
 begin
   srl_i <= {lfsr_in_i, srl_i[Width-1:1]};
 end

endmodule

