// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.
`default_nettype none
`include "jesd204b_a10_interface.v"
module jesd204b_a10_wrapper_mcgb  # (
   parameter LINK              = 1,  // Number of links, a link composed of multiple lanes
             L                 = 2,  // Number of lanes per converter device
             M                 = 2,  // Number of converters per converter device
             F                 = 2,  // Number of octets per frame
             S                 = 1,  // Number of transmitter samples per converter per frame
             N                 = 16, // Number of converter bits per converter
             N_PRIME           = 16, // Number of transmitted bits per sample 
             CS                = 0,  // Number of control bits per conversion sample				 
             F1_FRAMECLK_DIV   = 2,  // Frame clk divider for transport layer when F=1. Valid value = 1 or 4. Default parameter used in all F value scenarios.
             F2_FRAMECLK_DIV   = 2,  // Frame clk divider for transport layer when F=2. Valid value = 1 or 2. For F=4 & 8, this parameter is not used.
             POLYNOMIAL_LENGTH = 9,
             FEEDBACK_TAP      = 5,
             TL_DATA_BUS_WIDTH    = (F==8)? (8*8*L*N/N_PRIME) : (F==4)? (8*4*L*N/N_PRIME) : (F==2) ? (F2_FRAMECLK_DIV*8*2*L*N/N_PRIME) : (F==1) ? (F1_FRAMECLK_DIV*8*1*L*N/N_PRIME) : 1,
             TL_CONTROL_BUS_WIDTH = ( (CS==0) ? 1 : (TL_DATA_BUS_WIDTH/N*CS) ),
			 COMPILE_TX_PORTION = 0,
			 COMPILE_PATTERN_CHECKER = 0
)(

   //RX/TX serial data input/output
   input  wire [LINK*L-1:0]                     rx_serial_data,
   output wire [LINK*L-1:0]                     tx_serial_data,

	//Clock output
   jesd204b_a10_interface                       jesd204b_a10_interface_pins
);

   logic [LINK-1:0][L-1:0]                     tx_ready_or_tx_csr_lane_powerdown;
   logic [LINK-1:0][L-1:0]                     rx_ready_or_rx_csr_lane_powerdown;
   logic [LINK-1:0]                            all_tx_ready;
   logic [LINK-1:0]                            all_rx_ready;
   logic [LINK-1:0][TL_DATA_BUS_WIDTH-1:0]     assembler_din;
   logic [LINK-1:0]                            assembler_din_valid;
   logic [LINK-1:0]                            assembler_din_ready;
   logic [LINK-1:0][TL_DATA_BUS_WIDTH-1:0]     deassembler_dout;
   logic [LINK-1:0]                            deassembler_dout_valid_bus;
   logic [LINK-1:0]                            deassembler_dout_ready;
   logic [LINK-1:0][TL_DATA_BUS_WIDTH-1:0]     avst_patgen_dout;
   logic [LINK-1:0]                            avst_patgen_data_valid;
   logic [LINK-1:0]                            avst_patgen_ready_in;
   logic [LINK-1:0][TL_DATA_BUS_WIDTH-1:0]     avst_patchk_din;
   logic [LINK-1:0]                            avst_patchk_data_valid;
   logic [LINK-1:0]                            avst_patchk_data_ready;

   genvar i, j;

   //Assign PIO status and control signals
   assign jesd204b_a10_interface_pins.io_status [0]    = jesd204b_a10_interface_pins.core_pll_locked;


   generate
      for (i=0; i<LINK; i=i+1) begin: GEN_IO_STATUS_CONTROL
         assign jesd204b_a10_interface_pins.io_status [(i*3)+1] = jesd204b_a10_interface_pins.tx_xcvr_ready_in[i];
         assign jesd204b_a10_interface_pins.io_status [(i*3)+2] = jesd204b_a10_interface_pins.rx_xcvr_ready_in[i];
         assign jesd204b_a10_interface_pins.io_status [(i*3)+3] = jesd204b_a10_interface_pins.avst_patchk_data_error[i];

         assign jesd204b_a10_interface_pins.rx_seriallpbken[i] = {L{jesd204b_a10_interface_pins.io_control[i]}};
      end
   endgenerate

   //Assign output signals
   assign jesd204b_a10_interface_pins.sync_n     = jesd204b_a10_interface_pins.rx_dev_sync_n;
   assign jesd204b_a10_interface_pins.alldev_lane_aligned = &jesd204b_a10_interface_pins.dev_lane_aligned;
   
   generate
      for (i=0; i<LINK; i=i+1) begin: GEN_SYSREF
         assign jesd204b_a10_interface_pins.tx_sysref[i] = jesd204b_a10_interface_pins.sysref ;
         assign jesd204b_a10_interface_pins.rx_sysref[i] = jesd204b_a10_interface_pins.sysref ;

         assign jesd204b_a10_interface_pins.jesd204_rx_dlb_disperr[i] = {16{1'b0}};
         assign jesd204b_a10_interface_pins.jesd204_rx_dlb_errdetect[i] = {16{1'b0}};
         assign jesd204b_a10_interface_pins.jesd204_rx_dlb_kchar_data[i] = {16{1'b0}};
         assign jesd204b_a10_interface_pins.jesd204_rx_dlb_data_valid[i] = {4{1'b0}};
         assign jesd204b_a10_interface_pins.jesd204_rx_dlb_data[i] = {128{1'b0}};
      end
   endgenerate

   generate
      for (i=0; i<LINK; i=i+1) begin: GEN_BLOCK
         assign jesd204b_a10_interface_pins.xcvr_pll_locked_bus[i] = {L{jesd204b_a10_interface_pins.xcvr_pll_locked[0][0]}};
         assign jesd204b_a10_interface_pins.rx_serial_data_reordered[i] = rx_serial_data[i*L+L-1:i*L];
         assign tx_serial_data[i*L+L-1:i*L] = jesd204b_a10_interface_pins.tx_serial_data_reordered[i];
			
         //OR XCVR ready signals with CSR lane powerdown signals on per lane basis. This is to ensure that when a lane
         //is powered down, its ready signal remains asserted and does not interfere with SW XCVR ready checking algorithms
         for (j=0; j<L; j=j+1) begin: GEN_XCVR_READY_OR_CSR_LANE_POWERDOWN
            assign tx_ready_or_tx_csr_lane_powerdown[i][j] = jesd204b_a10_interface_pins.xcvr_rst_ctrl_tx_ready[0][j] | jesd204b_a10_interface_pins.tx_csr_lane_powerdown[i][j];
            assign rx_ready_or_rx_csr_lane_powerdown[i][j] = jesd204b_a10_interface_pins.xcvr_rst_ctrl_rx_ready[0][j] | jesd204b_a10_interface_pins.rx_csr_lane_powerdown[i][j];
         end

         assign all_tx_ready[i]  = &tx_ready_or_tx_csr_lane_powerdown[i];
         assign all_rx_ready[i]  = &rx_ready_or_rx_csr_lane_powerdown[i];
         assign jesd204b_a10_interface_pins.tx_xcvr_ready_in[i] = all_tx_ready[i];
         assign jesd204b_a10_interface_pins.rx_xcvr_ready_in[i] = all_rx_ready[i];

         assign jesd204b_a10_interface_pins.avst_usr_din_reordered[i] = jesd204b_a10_interface_pins.avst_usr_din[TL_DATA_BUS_WIDTH*(i+1)-1:TL_DATA_BUS_WIDTH*i];
         assign assembler_din[i]          = jesd204b_a10_interface_pins.csr_tx_testmode[i] == 4'b0000 ? jesd204b_a10_interface_pins.avst_usr_din_reordered[i] : avst_patgen_dout[i];
         assign assembler_din_valid[i]    = jesd204b_a10_interface_pins.csr_tx_testmode[i] == 4'b0000 ? jesd204b_a10_interface_pins.avst_usr_din_valid[i]  : avst_patgen_data_valid[i];
         assign jesd204b_a10_interface_pins.avst_usr_din_ready[i]     = jesd204b_a10_interface_pins.csr_tx_testmode[i] == 4'b0000 ? assembler_din_ready[i] : 1'b0;
         assign avst_patgen_ready_in[i]   = assembler_din_ready[i];
		 
			if (COMPILE_TX_PORTION)
			begin
					 //Altera Transport Layer (TX)
					 altera_jesd204_transport_tx_top #(
						.L               (L),
						.F               (F),
						.N               (N),
						.N_PRIME         (N_PRIME),
						.CS              (CS),
						.F1_FRAMECLK_DIV (F1_FRAMECLK_DIV),
						.F2_FRAMECLK_DIV (F2_FRAMECLK_DIV),
						.RECONFIG_EN     (1)
					 ) u_jesd204b_transport_tx (
						.txlink_rst_n                (jesd204b_a10_interface_pins.tx_link_rst_n[0]),
						.txframe_rst_n               (jesd204b_a10_interface_pins.tx_frame_rst_n[0]),
						.txframe_clk                 (jesd204b_a10_interface_pins.frame_clk),
						.txlink_clk                  (jesd204b_a10_interface_pins.link_clk),
						.jesd204_tx_datain           (assembler_din[i]),
						.jesd204_tx_controlin        ({TL_CONTROL_BUS_WIDTH{1'b0}}),
						.jesd204_tx_data_valid       (assembler_din_valid[i]),
						.jesd204_tx_link_early_ready (jesd204b_a10_interface_pins.jesd204_tx_frame_ready[i]),
						.csr_l                       (jesd204b_a10_interface_pins.tx_csr_l[i]),
						.csr_f                       (jesd204b_a10_interface_pins.tx_csr_f[i]),
						.csr_n                       (jesd204b_a10_interface_pins.tx_csr_n[i]),
						.jesd204_tx_data_ready       (assembler_din_ready[i]),
						.jesd204_tx_link_error       (jesd204b_a10_interface_pins.jesd204_tx_frame_error[i]),
						.jesd204_tx_link_datain      (jesd204b_a10_interface_pins.jesd204_tx_link_data[i]),
						.jesd204_tx_link_data_valid  (jesd204b_a10_interface_pins.jesd204_tx_link_valid[i])
					 );
					 
					 pattern_generator_top #(
						.FRAMECLK_DIV      ((F == 1) ? F1_FRAMECLK_DIV : ((F == 2) ? F2_FRAMECLK_DIV : 1)),
						.M                 (M),
						.N                 (N),
						.S                 (S),
						.POLYNOMIAL_LENGTH (POLYNOMIAL_LENGTH),
						.FEEDBACK_TAP      (FEEDBACK_TAP),
						.REVERSE_DATA      (0)
					 ) u_gen (
						.clk               (jesd204b_a10_interface_pins.frame_clk),
						.rst_n             (jesd204b_a10_interface_pins.tx_frame_rst_n[0]),
						.csr_tx_testmode   (jesd204b_a10_interface_pins.csr_tx_testmode[i]),
						.csr_m             (jesd204b_a10_interface_pins.tx_csr_m[i]),
						.csr_s             (jesd204b_a10_interface_pins.tx_csr_s[i]),
						.error_inject      (1'b0),
						.ready             (avst_patgen_ready_in[i]),
						.valid             (avst_patgen_data_valid[i]),
						.avst_dataout      (avst_patgen_dout[i])
					 );
					 
					 
			end
			
         //Altera Transport Layer (RX)
         altera_jesd204_transport_rx_top #(
            .L               (L),
            .F               (F),
            .N               (N),
            .CS              (CS),
            .N_PRIME         (N_PRIME),
            .F1_FRAMECLK_DIV (F1_FRAMECLK_DIV),
            .F2_FRAMECLK_DIV (F2_FRAMECLK_DIV),
            .RECONFIG_EN     (1)
         ) u_jesd204b_transport_rx (
            .rxlink_rst_n               (jesd204b_a10_interface_pins.rx_link_rst_n[0]),
            .rxframe_rst_n              (jesd204b_a10_interface_pins.rx_frame_rst_n[0]),
            .rxframe_clk                (jesd204b_a10_interface_pins.frame_clk),
            .rxlink_clk                 (jesd204b_a10_interface_pins.link_clk),
            .jesd204_rx_link_datain     (jesd204b_a10_interface_pins.jesd204_rx_link_data[i]),
            .jesd204_rx_link_data_valid (jesd204b_a10_interface_pins.jesd204_rx_link_valid[i]),
            .jesd204_rx_data_ready      (deassembler_dout_ready[i]),
            .csr_l                      (jesd204b_a10_interface_pins.rx_csr_l[i]),
            .csr_f                      (jesd204b_a10_interface_pins.rx_csr_f[i]),
            .csr_n                      (jesd204b_a10_interface_pins.rx_csr_n[i]),
            .jesd204_rx_dataout         (deassembler_dout[i]),
            .jesd204_rx_controlout      (), //for CS=0, connection to this port is not needed
            .jesd204_rx_link_error      (jesd204b_a10_interface_pins.jesd204_rx_frame_error[i]),
            .jesd204_rx_data_valid      (deassembler_dout_valid_bus[i]),
            .jesd204_rx_link_data_ready (jesd204b_a10_interface_pins.jesd204_rx_link_ready[i])
         );

   
   
      if (COMPILE_PATTERN_CHECKER)
	  begin
				 pattern_checker_top #(
					.FRAMECLK_DIV      ((F == 1) ? F1_FRAMECLK_DIV : ((F == 2) ? F2_FRAMECLK_DIV : 1)),
					.M                 (M),
					.N                 (N),
					.S                 (S),
					.POLYNOMIAL_LENGTH (POLYNOMIAL_LENGTH),
					.FEEDBACK_TAP      (FEEDBACK_TAP),
					.ERR_THRESHOLD     (1),
					.REVERSE_DATA      (0)
				 ) u_chk (
					.clk              (jesd204b_a10_interface_pins.frame_clk),
					.rst_n            (jesd204b_a10_interface_pins.rx_frame_rst_n[0]),
					.csr_rx_testmode  (jesd204b_a10_interface_pins.csr_rx_testmode[i]),
					.csr_m            (jesd204b_a10_interface_pins.rx_csr_m[i]),
					.csr_s            (jesd204b_a10_interface_pins.rx_csr_s[i]),
					.ready            (avst_patchk_data_ready[i]),
					.valid            (avst_patchk_data_valid[i]),
					.avst_datain      (avst_patchk_din[i]),
					.err_out          (jesd204b_a10_interface_pins.avst_patchk_data_error[i])
				 );
		 end
		 
         assign jesd204b_a10_interface_pins.avst_usr_dout[TL_DATA_BUS_WIDTH*(i+1)-1:TL_DATA_BUS_WIDTH*i] = deassembler_dout[i];
         assign jesd204b_a10_interface_pins.avst_usr_dout_valid[i]                                       = deassembler_dout_valid_bus[i];
         assign deassembler_dout_ready[i]                                    = jesd204b_a10_interface_pins.csr_rx_testmode[i] == 4'b0000 ? jesd204b_a10_interface_pins.avst_usr_dout_ready[i] : avst_patchk_data_ready[i];
   end
   endgenerate

   assign avst_patchk_din          = deassembler_dout;
   assign avst_patchk_data_valid   = deassembler_dout_valid_bus;

endmodule
`default_nettype wire

