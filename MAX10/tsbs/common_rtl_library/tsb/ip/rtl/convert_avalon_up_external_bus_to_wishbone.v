
`include "interface_defs.v"
`include "keep_defines.v"

//`define CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP  (* keep = 1, preserve = 1 *)

`ifndef CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP
`define CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP 
`endif


module convert_avalon_up_external_bus_to_wishbone
(
 wishbone_interface wishbone_slave_interface_pins,
 altera_up_external_bus_interface altera_up_external_bus_interface_pins 
);

`CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP logic [63:0] avalon_up_to_wishbone_address        ;
`CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP logic [63:0] avalon_up_to_wishbone_readdata       ;
`CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP logic [63:0] avalon_up_to_wishbone_writedata      ;
`CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP logic [7:0]  avalon_up_to_wishbone_byteenable     ;
`CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP logic        avalon_up_to_wishbone_write          ;
`CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP logic        avalon_up_to_wishbone_cyc    ;
`CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP logic        avalon_up_to_wishbone_stb    ;
`CONVERT_AVALON_UP_EXTERNAL_BUS_TO_WISHBONE_KEEP logic        avalon_up_to_wishbone_ack_o          ;

assign   wishbone_slave_interface_pins.wbs_adr_i = avalon_up_to_wishbone_address;
assign   wishbone_slave_interface_pins.wbs_cyc_i = avalon_up_to_wishbone_cyc;
assign   wishbone_slave_interface_pins.wbs_dat_i = avalon_up_to_wishbone_writedata;
assign   wishbone_slave_interface_pins.wbs_sel_i = avalon_up_to_wishbone_byteenable;
assign   wishbone_slave_interface_pins.wbs_stb_i = avalon_up_to_wishbone_stb;
assign   wishbone_slave_interface_pins.wbs_we_i  = avalon_up_to_wishbone_write;
assign   avalon_up_to_wishbone_ack_o             = wishbone_slave_interface_pins.wbs_ack_o;
assign   avalon_up_to_wishbone_readdata          = wishbone_slave_interface_pins.wbs_dat_o;

assign avalon_up_to_wishbone_address                     =  altera_up_external_bus_interface_pins.address    ;       
assign altera_up_external_bus_interface_pins.read_data   =  avalon_up_to_wishbone_readdata;                      
assign avalon_up_to_wishbone_writedata                   =  altera_up_external_bus_interface_pins.write_data  ;      
assign avalon_up_to_wishbone_byteenable                  =  altera_up_external_bus_interface_pins.byte_enable ;      
assign avalon_up_to_wishbone_cyc                         =  altera_up_external_bus_interface_pins.bus_enable  ;      
assign avalon_up_to_wishbone_stb                         =  altera_up_external_bus_interface_pins.bus_enable  ;      
assign avalon_up_to_wishbone_write                       =  !altera_up_external_bus_interface_pins.rw ;              
assign altera_up_external_bus_interface_pins.acknowledge =  avalon_up_to_wishbone_ack_o;

endmodule