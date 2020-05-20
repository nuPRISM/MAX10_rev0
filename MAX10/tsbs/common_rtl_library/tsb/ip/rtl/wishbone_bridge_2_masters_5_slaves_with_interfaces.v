`default_nettype none
`include "interface_defs.v"
`include "keep_defines.v"

 module wishbone_bridge_2_masters_5_slaves_with_interfaces
 #(
 parameter WATCHDOG_TIMER_WIDTH = 16,
  ENABLE_MASTER0 = 0,
  MASTER0_ADDR_SHIFT_RIGHT_BY_2 = 0,
  ENABLE_MASTER1 = 0,
  MASTER1_ADDR_SHIFT_RIGHT_BY_2 = 0,
  ENABLE_SLAVE0 = 0,
  ENABLE_SLAVE1 = 0,
  ENABLE_SLAVE2 = 0,
  ENABLE_SLAVE3 = 0,
  ENABLE_SLAVE4 = 0, 
  NUM_WISHBONE_ADDRESS_BITS = 32,
  NUM_WISHBONE_DATA_BITS = 32,
  NUM_WISHBONE_SEL_BITS = NUM_WISHBONE_DATA_BITS/8,
  SLAVE0_SEL_ADDRESS = 32'hFFFFFFFF,
  SLAVE1_SEL_ADDRESS = 32'hFFFFFFFF,
  SLAVE2_SEL_ADDRESS = 32'hFFFFFFFF,
  SLAVE3_SEL_ADDRESS = 32'hFFFFFFFF,
  SLAVE4_SEL_ADDRESS = 32'hFFFFFFFF,   
  SLAVE0_SEL_WIDTH  = 30, //this will disable the slave by default
  SLAVE1_SEL_WIDTH  = 30, //this will disable the slave by default
  SLAVE2_SEL_WIDTH  = 30, //this will disable the slave by default
  SLAVE3_SEL_WIDTH  = 30, //this will disable the slave by default
  SLAVE4_SEL_WIDTH  = 30, //this will disable the slave by default 
  crop_output_addresses = 1
 ) ( 
    wishbone_interface master0,
    wishbone_interface master1,
    wishbone_interface slave0,
    wishbone_interface slave1,
    wishbone_interface slave2,
    wishbone_interface slave3,
    wishbone_interface slave4,
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
 endgenerate
 
// VME64x Core Wishbone Master Signals
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0] WbAdr_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbCyc_o       ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbErr_i       ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbRty_i       ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0] WbSel_o ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbStb_o       ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbAck_i       ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbWe_o        ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbStall_i     ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbIrq_i       ;

`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat1_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0] WbDat1_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0] WbAdr1_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbCyc1_o       ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbErr1_i       ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbRty1_i       ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0] WbSel1_o ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbStb1_o       ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbAck1_i       ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbWe1_o        ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbStall1_i     ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic WbIrq1_i       ;

`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0]  wbs0_adr_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_bte_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_cti_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_cyc_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs0_dat_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0]   wbs0_sel_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_stb_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_we_i ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_ack_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_err_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs0_rty_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs0_dat_o;

`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0]  wbs1_adr_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_bte_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_cti_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_cyc_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs1_dat_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0]   wbs1_sel_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_stb_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_we_i ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_ack_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_err_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs1_rty_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs1_dat_o;

// Wishbone Slave2 Signals	(for USER Register Address Mapping)
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_ADDRESS_BITS-1:0]  wbs2_adr_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_bte_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_cti_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_cyc_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs2_dat_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_SEL_BITS-1:0]   wbs2_sel_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_stb_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_we_i ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_ack_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_err_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic         wbs2_rty_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs2_dat_o;

`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_ADDRESS_BITS-1:0]  wbs3_adr_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_bte_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_cti_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_cyc_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs3_dat_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_SEL_BITS-1:0]   wbs3_sel_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_stb_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_we_i ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_ack_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_err_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs3_rty_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs3_dat_o;

`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_ADDRESS_BITS-1:0]  wbs4_adr_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_bte_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_cti_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_cyc_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs4_dat_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_SEL_BITS-1:0]   wbs4_sel_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_stb_i;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_we_i ;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_ack_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_err_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic         wbs4_rty_o;
`WISHBONE_BRIDGE_2_MASTERS_5_SLAVES_WITH_INTERFACES_KEEP    logic [NUM_WISHBONE_DATA_BITS-1:0]  wbs4_dat_o;

  
 wishbone_bridge_2_masters_5_slaves
	#(
	// Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
	.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
    .slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
    .slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
    .slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
	.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
	
   // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
	.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
    .slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
	.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
	.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
	.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  
	.aw(NUM_WISHBONE_ADDRESS_BITS),
	.dw(NUM_WISHBONE_DATA_BITS),
	.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
	.crop_output_addresses(crop_output_addresses)
	) wb_switch_inst
  (
   // Master ports
    .wbm0_adr_o(        WbAdr_o         ), 
	.wbm0_bte_o(                        ), 
	.wbm0_cti_o(                        ), 
	.wbm0_cyc_o(        WbCyc_o         ), 
	.wbm0_dat_o(        WbDat_o         ), 
	.wbm0_sel_o(        WbSel_o         ),
    .wbm0_stb_o(        WbStb_o         ), 
	.wbm0_we_o (        WbWe_o          ), 
	.wbm0_ack_i(        WbAck_i         ), 
	.wbm0_err_i(        WbErr_i         ), 
	.wbm0_rty_i(        WbRty_i         ), 
	.wbm0_dat_i(        WbDat_i         ),
	
	   // Master ports
    .wbm1_adr_o(        WbAdr1_o         ), 
	.wbm1_bte_o(                        ), 
	.wbm1_cti_o(                        ), 
	.wbm1_cyc_o(        WbCyc1_o         ), 
	.wbm1_dat_o(        WbDat1_o         ), 
	.wbm1_sel_o(        WbSel1_o         ),
    .wbm1_stb_o(        WbStb1_o         ), 
	.wbm1_we_o (        WbWe1_o          ), 
	.wbm1_ack_i(        WbAck1_i         ), 
	.wbm1_err_i(        WbErr1_i         ), 
	.wbm1_rty_i(        WbRty1_i         ), 
	.wbm1_dat_i(        WbDat1_i         ),
	
   // Slave ports
    .wbs0_adr_i(     wbs0_adr_i        ),
	.wbs0_bte_i(     wbs0_bte_i        ), 
	.wbs0_cti_i(     wbs0_cti_i        ), 
	.wbs0_cyc_i(     wbs0_cyc_i        ), 
	.wbs0_dat_i(     wbs0_dat_i        ), 
	.wbs0_sel_i(     wbs0_sel_i        ),
    .wbs0_stb_i(     wbs0_stb_i        ), 
	.wbs0_we_i (     wbs0_we_i         ), 
	.wbs0_ack_o(     wbs0_ack_o        ), 
	.wbs0_err_o(     wbs0_err_o        ), 
	.wbs0_rty_o(     wbs0_rty_o        ), 
	.wbs0_dat_o(     wbs0_dat_o        ),   
 
    .wbs1_adr_i(     wbs1_adr_i        ),
	.wbs1_bte_i(     wbs1_bte_i        ), 
	.wbs1_cti_i(     wbs1_cti_i        ), 
	.wbs1_cyc_i(     wbs1_cyc_i        ), 
	.wbs1_dat_i(     wbs1_dat_i        ), 
	.wbs1_sel_i(     wbs1_sel_i        ),
    .wbs1_stb_i(     wbs1_stb_i        ), 
	.wbs1_we_i (     wbs1_we_i         ), 
	.wbs1_ack_o(     wbs1_ack_o        ), 
	.wbs1_err_o(     wbs1_err_o        ), 
	.wbs1_rty_o(     wbs1_rty_o        ), 
	.wbs1_dat_o(     wbs1_dat_o        ),
   
	.wbs2_adr_i(     wbs2_adr_i        ),
	.wbs2_bte_i(     wbs2_bte_i        ), 
	.wbs2_cti_i(     wbs2_cti_i        ), 
	.wbs2_cyc_i(     wbs2_cyc_i        ), 
	.wbs2_dat_i(     wbs2_dat_i        ), 
	.wbs2_sel_i(     wbs2_sel_i        ),
    .wbs2_stb_i(     wbs2_stb_i        ), 
	.wbs2_we_i (     wbs2_we_i         ), 
	.wbs2_ack_o(     wbs2_ack_o        ), 
	.wbs2_err_o(     wbs2_err_o        ), 
	.wbs2_rty_o(     wbs2_rty_o        ), 
	.wbs2_dat_o(     wbs2_dat_o        ),
   
	.wbs3_adr_i(  wbs3_adr_i     ),
	.wbs3_bte_i(  wbs3_bte_i     ), 
	.wbs3_cti_i(  wbs3_cti_i     ), 
	.wbs3_cyc_i(  wbs3_cyc_i     ), 
	.wbs3_dat_i(  wbs3_dat_i     ), 
	.wbs3_sel_i(  wbs3_sel_i     ),
    .wbs3_stb_i(  wbs3_stb_i     ), 
	.wbs3_we_i (  wbs3_we_i      ), 
	.wbs3_ack_o(  wbs3_ack_o     ), 
	.wbs3_err_o(  wbs3_err_o     ), 
	.wbs3_rty_o(  wbs3_rty_o     ), 
	.wbs3_dat_o(  wbs3_dat_o     ),
   	
	
	.wbs4_adr_i(  wbs4_adr_i        ),
	.wbs4_bte_i(  wbs4_bte_i        ), 
	.wbs4_cti_i(  wbs4_cti_i        ), 
	.wbs4_cyc_i(  wbs4_cyc_i        ), 
	.wbs4_dat_i(  wbs4_dat_i        ), 
	.wbs4_sel_i(  wbs4_sel_i        ),
    .wbs4_stb_i(  wbs4_stb_i        ), 
	.wbs4_we_i (  wbs4_we_i         ), 
	.wbs4_ack_o(  wbs4_ack_o        ), 
	.wbs4_err_o(  wbs4_err_o        ), 
	.wbs4_rty_o(  wbs4_rty_o        ), 
	.wbs4_dat_o(  wbs4_dat_o        ),

	// Clocks, resets
    .wb_clk ( wb_clk ), 
	.wb_rst ( reset )
   );
   
   
assign WbAdr_o    = MASTER0_ADDR_SHIFT_RIGHT_BY_2 ? {2'b0,master0.wbs_adr_i[31:2]} : master0.wbs_adr_i; //wishbone address space is a word address space               
assign WbCyc_o    = master0.wbs_cyc_i ;
assign WbDat_o    = master0.wbs_dat_i ;
assign WbSel_o    = master0.wbs_sel_i ;
assign WbStb_o    = master0.wbs_stb_i ;
assign WbWe_o     = master0.wbs_we_i  ;
assign master0.wbs_ack_o    = WbAck_i;  
assign master0.wbs_err_o    = WbErr_i;  
assign master0.wbs_rty_o    = WbRty_i;  
assign master0.wbs_dat_o    = WbDat_i;  
  
assign WbAdr1_o    = MASTER1_ADDR_SHIFT_RIGHT_BY_2 ? {2'b0,master1.wbs_adr_i[31:2]} : master1.wbs_adr_i; //wishbone address space is a word address space               
assign WbCyc1_o    = master1.wbs_cyc_i ;
assign WbDat1_o    = master1.wbs_dat_i ;
assign WbSel1_o    = master1.wbs_sel_i ;
assign WbStb1_o    = master1.wbs_stb_i ;
assign WbWe1_o     = master1.wbs_we_i  ;
assign  master1.wbs_ack_o    = WbAck1_i;  
assign  master1.wbs_err_o    = WbErr1_i;  
assign  master1.wbs_rty_o    = WbRty1_i;  
assign  master1.wbs_dat_o    = WbDat1_i;  
  
  

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
    
 endmodule
 `default_nettype wire