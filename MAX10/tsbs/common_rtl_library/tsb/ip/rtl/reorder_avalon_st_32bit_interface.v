`default_nettype none
`include "interface_defs.v"
module reorder_avalon_st_32bit_interface
#(
parameter use_clk_from_avalon_st_interface_in = 0,
parameter connect_clocks = 1
)
(
avalon_st_32_bit_packet_interface  avalon_st_interface_in,
avalon_st_32_bit_packet_interface  avalon_st_interface_out,
input reorder
);

assign avalon_st_interface_in.ready  = avalon_st_interface_out.ready;

generate
        if (connect_clocks) 
		begin
			if (use_clk_from_avalon_st_interface_in) 
			begin
				 assign avalon_st_interface_out.clk    = avalon_st_interface_in.clk; //clk is assumed to come from in interface		
			end else
			begin
				 assign avalon_st_interface_in.clk    = avalon_st_interface_out.clk; //clk is assumed to come from out interface		
			end
		end
endgenerate


controlled_byte_reorder_of_word
controlled_byte_reorder_of_word_inst
(
.inword (avalon_st_interface_in.data),
.outword(avalon_st_interface_out.data),
.reorder(reorder)
);

assign avalon_st_interface_out.valid = avalon_st_interface_in.valid;
assign avalon_st_interface_out.sop   = avalon_st_interface_in.sop;
assign avalon_st_interface_out.eop   = avalon_st_interface_in.eop;
assign avalon_st_interface_out.empty = avalon_st_interface_in.empty;
assign avalon_st_interface_out.error = avalon_st_interface_in.error;

endmodule
