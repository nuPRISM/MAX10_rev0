`default_nettype none
`include "interface_defs.v"
module choose_between_two_streaming_avalon_st_interfaces
#(
parameter connect_clocks = 1,
parameter synchronizer_depth = 3
)
(
interface avalon_st_interface_in0,
interface avalon_st_interface_in1,
interface avalon_st_interface_out,
input wire sel,
input wire block_unconnected_interface
);


wire actual_sel;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_sel
(
.indata(sel),
.outdata(actual_sel),
.clk(avalon_st_interface_out.clk)
);

generate
			if (connect_clocks)
			begin
				  assign avalon_st_interface_in0.clk    = avalon_st_interface_out.clk; //clk is assumed to come from out interface		
				  assign avalon_st_interface_in1.clk    = avalon_st_interface_out.clk; //clk is assumed to come from out interface		
			end
endgenerate

always_comb
begin
       avalon_st_interface_in1.ready = actual_sel ? avalon_st_interface_out.ready  : (block_unconnected_interface ? 1'b0 : 1'b1);
	    avalon_st_interface_in0.ready = actual_sel ? (block_unconnected_interface ? 1'b0 : 1'b1) : avalon_st_interface_out.ready;
       avalon_st_interface_out.valid = actual_sel ? avalon_st_interface_in1.valid     : avalon_st_interface_in0.valid;
       avalon_st_interface_out.data  = actual_sel ? avalon_st_interface_in1.data      : avalon_st_interface_in0.data;     
end

endmodule
