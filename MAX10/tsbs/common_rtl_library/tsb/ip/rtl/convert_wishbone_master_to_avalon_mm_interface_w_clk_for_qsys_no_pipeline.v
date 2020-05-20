`include "interface_defs.v"
`include "keep_defines.v"

//`define CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP  (* keep = 1, preserve = 1 *)

`ifndef CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP
`define CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP 
`endif

module convert_wishbone_master_to_avalon_mm_interface_w_clk_for_qsys_no_pipeline
(
 wishbone_interface wishbone_master_interface_pins,
 //avalon_mm_pipeline_bridge_interface avalon_mm_slave_interface_pins 
 interface avalon_mm_slave_interface_pins 
);

`CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP logic [63:0] wb_to_avalon_address        ;
`CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP logic [63:0] wb_to_avalon_readdata       ;
`CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP logic [63:0] wb_to_avalon_writedata      ;
`CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP logic [7:0]  wb_to_avalon_byteenable     ;
`CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP logic        wb_to_avalon_write          ;
`CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP logic        wb_to_avalon_read           ;
`CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP logic        wb_to_avalon_waitrequest    ;
`CONVERT_WISHBONE_MASTER_TO_AVALON_MM_INTERFACE_W_CLK_NO_PIPELINE_FOR_QSYS_KEEP logic        wb_to_avalon_ack_o          ;

assign wishbone_master_interface_pins.wbs_ack_o  = wb_to_avalon_ack_o;
assign wishbone_master_interface_pins.wbs_dat_o  = wb_to_avalon_readdata ;

assign avalon_mm_slave_interface_pins.clk        = wishbone_master_interface_pins.clk;
assign avalon_mm_slave_interface_pins.address    = wb_to_avalon_address   ;
assign avalon_mm_slave_interface_pins.writedata  = wb_to_avalon_writedata ;
assign avalon_mm_slave_interface_pins.byteenable = wb_to_avalon_byteenable;
assign avalon_mm_slave_interface_pins.write      = wb_to_avalon_write     ;
assign avalon_mm_slave_interface_pins.read       = wb_to_avalon_read      ;

assign wb_to_avalon_address       = wishbone_master_interface_pins.wbs_adr_i;
assign wb_to_avalon_readdata      = avalon_mm_slave_interface_pins.readdata;
assign wb_to_avalon_writedata     = wishbone_master_interface_pins.wbs_dat_i;
assign wb_to_avalon_byteenable    = wishbone_master_interface_pins.wbs_sel_i;
assign wb_to_avalon_waitrequest   = avalon_mm_slave_interface_pins.waitrequest;
assign wb_to_avalon_write         = wishbone_master_interface_pins.wbs_cyc_i & wishbone_master_interface_pins.wbs_we_i;
assign wb_to_avalon_read          = wishbone_master_interface_pins.wbs_cyc_i & !wishbone_master_interface_pins.wbs_we_i;
assign wb_to_avalon_ack_o         = !wb_to_avalon_waitrequest & wishbone_master_interface_pins.wbs_cyc_i;

endmodule