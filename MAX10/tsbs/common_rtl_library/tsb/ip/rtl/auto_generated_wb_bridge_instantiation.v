//
// Number of masters = 1 Number of slaves = 1
//


  generate 
       if (NUM_MASTERS == 1) begin   
          if (NUM_SLAVES == 1) begin   
             
		          wishbone_bridge_1_masters_1_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 1 Number of slaves = 2
//


  generate 
       if (NUM_MASTERS == 1) begin   
          if (NUM_SLAVES == 2) begin   
             
		          wishbone_bridge_1_masters_2_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 1 Number of slaves = 3
//


  generate 
       if (NUM_MASTERS == 1) begin   
          if (NUM_SLAVES == 3) begin   
             
		          wishbone_bridge_1_masters_3_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 1 Number of slaves = 4
//


  generate 
       if (NUM_MASTERS == 1) begin   
          if (NUM_SLAVES == 4) begin   
             
		          wishbone_bridge_1_masters_4_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 1 Number of slaves = 5
//


  generate 
       if (NUM_MASTERS == 1) begin   
          if (NUM_SLAVES == 5) begin   
             
		          wishbone_bridge_1_masters_5_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
			    
         end 
   end 
endgenerate 


//
// Number of masters = 1 Number of slaves = 6
//


  generate 
       if (NUM_MASTERS == 1) begin   
          if (NUM_SLAVES == 6) begin   
             
		          wishbone_bridge_1_masters_6_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 1 Number of slaves = 7
//


  generate 
       if (NUM_MASTERS == 1) begin   
          if (NUM_SLAVES == 7) begin   
             
		          wishbone_bridge_1_masters_7_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 1 Number of slaves = 8
//


  generate 
       if (NUM_MASTERS == 1) begin   
          if (NUM_SLAVES == 8) begin   
             
		          wishbone_bridge_1_masters_8_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
  
                    //Slave 7
                    .wbs7_adr_i(  wbs7_adr_i        ),   
	                .wbs7_bte_i(  wbs7_bte_i        ),   
	                .wbs7_cti_i(  wbs7_cti_i        ),   
	                .wbs7_cyc_i(  wbs7_cyc_i        ),   
	                .wbs7_dat_i(  wbs7_dat_i        ),   
	                .wbs7_sel_i(  wbs7_sel_i        ),   
                    .wbs7_stb_i(  wbs7_stb_i        ),   
	                .wbs7_we_i (  wbs7_we_i         ),   
	                .wbs7_ack_o(  wbs7_ack_o        ),   
	                .wbs7_err_o(  wbs7_err_o        ),   
	                .wbs7_rty_o(  wbs7_rty_o        ),   
	                .wbs7_dat_o(  wbs7_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 2 Number of slaves = 1
//


  generate 
       if (NUM_MASTERS == 2) begin   
          if (NUM_SLAVES == 1) begin   
             
		          wishbone_bridge_2_masters_1_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 2 Number of slaves = 2
//


  generate 
       if (NUM_MASTERS == 2) begin   
          if (NUM_SLAVES == 2) begin   
             
		          wishbone_bridge_2_masters_2_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 2 Number of slaves = 3
//


  generate 
       if (NUM_MASTERS == 2) begin   
          if (NUM_SLAVES == 3) begin   
             
		          wishbone_bridge_2_masters_3_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 2 Number of slaves = 4
//


  generate 
       if (NUM_MASTERS == 2) begin   
          if (NUM_SLAVES == 4) begin   
             
		          wishbone_bridge_2_masters_4_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 2 Number of slaves = 5
//


  generate 
       if (NUM_MASTERS == 2) begin   
          if (NUM_SLAVES == 5) begin   
             
		          wishbone_bridge_2_masters_5_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
			    
         end 
   end 
endgenerate 


//
// Number of masters = 2 Number of slaves = 6
//


  generate 
       if (NUM_MASTERS == 2) begin   
          if (NUM_SLAVES == 6) begin   
             
		          wishbone_bridge_2_masters_6_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 2 Number of slaves = 7
//


  generate 
       if (NUM_MASTERS == 2) begin   
          if (NUM_SLAVES == 7) begin   
             
		          wishbone_bridge_2_masters_7_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 2 Number of slaves = 8
//


  generate 
       if (NUM_MASTERS == 2) begin   
          if (NUM_SLAVES == 8) begin   
             
		          wishbone_bridge_2_masters_8_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
  
                    //Slave 7
                    .wbs7_adr_i(  wbs7_adr_i        ),   
	                .wbs7_bte_i(  wbs7_bte_i        ),   
	                .wbs7_cti_i(  wbs7_cti_i        ),   
	                .wbs7_cyc_i(  wbs7_cyc_i        ),   
	                .wbs7_dat_i(  wbs7_dat_i        ),   
	                .wbs7_sel_i(  wbs7_sel_i        ),   
                    .wbs7_stb_i(  wbs7_stb_i        ),   
	                .wbs7_we_i (  wbs7_we_i         ),   
	                .wbs7_ack_o(  wbs7_ack_o        ),   
	                .wbs7_err_o(  wbs7_err_o        ),   
	                .wbs7_rty_o(  wbs7_rty_o        ),   
	                .wbs7_dat_o(  wbs7_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 3 Number of slaves = 1
//


  generate 
       if (NUM_MASTERS == 3) begin   
          if (NUM_SLAVES == 1) begin   
             
		          wishbone_bridge_3_masters_1_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 3 Number of slaves = 2
//


  generate 
       if (NUM_MASTERS == 3) begin   
          if (NUM_SLAVES == 2) begin   
             
		          wishbone_bridge_3_masters_2_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 3 Number of slaves = 3
//


  generate 
       if (NUM_MASTERS == 3) begin   
          if (NUM_SLAVES == 3) begin   
             
		          wishbone_bridge_3_masters_3_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 3 Number of slaves = 4
//


  generate 
       if (NUM_MASTERS == 3) begin   
          if (NUM_SLAVES == 4) begin   
             
		          wishbone_bridge_3_masters_4_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 3 Number of slaves = 5
//


  generate 
       if (NUM_MASTERS == 3) begin   
          if (NUM_SLAVES == 5) begin   
             
		          wishbone_bridge_3_masters_5_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
			    
         end 
   end 
endgenerate 


//
// Number of masters = 3 Number of slaves = 6
//


  generate 
       if (NUM_MASTERS == 3) begin   
          if (NUM_SLAVES == 6) begin   
             
		          wishbone_bridge_3_masters_6_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 3 Number of slaves = 7
//


  generate 
       if (NUM_MASTERS == 3) begin   
          if (NUM_SLAVES == 7) begin   
             
		          wishbone_bridge_3_masters_7_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 3 Number of slaves = 8
//


  generate 
       if (NUM_MASTERS == 3) begin   
          if (NUM_SLAVES == 8) begin   
             
		          wishbone_bridge_3_masters_8_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
  
                    //Slave 7
                    .wbs7_adr_i(  wbs7_adr_i        ),   
	                .wbs7_bte_i(  wbs7_bte_i        ),   
	                .wbs7_cti_i(  wbs7_cti_i        ),   
	                .wbs7_cyc_i(  wbs7_cyc_i        ),   
	                .wbs7_dat_i(  wbs7_dat_i        ),   
	                .wbs7_sel_i(  wbs7_sel_i        ),   
                    .wbs7_stb_i(  wbs7_stb_i        ),   
	                .wbs7_we_i (  wbs7_we_i         ),   
	                .wbs7_ack_o(  wbs7_ack_o        ),   
	                .wbs7_err_o(  wbs7_err_o        ),   
	                .wbs7_rty_o(  wbs7_rty_o        ),   
	                .wbs7_dat_o(  wbs7_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 4 Number of slaves = 1
//


  generate 
       if (NUM_MASTERS == 4) begin   
          if (NUM_SLAVES == 1) begin   
             
		          wishbone_bridge_4_masters_1_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 4 Number of slaves = 2
//


  generate 
       if (NUM_MASTERS == 4) begin   
          if (NUM_SLAVES == 2) begin   
             
		          wishbone_bridge_4_masters_2_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 4 Number of slaves = 3
//


  generate 
       if (NUM_MASTERS == 4) begin   
          if (NUM_SLAVES == 3) begin   
             
		          wishbone_bridge_4_masters_3_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 4 Number of slaves = 4
//


  generate 
       if (NUM_MASTERS == 4) begin   
          if (NUM_SLAVES == 4) begin   
             
		          wishbone_bridge_4_masters_4_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 4 Number of slaves = 5
//


  generate 
       if (NUM_MASTERS == 4) begin   
          if (NUM_SLAVES == 5) begin   
             
		          wishbone_bridge_4_masters_5_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
			    
         end 
   end 
endgenerate 


//
// Number of masters = 4 Number of slaves = 6
//


  generate 
       if (NUM_MASTERS == 4) begin   
          if (NUM_SLAVES == 6) begin   
             
		          wishbone_bridge_4_masters_6_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 4 Number of slaves = 7
//


  generate 
       if (NUM_MASTERS == 4) begin   
          if (NUM_SLAVES == 7) begin   
             
		          wishbone_bridge_4_masters_7_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 4 Number of slaves = 8
//


  generate 
       if (NUM_MASTERS == 4) begin   
          if (NUM_SLAVES == 8) begin   
             
		          wishbone_bridge_4_masters_8_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
  
                    //Slave 7
                    .wbs7_adr_i(  wbs7_adr_i        ),   
	                .wbs7_bte_i(  wbs7_bte_i        ),   
	                .wbs7_cti_i(  wbs7_cti_i        ),   
	                .wbs7_cyc_i(  wbs7_cyc_i        ),   
	                .wbs7_dat_i(  wbs7_dat_i        ),   
	                .wbs7_sel_i(  wbs7_sel_i        ),   
                    .wbs7_stb_i(  wbs7_stb_i        ),   
	                .wbs7_we_i (  wbs7_we_i         ),   
	                .wbs7_ack_o(  wbs7_ack_o        ),   
	                .wbs7_err_o(  wbs7_err_o        ),   
	                .wbs7_rty_o(  wbs7_rty_o        ),   
	                .wbs7_dat_o(  wbs7_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 5 Number of slaves = 1
//


  generate 
       if (NUM_MASTERS == 5) begin   
          if (NUM_SLAVES == 1) begin   
             
		          wishbone_bridge_5_masters_1_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 5 Number of slaves = 2
//


  generate 
       if (NUM_MASTERS == 5) begin   
          if (NUM_SLAVES == 2) begin   
             
		          wishbone_bridge_5_masters_2_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 5 Number of slaves = 3
//


  generate 
       if (NUM_MASTERS == 5) begin   
          if (NUM_SLAVES == 3) begin   
             
		          wishbone_bridge_5_masters_3_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 5 Number of slaves = 4
//


  generate 
       if (NUM_MASTERS == 5) begin   
          if (NUM_SLAVES == 4) begin   
             
		          wishbone_bridge_5_masters_4_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 5 Number of slaves = 5
//


  generate 
       if (NUM_MASTERS == 5) begin   
          if (NUM_SLAVES == 5) begin   
             
		          wishbone_bridge_5_masters_5_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
			    
         end 
   end 
endgenerate 


//
// Number of masters = 5 Number of slaves = 6
//


  generate 
       if (NUM_MASTERS == 5) begin   
          if (NUM_SLAVES == 6) begin   
             
		          wishbone_bridge_5_masters_6_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 5 Number of slaves = 7
//


  generate 
       if (NUM_MASTERS == 5) begin   
          if (NUM_SLAVES == 7) begin   
             
		          wishbone_bridge_5_masters_7_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 5 Number of slaves = 8
//


  generate 
       if (NUM_MASTERS == 5) begin   
          if (NUM_SLAVES == 8) begin   
             
		          wishbone_bridge_5_masters_8_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
  
                    //Slave 7
                    .wbs7_adr_i(  wbs7_adr_i        ),   
	                .wbs7_bte_i(  wbs7_bte_i        ),   
	                .wbs7_cti_i(  wbs7_cti_i        ),   
	                .wbs7_cyc_i(  wbs7_cyc_i        ),   
	                .wbs7_dat_i(  wbs7_dat_i        ),   
	                .wbs7_sel_i(  wbs7_sel_i        ),   
                    .wbs7_stb_i(  wbs7_stb_i        ),   
	                .wbs7_we_i (  wbs7_we_i         ),   
	                .wbs7_ack_o(  wbs7_ack_o        ),   
	                .wbs7_err_o(  wbs7_err_o        ),   
	                .wbs7_rty_o(  wbs7_rty_o        ),   
	                .wbs7_dat_o(  wbs7_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 6 Number of slaves = 1
//


  generate 
       if (NUM_MASTERS == 6) begin   
          if (NUM_SLAVES == 1) begin   
             
		          wishbone_bridge_6_masters_1_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
 
                    //Master 5
                    .wbm5_adr_o(        WbAdr5_o         ), 
	                .wbm5_bte_o(                        ), 
	                .wbm5_cti_o(                        ), 
	                .wbm5_cyc_o(        WbCyc5_o         ), 
	                .wbm5_dat_o(        WbDat5_o         ), 
	                .wbm5_sel_o(        WbSel5_o         ),
                    .wbm5_stb_o(        WbStb5_o         ), 
	                .wbm5_we_o (         WbWe5_o          ), 
	                .wbm5_ack_i(        WbAck5_i         ), 
	                .wbm5_err_i(        WbErr5_i         ), 
	                .wbm5_rty_i(        WbRty5_i         ), 
	                .wbm5_dat_i(        WbDat5_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 6 Number of slaves = 2
//


  generate 
       if (NUM_MASTERS == 6) begin   
          if (NUM_SLAVES == 2) begin   
             
		          wishbone_bridge_6_masters_2_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
 
                    //Master 5
                    .wbm5_adr_o(        WbAdr5_o         ), 
	                .wbm5_bte_o(                        ), 
	                .wbm5_cti_o(                        ), 
	                .wbm5_cyc_o(        WbCyc5_o         ), 
	                .wbm5_dat_o(        WbDat5_o         ), 
	                .wbm5_sel_o(        WbSel5_o         ),
                    .wbm5_stb_o(        WbStb5_o         ), 
	                .wbm5_we_o (         WbWe5_o          ), 
	                .wbm5_ack_i(        WbAck5_i         ), 
	                .wbm5_err_i(        WbErr5_i         ), 
	                .wbm5_rty_i(        WbRty5_i         ), 
	                .wbm5_dat_i(        WbDat5_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 6 Number of slaves = 3
//


  generate 
       if (NUM_MASTERS == 6) begin   
          if (NUM_SLAVES == 3) begin   
             
		          wishbone_bridge_6_masters_3_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
 
                    //Master 5
                    .wbm5_adr_o(        WbAdr5_o         ), 
	                .wbm5_bte_o(                        ), 
	                .wbm5_cti_o(                        ), 
	                .wbm5_cyc_o(        WbCyc5_o         ), 
	                .wbm5_dat_o(        WbDat5_o         ), 
	                .wbm5_sel_o(        WbSel5_o         ),
                    .wbm5_stb_o(        WbStb5_o         ), 
	                .wbm5_we_o (         WbWe5_o          ), 
	                .wbm5_ack_i(        WbAck5_i         ), 
	                .wbm5_err_i(        WbErr5_i         ), 
	                .wbm5_rty_i(        WbRty5_i         ), 
	                .wbm5_dat_i(        WbDat5_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 6 Number of slaves = 4
//


  generate 
       if (NUM_MASTERS == 6) begin   
          if (NUM_SLAVES == 4) begin   
             
		          wishbone_bridge_6_masters_4_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
 
                    //Master 5
                    .wbm5_adr_o(        WbAdr5_o         ), 
	                .wbm5_bte_o(                        ), 
	                .wbm5_cti_o(                        ), 
	                .wbm5_cyc_o(        WbCyc5_o         ), 
	                .wbm5_dat_o(        WbDat5_o         ), 
	                .wbm5_sel_o(        WbSel5_o         ),
                    .wbm5_stb_o(        WbStb5_o         ), 
	                .wbm5_we_o (         WbWe5_o          ), 
	                .wbm5_ack_i(        WbAck5_i         ), 
	                .wbm5_err_i(        WbErr5_i         ), 
	                .wbm5_rty_i(        WbRty5_i         ), 
	                .wbm5_dat_i(        WbDat5_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 6 Number of slaves = 5
//


  generate 
       if (NUM_MASTERS == 6) begin   
          if (NUM_SLAVES == 5) begin   
             
		          wishbone_bridge_6_masters_5_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
 
                    //Master 5
                    .wbm5_adr_o(        WbAdr5_o         ), 
	                .wbm5_bte_o(                        ), 
	                .wbm5_cti_o(                        ), 
	                .wbm5_cyc_o(        WbCyc5_o         ), 
	                .wbm5_dat_o(        WbDat5_o         ), 
	                .wbm5_sel_o(        WbSel5_o         ),
                    .wbm5_stb_o(        WbStb5_o         ), 
	                .wbm5_we_o (         WbWe5_o          ), 
	                .wbm5_ack_i(        WbAck5_i         ), 
	                .wbm5_err_i(        WbErr5_i         ), 
	                .wbm5_rty_i(        WbRty5_i         ), 
	                .wbm5_dat_i(        WbDat5_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
			    
         end 
   end 
endgenerate 


//
// Number of masters = 6 Number of slaves = 6
//


  generate 
       if (NUM_MASTERS == 6) begin   
          if (NUM_SLAVES == 6) begin   
             
		          wishbone_bridge_6_masters_6_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
 
                    //Master 5
                    .wbm5_adr_o(        WbAdr5_o         ), 
	                .wbm5_bte_o(                        ), 
	                .wbm5_cti_o(                        ), 
	                .wbm5_cyc_o(        WbCyc5_o         ), 
	                .wbm5_dat_o(        WbDat5_o         ), 
	                .wbm5_sel_o(        WbSel5_o         ),
                    .wbm5_stb_o(        WbStb5_o         ), 
	                .wbm5_we_o (         WbWe5_o          ), 
	                .wbm5_ack_i(        WbAck5_i         ), 
	                .wbm5_err_i(        WbErr5_i         ), 
	                .wbm5_rty_i(        WbRty5_i         ), 
	                .wbm5_dat_i(        WbDat5_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 6 Number of slaves = 7
//


  generate 
       if (NUM_MASTERS == 6) begin   
          if (NUM_SLAVES == 7) begin   
             
		          wishbone_bridge_6_masters_7_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
 
                    //Master 5
                    .wbm5_adr_o(        WbAdr5_o         ), 
	                .wbm5_bte_o(                        ), 
	                .wbm5_cti_o(                        ), 
	                .wbm5_cyc_o(        WbCyc5_o         ), 
	                .wbm5_dat_o(        WbDat5_o         ), 
	                .wbm5_sel_o(        WbSel5_o         ),
                    .wbm5_stb_o(        WbStb5_o         ), 
	                .wbm5_we_o (         WbWe5_o          ), 
	                .wbm5_ack_i(        WbAck5_i         ), 
	                .wbm5_err_i(        WbErr5_i         ), 
	                .wbm5_rty_i(        WbRty5_i         ), 
	                .wbm5_dat_i(        WbDat5_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


//
// Number of masters = 6 Number of slaves = 8
//


  generate 
       if (NUM_MASTERS == 6) begin   
          if (NUM_SLAVES == 8) begin   
             
		          wishbone_bridge_6_masters_8_slaves #(
 
		            // Base Address of Registers (32-bit Address not 8-bit... ie. 2 LSB dropped from VME_A)
					.slave0_sel_addr ( SLAVE0_SEL_ADDRESS ),  
					.slave1_sel_addr ( SLAVE1_SEL_ADDRESS ), 
					.slave2_sel_addr ( SLAVE2_SEL_ADDRESS ),  
					.slave3_sel_addr ( SLAVE3_SEL_ADDRESS ),  
					.slave4_sel_addr ( SLAVE4_SEL_ADDRESS ),  
					.slave5_sel_addr ( SLAVE5_SEL_ADDRESS ),  
					.slave6_sel_addr ( SLAVE6_SEL_ADDRESS ),  
					.slave7_sel_addr ( SLAVE7_SEL_ADDRESS ),  
					
				    // number of MSB's in 32bit WB Address that must match (ie. bits in Register Base Address)
					.slave0_sel_width ( SLAVE0_SEL_WIDTH  ),   
					.slave1_sel_width ( SLAVE1_SEL_WIDTH  ), 
					.slave2_sel_width ( SLAVE2_SEL_WIDTH  ),   
					.slave3_sel_width ( SLAVE3_SEL_WIDTH  ),  
					.slave4_sel_width ( SLAVE4_SEL_WIDTH  ),  	
					.slave5_sel_width ( SLAVE5_SEL_WIDTH  ),  
					.slave6_sel_width ( SLAVE6_SEL_WIDTH  ),  
					.slave7_sel_width ( SLAVE7_SEL_WIDTH  ),  
					.aw(NUM_WISHBONE_ADDRESS_BITS),
					.dw(NUM_WISHBONE_DATA_BITS),
					.watchdog_timer_width(WATCHDOG_TIMER_WIDTH),
					.crop_output_addresses(crop_output_addresses)
					) 
					
					wb_switch_inst 
					
					(
 
                    //Master 0
                    .wbm0_adr_o(        WbAdr0_o         ), 
	                .wbm0_bte_o(                        ), 
	                .wbm0_cti_o(                        ), 
	                .wbm0_cyc_o(        WbCyc0_o         ), 
	                .wbm0_dat_o(        WbDat0_o         ), 
	                .wbm0_sel_o(        WbSel0_o         ),
                    .wbm0_stb_o(        WbStb0_o         ), 
	                .wbm0_we_o (         WbWe0_o          ), 
	                .wbm0_ack_i(        WbAck0_i         ), 
	                .wbm0_err_i(        WbErr0_i         ), 
	                .wbm0_rty_i(        WbRty0_i         ), 
	                .wbm0_dat_i(        WbDat0_i         ), 
 
                    //Master 1
                    .wbm1_adr_o(        WbAdr1_o         ), 
	                .wbm1_bte_o(                        ), 
	                .wbm1_cti_o(                        ), 
	                .wbm1_cyc_o(        WbCyc1_o         ), 
	                .wbm1_dat_o(        WbDat1_o         ), 
	                .wbm1_sel_o(        WbSel1_o         ),
                    .wbm1_stb_o(        WbStb1_o         ), 
	                .wbm1_we_o (         WbWe1_o          ), 
	                .wbm1_ack_i(        WbAck1_i         ), 
	                .wbm1_err_i(        WbErr1_i         ), 
	                .wbm1_rty_i(        WbRty1_i         ), 
	                .wbm1_dat_i(        WbDat1_i         ), 
 
                    //Master 2
                    .wbm2_adr_o(        WbAdr2_o         ), 
	                .wbm2_bte_o(                        ), 
	                .wbm2_cti_o(                        ), 
	                .wbm2_cyc_o(        WbCyc2_o         ), 
	                .wbm2_dat_o(        WbDat2_o         ), 
	                .wbm2_sel_o(        WbSel2_o         ),
                    .wbm2_stb_o(        WbStb2_o         ), 
	                .wbm2_we_o (         WbWe2_o          ), 
	                .wbm2_ack_i(        WbAck2_i         ), 
	                .wbm2_err_i(        WbErr2_i         ), 
	                .wbm2_rty_i(        WbRty2_i         ), 
	                .wbm2_dat_i(        WbDat2_i         ), 
 
                    //Master 3
                    .wbm3_adr_o(        WbAdr3_o         ), 
	                .wbm3_bte_o(                        ), 
	                .wbm3_cti_o(                        ), 
	                .wbm3_cyc_o(        WbCyc3_o         ), 
	                .wbm3_dat_o(        WbDat3_o         ), 
	                .wbm3_sel_o(        WbSel3_o         ),
                    .wbm3_stb_o(        WbStb3_o         ), 
	                .wbm3_we_o (         WbWe3_o          ), 
	                .wbm3_ack_i(        WbAck3_i         ), 
	                .wbm3_err_i(        WbErr3_i         ), 
	                .wbm3_rty_i(        WbRty3_i         ), 
	                .wbm3_dat_i(        WbDat3_i         ), 
 
                    //Master 4
                    .wbm4_adr_o(        WbAdr4_o         ), 
	                .wbm4_bte_o(                        ), 
	                .wbm4_cti_o(                        ), 
	                .wbm4_cyc_o(        WbCyc4_o         ), 
	                .wbm4_dat_o(        WbDat4_o         ), 
	                .wbm4_sel_o(        WbSel4_o         ),
                    .wbm4_stb_o(        WbStb4_o         ), 
	                .wbm4_we_o (         WbWe4_o          ), 
	                .wbm4_ack_i(        WbAck4_i         ), 
	                .wbm4_err_i(        WbErr4_i         ), 
	                .wbm4_rty_i(        WbRty4_i         ), 
	                .wbm4_dat_i(        WbDat4_i         ), 
 
                    //Master 5
                    .wbm5_adr_o(        WbAdr5_o         ), 
	                .wbm5_bte_o(                        ), 
	                .wbm5_cti_o(                        ), 
	                .wbm5_cyc_o(        WbCyc5_o         ), 
	                .wbm5_dat_o(        WbDat5_o         ), 
	                .wbm5_sel_o(        WbSel5_o         ),
                    .wbm5_stb_o(        WbStb5_o         ), 
	                .wbm5_we_o (         WbWe5_o          ), 
	                .wbm5_ack_i(        WbAck5_i         ), 
	                .wbm5_err_i(        WbErr5_i         ), 
	                .wbm5_rty_i(        WbRty5_i         ), 
	                .wbm5_dat_i(        WbDat5_i         ), 
  
                    //Slave 0
                    .wbs0_adr_i(  wbs0_adr_i        ),   
	                .wbs0_bte_i(  wbs0_bte_i        ),   
	                .wbs0_cti_i(  wbs0_cti_i        ),   
	                .wbs0_cyc_i(  wbs0_cyc_i        ),   
	                .wbs0_dat_i(  wbs0_dat_i        ),   
	                .wbs0_sel_i(  wbs0_sel_i        ),   
                    .wbs0_stb_i(  wbs0_stb_i        ),   
	                .wbs0_we_i (  wbs0_we_i         ),   
	                .wbs0_ack_o(  wbs0_ack_o        ),   
	                .wbs0_err_o(  wbs0_err_o        ),   
	                .wbs0_rty_o(  wbs0_rty_o        ),   
	                .wbs0_dat_o(  wbs0_dat_o        ),
  
                    //Slave 1
                    .wbs1_adr_i(  wbs1_adr_i        ),   
	                .wbs1_bte_i(  wbs1_bte_i        ),   
	                .wbs1_cti_i(  wbs1_cti_i        ),   
	                .wbs1_cyc_i(  wbs1_cyc_i        ),   
	                .wbs1_dat_i(  wbs1_dat_i        ),   
	                .wbs1_sel_i(  wbs1_sel_i        ),   
                    .wbs1_stb_i(  wbs1_stb_i        ),   
	                .wbs1_we_i (  wbs1_we_i         ),   
	                .wbs1_ack_o(  wbs1_ack_o        ),   
	                .wbs1_err_o(  wbs1_err_o        ),   
	                .wbs1_rty_o(  wbs1_rty_o        ),   
	                .wbs1_dat_o(  wbs1_dat_o        ),
  
                    //Slave 2
                    .wbs2_adr_i(  wbs2_adr_i        ),   
	                .wbs2_bte_i(  wbs2_bte_i        ),   
	                .wbs2_cti_i(  wbs2_cti_i        ),   
	                .wbs2_cyc_i(  wbs2_cyc_i        ),   
	                .wbs2_dat_i(  wbs2_dat_i        ),   
	                .wbs2_sel_i(  wbs2_sel_i        ),   
                    .wbs2_stb_i(  wbs2_stb_i        ),   
	                .wbs2_we_i (  wbs2_we_i         ),   
	                .wbs2_ack_o(  wbs2_ack_o        ),   
	                .wbs2_err_o(  wbs2_err_o        ),   
	                .wbs2_rty_o(  wbs2_rty_o        ),   
	                .wbs2_dat_o(  wbs2_dat_o        ),
  
                    //Slave 3
                    .wbs3_adr_i(  wbs3_adr_i        ),   
	                .wbs3_bte_i(  wbs3_bte_i        ),   
	                .wbs3_cti_i(  wbs3_cti_i        ),   
	                .wbs3_cyc_i(  wbs3_cyc_i        ),   
	                .wbs3_dat_i(  wbs3_dat_i        ),   
	                .wbs3_sel_i(  wbs3_sel_i        ),   
                    .wbs3_stb_i(  wbs3_stb_i        ),   
	                .wbs3_we_i (  wbs3_we_i         ),   
	                .wbs3_ack_o(  wbs3_ack_o        ),   
	                .wbs3_err_o(  wbs3_err_o        ),   
	                .wbs3_rty_o(  wbs3_rty_o        ),   
	                .wbs3_dat_o(  wbs3_dat_o        ),
  
                    //Slave 4
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
  
                    //Slave 5
                    .wbs5_adr_i(  wbs5_adr_i        ),   
	                .wbs5_bte_i(  wbs5_bte_i        ),   
	                .wbs5_cti_i(  wbs5_cti_i        ),   
	                .wbs5_cyc_i(  wbs5_cyc_i        ),   
	                .wbs5_dat_i(  wbs5_dat_i        ),   
	                .wbs5_sel_i(  wbs5_sel_i        ),   
                    .wbs5_stb_i(  wbs5_stb_i        ),   
	                .wbs5_we_i (  wbs5_we_i         ),   
	                .wbs5_ack_o(  wbs5_ack_o        ),   
	                .wbs5_err_o(  wbs5_err_o        ),   
	                .wbs5_rty_o(  wbs5_rty_o        ),   
	                .wbs5_dat_o(  wbs5_dat_o        ),
  
                    //Slave 6
                    .wbs6_adr_i(  wbs6_adr_i        ),   
	                .wbs6_bte_i(  wbs6_bte_i        ),   
	                .wbs6_cti_i(  wbs6_cti_i        ),   
	                .wbs6_cyc_i(  wbs6_cyc_i        ),   
	                .wbs6_dat_i(  wbs6_dat_i        ),   
	                .wbs6_sel_i(  wbs6_sel_i        ),   
                    .wbs6_stb_i(  wbs6_stb_i        ),   
	                .wbs6_we_i (  wbs6_we_i         ),   
	                .wbs6_ack_o(  wbs6_ack_o        ),   
	                .wbs6_err_o(  wbs6_err_o        ),   
	                .wbs6_rty_o(  wbs6_rty_o        ),   
	                .wbs6_dat_o(  wbs6_dat_o        ),
  
                    //Slave 7
                    .wbs7_adr_i(  wbs7_adr_i        ),   
	                .wbs7_bte_i(  wbs7_bte_i        ),   
	                .wbs7_cti_i(  wbs7_cti_i        ),   
	                .wbs7_cyc_i(  wbs7_cyc_i        ),   
	                .wbs7_dat_i(  wbs7_dat_i        ),   
	                .wbs7_sel_i(  wbs7_sel_i        ),   
                    .wbs7_stb_i(  wbs7_stb_i        ),   
	                .wbs7_we_i (  wbs7_we_i         ),   
	                .wbs7_ack_o(  wbs7_ack_o        ),   
	                .wbs7_err_o(  wbs7_err_o        ),   
	                .wbs7_rty_o(  wbs7_rty_o        ),   
	                .wbs7_dat_o(  wbs7_dat_o        ),
	// Clocks, resets
						.wb_clk ( wb_clk ), 
						.wb_rst ( reset )
					   );
			    
         end 
   end 
endgenerate 


