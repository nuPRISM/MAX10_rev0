`default_nettype none
`include "interface_defs.v"
module wb_compatible_status_regfile_w_interfaces
#(
parameter num_address_bits = 8,
parameter NUM_OF_STATUS_REGS = 2**num_address_bits,
parameter DATA_WIDTH = 32
)
(
    wishbone_interface wb_master,
	input reset,
	input wire [DATA_WIDTH-1:0]   STATUS [NUM_OF_STATUS_REGS-1:0]
  
);
 
	wb_compatible_status_regfile 
	#(
	.num_address_bits (num_address_bits),
	.NUM_OF_STATUS_REGS (NUM_OF_STATUS_REGS),
	.DATA_WIDTH       (DATA_WIDTH)
	) wb_compatible_status_regfile_inst
	( 
	    .wb_clk_i   ( wb_master.clk                         ), 
		.wb_rst_i   ( reset                                    ), 
		.wb_adr_i   ( wb_master.wbs_adr_i                      ), 
		.wb_dat_i   ( wb_master.wbs_dat_i                      ), 
		.wb_dat_o   ( wb_master.wbs_dat_o                      ),
		.wb_we_i    ( wb_master.wbs_we_i                       ), 
		.wb_stb_i   ( wb_master.wbs_stb_i                      ), 
		.wb_cyc_i   ( wb_master.wbs_cyc_i                      ), 
		.wb_ack_o   ( wb_master.wbs_ack_o                      ), 
		.wb_inta_o  (                                          ),
		.STATUS     ( STATUS                                   )
	);

endmodule
`default_nettype wire
