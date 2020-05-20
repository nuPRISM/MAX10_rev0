`default_nettype none
module to_fast_clk_interface_better(indata,outdata,inclk,outclk,actual_CE);
//the purpose of this module is to ensure that the CE of the 
//output data does not change near the output clock to avoid a race.
//inclk must be much slower than outclk

parameter width = 32;
parameter synchronizer_depth = 2;

input [width-1:0]  indata;
output [width-1:0] outdata;
input inclk,outclk;
output actual_CE;
reg[width-1:0] outdata;

logic trapped_input_clk;
logic actual_CE;

async_trap_and_reset_gen_1_pulse_robust
#(.synchronizer_depth(synchronizer_depth))
trap_input_clock(
.async_sig(inclk), 
.outclk(outclk), 
.out_sync_sig(), 
.unregistered_out_sync_sig(trapped_input_clk),
.auto_reset(1'b1), 
.reset(1'b1)
);

assign actual_CE  = trapped_input_clk;

always @ (posedge outclk)
begin
      if (actual_CE)
		begin
			  outdata <= indata;
		end
end


endmodule
`default_nettype wire