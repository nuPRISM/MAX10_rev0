`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "uart_regfile_interface_defs.v"

module discard_error_packets_and_dc_fifo_w_uart
#(
parameter current_FMC = 1,
parameter DEFAULT_WORDS_BEFORE_NEW_PACKET = 5000,
parameter REGFILE_DEFAULT_BAUD_RATE = 2000000,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter synchronizer_depth = 3

)
(
 vme_support_interface vme_pins,
 fmc_pins_interface fmc_pins,
 carrier_board_clks_interface carrier_clk_pins,
 board_support_interface board_support_pins,
 
 avalon_st_32_bit_packet_interface avalon_st_to_udp_streamer_0,
 avalon_st_32_bit_packet_interface avalon_st_to_udp_streamer_1,
 avalon_st_32_bit_packet_interface avalon_st_to_udp_streamer_2,
 avalon_st_32_bit_packet_interface avalon_st_to_udp_streamer_3,
 

 
 
  input uart_clk,
  input rate_match_clk,
  wishbone_interface external_nios_dacs_status_wishbone_interface_pins,
  wishbone_interface external_nios_dacs_control_wishbone_interface_pins,
 
  input uart_rx,
  output uart_tx,
  
  input async_hw_trigger,
  output actual_hw_trigger,
  input wire       UART_IS_SECONDARY_UART,
  input wire [7:0] UART_NUM_SECONDARY_UARTS,
  input wire [7:0] UART_ADDRESS_OF_THIS_UART,
  output     [7:0] NUM_UARTS_HERE
);

import uart_regfile_types::*;

avalon_st_32_bit_packet_interface raw_avalon_st_to_udp_streamer_0();
avalon_st_32_bit_packet_interface raw2_avalon_st_to_udp_streamer_0();
avalon_st_32_bit_packet_interface raw_avalon_st_to_udp_streamer_1();
avalon_st_32_bit_packet_interface raw2_avalon_st_to_udp_streamer_1();
avalon_st_32_bit_packet_interface raw_avalon_st_to_udp_streamer_2();
avalon_st_32_bit_packet_interface raw2_avalon_st_to_udp_streamer_2();
avalon_st_32_bit_packet_interface raw_avalon_st_to_udp_streamer_3();
avalon_st_32_bit_packet_interface raw2_avalon_st_to_udp_streamer_3();

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  Start GRIFFIN support
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////

	uart_struct uart_pins; 
	wire primary_local_txd, 
	     mux_16_to_1_uart_txd, 
	     serialite_s2m_txd;
	wire [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0] slite_uart_txd;

	
	
	assign uart_pins.rx = board_support_pins.uart_pins[1].tx;
	assign board_support_pins.uart_pins[1].rx = uart_pins.tx;
	

	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  Start Streaming Support
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [3:0] reset_udp_streamer_n;
wire [3:0] actual_reset_udp_streamer_n;
wire auto_reset;

wire [3:0] reset_udp_n;
wire auto_reset_udp;
wire [3:0] actual_reset_udp_n;											 
														 
	
	 wire        reconfig_clk = carrier_clk_pins.CLKIN_DDR_50;

(* keep = 1 *) avalon_st_32_bit_packet_interface  avalon_st_packet_tx_out_to_udp_0();
//(* keep = 1 *) avalon_st_32_bit_packet_interface  avalon_st_packet_rx_in_to_udp_0();
(* keep = 1 *) avalon_st_32_bit_packet_interface  avalon_st_packet_tx_out_to_udp_2();
(* keep = 1 *) avalon_st_32_bit_packet_interface  avalon_st_packet_tx_out_to_udp_3();

(* keep = 1 *)  logic           			mux_16_channel_input_multiplexed_output_avalon_streaming_source_ready           ;
(* keep = 1 *)  logic           			mux_16_channel_input_multiplexed_output_avalon_streaming_source_valid           ;
(* keep = 1 *)  logic  [31:0]   			mux_16_channel_input_multiplexed_output_avalon_streaming_source_data            ;
(* keep = 1 *)  logic     [1:0] 			mux_16_channel_input_multiplexed_output_avalon_streaming_source_empty           ;
(* keep = 1 *)  logic          			    mux_16_channel_input_multiplexed_output_avalon_streaming_source_error           ;
(* keep = 1 *)  logic           			mux_16_channel_input_multiplexed_output_avalon_streaming_source_startofpacket   ;
(* keep = 1 *)  logic           			mux_16_channel_input_multiplexed_output_avalon_streaming_source_endofpacket     ;    
				
	
	  concat_avalon_st_interfaces
	  #(
	  	  .connect_clocks(0) //assume clocks are correct (100MHz)
	  )
      concat_avalon_st_interfaces_to_udp_streamer_0
      (
        .avalon_st_interface_in  (avalon_st_packet_tx_out_to_udp_0),
        .avalon_st_interface_out (avalon_st_to_udp_streamer_0)
      );
	
	  concat_avalon_st_interfaces
	  #(
	  	  .connect_clocks(0) //assume clocks are correct (100MHz)
	  )
      concat_avalon_st_interfaces_fmc2_0_rx_in
      (
        .avalon_st_interface_in  (raw_avalon_st_to_udp_streamer_2),
        .avalon_st_interface_out (avalon_st_to_udp_streamer_2)
      );
	  

	  
	   concat_avalon_st_interfaces
		#(
	  	  .connect_clocks(0) //assume clocks are correct (100MHz)
	  )
      concat_avalon_st_interfaces_fmc2_4_rx_in
      (
        .avalon_st_interface_in  (raw_avalon_st_to_udp_streamer_3),
        .avalon_st_interface_out (avalon_st_to_udp_streamer_3)
      );
	
	
	
	
(* keep = 1 *) wire griffin_packet_word_clk;
wire [15:0] Griffin_Packet_Clock_Word_Clock_Divisor;

Divisor_frecuencia
#(.Bits_counter(16))
Generate_pw_clock
 (	
  //.CLOCK(carrier_clk_pins.clk_350M),
  .CLOCK(carrier_clk_pins.CLK_200MHz),
  .TIMER_OUT(griffin_packet_word_clk),
  .Comparator(Griffin_Packet_Clock_Word_Clock_Divisor)
 );	 
 /*
(* keep = 1 *) wire clk_6_25_raw;
(* keep = 1 *) wire clk_6_25;
 
Divisor_frecuencia
#(.Bits_counter(8))
Generate_6_25_MHz_clk
 (	
  .CLOCK(carrier_clk_pins.CLKIN_DDR_50),
  .TIMER_OUT(clk_6_25_raw),
  .Comparator(3)
 );	 
 
Versatile_BUFG CLK_6_25M_BUFG(.I(clk_6_25_raw),.O(clk_6_25));
	*/
wire slite_clk_tx_out ;

generate
		if (USE_200_MHZ_CLK_FOR_SERIALLITE)
		begin
			assign slite_clk_tx_out= carrier_clk_pins.CLK_200MHz;
			parameter SLITE_CLK_SPEED_IN_HZ = 200000000;
		end
		else
		begin
			assign slite_clk_tx_out= carrier_clk_pins.CLK_100MHz;
			parameter SLITE_CLK_SPEED_IN_HZ = 100000000;
		end
		
endgenerate
	
avalon_st_32_bit_packet_interface  avalon_st_packet_tx_out_fmc1_4();
avalon_st_32_bit_packet_interface  avalon_st_packet_rx_in_fmc1_4();
avalon_st_32_bit_packet_interface  avalon_st_packet_tx_out_fmc1_5();
avalon_st_32_bit_packet_interface  avalon_st_packet_rx_in_fmc1_5();
avalon_st_32_bit_packet_interface  avalon_st_packet_tx_out_fmc1_6();
avalon_st_32_bit_packet_interface  avalon_st_packet_rx_in_fmc1_6();
avalon_st_32_bit_packet_interface  avalon_st_packet_tx_out_fmc1_7();
avalon_st_32_bit_packet_interface  avalon_st_packet_rx_in_fmc1_7();

wire override_muxout_tx_ready;

     assign avalon_st_packet_tx_out_fmc1_4.empty    = mux_16_channel_input_multiplexed_output_avalon_streaming_source_empty        ;
     assign avalon_st_packet_tx_out_fmc1_4.eop      = mux_16_channel_input_multiplexed_output_avalon_streaming_source_endofpacket  ;
     assign avalon_st_packet_tx_out_fmc1_4.sop      = mux_16_channel_input_multiplexed_output_avalon_streaming_source_startofpacket  ;
     assign avalon_st_packet_tx_out_fmc1_4.valid    = mux_16_channel_input_multiplexed_output_avalon_streaming_source_valid          ;
     assign avalon_st_packet_tx_out_fmc1_4.data     = mux_16_channel_input_multiplexed_output_avalon_streaming_source_data           ;
     assign avalon_st_packet_tx_out_fmc1_4.error    = mux_16_channel_input_multiplexed_output_avalon_streaming_source_error;
	 assign mux_16_channel_input_multiplexed_output_avalon_streaming_source_ready = avalon_st_packet_tx_out_fmc1_4.ready | override_muxout_tx_ready ;
     assign avalon_st_packet_tx_out_fmc1_4.clk      = slite_clk_tx_out; //clk_6_25;	
	 	 	
	(* keep = 1 *) wire [7:0] current_serialite_rx_packet_id;
	(* keep = 1 *) wire [7:0] current_serialite_rx_clk;
	
	parameter SERIALITE_ctl_rxrdp_ftl_DEFAULT     = 70; 
	parameter SERIALITE_ctl_rxrdp_eopdav_DEFAULT  = 1;
	parameter SERIALITE_ctl_txrdp_fth_DEFAULT     = 100;
	/*
	parameter SERIALITE_ctl_rxhpp_ftl_DEFAULT     =      9; 
	parameter SERIALITE_ctl_rxhpp_eopdav_DEFAULT  =      0;
	parameter SERIALITE_ctl_txhpp_fth_DEFAULT     = 32'hE0;
	*/
	parameter SERIALITE_ctl_rxhpp_ftl_DEFAULT     = 50;
	parameter SERIALITE_ctl_rxhpp_eopdav_DEFAULT  =  1;
	parameter SERIALITE_ctl_txhpp_fth_DEFAULT     = 50;
	
	
	/*
    serialite_xcvr_1_channel_w_uart_control
    #(
     .xcvr_name("sltf1c4"),
	 .ctl_rxrdp_ftl_DEFAULT   (SERIALITE_ctl_rxrdp_ftl_DEFAULT    ),
     .ctl_rxrdp_eopdav_DEFAULT(SERIALITE_ctl_rxrdp_eopdav_DEFAULT),
     .ctl_txrdp_fth_DEFAULT   (SERIALITE_ctl_txrdp_fth_DEFAULT   ),
     .REGFILE_BAUD_RATE       (REGFILE_DEFAULT_BAUD_RATE         )
	  
    )
	s2m_serialite_xcvr_1_channel_w_uart_control_inst
   (
	.XCVR_RX(fmc_pins.fmc[1].FMC_RX[4]),
	.XCVR_TX(fmc_pins.fmc[1].FMC_TX[4]),
	.CLKIN_125MHz(carrier_clk_pins.CLKIN_VAR_R),
	.CLKIN_50MHz(carrier_clk_pins.CLKIN_DDR_50),
	.uart_tx(serialite_s2m_txd),
	.uart_rx(uart_pins.rx),
	.avalon_st_packet_tx_out(avalon_st_packet_tx_out_fmc1_4),
	.avalon_st_packet_rx_in (avalon_st_packet_rx_in_fmc1_4 ),	
	.current_rx_packet_id(current_serialite_rx_packet_id),
	.rx_clk(current_serialite_rx_clk),
    .IS_SECONDARY_UART(1),
    .NUM_SECONDARY_UARTS(0),
    .ADDRESS_OF_THIS_UART(1)
	);
    */
	 
	
	 /*
	 
	 genvar current_fmc1_slite_xcvr; 
	 generate
	           begin : seriallite_out_stream
				            Reconfig_GX_4_Channel
					        Reconfig_GX_4_Serialite_Channels
					       (
						    .reconfig_clk     (reconfig_clk) ,
						    .reconfig_fromgxb (reconfig_fromgxb_all_channels[(current_reconfig_block+1)*68-1 -: 68]) ,
						    .busy             (xcvr_reconfig_busy_all_channels[(current_reconfig_block+1)*1-1  -: 1 ]) ,
						    .error            (reconfig_gx_error_all_channels[(current_reconfig_block+1)*32-1 -: 32]) ,
						    .reconfig_togxb   (reconfig_togxb_all_channels[(current_reconfig_block+1)*4-1 -: 4])
					       );
						   
						   
			 for (current_fmc1_slite_xcvr = 0; current_fmc1_slite_xcvr < NUM_FMC1_SLITE_XCVRS; current_fmc1_slite_xcvr++)
			 begin : fmc1_slite_xcvr
				    wire  [3:0]   reconfig_togxb;	
                    wire [16:0]	  reconfig_fromgxb;	
                    wire [31:0]   reconfig_gx_error;	
                    wire          xcvr_reconfig_busy;	
						
            
					serialite_priority_xcvr_1_channel_w_uart_control_external_reconfig
                     #(
                      .xcvr_name("sltf1c4"),
                      .ctl_rxhpp_ftl_DEFAULT   (SERIALITE_ctl_rxhpp_ftl_DEFAULT    ),
                      .ctl_rxhpp_eopdav_DEFAULT(SERIALITE_ctl_rxhpp_eopdav_DEFAULT),
                      .ctl_txhpp_fth_DEFAULT   (SERIALITE_ctl_txhpp_fth_DEFAULT   ),
                      .REGFILE_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
                      .logical_channel_number(0)					  
                     )
                    s2m_serialite_xcvr_1_channel_w_uart_control_inst
					(
					 .XCVR_RX(fmc_pins.fmc[1].FMC_RX[4]),
					 .XCVR_TX(fmc_pins.fmc[1].FMC_TX[4]),
					 .CLKIN_125MHz(carrier_clk_pins.CLKIN_VAR_R),
					 .CLKIN_50MHz(carrier_clk_pins.CLKIN_DDR_50),
					 .uart_tx(serialite_s2m_txd),
					 .uart_rx(uart_pins.rx),
					 .avalon_st_packet_tx_out(avalon_st_packet_tx_out_fmc1_4),
					 .avalon_st_packet_rx_in (avalon_st_packet_rx_in_fmc1_4 ),	
					 .current_rx_packet_id(current_serialite_rx_packet_id),
					 .rx_clk(current_serialite_rx_clk),
					 .IS_SECONDARY_UART(1),
					 .NUM_SECONDARY_UARTS(0),
					 .ADDRESS_OF_THIS_UART(1),
					 .reconfig_clk        (reconfig_clk       ),
					 .reconfig_togxb      (reconfig_togxb     ),
					 .reconfig_fromgxb    (reconfig_fromgxb   ),
					 .reconfig_gx_error   (reconfig_gx_error  ),
					 .xcvr_reconfig_busy  (xcvr_reconfig_busy )
				 );
				end
      endgenerate						
		*/
		
genvar current_udp_streamer;
generate	
		for (current_udp_streamer = 0; current_udp_streamer < 4; current_udp_streamer++)
		begin : sync_udp_reset
				doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
				sync_reset_auto_reset_udp
				(
				.indata(reset_udp_n[current_udp_streamer]),
				.outdata(actual_reset_udp_n[current_udp_streamer]),
				.clk(carrier_clk_pins.CLK_100MHz)
				);	
						
				doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
				sync_reset_to_slite_clk_for_udp_streamers
				(
				.indata(reset_udp_streamer_n[current_udp_streamer]),
				.outdata(actual_reset_udp_streamer_n[current_udp_streamer]),
				.clk(slite_clk_tx_out)
				);
		end		
endgenerate	

wire avalon_st_packet_rx_in_fmc1_4_ready_raw; 
     wire [3:0] override_udp_ready;
     wire [3:0] actual_override_udp_ready;

		 generate
	           begin : seriallite_out_stream
				  
				        wire  [3:0]   reconfig_togxb;	
                    wire [16:0]	  reconfig_fromgxb;	
                    wire [31:0]   reconfig_gx_error;	
                    wire          xcvr_reconfig_busy;	
						  
						Reconfig_GX Reconfig_GX_inst(
						 .reconfig_clk(reconfig_clk),
						 .reconfig_fromgxb (reconfig_fromgxb),
						 .busy (xcvr_reconfig_busy),
						 .error ( reconfig_gx_error ),
						 .reconfig_togxb(reconfig_togxb)
						 );
	
		
`ifdef USE_NO_ROE_SERIALLITE_VARIANT
    				serialite_priority_xcvr_1_channel_w_uart_control_external_reconfig_no_roe      
`else
					serialite_priority_xcvr_1_channel_w_uart_control_external_reconfig
`endif
                     #(
                      .xcvr_name("sltf1c4"),
                      .ctl_rxhpp_ftl_DEFAULT   (SERIALITE_ctl_rxhpp_ftl_DEFAULT    ),
                      .ctl_rxhpp_eopdav_DEFAULT(SERIALITE_ctl_rxhpp_eopdav_DEFAULT),
                      .ctl_txhpp_fth_DEFAULT   (SERIALITE_ctl_txhpp_fth_DEFAULT   ),
                      .REGFILE_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
                      .logical_channel_number(0)					  
                     )
                    s2m_serialite_xcvr_1_channel_w_uart_control_inst
                    (
                     .XCVR_RX(fmc_pins.fmc[1].FMC_RX[4]),
							.XCVR_TX(fmc_pins.fmc[1].FMC_TX[4]),
							.CLKIN_125MHz(carrier_clk_pins.CLKIN_VAR_R),
							.CLKIN_50MHz(carrier_clk_pins.CLKIN_DDR_50),
							.uart_tx(serialite_s2m_txd),
							.uart_rx(uart_pins.rx),
							.avalon_st_packet_tx_out(avalon_st_packet_tx_out_fmc1_4),
						  .avalon_st_packet_rx_in (avalon_st_packet_rx_in_fmc1_4 ),	
						  .current_rx_packet_id(current_serialite_rx_packet_id),
                    .rx_clk(current_serialite_rx_clk),
                    .IS_SECONDARY_UART(1),
                    .NUM_SECONDARY_UARTS(0),
                    .ADDRESS_OF_THIS_UART(1),
					     .reconfig_clk        (reconfig_clk       ),
					     .reconfig_togxb      (reconfig_togxb     ),
					     .reconfig_fromgxb    (reconfig_fromgxb   ),
					     .reconfig_gx_error   (reconfig_gx_error  ),
					     .xcvr_reconfig_busy  (xcvr_reconfig_busy )
                  );
						
						
                   //standalone_error_packet_discard 
				         standalone_error_packet_discard_no_avalon_mm
						 discard_errors_going_to_udp_1 (
                        .clk_clk                                          (carrier_clk_pins.CLK_100MHz),                                          //                                  clk.clk
                        .reset_reset_n                                    ((!auto_reset_udp) & (actual_reset_udp_n[1])),                                    //                                reset.reset_n
                        .error_packet_discard_avalon_st_src_valid         (avalon_st_to_udp_streamer_1.valid    ),         //   error_packet_discard_avalon_st_src.valid
                        .error_packet_discard_avalon_st_src_ready         (avalon_st_to_udp_streamer_1.ready    ),         //                                     .ready
                        .error_packet_discard_avalon_st_src_data          (avalon_st_to_udp_streamer_1.data     ),          //                                     .data
                        .error_packet_discard_avalon_st_src_empty         (avalon_st_to_udp_streamer_1.empty    ),         //                                     .empty
                        .error_packet_discard_avalon_st_src_startofpacket (avalon_st_to_udp_streamer_1.sop      ), //                                     .startofpacket
                        .error_packet_discard_avalon_st_src_endofpacket   (avalon_st_to_udp_streamer_1.eop      ),   //                                     .endofpacket
                        .error_packet_discard_avalon_st_snk_valid         (raw_avalon_st_to_udp_streamer_1.valid),         //   error_packet_discard_avalon_st_snk.valid
                        .error_packet_discard_avalon_st_snk_ready         (raw_avalon_st_to_udp_streamer_1.ready),         //                                     .ready
                        .error_packet_discard_avalon_st_snk_data          (raw_avalon_st_to_udp_streamer_1.data ),          //                                     .data
                        .error_packet_discard_avalon_st_snk_empty         (raw_avalon_st_to_udp_streamer_1.empty),         //                                     .empty
                        .error_packet_discard_avalon_st_snk_startofpacket (raw_avalon_st_to_udp_streamer_1.sop  ), //                                     .startofpacket
                        .error_packet_discard_avalon_st_snk_endofpacket   (raw_avalon_st_to_udp_streamer_1.eop  ),   //                                     .endofpacket
                        .error_packet_discard_avalon_st_snk_error         ({5'b0,raw_avalon_st_to_udp_streamer_1.error})         //                                     .error
                        //.bridge_to_internal_avalon_mm_slave_waitrequest   (avalon_mm_pipeline_bridge_interface_pins.waitrequest   ),   // bridge_to_internal_avalon_mm_slave.waitrequest
                        //.bridge_to_internal_avalon_mm_slave_readdata      (avalon_mm_pipeline_bridge_interface_pins.readdata      ),      //                                   .readdata
                        //.bridge_to_internal_avalon_mm_slave_readdatavalid (avalon_mm_pipeline_bridge_interface_pins.readdatavalid ), //                                   .readdatavalid
                        //.bridge_to_internal_avalon_mm_slave_burstcount    (avalon_mm_pipeline_bridge_interface_pins.burstcount    ),    //                                   .burstcount
                        //.bridge_to_internal_avalon_mm_slave_writedata     (avalon_mm_pipeline_bridge_interface_pins.writedata     ),     //                                   .writedata
                        //.bridge_to_internal_avalon_mm_slave_address       (avalon_mm_pipeline_bridge_interface_pins.address       ),       //                                   .address
                        //.bridge_to_internal_avalon_mm_slave_write         (avalon_mm_pipeline_bridge_interface_pins.write         ),         //                                   .write
                        //.bridge_to_internal_avalon_mm_slave_read          (avalon_mm_pipeline_bridge_interface_pins.read          ),          //                                   .read
                        //.bridge_to_internal_avalon_mm_slave_byteenable    (avalon_mm_pipeline_bridge_interface_pins.byteenable    ),    //                                   .byteenable
                        //.bridge_to_internal_avalon_mm_slave_debugaccess   (avalon_mm_pipeline_bridge_interface_pins.debugaccess   ),   //                                   .debugaccess
                        //.clk_avalon_mm_clk                                (avalon_mm_pipeline_bridge_interface_pins.clk           )                                 //                      clk_avalon_mm.clk
                    );
                   
                   
						
						
						 avalon_st_dc_fifo_only 
						 connect_slite_to_udp1 (
															  .in_clk_clk             (       slite_clk_tx_out                        ),             //   in_clk.clk
															  .in_reset_reset_n        ((!auto_reset) & (actual_reset_udp_streamer_n[1])),       // in_reset.reset_n
															  .out_data_data           (raw_avalon_st_to_udp_streamer_1.data ),           //      out_data.data
															  .out_data_valid          (raw_avalon_st_to_udp_streamer_1.valid),          //              .valid
															  .out_data_ready          (raw_avalon_st_to_udp_streamer_1.ready),          //              .ready
															  .out_data_startofpacket  (raw_avalon_st_to_udp_streamer_1.sop  ),  //              .startofpacket
															  .out_data_endofpacket    (raw_avalon_st_to_udp_streamer_1.eop  ),    //              .endofpacket
															  .out_data_empty          (raw_avalon_st_to_udp_streamer_1.empty),          //              .empty
															  .out_data_error          (raw_avalon_st_to_udp_streamer_1.error),         //         .error
															  .in_data_data            (avalon_st_packet_rx_in_fmc1_4.data),            //       in_data.data
															  .in_data_valid           (avalon_st_packet_rx_in_fmc1_4.valid),                               //              .valid
															  .in_data_ready           (avalon_st_packet_rx_in_fmc1_4_ready_raw),           //              .ready
															  .in_data_startofpacket   (avalon_st_packet_rx_in_fmc1_4.sop),   //              .startofpacket
															  .in_data_endofpacket     (avalon_st_packet_rx_in_fmc1_4.eop),     //              .endofpacket
															  .in_data_empty           (avalon_st_packet_rx_in_fmc1_4.empty),           //              .empty
															  .in_data_error           (avalon_st_packet_rx_in_fmc1_4.error),         //         .error
															  .out_clk_clk             (carrier_clk_pins.CLK_100MHz),            //  out_clk.clk
															  .out_rst_reset_n         ((!auto_reset_udp) & (actual_reset_udp_n[1]))         //  out_rst.reset_n
														 );
														 
														 assign avalon_st_packet_rx_in_fmc1_4.ready = avalon_st_packet_rx_in_fmc1_4_ready_raw || actual_override_udp_ready[1];
														 assign avalon_st_packet_rx_in_fmc1_4.clk = slite_clk_tx_out;
														 assign raw_avalon_st_to_udp_streamer_1.clk = carrier_clk_pins.CLK_100MHz;

														generate_one_shot_pulse 
														#(.num_clks_to_wait(1))  
														generate_auto_reset_udp
														(
														.clk(carrier_clk_pins.CLK_100MHz), 
														.oneshot_pulse(auto_reset_udp)
														);
															
													
														
														doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
														sync_override_udp_ready1
														(
														.indata(override_udp_ready[1]),
														.outdata(actual_override_udp_ready[1]),
														.clk(avalon_st_packet_rx_in_fmc1_4.clk)
														);
															
                                           /*
														 
														  concat_avalon_st_interfaces
														  #(
														  .use_clk_from_avalon_st_interface_in(0)
														  )
															concat_avalon_st_interfaces_to_udp_streamer_1
															(
															  .avalon_st_interface_in  (avalon_st_packet_rx_in_fmc1_4),
															  .avalon_st_interface_out (avalon_st_to_udp_streamer_1)
															);
														
																			
														*/	
						
						
						
						end
      endgenerate						
		
	

	
	

		(* keep = 1 *) wire [31:0] griffin_packet_data;
		(* keep = 1 *) wire [23:0] griffin_packet_count;
		(* keep = 1 *) wire [23:0] griffin_packet_word_counter;
		(* keep = 1 *) wire [23:0] griffin_total_word_counter;
		(* keep = 1 *) wire [23:0] griffin_packet_words_before_new_packet;
		(* keep = 1 *) wire [23:0] griffin_packet_length_in_words;
		(* keep = 1 *) wire griffin_tx_packet_transpose_input;
		(* keep = 1 *) wire griffin_tx_packet_transpose_output;
		(* keep = 1 *) wire griffin_tx_packet_tx_enable;
		(* keep = 1 *) wire [11:0] griffin_tx_state;                            
		(* keep = 1 *) wire [31:0] griffin_tx_possibly_transposed_indata;       
		(* keep = 1 *) wire [31:0] griffin_tx_actual_possibly_transposed_indata;
		(* keep = 1 *) wire [15:0] griffin_tx_packet_byte_count;
		(* keep = 1 *) wire griffin_tx_select_inserted_data;             
		(* keep = 1 *) wire [31:0] griffin_tx_inserted_data;
		(* keep = 1 *) wire [31:0] griffin_tx_actual_output_data;
		(* keep = 1 *) wire griffin_tx_enable_output_data;               
		(* keep = 1 *) wire griffin_tx_new_packet_work_clk_has_arrived;
			 
			
	    (* keep = 1 *) wire        griffin_streamer_to_udp_packet_word_clk               [3:0];
		(* keep = 1 *) wire [23:0] griffin_streamer_to_udp_packet_count                  [3:0];
		(* keep = 1 *) wire [23:0] griffin_streamer_to_udp_packet_word_counter           [3:0];
		(* keep = 1 *) wire [23:0] griffin_streamer_to_udp_total_word_counter            [3:0];
		(* keep = 1 *) wire [23:0] griffin_streamer_to_udp_packet_words_before_new_packet[3:0];
		(* keep = 1 *) wire [13:0] griffin_streamer_to_udp_packet_length_in_words        [3:0];
		(* keep = 1 *) wire  [3:0]      griffin_streamer_to_udp_tx_packet_tx_reset  ;
		(* keep = 1 *) wire  [3:0]      griffin_streamer_to_udp_tx_packet_tx_enable ;

 //assign griffin_streamer_to_udp_tx_packet_tx_reset  = udp_streamer_reset;
 //assign griffin_streamer_to_udp_tx_packet_tx_enable = udp_streamer_enable;
 
 
 
 wire [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0] slave_packet_emulator_demarcate_reset;
 wire [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0] griffin_input_slave_mux_almost_full_data ;
 wire [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0] griffin_input_slave_mux_almost_empty_data;
 wire [1:0] input_fifo_for_udp_inserter_0_sc_fifo_0_almost_empty_data;
 wire input_fifo_for_udp_inserter_0_sc_fifo_0_almost_full_data; 
 wire [1:0] input_fifo_for_udp_inserter_2_sc_fifo_0_almost_empty_data;
 wire input_fifo_for_udp_inserter_2_sc_fifo_0_almost_full_data;
 wire [1:0] input_fifo_for_udp_inserter_3_sc_fifo_0_almost_empty_data;
 wire input_fifo_for_udp_inserter_3_sc_fifo_0_almost_full_data;
 
(* keep = 1 *) wire [23:0] slave_entrance_emulator_griffin_packet_count                          [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire [23:0] slave_entrance_emulator_griffin_packet_word_counter                   [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire [23:0] slave_entrance_emulator_griffin_total_word_counter                    [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire [23:0] slave_entrance_emulator_griffin_packet_words_before_new_packet        [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire        slave_entrance_emulator_griffin_tx_packet_transpose_input             [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire        slave_entrance_emulator_griffin_tx_packet_transpose_output            [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire  [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0]      slave_entrance_emulator_griffin_tx_packet_tx_enable;
(* keep = 1 *) wire [11:0] slave_entrance_emulator_griffin_tx_state                              [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];                            
(* keep = 1 *) wire [31:0] slave_entrance_emulator_griffin_tx_possibly_transposed_indata         [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];       
(* keep = 1 *) wire [31:0] slave_entrance_emulator_griffin_tx_actual_possibly_transposed_indata  [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire        slave_entrance_emulator_griffin_packet_word_clk                       [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
               wire  [23:0] slave_entrance_emulator_griffin_packet_length_in_words                [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];

		       wire         slave_entrance_emulator_griffin_avalon_st_clk                          [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire         slave_entrance_emulator_griffin_packet_sop                            [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire         slave_entrance_emulator_griffin_packet_eop                            [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire         slave_entrance_emulator_griffin_packet_valid                          [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire         slave_entrance_emulator_griffin_packet_ready                          [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire         slave_entrance_emulator_griffin_packet_error                          [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire   [1:0] slave_entrance_emulator_griffin_packet_empty                          [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];
(* keep = 1 *) wire [31:0]  slave_entrance_emulator_griffin_packet_data                           [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0];

(* keep = 1 *) wire        [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0] selected_real_received_slite_data_to_go_to_mux;
(* keep = 1 *) wire        [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0] block_unselected_data_to_mux;
 wire [7:0] UniqueIDAdd;
 

  wire [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS-1:0] reconfig_togxb_all_channels;
  wire [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS*17-1:0] reconfig_fromgxb_all_channels;
  wire [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS/4*32-1:0] reconfig_gx_error_all_channels;
  wire [NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS/4-1:0] xcvr_reconfig_busy_all_channels;

	genvar current_reconfig_block;
	 generate
	           for (current_reconfig_block = 0; current_reconfig_block < NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS/4; current_reconfig_block++)
			   begin : generate_reconfig_blocks						
					 
					        Reconfig_GX_4_Channel
					        Reconfig_GX_4_Serialite_Channels
					       (
						    .reconfig_clk     (reconfig_clk) ,
						    .reconfig_fromgxb (reconfig_fromgxb_all_channels[(current_reconfig_block+1)*68-1 -: 68]) ,
						    .busy             (xcvr_reconfig_busy_all_channels[(current_reconfig_block+1)*1-1  -: 1 ]) ,
						    .error            (reconfig_gx_error_all_channels[(current_reconfig_block+1)*32-1 -: 32]) ,
						    .reconfig_togxb   (reconfig_togxb_all_channels[(current_reconfig_block+1)*4-1 -: 4])
					       );
               end
	endgenerate
    genvar current_slave_entrance_emulator;
	 generate
	           for (current_slave_entrance_emulator = 0; current_slave_entrance_emulator < NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS; current_slave_entrance_emulator++)
			   begin : generate_slave_entrance_emulators
							
                    avalon_st_32_bit_packet_interface  avalon_st_source_out();
					avalon_st_32_bit_packet_interface  avalon_st_selected_source_out();
				    avalon_st_32_bit_packet_interface  avalon_st_packet_rx_in();

					avalon_st_32_bit_packet_interface  avalon_st_packet_tx_out_to_slite();

					
					choose_between_two_avalon_st_interfaces
					#(
					  .connect_clocks(0)
					)
					choose_between_emulated_and_real_data_packets
					(
					  .avalon_st_interface_in0(avalon_st_source_out),
					  .avalon_st_interface_in1(avalon_st_packet_rx_in),
					  .avalon_st_interface_out(avalon_st_selected_source_out),
					  .sel(selected_real_received_slite_data_to_go_to_mux[current_slave_entrance_emulator]),
					  .block_unconnected_interface(block_unselected_data_to_mux[current_slave_entrance_emulator])

					);
					
					
					generate_avalon_st_compatible_emulated_packet
					generate_avalon_st_compatible_emulated_packet_inst
					(					
					.unique_index(UniqueIDAdd+current_slave_entrance_emulator+4),
					.avalon_st_source_out            (avalon_st_source_out                                                                                  ),
					.packet_clk                      (slave_entrance_emulator_griffin_packet_word_clk                      [current_slave_entrance_emulator]),
					.avalon_st_clk                   (slave_entrance_emulator_griffin_avalon_st_clk                        [current_slave_entrance_emulator]),
					.packet_words_before_new_packet  (slave_entrance_emulator_griffin_packet_words_before_new_packet       [current_slave_entrance_emulator]),
					.packet_length_in_words          (slave_entrance_emulator_griffin_packet_length_in_words               [current_slave_entrance_emulator]),
					.transpose_input                 (1'b0                                                                                                  ),
					.transpose_output                (1'b0                                                                                                  ),
					.enable                          (slave_entrance_emulator_griffin_tx_packet_tx_enable                  [current_slave_entrance_emulator]),
					.reset                           (slave_packet_emulator_demarcate_reset                                [current_slave_entrance_emulator])
					);
		   
		   /*
		         generate_avalon_st_compatible_emulated_packet					
			      generate_packets_to_tx_slite
					(
					.unique_index(UniqueIDAdd+current_slave_entrance_emulator+4+NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS),
					.avalon_st_source_out            (avalon_st_packet_tx_out_to_slite                                                                                  ),
					.packet_clk                      (slave_entrance_emulator_griffin_packet_word_clk                      [current_slave_entrance_emulator]),
					.avalon_st_clk                   (slave_entrance_emulator_griffin_avalon_st_clk                        [current_slave_entrance_emulator]),
					.packet_words_before_new_packet  (slave_entrance_emulator_griffin_packet_words_before_new_packet       [current_slave_entrance_emulator]),
					.packet_length_in_words          (slave_entrance_emulator_griffin_packet_length_in_words               [current_slave_entrance_emulator]),
					.transpose_input                 (1'b0                                                                                                  ),
					.transpose_output                (1'b0                                                                                                  ),
					.enable                          (slave_entrance_emulator_griffin_tx_packet_tx_enable                  [current_slave_entrance_emulator]),
					.reset                           (slave_packet_emulator_demarcate_reset                                [current_slave_entrance_emulator])
					);
			*/		
					/*
					 avalon_st_splitter_1_to_2 u0 (
										.avalon_st_splitter_clk_clk            (slave_entrance_emulator_griffin_avalon_st_clk),            //   avalon_st_splitter_clk.clk
										.avalon_st_splitter_reset_reset        (1'b0),        // avalon_st_splitter_reset.reset
										.avalon_st_splitter_in_ready           (<connected-to-avalon_st_splitter_in_ready>),           //    avalon_st_splitter_in.ready
										.avalon_st_splitter_in_valid           (<connected-to-avalon_st_splitter_in_valid>),           //                         .valid
										.avalon_st_splitter_in_startofpacket   (<connected-to-avalon_st_splitter_in_startofpacket>),   //                         .startofpacket
										.avalon_st_splitter_in_endofpacket     (<connected-to-avalon_st_splitter_in_endofpacket>),     //                         .endofpacket
										.avalon_st_splitter_in_empty           (<connected-to-avalon_st_splitter_in_empty>),           //                         .empty
										.avalon_st_splitter_in_error           (<connected-to-avalon_st_splitter_in_error>),           //                         .error
										.avalon_st_splitter_in_data            (<connected-to-avalon_st_splitter_in_data>),            //                         .data
										.avalon_st_splitter_out0_ready         (<connected-to-avalon_st_splitter_out0_ready>),         //  avalon_st_splitter_out0.ready
										.avalon_st_splitter_out0_valid         (<connected-to-avalon_st_splitter_out0_valid>),         //                         .valid
										.avalon_st_splitter_out0_startofpacket (<connected-to-avalon_st_splitter_out0_startofpacket>), //                         .startofpacket
										.avalon_st_splitter_out0_endofpacket   (<connected-to-avalon_st_splitter_out0_endofpacket>),   //                         .endofpacket
										.avalon_st_splitter_out0_empty         (<connected-to-avalon_st_splitter_out0_empty>),         //                         .empty
										.avalon_st_splitter_out0_error         (<connected-to-avalon_st_splitter_out0_error>),         //                         .error
										.avalon_st_splitter_out0_data          (<connected-to-avalon_st_splitter_out0_data>),          //                         .data
										.avalon_st_splitter_out1_ready         (<connected-to-avalon_st_splitter_out1_ready>),         //  avalon_st_splitter_out1.ready
										.avalon_st_splitter_out1_valid         (<connected-to-avalon_st_splitter_out1_valid>),         //                         .valid
										.avalon_st_splitter_out1_startofpacket (<connected-to-avalon_st_splitter_out1_startofpacket>), //                         .startofpacket
										.avalon_st_splitter_out1_endofpacket   (<connected-to-avalon_st_splitter_out1_endofpacket>),   //                         .endofpacket
										.avalon_st_splitter_out1_empty         (<connected-to-avalon_st_splitter_out1_empty>),         //                         .empty
										.avalon_st_splitter_out1_error         (<connected-to-avalon_st_splitter_out1_error>),         //                         .error
										.avalon_st_splitter_out1_data          (<connected-to-avalon_st_splitter_out1_data>)           //                         .data
									);

                    */
					
					
		          griffin_avalon_st_fifoed_packet_source					
			      generate_packets_to_tx_slite
					(
					.unique_index(UniqueIDAdd+current_slave_entrance_emulator+4+NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS),
					.avalon_st_packet_tx_out            (avalon_st_packet_tx_out_to_slite                                                                                  ),
					.packet_clk                      (slave_entrance_emulator_griffin_packet_word_clk                      [current_slave_entrance_emulator]),
					.avalon_st_clk                   (slave_entrance_emulator_griffin_avalon_st_clk                        [current_slave_entrance_emulator]),
					.packet_words_before_new_packet  (slave_entrance_emulator_griffin_packet_words_before_new_packet       [current_slave_entrance_emulator]),
					.packet_length_in_words          (slave_entrance_emulator_griffin_packet_length_in_words               [current_slave_entrance_emulator]),
					.enable                          (slave_entrance_emulator_griffin_tx_packet_tx_enable                  [current_slave_entrance_emulator]),
					.reset                           (slave_packet_emulator_demarcate_reset                                [current_slave_entrance_emulator])
					);
		   
		            assign avalon_st_selected_source_out.ready                        = slave_entrance_emulator_griffin_packet_ready[current_slave_entrance_emulator];
		            assign slave_entrance_emulator_griffin_packet_sop        [current_slave_entrance_emulator]   =    avalon_st_selected_source_out.sop;
		            assign slave_entrance_emulator_griffin_packet_eop        [current_slave_entrance_emulator]   =    avalon_st_selected_source_out.eop;
		            assign slave_entrance_emulator_griffin_packet_valid      [current_slave_entrance_emulator]   =    avalon_st_selected_source_out.valid;
		            assign slave_entrance_emulator_griffin_packet_error      [current_slave_entrance_emulator]   =    avalon_st_selected_source_out.error;
		            assign slave_entrance_emulator_griffin_packet_empty      [current_slave_entrance_emulator]   =    avalon_st_selected_source_out.empty;
		            assign slave_entrance_emulator_griffin_packet_data       [current_slave_entrance_emulator]   =    avalon_st_selected_source_out.data;
		    
					assign slave_entrance_emulator_griffin_tx_packet_transpose_input     [current_slave_entrance_emulator]=griffin_tx_packet_transpose_input ;
					assign slave_entrance_emulator_griffin_tx_packet_transpose_output    [current_slave_entrance_emulator]=griffin_tx_packet_transpose_output;
					assign slave_entrance_emulator_griffin_packet_word_clk               [current_slave_entrance_emulator]=griffin_packet_word_clk           ;
					assign slave_entrance_emulator_griffin_packet_length_in_words        [current_slave_entrance_emulator]=griffin_packet_length_in_words    ;
					
					assign slave_entrance_emulator_griffin_avalon_st_clk                        [current_slave_entrance_emulator] = slite_clk_tx_out;// clk_6_25;
					assign avalon_st_selected_source_out.clk                                                                      = slite_clk_tx_out;// clk_6_25;
					assign avalon_st_packet_rx_in.clk                                                                             = slite_clk_tx_out;// clk_6_25;
					
					localparam [7:0] slite_ascii_suffix_digit_0 = 48 + (current_slave_entrance_emulator % 10);
					localparam [7:0] slite_ascii_suffix_digit_1 = 48 + (current_slave_entrance_emulator / 10);
					localparam current_slite_fmc  = (current_slave_entrance_emulator > ((NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS/2)-1)) ? 2 : 0; 
					localparam current_slite_xcvr = (current_slave_entrance_emulator > ((NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS/2)-1)) ? (current_slave_entrance_emulator-NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS/2) : current_slave_entrance_emulator; 
					wire slite_clk;
					assign slite_clk = (current_slave_entrance_emulator > ((NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS/2)-1)) ? carrier_clk_pins.CLKIN_VAR_L : carrier_clk_pins.CLKIN_VAR_R;						
	
	                localparam current_logical_channel = (current_slave_entrance_emulator * 4);
	                localparam current_reconfig_instance_index = (current_slave_entrance_emulator/4+1);
				    localparam current_logical_channel_modulo_16 = current_logical_channel % 16;

					
                    wire  [3:0]   reconfig_togxb;	
                    wire [16:0]	  reconfig_fromgxb;	
                    wire [31:0]   reconfig_gx_error;	
                    wire          xcvr_reconfig_busy;	
	
 	                assign reconfig_togxb = reconfig_togxb_all_channels[current_reconfig_instance_index*4-1 -: 4];	
	                assign reconfig_fromgxb_all_channels[(current_slave_entrance_emulator+1)*17-1 -: 17] = reconfig_fromgxb;	
	                assign reconfig_gx_error = reconfig_gx_error_all_channels[current_reconfig_instance_index*32-1 -: 32];	
	                assign xcvr_reconfig_busy = xcvr_reconfig_busy_all_channels[current_reconfig_instance_index-1 -: 1];	
	
                    						
							`ifdef USE_NO_ROE_SERIALLITE_VARIANT
								serialite_priority_xcvr_1_channel_w_uart_control_external_reconfig_no_roe      
							`else
								serialite_priority_xcvr_1_channel_w_uart_control_external_reconfig
							`endif                   
							
                     #(
                      .xcvr_name({"slite",slite_ascii_suffix_digit_1,slite_ascii_suffix_digit_0}),
                      .ctl_rxhpp_ftl_DEFAULT   (SERIALITE_ctl_rxhpp_ftl_DEFAULT    ),
                      .ctl_rxhpp_eopdav_DEFAULT(SERIALITE_ctl_rxhpp_eopdav_DEFAULT),
                      .ctl_txhpp_fth_DEFAULT   (SERIALITE_ctl_txhpp_fth_DEFAULT   ),
                      .REGFILE_BAUD_RATE(REGFILE_DEFAULT_BAUD_RATE),
                      .logical_channel_number(current_logical_channel_modulo_16)					  
                     )
                    s2m_serialite_xcvr_1_channel_w_uart_control_inst
                    (
                    .XCVR_RX          (fmc_pins.fmc[current_slite_fmc].FMC_RX[current_slite_xcvr]),
                    .XCVR_TX          (fmc_pins.fmc[current_slite_fmc].FMC_TX[current_slite_xcvr]),
                    .CLKIN_125MHz     (slite_clk),
                    .CLKIN_50MHz      (carrier_clk_pins.CLKIN_DDR_50),
                    .uart_tx(slite_uart_txd[current_slave_entrance_emulator]),
                    .uart_rx(uart_pins.rx),
                    .avalon_st_packet_tx_out(avalon_st_packet_tx_out_to_slite),
                    .avalon_st_packet_rx_in (avalon_st_packet_rx_in ),	
                    .current_rx_packet_id(),
                    .rx_clk(),
                    .IS_SECONDARY_UART(1),
                    .NUM_SECONDARY_UARTS(0),
                    .ADDRESS_OF_THIS_UART(current_slave_entrance_emulator+3),
					.reconfig_clk        (reconfig_clk       ),
					.reconfig_togxb      (reconfig_togxb     ),
					.reconfig_fromgxb    (reconfig_fromgxb   ),
					.reconfig_gx_error   (reconfig_gx_error  ),
					.xcvr_reconfig_busy  (xcvr_reconfig_busy )
                    );
	
					
				end
	endgenerate
	 	 			
						

generate_one_shot_pulse 
#(.num_clks_to_wait(1))  
generate_auto_reset
(
.clk(slite_clk_tx_out), 
.oneshot_pulse(auto_reset)
);

	parameter wb_local_regfile_address_numbits        =   16;

	parameter wb_local_regfile_data_numbytes        =   4;
    parameter wb_local_regfile_desc_numbytes        =  16;
    parameter wb_num_of_local_regfile_control_regs     =  32'h88;
	wire [31:0] uart_bridge_test_pio;

	

uart_wishbone_bridge_interface 	
#(                                                                                                     
  .DATA_NUMBYTES                                (wb_local_regfile_data_numbytes                       ),
  .DESC_NUMBYTES                                (wb_local_regfile_desc_numbytes                       ),
  .NUM_OF_CONTROL_REGS                          (wb_num_of_local_regfile_control_regs                 )
)
mux_16_to_1_uart_interface_pins();

assign mux_16_to_1_uart_interface_pins.display_name         = "PacketMux16_to_1";
assign mux_16_to_1_uart_interface_pins.clk                  = slite_clk_tx_out;
assign mux_16_to_1_uart_interface_pins.async_reset          = local_regfile_control_async_reset;
assign mux_16_to_1_uart_interface_pins.user_type            = uart_regfile_types::PACKET_MUX_16_TO_1_AVALON_MM_MAPPED_UART_REGFILE;
assign mux_16_to_1_uart_interface_pins.num_secondary_uarts  = 0; 
assign mux_16_to_1_uart_interface_pins.address_of_this_uart = 2;
assign mux_16_to_1_uart_interface_pins.is_secondary_uart    = 1;
assign mux_16_to_1_uart_interface_pins.rxd = uart_pins.rx;
assign mux_16_to_1_uart_txd = mux_16_to_1_uart_interface_pins.txd;

assign mux_16_to_1_uart_interface_pins.control_desc[0] = "pio_out";
assign mux_16_to_1_uart_interface_pins.control_desc[4] = "pio_in";

localparam ZERO_IN_ASCII = 48;
localparam start_address_of_mux_fifos_in_avalon_mm = 8;

genvar curr_fifo_number;
generate
       //see ug_embedded_ip.pdf table 15-3 for scfifo register map
       for (curr_fifo_number = 0; curr_fifo_number < 16; curr_fifo_number++)
		 begin : assign_descriptions_for_scfifo_avalon_mm_address_space
		      wire [7:0] char1 = ((curr_fifo_number/10)+ZERO_IN_ASCII);
			  wire [7:0] char2 = ((curr_fifo_number % 10)+ZERO_IN_ASCII);
		      assign mux_16_to_1_uart_interface_pins.control_desc[(curr_fifo_number)*8+start_address_of_mux_fifos_in_avalon_mm]   = {"fill_level",char1,char2};
			  assign mux_16_to_1_uart_interface_pins.control_desc[(curr_fifo_number)*8+start_address_of_mux_fifos_in_avalon_mm+1] = {"reserved",char1,char2};
			  assign mux_16_to_1_uart_interface_pins.control_desc[(curr_fifo_number)*8+start_address_of_mux_fifos_in_avalon_mm+2] = {"AlmostFullThr",char1,char2};
			  assign mux_16_to_1_uart_interface_pins.control_desc[(curr_fifo_number)*8+start_address_of_mux_fifos_in_avalon_mm+3] = {"AlmostEmptyThr",char1,char2};
			  assign mux_16_to_1_uart_interface_pins.control_desc[(curr_fifo_number)*8+start_address_of_mux_fifos_in_avalon_mm+4] = {"CutThruThr",char1,char2};
			  assign mux_16_to_1_uart_interface_pins.control_desc[(curr_fifo_number)*8+start_address_of_mux_fifos_in_avalon_mm+5] = {"DropOnError",char1,char2};
		 end 
endgenerate

avalon_mm_pipeline_bridge_interface 
#(
.num_address_bits(wb_local_regfile_address_numbits)
)
mux_16_to_1_mm_slave_interface_pins();

uart_controlled_avalon_mm_master_w_interfaces
#(
	.NUM_OF_CONTROL_REGS   (wb_num_of_local_regfile_control_regs),
    .DATA_NUMBYTES   (wb_local_regfile_data_numbytes),
    .DESC_NUMBYTES   (wb_local_regfile_desc_numbytes),
    .ADDRESS_WIDTH_IN_BITS (wb_local_regfile_address_numbits),		  
	.CLOCK_SPEED_IN_HZ(SLITE_CLK_SPEED_IN_HZ),
    .UART_BAUD_RATE_IN_HZ(REGFILE_DEFAULT_BAUD_RATE),
	.USE_AUTO_RESET(1'b1),
	.DISABLE_ERROR_MONITORING(1'b1)
	
)
uart_control_of_16_to_1_mux
(
 .uart_regfile_interface_pins(mux_16_to_1_uart_interface_pins),
 .avalon_mm_slave_interface_pins(mux_16_to_1_mm_slave_interface_pins)
);

	
griffin_16_channel_mux_w_fifo_standalone_200MHz 
griffin_16_channel_mux_w_fifo_standalone_200MHz_inst (
        .clk_clk                                                  (slite_clk_tx_out),                                                  //                                        clk.clk
        .reset_reset_n                                            ((!auto_reset) & (actual_reset_udp_streamer_n[1])),                                            //                                      reset.reset_n
        
	    .pio_out_external_connection_export                       (uart_bridge_test_pio),                       //                pio_out_external_connection.export
        .pio_in_external_connection_export                        (uart_bridge_test_pio),                         //                 pio_in_external_connection.export
        /*
		.mm_bridge_0_s0_waitrequest                               ( mux_waitrequest                                                     ),                               //                             mm_bridge_0_s0.waitrequest
        .mm_bridge_0_s0_readdata                                  ( wbm_dat_i                                            ),                            //                                           .readdata
        .mm_bridge_0_s0_readdatavalid                             (  mux_readdatavalid                                                    ),                            //                                           .readdatavalid
        .mm_bridge_0_s0_burstcount                                ( 0                                                    ),                            //                                           .burstcount
        .mm_bridge_0_s0_writedata                                 ( wbm_dat_o                                            ),                            //                                           .writedata
        .mm_bridge_0_s0_address                                   ( wbm_adr_o                                            ),                            //                                           .address
        .mm_bridge_0_s0_write                                     ( wbm_cyc_o & wbm_we_o                                 ),                            //                                           .write
        .mm_bridge_0_s0_read                                      ( wbm_cyc_o & !wbm_we_o                                ),                            //                                           .read
        .mm_bridge_0_s0_byteenable                                ( wbm_sel_o                                            ),                            //                                           .byteenable
        .mm_bridge_0_s0_debugaccess                               ( 0                                                    ),                            //                                           .debugaccess
         */	
		 
		.mm_bridge_0_s0_waitrequest                               ( mux_16_to_1_mm_slave_interface_pins.waitrequest               ),                               //                             mm_bridge_0_s0.waitrequest
        .mm_bridge_0_s0_readdata                                  ( mux_16_to_1_mm_slave_interface_pins.readdata                  ),                            //                                           .readdata
        .mm_bridge_0_s0_readdatavalid                             ( mux_16_to_1_mm_slave_interface_pins.readdatavalid             ),                            //                                           .readdatavalid
        .mm_bridge_0_s0_burstcount                                ( mux_16_to_1_mm_slave_interface_pins.burstcount                ),                            //                                           .burstcount
        .mm_bridge_0_s0_writedata                                 ( mux_16_to_1_mm_slave_interface_pins.writedata                 ),                            //                                           .writedata
        .mm_bridge_0_s0_address                                   ( mux_16_to_1_mm_slave_interface_pins.address                   ),                            //                                           .address
        .mm_bridge_0_s0_write                                     ( mux_16_to_1_mm_slave_interface_pins.write                     ),                            //                                           .write
        .mm_bridge_0_s0_read                                      ( mux_16_to_1_mm_slave_interface_pins.read                      ),                            //                                           .read
        .mm_bridge_0_s0_byteenable                                ( mux_16_to_1_mm_slave_interface_pins.byteenable                ),                            //                                           .byteenable
        .mm_bridge_0_s0_debugaccess                               ( mux_16_to_1_mm_slave_interface_pins.debugaccess               ),                            //                                           .debugaccess
		
		
		.fifo_0_sc_fifo_0_in_data                                 (slave_entrance_emulator_griffin_packet_data [0]         ),                                 //                        fifo_0_sc_fifo_0_in.data
        .fifo_0_sc_fifo_0_in_valid                                (slave_entrance_emulator_griffin_packet_valid[0]        ),                                //                                                                .valid
        .fifo_0_sc_fifo_0_in_ready                                (slave_entrance_emulator_griffin_packet_ready[0]        ),                                //                                                                .ready
        .fifo_0_sc_fifo_0_in_startofpacket                        (slave_entrance_emulator_griffin_packet_sop  [0]          ),                        //                                                                .startofpacket
        .fifo_0_sc_fifo_0_in_endofpacket                          (slave_entrance_emulator_griffin_packet_eop  [0]          ),                          //                                                                .endofpacket
        .fifo_0_sc_fifo_0_in_empty                                (slave_entrance_emulator_griffin_packet_empty[0]        ),                                //                                                                .empty		
        
		.fifo_1_sc_fifo_0_in_data                                 (slave_entrance_emulator_griffin_packet_data [1]         ),                     //                        fifo_1_sc_fifo_0_in.data
        .fifo_1_sc_fifo_0_in_valid                                (slave_entrance_emulator_griffin_packet_valid[1]        ),                     //                                                                .valid
        .fifo_1_sc_fifo_0_in_ready                                (slave_entrance_emulator_griffin_packet_ready[1]        ),                     //                                                                .ready
        .fifo_1_sc_fifo_0_in_startofpacket                        (slave_entrance_emulator_griffin_packet_sop  [1]          ),                     //                                                                .startofpacket
        .fifo_1_sc_fifo_0_in_endofpacket                          (slave_entrance_emulator_griffin_packet_eop  [1]          ),                     //                                                                .endofpacket
        .fifo_1_sc_fifo_0_in_empty                                (slave_entrance_emulator_griffin_packet_empty[1]        ),                     //                                                                .empty
		.fifo_2_sc_fifo_0_in_data                                 (slave_entrance_emulator_griffin_packet_data [2]         ),                     //                        fifo_2_sc_fifo_0_in.data
        .fifo_2_sc_fifo_0_in_valid                                (slave_entrance_emulator_griffin_packet_valid[2]        ),                     //                                                                .valid
        .fifo_2_sc_fifo_0_in_ready                                (slave_entrance_emulator_griffin_packet_ready[2]        ),                     //                                                                .ready
        .fifo_2_sc_fifo_0_in_startofpacket                        (slave_entrance_emulator_griffin_packet_sop  [2]          ),                     //                                                                .startofpacket
        .fifo_2_sc_fifo_0_in_endofpacket                          (slave_entrance_emulator_griffin_packet_eop  [2]          ),                     //                                                                .endofpacket
        .fifo_2_sc_fifo_0_in_empty                                (slave_entrance_emulator_griffin_packet_empty[2]        ),                     //                                                                .empty
		.fifo_3_sc_fifo_0_in_data                                 (slave_entrance_emulator_griffin_packet_data [3]         ),                     //                        fifo_3_sc_fifo_0_in.data
        .fifo_3_sc_fifo_0_in_valid                                (slave_entrance_emulator_griffin_packet_valid[3]        ),                     //                                                                .valid
        .fifo_3_sc_fifo_0_in_ready                                (slave_entrance_emulator_griffin_packet_ready[3]        ),                     //                                                                .ready
        .fifo_3_sc_fifo_0_in_startofpacket                        (slave_entrance_emulator_griffin_packet_sop  [3]          ),                     //                                                                .startofpacket
        .fifo_3_sc_fifo_0_in_endofpacket                          (slave_entrance_emulator_griffin_packet_eop  [3]          ),                     //                                                                .endofpacket
        .fifo_3_sc_fifo_0_in_empty                                (slave_entrance_emulator_griffin_packet_empty[3]        ),                     //                                                                .empty
		.fifo_4_sc_fifo_0_in_data                                 (slave_entrance_emulator_griffin_packet_data [4]         ),                     //                        fifo_4_sc_fifo_0_in.data
        .fifo_4_sc_fifo_0_in_valid                                (slave_entrance_emulator_griffin_packet_valid[4]        ),                     //                                                                .valid
        .fifo_4_sc_fifo_0_in_ready                                (slave_entrance_emulator_griffin_packet_ready[4]        ),                     //                                                                .ready
        .fifo_4_sc_fifo_0_in_startofpacket                        (slave_entrance_emulator_griffin_packet_sop  [4]          ),                     //                                                                .startofpacket
        .fifo_4_sc_fifo_0_in_endofpacket                          (slave_entrance_emulator_griffin_packet_eop  [4]          ),                     //                                                                .endofpacket
        .fifo_4_sc_fifo_0_in_empty                                (slave_entrance_emulator_griffin_packet_empty[4]        ),                     //                                                                .empty
		.fifo_5_sc_fifo_0_in_data                                 (slave_entrance_emulator_griffin_packet_data [5]         ),                     //                        fifo_5_sc_fifo_0_in.data
        .fifo_5_sc_fifo_0_in_valid                                (slave_entrance_emulator_griffin_packet_valid[5]        ),                     //                                                                .valid
        .fifo_5_sc_fifo_0_in_ready                                (slave_entrance_emulator_griffin_packet_ready[5]        ),                     //                                                                .ready
        .fifo_5_sc_fifo_0_in_startofpacket                        (slave_entrance_emulator_griffin_packet_sop  [5]          ),                     //                                                                .startofpacket
        .fifo_5_sc_fifo_0_in_endofpacket                          (slave_entrance_emulator_griffin_packet_eop  [5]          ),                     //                                                                .endofpacket
        .fifo_5_sc_fifo_0_in_empty                                (slave_entrance_emulator_griffin_packet_empty[5]        ),                     //                                                                .empty
		.fifo_6_sc_fifo_0_in_data                                 (slave_entrance_emulator_griffin_packet_data [6]         ),                     //                        fifo_6_sc_fifo_0_in.data
        .fifo_6_sc_fifo_0_in_valid                                (slave_entrance_emulator_griffin_packet_valid[6]        ),                     //                                                                .valid
        .fifo_6_sc_fifo_0_in_ready                                (slave_entrance_emulator_griffin_packet_ready[6]        ),                     //                                                                .ready
        .fifo_6_sc_fifo_0_in_startofpacket                        (slave_entrance_emulator_griffin_packet_sop  [6]          ),                     //                                                                .startofpacket
        .fifo_6_sc_fifo_0_in_endofpacket                          (slave_entrance_emulator_griffin_packet_eop [6]          ),                     //                                                                .endofpacket
        .fifo_6_sc_fifo_0_in_empty                                (slave_entrance_emulator_griffin_packet_empty[6]        ),                     //                                                                .empty
		.fifo_7_sc_fifo_0_in_data                                 (slave_entrance_emulator_griffin_packet_data[7]         ),                     //                        fifo_7_sc_fifo_0_in.data
        .fifo_7_sc_fifo_0_in_valid                                (slave_entrance_emulator_griffin_packet_valid[7]        ),                     //                                                                .valid
        .fifo_7_sc_fifo_0_in_ready                                (slave_entrance_emulator_griffin_packet_ready[7]        ),                     //                                                                .ready
        .fifo_7_sc_fifo_0_in_startofpacket                        (slave_entrance_emulator_griffin_packet_sop[7]                ),                     //                                                                .startofpacket
        .fifo_7_sc_fifo_0_in_endofpacket                          (slave_entrance_emulator_griffin_packet_eop[7]                 ),                     //                                                                .endofpacket
        .fifo_7_sc_fifo_0_in_empty                                (slave_entrance_emulator_griffin_packet_empty[7]                                       ),                     //                                                                .empty
        .fifo_8_sc_fifo_0_in_data                                 (slave_entrance_emulator_griffin_packet_data[8]             ),                     //                        fifo_8_sc_fifo_0_in.data
        .fifo_8_sc_fifo_0_in_valid                                (slave_entrance_emulator_griffin_packet_valid[8]            ),                     //                                                                .valid
        .fifo_8_sc_fifo_0_in_ready                                (slave_entrance_emulator_griffin_packet_ready[8]                                                         ),                     //                                                                .ready
        .fifo_8_sc_fifo_0_in_startofpacket                        (slave_entrance_emulator_griffin_packet_sop[8]              ),                     //                                                                .startofpacket
        .fifo_8_sc_fifo_0_in_endofpacket                          (slave_entrance_emulator_griffin_packet_eop[8]               ),                     //                                                                .endofpacket
        .fifo_8_sc_fifo_0_in_empty                                (slave_entrance_emulator_griffin_packet_empty[8]                                   ),                     //                                                                .empty
        .fifo_9_sc_fifo_0_in_data                                 (slave_entrance_emulator_griffin_packet_data[9]           ),                     //                        fifo_9_sc_fifo_0_in.data
        .fifo_9_sc_fifo_0_in_valid                                (slave_entrance_emulator_griffin_packet_valid[9]          ),                     //                                                                .valid
        .fifo_9_sc_fifo_0_in_ready                                (slave_entrance_emulator_griffin_packet_ready[9]                                                              ),                     //                                                                .ready
        .fifo_9_sc_fifo_0_in_startofpacket                        (slave_entrance_emulator_griffin_packet_sop[9]            ),                     //                                                                .startofpacket
        .fifo_9_sc_fifo_0_in_endofpacket                          (slave_entrance_emulator_griffin_packet_eop[9]             ),                     //                                                                .endofpacket
        .fifo_9_sc_fifo_0_in_empty                                (slave_entrance_emulator_griffin_packet_empty[9]                                  ),                     //                                                                .empty
        .fifo_10_sc_fifo_0_in_data                                (slave_entrance_emulator_griffin_packet_data[10]          ),                     //                       fifo_10_sc_fifo_0_in.data
        .fifo_10_sc_fifo_0_in_valid                               (slave_entrance_emulator_griffin_packet_valid[10]         ),                     //                                                                .valid
        .fifo_10_sc_fifo_0_in_ready                               (slave_entrance_emulator_griffin_packet_ready[10]                                                              ),                     //                                                                .ready
        .fifo_10_sc_fifo_0_in_startofpacket                       (slave_entrance_emulator_griffin_packet_sop[10]           ),                     //                                                                .startofpacket
        .fifo_10_sc_fifo_0_in_endofpacket                         (slave_entrance_emulator_griffin_packet_eop[10]            ),                     //                                                                .endofpacket
        .fifo_10_sc_fifo_0_in_empty                               (slave_entrance_emulator_griffin_packet_empty[10]                                   ),                     //                                                                .empty
        .fifo_11_sc_fifo_0_in_data                                (slave_entrance_emulator_griffin_packet_data[11]         ),                     //                       fifo_12_sc_fifo_0_in.data
        .fifo_11_sc_fifo_0_in_valid                               (slave_entrance_emulator_griffin_packet_valid[11]        ),                     //                                                                .valid
        .fifo_11_sc_fifo_0_in_ready                               (slave_entrance_emulator_griffin_packet_ready[11]                                                           ),                     //                                                                .ready
        .fifo_11_sc_fifo_0_in_startofpacket                       (slave_entrance_emulator_griffin_packet_sop[11]          ),                     //                                                                .startofpacket
        .fifo_11_sc_fifo_0_in_endofpacket                         (slave_entrance_emulator_griffin_packet_eop[11]           ),                     //                                                                .endofpacket
        .fifo_11_sc_fifo_0_in_empty                               (slave_entrance_emulator_griffin_packet_empty[11]                             ),                     //                                                                .empty
		
		`ifndef ROUTE_CHANNELS_12_AND_15_TO_UDP
        .fifo_12_sc_fifo_0_in_data                                (slave_entrance_emulator_griffin_packet_data[12]        ),                     //                       fifo_11_sc_fifo_0_in.data
        .fifo_12_sc_fifo_0_in_valid                               (slave_entrance_emulator_griffin_packet_valid[12]       ),                     //                                                                .valid
        .fifo_12_sc_fifo_0_in_ready                               (slave_entrance_emulator_griffin_packet_ready[12]                                                         ),                     //                                                                .ready
        .fifo_12_sc_fifo_0_in_startofpacket                       (slave_entrance_emulator_griffin_packet_sop[12]         ),                     //                                                                .startofpacket
        .fifo_12_sc_fifo_0_in_endofpacket                         (slave_entrance_emulator_griffin_packet_eop[12]          ),                     //                                                                .endofpacket
        .fifo_12_sc_fifo_0_in_empty                               (slave_entrance_emulator_griffin_packet_empty[12]                                 ),                     //                                                                .empty
		`endif
		
        .fifo_13_sc_fifo_0_in_data                                (slave_entrance_emulator_griffin_packet_data[13]      ),                     //                       fifo_13_sc_fifo_0_in.data
        .fifo_13_sc_fifo_0_in_valid                               (slave_entrance_emulator_griffin_packet_valid[13]     ),                     //                                                                .valid
        .fifo_13_sc_fifo_0_in_ready                               (slave_entrance_emulator_griffin_packet_ready[13]                                                      ),                     //                                                                .ready
        .fifo_13_sc_fifo_0_in_startofpacket                       (slave_entrance_emulator_griffin_packet_sop[13]       ),                     //                                                                .startofpacket
        .fifo_13_sc_fifo_0_in_endofpacket                         (slave_entrance_emulator_griffin_packet_eop[13]        ),                     //                                                                .endofpacket
        .fifo_13_sc_fifo_0_in_empty                               (slave_entrance_emulator_griffin_packet_empty[13]                          ),                     //                                                                .empty
        .fifo_14_sc_fifo_0_in_data                                (slave_entrance_emulator_griffin_packet_data[14]      ),                     //                       fifo_14_sc_fifo_0_in.data
        .fifo_14_sc_fifo_0_in_valid                               (slave_entrance_emulator_griffin_packet_valid[14]     ),                     //                                                                .valid
        .fifo_14_sc_fifo_0_in_ready                               (slave_entrance_emulator_griffin_packet_ready[14]                                                  ),                     //                                                                .ready
        .fifo_14_sc_fifo_0_in_startofpacket                       (slave_entrance_emulator_griffin_packet_sop[14]       ),                     //                                                                .startofpacket
        .fifo_14_sc_fifo_0_in_endofpacket                         (slave_entrance_emulator_griffin_packet_eop[14]        ),                     //                                                                .endofpacket		
        .fifo_14_sc_fifo_0_in_empty                               (slave_entrance_emulator_griffin_packet_empty[14]                              ),                     //                                                                .empty
		
		`ifndef ROUTE_CHANNELS_12_AND_15_TO_UDP
        .fifo_15_sc_fifo_0_in_data                                (slave_entrance_emulator_griffin_packet_data[15]    ),                     //                       fifo_15_sc_fifo_0_in.data
        .fifo_15_sc_fifo_0_in_valid                               (slave_entrance_emulator_griffin_packet_valid[15]   ),                     //                                                                .valid
        .fifo_15_sc_fifo_0_in_ready                               (slave_entrance_emulator_griffin_packet_ready[15]                                                    ),                     //                                                                .ready
        .fifo_15_sc_fifo_0_in_startofpacket                       (slave_entrance_emulator_griffin_packet_sop[15]     ),                     //                                                                .startofpacket
        .fifo_15_sc_fifo_0_in_endofpacket                         (slave_entrance_emulator_griffin_packet_eop[15]      ),                     //                                                                .endofpacket
        .fifo_15_sc_fifo_0_in_empty                               (slave_entrance_emulator_griffin_packet_empty[15]                             ),                     //    
		`endif		
		
	    .fifo_0_sc_fifo_0_almost_empty_data                                            (griffin_input_slave_mux_almost_empty_data [0]),        
	    .fifo_1_sc_fifo_0_almost_empty_data                                            (griffin_input_slave_mux_almost_empty_data [1]),        
	    .fifo_2_sc_fifo_0_almost_empty_data                                            (griffin_input_slave_mux_almost_empty_data [2]),        
	    .fifo_3_sc_fifo_0_almost_empty_data                                            (griffin_input_slave_mux_almost_empty_data [3]),        
	    .fifo_4_sc_fifo_0_almost_empty_data                                            (griffin_input_slave_mux_almost_empty_data [4]),        
	    .fifo_5_sc_fifo_0_almost_empty_data                                            (griffin_input_slave_mux_almost_empty_data [5]),        
	    .fifo_6_sc_fifo_0_almost_empty_data                                            (griffin_input_slave_mux_almost_empty_data [6]),        
	    .fifo_7_sc_fifo_0_almost_empty_data                                            (griffin_input_slave_mux_almost_empty_data [7]),        
	    .fifo_8_sc_fifo_0_almost_empty_data                                            (griffin_input_slave_mux_almost_empty_data [8]),        
	    .fifo_9_sc_fifo_0_almost_empty_data                                            (griffin_input_slave_mux_almost_empty_data [9]),        
	    .fifo_10_sc_fifo_0_almost_empty_data                                           (griffin_input_slave_mux_almost_empty_data[10]),       
	    .fifo_11_sc_fifo_0_almost_empty_data                                           (griffin_input_slave_mux_almost_empty_data[11]),       
	    .fifo_12_sc_fifo_0_almost_empty_data                                           (griffin_input_slave_mux_almost_empty_data[12]),       
	    .fifo_13_sc_fifo_0_almost_empty_data                                           (griffin_input_slave_mux_almost_empty_data[13]),       
	    .fifo_14_sc_fifo_0_almost_empty_data                                           (griffin_input_slave_mux_almost_empty_data[14]),       
	    .fifo_15_sc_fifo_0_almost_empty_data                                           (griffin_input_slave_mux_almost_empty_data[15]),       
	  	 
	    .fifo_0_sc_fifo_0_almost_full_data                                             (griffin_input_slave_mux_almost_full_data [0]),              
	    .fifo_1_sc_fifo_0_almost_full_data                                             (griffin_input_slave_mux_almost_full_data [1]),              
	    .fifo_2_sc_fifo_0_almost_full_data                                             (griffin_input_slave_mux_almost_full_data [2]),              
	    .fifo_3_sc_fifo_0_almost_full_data                                             (griffin_input_slave_mux_almost_full_data [3]),              
	    .fifo_4_sc_fifo_0_almost_full_data                                             (griffin_input_slave_mux_almost_full_data [4]),              
	    .fifo_5_sc_fifo_0_almost_full_data                                             (griffin_input_slave_mux_almost_full_data [5]),              
	    .fifo_6_sc_fifo_0_almost_full_data                                             (griffin_input_slave_mux_almost_full_data [6]),              
	    .fifo_7_sc_fifo_0_almost_full_data                                             (griffin_input_slave_mux_almost_full_data [7]),              
	    .fifo_8_sc_fifo_0_almost_full_data                                             (griffin_input_slave_mux_almost_full_data [8]),              
	    .fifo_9_sc_fifo_0_almost_full_data                                             (griffin_input_slave_mux_almost_full_data [9]),              
	    .fifo_10_sc_fifo_0_almost_full_data                                            (griffin_input_slave_mux_almost_full_data[10]),             
	    .fifo_11_sc_fifo_0_almost_full_data                                            (griffin_input_slave_mux_almost_full_data[11]),             
	    .fifo_12_sc_fifo_0_almost_full_data                                            (griffin_input_slave_mux_almost_full_data[12]),             
	    .fifo_13_sc_fifo_0_almost_full_data                                            (griffin_input_slave_mux_almost_full_data[13]),             
	    .fifo_14_sc_fifo_0_almost_full_data                                            (griffin_input_slave_mux_almost_full_data[14]),             
	    .fifo_15_sc_fifo_0_almost_full_data                                            (griffin_input_slave_mux_almost_full_data[15]),             
	  
	  
	    .multiplexed_output_avalon_streaming_source_ready                              (mux_16_channel_input_multiplexed_output_avalon_streaming_source_ready        ),               //   multiplexed_output_avalon_streaming_source.ready
        .multiplexed_output_avalon_streaming_source_valid                              (mux_16_channel_input_multiplexed_output_avalon_streaming_source_valid        ),     //                                                                  .valid
        .multiplexed_output_avalon_streaming_source_data                               (mux_16_channel_input_multiplexed_output_avalon_streaming_source_data         ),     //                                                                  .data
        .multiplexed_output_avalon_streaming_source_startofpacket                      (mux_16_channel_input_multiplexed_output_avalon_streaming_source_startofpacket),     //                                                                  .startofpacket
        .multiplexed_output_avalon_streaming_source_endofpacket                        (mux_16_channel_input_multiplexed_output_avalon_streaming_source_endofpacket  ),     //                                                                  .endofpacket
        .multiplexed_output_avalon_streaming_source_empty                              (mux_16_channel_input_multiplexed_output_avalon_streaming_source_empty        ),     //                      
        .multiplexed_output_avalon_streaming_source_error                              (mux_16_channel_input_multiplexed_output_avalon_streaming_source_error        ),     //                      
		            
        .fifo_0_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[0 ]        ),                                //                                                                .empty		
        .fifo_1_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[1 ]        ),                                //                                                                .empty		
        .fifo_2_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[2 ]        ),                                //                                                                .empty		
        .fifo_3_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[3 ]        ),                                //                                                                .empty		
        .fifo_4_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[4 ]        ),                                //                                                                .empty		
        .fifo_5_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[5 ]        ),                                //                                                                .empty		
        .fifo_6_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[6 ]        ),                                //                                                                .empty		
        .fifo_7_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[7 ]        ),                                //                                                                .empty		
        .fifo_8_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[8 ]        ),                                //                                                                .empty		
        .fifo_9_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[9 ]        ),                                //                                                                .empty		
        .fifo_10_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[10]        ),                                //                                                                .empty		
        .fifo_11_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[11]        ),                                //                                                                .empty		
        .fifo_12_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[12]        ),                                //                                                                .empty		
        .fifo_13_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[13]        ),                                //                                                                .empty		
        .fifo_14_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[14]        ),                                //                                                                .empty		
        .fifo_15_sc_fifo_0_in_error                                (slave_entrance_emulator_griffin_packet_error[15]        )                                //                                                                .empty		
					
    );
	
			

	assign griffin_streamer_to_udp_packet_words_before_new_packet[0]= griffin_packet_words_before_new_packet;
	assign griffin_streamer_to_udp_packet_words_before_new_packet[2]= griffin_packet_words_before_new_packet;
	assign griffin_streamer_to_udp_packet_words_before_new_packet[3]= griffin_packet_words_before_new_packet;
	assign griffin_streamer_to_udp_packet_length_in_words        [0]= griffin_packet_length_in_words;
	assign griffin_streamer_to_udp_packet_length_in_words        [2]= griffin_packet_length_in_words;
	assign griffin_streamer_to_udp_packet_length_in_words        [3]= griffin_packet_length_in_words;
	assign griffin_streamer_to_udp_packet_word_clk[0]               = griffin_packet_word_clk;
	assign griffin_streamer_to_udp_packet_word_clk[2]               = griffin_packet_word_clk;
	assign griffin_streamer_to_udp_packet_word_clk[3]               = griffin_packet_word_clk;

griffin_avalon_st_fifoed_packet_source
udp_0_griffin_avalon_st_fifoed_packet_source
(
.unique_index(UniqueIDAdd+0),
.avalon_st_packet_tx_out        (avalon_st_packet_tx_out_to_udp_0                            ),
.reset                          (griffin_streamer_to_udp_tx_packet_tx_reset               [0]),
.enable                         (griffin_streamer_to_udp_tx_packet_tx_enable              [0]),
.packet_clk                     (griffin_streamer_to_udp_packet_word_clk                  [0]),
.avalon_st_clk                  (carrier_clk_pins.CLK_100MHz                                 ),                                      
.packet_words_before_new_packet (griffin_streamer_to_udp_packet_words_before_new_packet   [0]),
.packet_length_in_words         (griffin_streamer_to_udp_packet_length_in_words           [0]),
.packet_count                   (griffin_streamer_to_udp_packet_count                     [0]),
.packet_word_counter            (griffin_streamer_to_udp_packet_word_counter              [0]),
.total_word_counter             (griffin_streamer_to_udp_total_word_counter               [0]),
.fifo_almost_empty              (input_fifo_for_udp_inserter_0_sc_fifo_0_almost_empty_data    ),
.fifo_almost_full               (input_fifo_for_udp_inserter_0_sc_fifo_0_almost_full_data     ) 
);
	
`ifdef ROUTE_CHANNELS_12_AND_15_TO_UDP


doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_override_udp_ready2
(
.indata(override_udp_ready[2]),
.outdata(actual_override_udp_ready[2]),
.clk(avalon_st_packet_tx_out_to_udp_2.clk)
);

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_override_udp_ready3
(
.indata(override_udp_ready[3]),
.outdata(actual_override_udp_ready[3]),
.clk(avalon_st_packet_tx_out_to_udp_3.clk)
);

assign 	avalon_st_packet_tx_out_to_udp_2.data = slave_entrance_emulator_griffin_packet_data[12]  ;
assign 	avalon_st_packet_tx_out_to_udp_2.valid = slave_entrance_emulator_griffin_packet_valid[12] ;
assign 	slave_entrance_emulator_griffin_packet_ready[12] = avalon_st_packet_tx_out_to_udp_2.ready || actual_override_udp_ready[2];
assign 	avalon_st_packet_tx_out_to_udp_2.sop  = slave_entrance_emulator_griffin_packet_sop[12]   ;
assign 	avalon_st_packet_tx_out_to_udp_2.eop  = slave_entrance_emulator_griffin_packet_eop[12]   ;
assign 	avalon_st_packet_tx_out_to_udp_2.empty = slave_entrance_emulator_griffin_packet_empty[12] ;
assign 	avalon_st_packet_tx_out_to_udp_2.error = slave_entrance_emulator_griffin_packet_error[12] ;
assign 	avalon_st_packet_tx_out_to_udp_2.clk = slite_clk_tx_out ;
	
assign 	avalon_st_packet_tx_out_to_udp_3.data = slave_entrance_emulator_griffin_packet_data[15]  ;
assign 	avalon_st_packet_tx_out_to_udp_3.valid = slave_entrance_emulator_griffin_packet_valid[15] ;
assign 	slave_entrance_emulator_griffin_packet_ready[15] = avalon_st_packet_tx_out_to_udp_3.ready || actual_override_udp_ready[3];
assign 	avalon_st_packet_tx_out_to_udp_3.sop  = slave_entrance_emulator_griffin_packet_sop[15]   ;
assign 	avalon_st_packet_tx_out_to_udp_3.eop  = slave_entrance_emulator_griffin_packet_eop[15]   ;
assign 	avalon_st_packet_tx_out_to_udp_3.empty = slave_entrance_emulator_griffin_packet_empty[15] ;
assign 	avalon_st_packet_tx_out_to_udp_3.error = slave_entrance_emulator_griffin_packet_error[15] ;
assign 	avalon_st_packet_tx_out_to_udp_3.clk = slite_clk_tx_out ;
	
	

avalon_st_dc_fifo_only 
connect_slite_to_udp2 (
	  .in_clk_clk             (       slite_clk_tx_out                        ),             //   in_clk.clk
	  .in_reset_reset_n        ((!auto_reset) & (actual_reset_udp_streamer_n[2])),       // in_reset.reset_n
	  .out_data_data           (raw2_avalon_st_to_udp_streamer_2.data ),           //      out_data.data
	  .out_data_valid          (raw2_avalon_st_to_udp_streamer_2.valid),          //              .valid
	  .out_data_ready          (raw2_avalon_st_to_udp_streamer_2.ready),          //              .ready
	  .out_data_startofpacket  (raw2_avalon_st_to_udp_streamer_2.sop  ),  //              .startofpacket
	  .out_data_endofpacket    (raw2_avalon_st_to_udp_streamer_2.eop  ),    //              .endofpacket
	  .out_data_empty          (raw2_avalon_st_to_udp_streamer_2.empty),          //              .empty
	  .out_data_error          (raw2_avalon_st_to_udp_streamer_2.error),         //         .error
	  .in_data_data            (avalon_st_packet_tx_out_to_udp_2.data),            //       in_data.data
	  .in_data_valid           (avalon_st_packet_tx_out_to_udp_2.valid),                               //              .valid
	  .in_data_ready           (avalon_st_packet_tx_out_to_udp_2.ready),           //              .ready
	  .in_data_startofpacket   (avalon_st_packet_tx_out_to_udp_2.sop),   //              .startofpacket
	  .in_data_endofpacket     (avalon_st_packet_tx_out_to_udp_2.eop),     //              .endofpacket
	  .in_data_empty           (avalon_st_packet_tx_out_to_udp_2.empty),           //              .empty
	  .in_data_error           (avalon_st_packet_tx_out_to_udp_2.error),         //         .error
	  .out_clk_clk             (carrier_clk_pins.CLK_100MHz),            //  out_clk.clk
	  .out_rst_reset_n         ((!auto_reset_udp) & (actual_reset_udp_n[2]))         //  out_rst.reset_n
 );
	
standalone_error_packet_discard_no_avalon_mm 
	 discard_errors_going_to_udp_2 (
     .clk_clk                                          (carrier_clk_pins.CLK_100MHz),                                          //                                  clk.clk
     .reset_reset_n                                    ((!auto_reset_udp) & (actual_reset_udp_n[2])),                                    //                                reset.reset_n
     .error_packet_discard_avalon_st_src_valid         (raw_avalon_st_to_udp_streamer_2.valid    ),         //   error_packet_discard_avalon_st_src.valid
     .error_packet_discard_avalon_st_src_ready         (raw_avalon_st_to_udp_streamer_2.ready    ),         //                                     .ready
     .error_packet_discard_avalon_st_src_data          (raw_avalon_st_to_udp_streamer_2.data     ),          //                                     .data
     .error_packet_discard_avalon_st_src_empty         (raw_avalon_st_to_udp_streamer_2.empty    ),         //                                     .empty
     .error_packet_discard_avalon_st_src_startofpacket (raw_avalon_st_to_udp_streamer_2.sop      ), //                                     .startofpacket
     .error_packet_discard_avalon_st_src_endofpacket   (raw_avalon_st_to_udp_streamer_2.eop      ),   //                                     .endofpacket
     .error_packet_discard_avalon_st_snk_valid         (raw2_avalon_st_to_udp_streamer_2.valid),         //   error_packet_discard_avalon_st_snk.valid
     .error_packet_discard_avalon_st_snk_ready         (raw2_avalon_st_to_udp_streamer_2.ready),         //                                     .ready
     .error_packet_discard_avalon_st_snk_data          (raw2_avalon_st_to_udp_streamer_2.data ),          //                                     .data
     .error_packet_discard_avalon_st_snk_empty         (raw2_avalon_st_to_udp_streamer_2.empty),         //                                     .empty
     .error_packet_discard_avalon_st_snk_startofpacket (raw2_avalon_st_to_udp_streamer_2.sop  ), //                                     .startofpacket
     .error_packet_discard_avalon_st_snk_endofpacket   (raw2_avalon_st_to_udp_streamer_2.eop  ),   //                                     .endofpacket
     .error_packet_discard_avalon_st_snk_error         ({5'b0,raw2_avalon_st_to_udp_streamer_2.error})         //                                     .error
   
 );
	
avalon_st_dc_fifo_only 
connect_slite_to_udp3 (
	  .in_clk_clk             (       slite_clk_tx_out                        ),             //   in_clk.clk
	  .in_reset_reset_n        ((!auto_reset) & (actual_reset_udp_streamer_n[3])),       // in_reset.reset_n
	  .out_data_data           (raw2_avalon_st_to_udp_streamer_3.data ),           //      out_data.data
	  .out_data_valid          (raw2_avalon_st_to_udp_streamer_3.valid),          //              .valid
	  .out_data_ready          (raw2_avalon_st_to_udp_streamer_3.ready),          //              .ready
	  .out_data_startofpacket  (raw2_avalon_st_to_udp_streamer_3.sop  ),  //              .startofpacket
	  .out_data_endofpacket    (raw2_avalon_st_to_udp_streamer_3.eop  ),    //              .endofpacket
	  .out_data_empty          (raw2_avalon_st_to_udp_streamer_3.empty),          //              .empty
	  .out_data_error          (raw2_avalon_st_to_udp_streamer_3.error),         //         .error
	  .in_data_data            (avalon_st_packet_tx_out_to_udp_3.data),            //       in_data.data
	  .in_data_valid           (avalon_st_packet_tx_out_to_udp_3.valid),                               //              .valid
	  .in_data_ready           (avalon_st_packet_tx_out_to_udp_3.ready),           //              .ready
	  .in_data_startofpacket   (avalon_st_packet_tx_out_to_udp_3.sop),   //              .startofpacket
	  .in_data_endofpacket     (avalon_st_packet_tx_out_to_udp_3.eop),     //              .endofpacket
	  .in_data_empty           (avalon_st_packet_tx_out_to_udp_3.empty),           //              .empty
	  .in_data_error           (avalon_st_packet_tx_out_to_udp_3.error),         //         .error
	  .out_clk_clk             (carrier_clk_pins.CLK_100MHz),            //  out_clk.clk
	  .out_rst_reset_n         ((!auto_reset_udp) & (actual_reset_udp_n[3]))         //  out_rst.reset_n
 );
 
 
standalone_error_packet_discard_no_avalon_mm 
	 discard_errors_going_to_udp_3 (
     .clk_clk                                          (carrier_clk_pins.CLK_100MHz),                                          //                                  clk.clk
     .reset_reset_n                                    ((!auto_reset_udp) & (actual_reset_udp_n[3])),                                    //                                reset.reset_n
     .error_packet_discard_avalon_st_src_valid         (raw_avalon_st_to_udp_streamer_3.valid    ),         //   error_packet_discard_avalon_st_src.valid
     .error_packet_discard_avalon_st_src_ready         (raw_avalon_st_to_udp_streamer_3.ready    ),         //                                     .ready
     .error_packet_discard_avalon_st_src_data          (raw_avalon_st_to_udp_streamer_3.data     ),          //                                     .data
     .error_packet_discard_avalon_st_src_empty         (raw_avalon_st_to_udp_streamer_3.empty    ),         //                                     .empty
     .error_packet_discard_avalon_st_src_startofpacket (raw_avalon_st_to_udp_streamer_3.sop      ), //                                     .startofpacket
     .error_packet_discard_avalon_st_src_endofpacket   (raw_avalon_st_to_udp_streamer_3.eop      ),   //                                     .endofpacket
     .error_packet_discard_avalon_st_snk_valid         (raw2_avalon_st_to_udp_streamer_3.valid),         //   error_packet_discard_avalon_st_snk.valid
     .error_packet_discard_avalon_st_snk_ready         (raw2_avalon_st_to_udp_streamer_3.ready),         //                                     .ready
     .error_packet_discard_avalon_st_snk_data          (raw2_avalon_st_to_udp_streamer_3.data ),          //                                     .data
     .error_packet_discard_avalon_st_snk_empty         (raw2_avalon_st_to_udp_streamer_3.empty),         //                                     .empty
     .error_packet_discard_avalon_st_snk_startofpacket (raw2_avalon_st_to_udp_streamer_3.sop  ), //                                     .startofpacket
     .error_packet_discard_avalon_st_snk_endofpacket   (raw2_avalon_st_to_udp_streamer_3.eop  ),   //                                     .endofpacket
     .error_packet_discard_avalon_st_snk_error         ({5'b0,raw2_avalon_st_to_udp_streamer_3.error})         //                                     .error
   
 );
	assign raw2_avalon_st_to_udp_streamer_2.clk = carrier_clk_pins.CLK_100MHz;
	assign raw2_avalon_st_to_udp_streamer_3.clk = carrier_clk_pins.CLK_100MHz;
	assign raw_avalon_st_to_udp_streamer_2.clk = carrier_clk_pins.CLK_100MHz;
	assign raw_avalon_st_to_udp_streamer_3.clk = carrier_clk_pins.CLK_100MHz;
`else
	
	
	
griffin_avalon_st_fifoed_packet_source
udp_2_griffin_avalon_st_fifoed_packet_source
(
.unique_index(UniqueIDAdd+2),
.avalon_st_packet_tx_out        (raw_avalon_st_to_udp_streamer_2                             ),
.reset                          (griffin_streamer_to_udp_tx_packet_tx_reset             [2]),
.enable                         (griffin_streamer_to_udp_tx_packet_tx_enable            [2]),
.packet_clk                     (griffin_streamer_to_udp_packet_word_clk                [2]),
.avalon_st_clk                  (carrier_clk_pins.CLK_100MHz                                                     ),                                      
.packet_words_before_new_packet (griffin_streamer_to_udp_packet_words_before_new_packet [2]),
.packet_length_in_words         (griffin_streamer_to_udp_packet_length_in_words         [2]),
.packet_count                   (griffin_streamer_to_udp_packet_count                   [2]),
.packet_word_counter            (griffin_streamer_to_udp_packet_word_counter            [2]),
.total_word_counter             (griffin_streamer_to_udp_total_word_counter             [2]),
.fifo_almost_empty              (input_fifo_for_udp_inserter_2_sc_fifo_0_almost_empty_data    ),
.fifo_almost_full               (input_fifo_for_udp_inserter_2_sc_fifo_0_almost_full_data     ) 
);	
	
griffin_avalon_st_fifoed_packet_source
udp_3_griffin_avalon_st_fifoed_packet_source
(
.unique_index(UniqueIDAdd+3),
.avalon_st_packet_tx_out        (raw_avalon_st_to_udp_streamer_3                           ),
.reset                          (griffin_streamer_to_udp_tx_packet_tx_reset              [3]),
.enable                         (griffin_streamer_to_udp_tx_packet_tx_enable             [3]),
.packet_clk                     (griffin_streamer_to_udp_packet_word_clk                 [3]),
.avalon_st_clk                  (carrier_clk_pins.CLK_100MHz                                ),                                      
.packet_words_before_new_packet (griffin_streamer_to_udp_packet_words_before_new_packet  [3]),
.packet_length_in_words         (griffin_streamer_to_udp_packet_length_in_words          [3]),
.packet_count                   (griffin_streamer_to_udp_packet_count                    [3]),
.packet_word_counter            (griffin_streamer_to_udp_packet_word_counter             [3]),
.total_word_counter             (griffin_streamer_to_udp_total_word_counter              [3]),
.fifo_almost_empty              (input_fifo_for_udp_inserter_3_sc_fifo_0_almost_empty_data    ),
.fifo_almost_full               (input_fifo_for_udp_inserter_3_sc_fifo_0_almost_full_data     ) 
);
`endif
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//
	//  End Streaming Support
	//
	//
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  Start Regfile 0 Support
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
	


//===========================================================================
// For GP UART Regfile 0
//===========================================================================						
							
	
			
    parameter local_regfile_data_numbytes        =   4;
    parameter local_regfile_data_width           =   8*local_regfile_data_numbytes;
    parameter local_regfile_desc_numbytes        =  16;
    parameter local_regfile_desc_width           =   8*local_regfile_desc_numbytes;
    parameter num_of_local_regfile_control_regs  =  32;
    parameter num_of_local_regfile_status_regs   =  8;
	
    wire [local_regfile_data_width-1:0] local_regfile_control_regs_default_vals[num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_regs             [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_regs_bitwidth    [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_status           [num_of_local_regfile_status_regs -1:0];
    wire [local_regfile_desc_width-1:0] local_regfile_control_desc             [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_desc_width-1:0] local_regfile_status_desc              [num_of_local_regfile_status_regs -1:0];
	
    wire local_regfile_control_rd_error;
	wire local_regfile_control_async_reset = 1'b0;
	wire local_regfile_control_wr_error;
	wire local_regfile_control_transaction_error;
	
	
	wire [3:0] local_regfile_main_sm;
	wire [2:0] local_regfile_tx_sm;
	wire [7:0] local_regfile_command_count;
	
	
	
	wire [31:0] testCtrl0, testCtrl1, testCtrl2;
	
	//assign local_regfile_control_regs_default_vals[0]  =  64'hFEDCBA9876543210;
	
	assign local_regfile_control_regs_default_vals[1] = 32'hffffffff;
    assign local_regfile_control_desc[1] = "RstUDPStrm1_n";
    assign {reset_udp_n,reset_udp_streamer_n} = local_regfile_control_regs[1];
    assign local_regfile_control_regs_bitwidth[1] = 16;			
			
		
	assign local_regfile_control_regs_default_vals[2] = 0;
    assign local_regfile_control_desc[2] = "gTXPackTxIn";
    assign griffin_tx_packet_transpose_input = local_regfile_control_regs[2];
    assign local_regfile_control_regs_bitwidth[2] = 1;		
	 
	 
	assign local_regfile_control_regs_default_vals[3] = 0;
    assign local_regfile_control_desc[3] = "grifStreamerRst";
    assign griffin_streamer_to_udp_tx_packet_tx_reset = local_regfile_control_regs[3];
    assign local_regfile_control_regs_bitwidth[3] = 4;		
	 
	assign local_regfile_control_regs_default_vals[4] = 4'hF;
    assign local_regfile_control_desc[4] = "grifStreamerEna";
    assign griffin_streamer_to_udp_tx_packet_tx_enable = local_regfile_control_regs[4];
    assign local_regfile_control_regs_bitwidth[4] = 4;		
	 	 
	 
	 
	 
	 /*
	assign local_regfile_control_regs_default_vals[22] = 0;
    assign local_regfile_control_desc[22] = "gTXPackTxOut";
    assign griffin_tx_packet_transpose_output = local_regfile_control_regs[22];
    assign local_regfile_control_regs_bitwidth[22] = 1;		
	 
	assign local_regfile_control_regs_default_vals[23] = 0;
    assign local_regfile_control_desc[23] = "gTXPackTxEn";
    assign griffin_tx_packet_tx_enable = local_regfile_control_regs[23];
    assign local_regfile_control_regs_bitwidth[23] = 1;		
	 */
	 
	assign local_regfile_control_regs_default_vals[5] = 24'h40;
    assign local_regfile_control_desc[5] = "gPacketLengthInWords";
    assign griffin_packet_length_in_words  = local_regfile_control_regs[5];
    assign local_regfile_control_regs_bitwidth[5] = 24;		
	 
			 
	assign local_regfile_control_regs_default_vals[6] = 24'h64;
    assign local_regfile_control_desc[6] = "gPackWordBfreNew";
    assign griffin_packet_words_before_new_packet = local_regfile_control_regs[6];
    assign local_regfile_control_regs_bitwidth[6] = 24;		
	
	assign local_regfile_control_regs_default_vals[7] = 16'h7AAA;
    assign local_regfile_control_desc[7] = "gPackClkWordDiv";
    assign Griffin_Packet_Clock_Word_Clock_Divisor = local_regfile_control_regs[7];
    assign local_regfile_control_regs_bitwidth[7] = 16;		
	    
	/*
	assign local_regfile_control_regs_default_vals[27] = 0;
    assign local_regfile_control_desc[27] = "slvEmulRst";
    assign slave_packet_emulator_demarcate_reset = local_regfile_control_regs[27];
    assign local_regfile_control_regs_bitwidth[27] = NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS;		
			 
	assign local_regfile_control_regs_default_vals[28] = 0;
    assign local_regfile_control_desc[28] = "SlvEmulTxEn";
    assign slave_entrance_emulator_griffin_tx_packet_tx_enable  = local_regfile_control_regs[28];
    assign local_regfile_control_regs_bitwidth[28] = NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS;		
	 */
	 
	assign slave_entrance_emulator_griffin_tx_packet_tx_enable = {NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS{ griffin_streamer_to_udp_tx_packet_tx_enable[1]}};
	assign slave_packet_emulator_demarcate_reset               = {NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS{ griffin_streamer_to_udp_tx_packet_tx_reset [1]}};
	 
	assign local_regfile_control_regs_default_vals[8] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[8] = "gPackWodBfrNew0";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[0] = local_regfile_control_regs[8];
    assign local_regfile_control_regs_bitwidth[8] = 24;		
    	
	 
	assign local_regfile_control_regs_default_vals[9] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[9] = "gPackWodBfrNew1";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[1] = local_regfile_control_regs[9];
    assign local_regfile_control_regs_bitwidth[9] = 24;		
    	
	assign local_regfile_control_regs_default_vals[10] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[10] = "gPackWodBfrNew2";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[2] = local_regfile_control_regs[10];
    assign local_regfile_control_regs_bitwidth[10] = 24;		
    
	
	 
	assign local_regfile_control_regs_default_vals[11] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[11] = "gPackWodBfrNew3";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[3] = local_regfile_control_regs[11];
    assign local_regfile_control_regs_bitwidth[11] = 24;		
	
	assign local_regfile_control_regs_default_vals[12] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[12] = "gPackWodBfrNew4";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[4] = local_regfile_control_regs[12];
    assign local_regfile_control_regs_bitwidth[12] = 24;		
    
	 
	assign local_regfile_control_regs_default_vals[13] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[13] = "gPackWodBfrNew5";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[5] = local_regfile_control_regs[13];
    assign local_regfile_control_regs_bitwidth[13] = 24;		
    
	assign local_regfile_control_regs_default_vals[14] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[14] = "gPackWodBfrNew6";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[6] = local_regfile_control_regs[14];
    assign local_regfile_control_regs_bitwidth[14] = 24;		
    
	
	assign local_regfile_control_regs_default_vals[15] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[15] = "gPackWodBfrNew7";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[7] = local_regfile_control_regs[15];
    assign local_regfile_control_regs_bitwidth[15] = 24;	
	
	assign local_regfile_control_regs_default_vals[16] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[16] = "gPackWodBfrNew8";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[8] = local_regfile_control_regs[16];
    assign local_regfile_control_regs_bitwidth[16] = 24;		
     
	assign local_regfile_control_regs_default_vals[17] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[17] = "gPackWodBfrNew9";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[9] = local_regfile_control_regs[17];
    assign local_regfile_control_regs_bitwidth[17] = 24;		
    	
	assign local_regfile_control_regs_default_vals[18] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[18] = "gPackWodBfrNew10";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[10] = local_regfile_control_regs[18];
    assign local_regfile_control_regs_bitwidth[18] = 24;		
     
	assign local_regfile_control_regs_default_vals[19] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[19] = "gPackWodBfrNew11";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[11] = local_regfile_control_regs[19];
    assign local_regfile_control_regs_bitwidth[19] = 24;		
	
	assign local_regfile_control_regs_default_vals[20] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[20] = "gPackWodBfrNew12";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[12] = local_regfile_control_regs[20];
    assign local_regfile_control_regs_bitwidth[20] = 24;		
     
	assign local_regfile_control_regs_default_vals[21] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[21] = "gPackWodBfrNew13";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[13] = local_regfile_control_regs[21];
    assign local_regfile_control_regs_bitwidth[21] = 24;		
      
	assign local_regfile_control_regs_default_vals[22] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[22] = "gPackWodBfrNew14";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[14] = local_regfile_control_regs[22];
    assign local_regfile_control_regs_bitwidth[22] = 24;		    	
	 
	assign local_regfile_control_regs_default_vals[23] = DEFAULT_WORDS_BEFORE_NEW_PACKET;
    assign local_regfile_control_desc[23] = "gPackWodBfrNew15";
    assign slave_entrance_emulator_griffin_packet_words_before_new_packet[15] = local_regfile_control_regs[23];
    assign local_regfile_control_regs_bitwidth[23] = 24;		
    
	assign local_regfile_control_regs_default_vals[24] = 32'hFFFF;
    assign local_regfile_control_desc[24] = "SelRealSliteData";
    assign selected_real_received_slite_data_to_go_to_mux = local_regfile_control_regs[24];
    assign local_regfile_control_regs_bitwidth[24] = NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS;	
	    
	 assign local_regfile_control_regs_default_vals[25] = 0;
    assign local_regfile_control_desc[25] = "BlkUnselData";
    assign block_unselected_data_to_mux = local_regfile_control_regs[25];
    assign local_regfile_control_regs_bitwidth[25] = NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS;	
	
    assign local_regfile_control_regs_default_vals[26] = 0;
    assign local_regfile_control_desc[26] = "UniqueIDAdd";
    assign UniqueIDAdd = local_regfile_control_regs[26];
    assign local_regfile_control_regs_bitwidth[26] = 7;	
		
    assign local_regfile_control_regs_default_vals[27] = 0;
    assign local_regfile_control_desc[27] = "OvrRideMuxOReady";
    assign override_muxout_tx_ready = local_regfile_control_regs[27];
    assign local_regfile_control_regs_bitwidth[27] = 1;	
	 
	 assign local_regfile_control_regs_default_vals[28] = 32'hE;
    assign local_regfile_control_desc[28] = "OvrRideUDPReady";
    assign override_udp_ready = local_regfile_control_regs[28];
    assign local_regfile_control_regs_bitwidth[28] = 4;	
	
	assign local_regfile_control_status[0] = griffin_input_slave_mux_almost_full_data;
	assign local_regfile_status_desc[0] = "gInpSlvMuxAlmFul";	
	
	assign local_regfile_control_status[1] = griffin_input_slave_mux_almost_empty_data;
	assign local_regfile_status_desc[1] = "gInpSlvMuxAlmEmp";
		
	assign local_regfile_control_status[2] = {
	1'b0,
	input_fifo_for_udp_inserter_3_sc_fifo_0_almost_empty_data,
	input_fifo_for_udp_inserter_3_sc_fifo_0_almost_full_data,
	1'b0,
	input_fifo_for_udp_inserter_2_sc_fifo_0_almost_empty_data,
	input_fifo_for_udp_inserter_2_sc_fifo_0_almost_full_data,
	1'b0,
	input_fifo_for_udp_inserter_0_sc_fifo_0_almost_empty_data,
	input_fifo_for_udp_inserter_0_sc_fifo_0_almost_full_data	
	};		     
	       
	assign local_regfile_status_desc[2] = "fifo_0_2_3_stat";
	
	
	assign local_regfile_control_status[3] = current_serialite_rx_packet_id;
	assign local_regfile_status_desc[3] = "s2mSLPacketid";
		
	assign local_regfile_control_status[4] = uart_bridge_test_pio;
	assign local_regfile_status_desc[4] = "uartTestPio";
		
	assign uart_pins.tx = primary_local_txd & serialite_s2m_txd & mux_16_to_1_uart_txd & (&slite_uart_txd);
			
		uart_controlled_register_file_ver3
		#( 
		  .NUM_OF_CONTROL_REGS(num_of_local_regfile_control_regs),
		  .NUM_OF_STATUS_REGS(num_of_local_regfile_status_regs),
		  .DATA_WIDTH_IN_BYTES  (local_regfile_data_numbytes),
          .DESC_WIDTH_IN_BYTES  (local_regfile_desc_numbytes),
		  .INIT_ALL_CONTROL_REGS_TO_DEFAULT (1'b0),  
		  .CONTROL_REGS_DEFAULT_VAL         (0),
		  .CLOCK_SPEED_IN_HZ(50000000),
          .UART_BAUD_RATE_IN_HZ(REGFILE_DEFAULT_BAUD_RATE)
		)
		local_uart_register_file
		(	
		 .DISPLAY_NAME("GriffinTop"),
		 .CLK(carrier_clk_pins.CLKIN_DDR_50),
		 .REG_ACTIVE_HIGH_ASYNC_RESET(local_regfile_control_async_reset),
		 .CONTROL(local_regfile_control_regs),
		 .CONTROL_DESC(local_regfile_control_desc),
		 .CONTROL_BITWIDTH(local_regfile_control_regs_bitwidth),
		 .STATUS(local_regfile_control_status),
		 .STATUS_DESC (local_regfile_status_desc),
		 .CONTROL_INIT_VAL(local_regfile_control_regs_default_vals),
		 .TRANSACTION_ERROR(local_regfile_control_transaction_error),
		 .WR_ERROR(local_regfile_control_wr_error),
		 .RD_ERROR(local_regfile_control_rd_error),
		 .USER_TYPE(uart_regfile_types::GRIFC_SLAVE_CTRL_REGFILE),
		 .NUM_SECONDARY_UARTS(NUM_LOWER_LEVEL_GRIFFIN_ACQ_STREAMS+2), //to support seriallite inputs and output seriallite
         .ADDRESS_OF_THIS_UART(0),
         .IS_SECONDARY_UART(0),
		 
		 
		 //UART
		 .uart_active_high_async_reset(1'b0),
		 .rxd(uart_pins.rx),
		 .txd(primary_local_txd),
		 
		 //UART DEBUG
		 .main_sm               (local_regfile_main_sm),
		 .tx_sm                 (local_regfile_tx_sm),
		 .command_count         (local_regfile_command_count)
		  
		);
		
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  End GRIFFIN support
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
endmodule
`default_nettype wire