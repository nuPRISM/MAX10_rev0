`include "interface_defs.v"

module convert_wishbone_master_to_avalon_mm_interface
(
 wishbone_interface wishbone_master_interface_pins,
 avalon_mm_pipeline_bridge_interface avalon_mm_slave_interface_pins 
);

assign avalon_mm_slave_interface_pins.address = wishbone_master_interface_pins.wbs_adr_i;
assign wishbone_master_interface_pins.wbs_dat_o = avalon_mm_slave_interface_pins.readdata;
assign avalon_mm_slave_interface_pins.writedata = wishbone_master_interface_pins.wbs_dat_i;
assign avalon_mm_slave_interface_pins.byteenable = wishbone_master_interface_pins.wbs_sel_i;
assign avalon_mm_slave_interface_pins.write = wishbone_master_interface_pins.wbs_cyc_i & wishbone_master_interface_pins.wbs_we_i;
assign avalon_mm_slave_interface_pins.read = wishbone_master_interface_pins.wbs_cyc_i & !wishbone_master_interface_pins.wbs_we_i;

assign wishbone_master_interface_pins.wbs_ack_o 
         = (!avalon_mm_slave_interface_pins.waitrequest & wishbone_master_interface_pins.wbs_we_i)
           | (avalon_mm_slave_interface_pins.readdatavalid & !wishbone_master_interface_pins.wbs_we_i);
		   
assign avalon_mm_slave_interface_pins.burstcount = 0;
assign avalon_mm_slave_interface_pins.debugaccess = 0;

endmodule