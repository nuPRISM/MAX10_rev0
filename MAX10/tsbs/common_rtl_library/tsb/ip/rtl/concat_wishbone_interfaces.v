`default_nettype none
`include "interface_defs.v"
module concat_wishbone_interfaces
#(
parameter use_clk_from_wishbone_interface_in = 0,
parameter connect_clocks = 1
)
(
wishbone_interface  wishbone_interface_in,
wishbone_interface  wishbone_interface_out
);

assign wishbone_interface_in.ready  = wishbone_interface_out.ready;

generate
        if (connect_clocks) 
		begin
			if (use_clk_from_wishbone_interface_in) 
			begin
				 assign wishbone_interface_out.clk    = wishbone_interface_in.clk; //clk is assumed to come from in interface		
			end else
			begin
				 assign wishbone_interface_in.clk    = wishbone_interface_out.clk; //clk is assumed to come from out interface		
			end
		end
endgenerate

assign wishbone_interface_out.wbs_adr_i    = wishbone_interface_in.wbs_adr_i ; 
assign wishbone_interface_out.wbs_bte_i    = wishbone_interface_in.wbs_bte_i ; 
assign wishbone_interface_out.wbs_cti_i    = wishbone_interface_in.wbs_cti_i ; 
assign wishbone_interface_out.wbs_cyc_i    = wishbone_interface_in.wbs_cyc_i ; 
assign wishbone_interface_out.wbs_dat_i    = wishbone_interface_in.wbs_dat_i ; 
assign wishbone_interface_out.wbs_sel_i    = wishbone_interface_in.wbs_sel_i ; 
assign wishbone_interface_out.wbs_stb_i    = wishbone_interface_in.wbs_stb_i ; 
assign wishbone_interface_out.wbs_we_i     = wishbone_interface_in.wbs_we_i  ; 
assign wishbone_interface_in.wbs_ack_o     = wishbone_interface_out.wbs_ack_o ;
assign wishbone_interface_in.wbs_err_o     = wishbone_interface_out.wbs_err_o ;
assign wishbone_interface_in.wbs_rty_o     = wishbone_interface_out.wbs_rty_o ;
assign wishbone_interface_in.wbs_dat_o     = wishbone_interface_out.wbs_dat_o ;

endmodule
