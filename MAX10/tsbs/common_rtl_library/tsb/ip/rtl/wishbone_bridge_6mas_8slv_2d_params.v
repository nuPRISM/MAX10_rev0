`default_nettype none
`include "interface_defs.v"
`include "keep_defines.v"

`ifndef WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP
`define WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP
`endif

 module wishbone_bridge_6mas_8slv_2d_params
 #(
 parameter integer slave_addresses[8] = '{32'hFFFFFFFF,32'hFFFFFFFF,32'hFFFFFFFF,32'hFFFFFFFF,32'hFFFFFFFF,32'hFFFFFFFF,32'hFFFFFFFF,32'hFFFFFFFF},
 parameter WATCHDOG_TIMER_WIDTH = 16,
  NUM_SLAVES = 8,
  NUM_MASTERS = 1,
  ENABLE_MASTER0 = 0,
  MASTER0_ADDR_SHIFT_RIGHT_BY_2 = 0,
  ENABLE_MASTER1 = 0,
  MASTER1_ADDR_SHIFT_RIGHT_BY_2 = 0, 
  ENABLE_MASTER2 = 0,
  MASTER2_ADDR_SHIFT_RIGHT_BY_2 = 0, 
  ENABLE_MASTER3 = 0,
  MASTER3_ADDR_SHIFT_RIGHT_BY_2 = 0,
  ENABLE_MASTER4 = 0,
  MASTER4_ADDR_SHIFT_RIGHT_BY_2 = 0,
  ENABLE_MASTER5 = 0,
  MASTER5_ADDR_SHIFT_RIGHT_BY_2 = 0, 
  ENABLE_SLAVE0 = 0,
  ENABLE_SLAVE1 = 0,
  ENABLE_SLAVE2 = 0,
  ENABLE_SLAVE3 = 0,
  ENABLE_SLAVE4 = 0, 
  ENABLE_SLAVE5 = 0, 
  ENABLE_SLAVE6 = 0, 
  ENABLE_SLAVE7 = 0, 
  NUM_WISHBONE_ADDRESS_BITS = 32,
  NUM_WISHBONE_DATA_BITS = 32,
  NUM_WISHBONE_SEL_BITS = NUM_WISHBONE_DATA_BITS/8,
  SLAVE0_SEL_ADDRESS = slave_addresses[0],
  SLAVE1_SEL_ADDRESS = slave_addresses[1],
  SLAVE2_SEL_ADDRESS = slave_addresses[2],
  SLAVE3_SEL_ADDRESS = slave_addresses[3],
  SLAVE4_SEL_ADDRESS = slave_addresses[4],   
  SLAVE5_SEL_ADDRESS = slave_addresses[5],   
  SLAVE6_SEL_ADDRESS = slave_addresses[6],   
  SLAVE7_SEL_ADDRESS = slave_addresses[7],   
  SLAVE0_SEL_WIDTH  = 30, //this will disable the slave by default
  SLAVE1_SEL_WIDTH  = 30, //this will disable the slave by default
  SLAVE2_SEL_WIDTH  = 30, //this will disable the slave by default
  SLAVE3_SEL_WIDTH  = 30, //this will disable the slave by default
  SLAVE4_SEL_WIDTH  = 30, //this will disable the slave by default 
  SLAVE5_SEL_WIDTH  = 30, //this will disable the slave by default 
  SLAVE6_SEL_WIDTH  = 30, //this will disable the slave by default 
  SLAVE7_SEL_WIDTH  = 30, //this will disable the slave by default 
  crop_output_addresses = 1
 ) ( 
    wishbone_interface master0,
    wishbone_interface master1,
    wishbone_interface master2,
    wishbone_interface master3,
    wishbone_interface master4,
    wishbone_interface master5,
    wishbone_interface slave0,
    wishbone_interface slave1,
    wishbone_interface slave2,
    wishbone_interface slave3,
    wishbone_interface slave4,
    wishbone_interface slave5,
    wishbone_interface slave6,
    wishbone_interface slave7,
	input wb_clk,
	input reset
 );
 
 
 
 
 
  generate 
			   if (!ENABLE_MASTER0)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   master0(); //generate dummy interface to allow top module to leave this interface disconnected
				   assign master0.wbs_cyc_i = 0;
				   assign master0.wbs_stb_i = 0;				   
				   assign master0.wbs_dat_i = 0;
				   assign master0.wbs_sel_i = 0;
				   assign master0.wbs_we_i  = 0;			   				   
			   end
			   
			   if (!ENABLE_MASTER1)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   master1(); //generate dummy interface to allow top module to leave this interface disconnected
				   assign master1.wbs_cyc_i = 0;
				   assign master1.wbs_stb_i = 0;				   
				   assign master1.wbs_dat_i = 0;
				   assign master1.wbs_sel_i = 0;
				   assign master1.wbs_we_i  = 0;			   				   
			   end
			   
			   if (!ENABLE_MASTER2)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   master2(); //generate dummy interface to allow top module to leave this interface disconnected
				   assign master2.wbs_cyc_i = 0;
				   assign master2.wbs_stb_i = 0;				   
				   assign master2.wbs_dat_i = 0;
				   assign master2.wbs_sel_i = 0;
				   assign master2.wbs_we_i  = 0;			   				   
			   end
			   
			   if (!ENABLE_MASTER3)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   master3(); //generate dummy interface to allow top module to leave this interface disconnected
				   assign master3.wbs_cyc_i = 0;
				   assign master3.wbs_stb_i = 0;				   
				   assign master3.wbs_dat_i = 0;
				   assign master3.wbs_sel_i = 0;
				   assign master3.wbs_we_i  = 0;			   				   
			   end
			   
			   if (!ENABLE_MASTER4)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   master4(); //generate dummy interface to allow top module to leave this interface disconnected
				   assign master4.wbs_cyc_i = 0;
				   assign master4.wbs_stb_i = 0;				   
				   assign master4.wbs_dat_i = 0;
				   assign master4.wbs_sel_i = 0;
				   assign master4.wbs_we_i  = 0;			   				   
			   end
			   
			   if (!ENABLE_MASTER5)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   master5(); //generate dummy interface to allow top module to leave this interface disconnected
				   assign master5.wbs_cyc_i = 0;
				   assign master5.wbs_stb_i = 0;				   
				   assign master5.wbs_dat_i = 0;
				   assign master5.wbs_sel_i = 0;
				   assign master5.wbs_we_i  = 0;			   				   
			   end
			   
			   if (!ENABLE_SLAVE0)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   slave0(); 	   				   
			   end
			   
			   if (!ENABLE_SLAVE1)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   slave1(); 	   				   
			   end 
			   
			   if (!ENABLE_SLAVE2)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   slave2(); 	   				   
			   end
			   
			   if (!ENABLE_SLAVE3)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   slave3(); 	   				   
			   end			   
			   
			   if (!ENABLE_SLAVE4)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   slave4(); 	   				   
			   end
			   
			   if (!ENABLE_SLAVE5)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   slave5(); 	   				   
			   end
			   
			    if (!ENABLE_SLAVE6)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   slave6(); 	   				   
			   end
			   
			   
			    if (!ENABLE_SLAVE7)
			   begin
				   wishbone_interface
				   #(
                    .num_address_bits(NUM_WISHBONE_ADDRESS_BITS),
                    .num_data_bits(NUM_WISHBONE_DATA_BITS)
                   )
				   slave7(); 	   				   
			   end
 endgenerate
 
// VME64x Core Wishbone Master Signals

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat0_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat0_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0] WbAdr0_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbCyc0_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbErr0_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbRty0_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0] WbSel0_o ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStb0_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbAck0_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbWe0_o        ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStall0_i     ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbIrq0_i       ;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat1_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat1_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0] WbAdr1_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbCyc1_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbErr1_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbRty1_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0] WbSel1_o ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStb1_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbAck1_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbWe1_o        ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStall1_i     ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbIrq1_i       ;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat2_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat2_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0] WbAdr2_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbCyc2_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbErr2_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbRty2_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0] WbSel2_o ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStb2_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbAck2_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbWe2_o        ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStall2_i     ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbIrq2_i       ;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat3_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat3_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0] WbAdr3_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbCyc3_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbErr3_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbRty3_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0] WbSel3_o ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStb3_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbAck3_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbWe3_o        ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStall3_i     ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbIrq3_i       ;


`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat4_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat4_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0] WbAdr4_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbCyc4_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbErr4_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbRty4_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0] WbSel4_o ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStb4_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbAck4_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbWe4_o        ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStall4_i     ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbIrq4_i       ;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat5_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat5_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0] WbAdr5_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbCyc5_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbErr5_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbRty5_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0] WbSel5_o ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStb5_o       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbAck5_i       ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbWe5_o        ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbStall5_i     ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic WbIrq5_i       ;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0]  wbs0_adr_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_bte_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_cti_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_cyc_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs0_dat_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0]   wbs0_sel_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_stb_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_we_i ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_ack_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_err_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_rty_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs0_dat_o;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0]  wbs1_adr_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_bte_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_cti_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_cyc_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs1_dat_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0]   wbs1_sel_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_stb_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_we_i ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_ack_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_err_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_rty_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs1_dat_o;

// Wishbone Slave2 Signals	(for USER Register Address Mapping)
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0]  wbs2_adr_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_bte_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_cti_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_cyc_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs2_dat_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0]   wbs2_sel_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_stb_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_we_i ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_ack_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_err_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_rty_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs2_dat_o;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_ADDRESS_BITS-1:0]  wbs3_adr_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_bte_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_cti_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_cyc_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs3_dat_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_SEL_BITS-1:0]   wbs3_sel_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_stb_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_we_i ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_ack_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_err_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_rty_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs3_dat_o;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_ADDRESS_BITS-1:0]  wbs4_adr_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_bte_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_cti_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_cyc_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs4_dat_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_SEL_BITS-1:0]   wbs4_sel_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                               wbs4_stb_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                               wbs4_we_i ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                               wbs4_ack_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                               wbs4_err_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                               wbs4_rty_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs4_dat_o;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_ADDRESS_BITS-1:0]    wbs5_adr_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs5_bte_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs5_cti_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs5_cyc_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]       wbs5_dat_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_SEL_BITS-1:0]        wbs5_sel_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs5_stb_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs5_we_i ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs5_ack_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs5_err_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs5_rty_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]       wbs5_dat_o;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_ADDRESS_BITS-1:0]    wbs6_adr_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs6_bte_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs6_cti_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs6_cyc_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]       wbs6_dat_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_SEL_BITS-1:0]        wbs6_sel_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs6_stb_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs6_we_i ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs6_ack_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs6_err_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs6_rty_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]       wbs6_dat_o;

`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_ADDRESS_BITS-1:0]    wbs7_adr_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs7_bte_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs7_cti_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs7_cyc_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]       wbs7_dat_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_SEL_BITS-1:0]        wbs7_sel_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs7_stb_i;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs7_we_i ;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs7_ack_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs7_err_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic                                    wbs7_rty_o;
`WISHBONE_BRIDGE_UP_TO_6_MASTERS_UP_TO_8_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]       wbs7_dat_o;

`include "auto_generated_wb_bridge_instantiation.v"

   
assign WbAdr0_o    = MASTER0_ADDR_SHIFT_RIGHT_BY_2 ? {2'b0,master0.wbs_adr_i[31:2]} : master0.wbs_adr_i; //wishbone address space is a word address space               
assign WbCyc0_o    = master0.wbs_cyc_i ;
assign WbDat0_o    = master0.wbs_dat_i ;
assign WbSel0_o    = master0.wbs_sel_i ;
assign WbStb0_o    = master0.wbs_stb_i ;
assign WbWe0_o     = master0.wbs_we_i  ;
assign master0.wbs_ack_o    = WbAck0_i;  
assign master0.wbs_err_o    = WbErr0_i;  
assign master0.wbs_rty_o    = WbRty0_i;  
assign master0.wbs_dat_o    = WbDat0_i;  
  
assign   WbAdr1_o              = MASTER1_ADDR_SHIFT_RIGHT_BY_2 ? 
                           {2'b0,master1.wbs_adr_i[31:2]} 
						       : master1.wbs_adr_i; //wishbone address space is a word address space               
assign   WbCyc1_o              = master1.wbs_cyc_i ;
assign   WbDat1_o              = master1.wbs_dat_i ;
assign   WbSel1_o              = master1.wbs_sel_i ;
assign   WbStb1_o              = master1.wbs_stb_i ;
assign    WbWe1_o              = master1.wbs_we_i  ;
assign  master1.wbs_ack_o      =  WbAck1_i;  
assign  master1.wbs_err_o      =  WbErr1_i;  
assign  master1.wbs_rty_o      =  WbRty1_i;  
assign  master1.wbs_dat_o      =  WbDat1_i;  
                               
assign   WbAdr2_o              = MASTER2_ADDR_SHIFT_RIGHT_BY_2 ? 
                           {2'b0,master2.wbs_adr_i[31:2]} 
						       : master2.wbs_adr_i; //wishbone address space is a word address space               
assign   WbCyc2_o              = master2.wbs_cyc_i ;
assign   WbDat2_o              = master2.wbs_dat_i ;
assign   WbSel2_o              = master2.wbs_sel_i ;
assign   WbStb2_o              = master2.wbs_stb_i ;
assign    WbWe2_o              = master2.wbs_we_i  ;
assign  master2.wbs_ack_o      =  WbAck2_i;  
assign  master2.wbs_err_o      =  WbErr2_i;  
assign  master2.wbs_rty_o      =  WbRty2_i;  
assign  master2.wbs_dat_o      =  WbDat2_i;  
                                 
                   
assign   WbAdr3_o              = MASTER3_ADDR_SHIFT_RIGHT_BY_2 ? 
                           {2'b0,master3.wbs_adr_i[31:2]} 
						       : master3.wbs_adr_i; //wishbone address space is a word address space               
assign   WbCyc3_o              = master3.wbs_cyc_i ;
assign   WbDat3_o              = master3.wbs_dat_i ;
assign   WbSel3_o              = master3.wbs_sel_i ;
assign   WbStb3_o              = master3.wbs_stb_i ;
assign    WbWe3_o              = master3.wbs_we_i  ;
assign  master3.wbs_ack_o      =  WbAck3_i;  
assign  master3.wbs_err_o      =  WbErr3_i;  
assign  master3.wbs_rty_o      =  WbRty3_i;  
assign  master3.wbs_dat_o      =  WbDat3_i;  
                                                    
assign   WbAdr4_o              = MASTER4_ADDR_SHIFT_RIGHT_BY_2 ? 
                           {2'b0,master4.wbs_adr_i[31:2]} 
						       : master4.wbs_adr_i; //wishbone address space is a word address space               
assign   WbCyc4_o              = master4.wbs_cyc_i ;
assign   WbDat4_o              = master4.wbs_dat_i ;
assign   WbSel4_o              = master4.wbs_sel_i ;
assign   WbStb4_o              = master4.wbs_stb_i ;
assign    WbWe4_o              = master4.wbs_we_i  ;
assign  master4.wbs_ack_o      =  WbAck4_i;  
assign  master4.wbs_err_o      =  WbErr4_i;  
assign  master4.wbs_rty_o      =  WbRty4_i;  
assign  master4.wbs_dat_o      =  WbDat4_i;  

                                            
assign   WbAdr5_o              = MASTER5_ADDR_SHIFT_RIGHT_BY_2 ? 
                           {2'b0,master5.wbs_adr_i[31:2]} 
						       : master5.wbs_adr_i; //wishbone address space is a word address space               
assign   WbCyc5_o              = master5.wbs_cyc_i ;
assign   WbDat5_o              = master5.wbs_dat_i ;
assign   WbSel5_o              = master5.wbs_sel_i ;
assign   WbStb5_o              = master5.wbs_stb_i ;
assign    WbWe5_o              = master5.wbs_we_i  ;
assign  master5.wbs_ack_o      =  WbAck5_i;  
assign  master5.wbs_err_o      =  WbErr5_i;  
assign  master5.wbs_rty_o      =  WbRty5_i;  
assign  master5.wbs_dat_o      =  WbDat5_i;  

                                            
assign slave0.wbs_adr_i=wbs0_adr_i;
assign slave0.wbs_bte_i=wbs0_bte_i;
assign slave0.wbs_cti_i=wbs0_cti_i;
assign slave0.wbs_cyc_i=wbs0_cyc_i;
assign slave0.wbs_dat_i=wbs0_dat_i;
assign slave0.wbs_sel_i=wbs0_sel_i;
assign slave0.wbs_stb_i=wbs0_stb_i;
assign slave0.wbs_we_i =wbs0_we_i ;
assign wbs0_ack_o = slave0.wbs_ack_o;
assign wbs0_err_o = slave0.wbs_err_o;
assign wbs0_rty_o = slave0.wbs_rty_o;
assign wbs0_dat_o = slave0.wbs_dat_o;
assign slave0.clk = wb_clk;
 
assign slave1.wbs_adr_i=wbs1_adr_i;
assign slave1.wbs_bte_i=wbs1_bte_i;
assign slave1.wbs_cti_i=wbs1_cti_i;
assign slave1.wbs_cyc_i=wbs1_cyc_i;
assign slave1.wbs_dat_i=wbs1_dat_i;
assign slave1.wbs_sel_i=wbs1_sel_i;
assign slave1.wbs_stb_i=wbs1_stb_i;
assign slave1.wbs_we_i =wbs1_we_i ;
assign wbs1_ack_o = slave1.wbs_ack_o;
assign wbs1_err_o = slave1.wbs_err_o;
assign wbs1_rty_o = slave1.wbs_rty_o;
assign wbs1_dat_o = slave1.wbs_dat_o;
assign slave1.clk = wb_clk;

assign slave2.wbs_adr_i=wbs2_adr_i;
assign slave2.wbs_bte_i=wbs2_bte_i;
assign slave2.wbs_cti_i=wbs2_cti_i;
assign slave2.wbs_cyc_i=wbs2_cyc_i;
assign slave2.wbs_dat_i=wbs2_dat_i;
assign slave2.wbs_sel_i=wbs2_sel_i;
assign slave2.wbs_stb_i=wbs2_stb_i;
assign slave2.wbs_we_i =wbs2_we_i ;
assign wbs2_ack_o = slave2.wbs_ack_o;
assign wbs2_err_o = slave2.wbs_err_o;
assign wbs2_rty_o = slave2.wbs_rty_o;
assign wbs2_dat_o = slave2.wbs_dat_o;
assign slave2.clk = wb_clk; 


assign slave3.wbs_adr_i=wbs3_adr_i;
assign slave3.wbs_bte_i=wbs3_bte_i;
assign slave3.wbs_cti_i=wbs3_cti_i;
assign slave3.wbs_cyc_i=wbs3_cyc_i;
assign slave3.wbs_dat_i=wbs3_dat_i;
assign slave3.wbs_sel_i=wbs3_sel_i;
assign slave3.wbs_stb_i=wbs3_stb_i;
assign slave3.wbs_we_i =wbs3_we_i ;
assign wbs3_ack_o = slave3.wbs_ack_o;
assign wbs3_err_o = slave3.wbs_err_o;
assign wbs3_rty_o = slave3.wbs_rty_o;
assign wbs3_dat_o = slave3.wbs_dat_o;
assign slave3.clk = wb_clk; 

assign slave4.wbs_adr_i=wbs4_adr_i;
assign slave4.wbs_bte_i=wbs4_bte_i;
assign slave4.wbs_cti_i=wbs4_cti_i;
assign slave4.wbs_cyc_i=wbs4_cyc_i;
assign slave4.wbs_dat_i=wbs4_dat_i;
assign slave4.wbs_sel_i=wbs4_sel_i;
assign slave4.wbs_stb_i=wbs4_stb_i;
assign slave4.wbs_we_i =wbs4_we_i ;
assign wbs4_ack_o = slave4.wbs_ack_o;
assign wbs4_err_o = slave4.wbs_err_o;
assign wbs4_rty_o = slave4.wbs_rty_o;
assign wbs4_dat_o = slave4.wbs_dat_o;
assign slave4.clk = wb_clk; 
    
assign slave5.wbs_adr_i=wbs5_adr_i;
assign slave5.wbs_bte_i=wbs5_bte_i;
assign slave5.wbs_cti_i=wbs5_cti_i;
assign slave5.wbs_cyc_i=wbs5_cyc_i;
assign slave5.wbs_dat_i=wbs5_dat_i;
assign slave5.wbs_sel_i=wbs5_sel_i;
assign slave5.wbs_stb_i=wbs5_stb_i;
assign slave5.wbs_we_i =wbs5_we_i ;
assign wbs5_ack_o = slave5.wbs_ack_o;
assign wbs5_err_o = slave5.wbs_err_o;
assign wbs5_rty_o = slave5.wbs_rty_o;
assign wbs5_dat_o = slave5.wbs_dat_o;
assign slave5.clk = wb_clk; 
    
assign slave6.wbs_adr_i=wbs6_adr_i;
assign slave6.wbs_bte_i=wbs6_bte_i;
assign slave6.wbs_cti_i=wbs6_cti_i;
assign slave6.wbs_cyc_i=wbs6_cyc_i;
assign slave6.wbs_dat_i=wbs6_dat_i;
assign slave6.wbs_sel_i=wbs6_sel_i;
assign slave6.wbs_stb_i=wbs6_stb_i;
assign slave6.wbs_we_i =wbs6_we_i ;
assign wbs6_ack_o = slave6.wbs_ack_o;
assign wbs6_err_o = slave6.wbs_err_o;
assign wbs6_rty_o = slave6.wbs_rty_o;
assign wbs6_dat_o = slave6.wbs_dat_o;
assign slave6.clk = wb_clk; 
      
assign slave7.wbs_adr_i=wbs7_adr_i;
assign slave7.wbs_bte_i=wbs7_bte_i;
assign slave7.wbs_cti_i=wbs7_cti_i;
assign slave7.wbs_cyc_i=wbs7_cyc_i;
assign slave7.wbs_dat_i=wbs7_dat_i;
assign slave7.wbs_sel_i=wbs7_sel_i;
assign slave7.wbs_stb_i=wbs7_stb_i;
assign slave7.wbs_we_i =wbs7_we_i ;
assign wbs7_ack_o = slave7.wbs_ack_o;
assign wbs7_err_o = slave7.wbs_err_o;
assign wbs7_rty_o = slave7.wbs_rty_o;
assign wbs7_dat_o = slave7.wbs_dat_o;
assign slave7.clk = wb_clk; 
  
 endmodule
 `default_nettype wire