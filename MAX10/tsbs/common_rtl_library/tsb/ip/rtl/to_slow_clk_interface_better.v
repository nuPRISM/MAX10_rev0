`default_nettype none
module to_slow_clk_interface_better(indata,outdata,inclk,outclk,actual_CE);
//the purpose of this module is to ensure that the CE of the 
//output data does not change near the output clock to avoid a race.
//inclk must be much faster than outclk
//outclk must be at least 4.5 times slower than inclk to work

parameter width = 32;
parameter synchronizer_depth = 2;

input [width-1:0]  indata;
output [width-1:0] outdata;
input inclk,outclk;
output actual_CE;
reg[width-1:0] outdata, raw_outdata;

logic trapped_output_clk;
logic actual_CE;

async_trap_and_reset_gen_1_pulse_robust 
#(.synchronizer_depth(synchronizer_depth))
trap_output_clock(
.async_sig(outclk), 
.outclk(inclk), 
.out_sync_sig(), 
.unregistered_out_sync_sig(trapped_output_clk),
.auto_reset(1'b1), 
.reset(1'b1)
);

assign actual_CE  = trapped_output_clk;

always @ (posedge inclk)
begin
      if (actual_CE)
		begin
			  raw_outdata <= indata;
		end
end


always @ (posedge outclk)
begin
      outdata <= raw_outdata;
end

endmodule
`default_nettype wire