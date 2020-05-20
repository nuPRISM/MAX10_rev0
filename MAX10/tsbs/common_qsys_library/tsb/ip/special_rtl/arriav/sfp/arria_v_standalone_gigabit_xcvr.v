// megafunction wizard: %Arria V Transceiver Native PHY v13.1%
// GENERATION: XML
// arria_v_standalone_gigabit_xcvr.v

// Generated using ACDS version 13.1.1 166 at 2014.01.15.14:25:31

`timescale 1 ps / 1 ps
module arria_v_standalone_gigabit_xcvr (
		input  wire [0:0]   pll_powerdown,        //        pll_powerdown.pll_powerdown
		input  wire [0:0]   tx_analogreset,       //       tx_analogreset.tx_analogreset
		input  wire [0:0]   tx_digitalreset,      //      tx_digitalreset.tx_digitalreset
		input  wire [0:0]   tx_pll_refclk,        //        tx_pll_refclk.tx_pll_refclk
		output wire [0:0]   tx_pma_clkout,        //        tx_pma_clkout.tx_pma_clkout
		output wire [0:0]   tx_serial_data,       //       tx_serial_data.tx_serial_data
		input  wire [79:0]  tx_pma_parallel_data, // tx_pma_parallel_data.tx_pma_parallel_data
		output wire [0:0]   pll_locked,           //           pll_locked.pll_locked
		input  wire [0:0]   rx_analogreset,       //       rx_analogreset.rx_analogreset
		input  wire [0:0]   rx_digitalreset,      //      rx_digitalreset.rx_digitalreset
		input  wire [0:0]   rx_cdr_refclk,        //        rx_cdr_refclk.rx_cdr_refclk
		output wire [0:0]   rx_pma_clkout,        //        rx_pma_clkout.rx_pma_clkout
		input  wire [0:0]   rx_serial_data,       //       rx_serial_data.rx_serial_data
		output wire [79:0]  rx_pma_parallel_data, // rx_pma_parallel_data.rx_pma_parallel_data
		input  wire [0:0]   rx_clkslip,           //           rx_clkslip.rx_clkslip
		input  wire [0:0]   rx_set_locktodata,    //    rx_set_locktodata.rx_set_locktodata
		input  wire [0:0]   rx_set_locktoref,     //     rx_set_locktoref.rx_set_locktoref
		output wire [0:0]   rx_is_lockedtoref,    //    rx_is_lockedtoref.rx_is_lockedtoref
		output wire [0:0]   rx_is_lockedtodata,   //   rx_is_lockedtodata.rx_is_lockedtodata
		input  wire [0:0]   rx_seriallpbken,      //      rx_seriallpbken.rx_seriallpbken
		output wire [0:0]   tx_cal_busy,          //          tx_cal_busy.tx_cal_busy
		output wire [0:0]   rx_cal_busy,          //          rx_cal_busy.rx_cal_busy
		input  wire [139:0] reconfig_to_xcvr,     //     reconfig_to_xcvr.reconfig_to_xcvr
		output wire [91:0]  reconfig_from_xcvr    //   reconfig_from_xcvr.reconfig_from_xcvr
	);

	altera_xcvr_native_av #(
		.tx_enable                       (1),
		.rx_enable                       (1),
		.enable_std                      (0),
		.data_path_select                ("pma_direct"),
		.channels                        (1),
		.bonded_mode                     ("non_bonded"),
		.data_rate                       ("1250 Mbps"),
		.pma_width                       (10),
		.tx_pma_clk_div                  (1),
		.pll_reconfig_enable             (0),
		.pll_external_enable             (0),
		.pll_data_rate                   ("1250 Mbps"),
		.pll_type                        ("CMU"),
		.pma_bonding_mode                ("x1"),
		.plls                            (1),
		.pll_select                      (0),
		.pll_refclk_cnt                  (1),
		.pll_refclk_select               ("0"),
		.pll_refclk_freq                 ("125.0 MHz"),
		.pll_feedback_path               ("internal"),
		.cdr_reconfig_enable             (1),
		.cdr_refclk_cnt                  (1),
		.cdr_refclk_select               (0),
		.cdr_refclk_freq                 ("125.0 MHz"),
		.rx_ppm_detect_threshold         ("1000"),
		.rx_clkslip_enable               (1),
		.std_protocol_hint               ("gige"),
		.std_pcs_pma_width               (10),
		.std_low_latency_bypass_enable   (0),
		.std_tx_pcfifo_mode              ("low_latency"),
		.std_rx_pcfifo_mode              ("low_latency"),
		.std_rx_byte_order_enable        (0),
		.std_rx_byte_order_mode          ("manual"),
		.std_rx_byte_order_width         (9),
		.std_rx_byte_order_symbol_count  (1),
		.std_rx_byte_order_pattern       ("0"),
		.std_rx_byte_order_pad           ("0"),
		.std_tx_byte_ser_enable          (0),
		.std_rx_byte_deser_enable        (0),
		.std_tx_8b10b_enable             (1),
		.std_tx_8b10b_disp_ctrl_enable   (0),
		.std_rx_8b10b_enable             (1),
		.std_rx_rmfifo_enable            (1),
		.std_rx_rmfifo_pattern_p         ("A257C"),
		.std_rx_rmfifo_pattern_n         ("AB683"),
		.std_tx_bitslip_enable           (0),
		.std_rx_word_aligner_mode        ("sync_sm"),
		.std_rx_word_aligner_pattern_len (10),
		.std_rx_word_aligner_pattern     ("17C"),
		.std_rx_word_aligner_rknumber    (3),
		.std_rx_word_aligner_renumber    (3),
		.std_rx_word_aligner_rgnumber    (3),
		.std_rx_run_length_val           (31),
		.std_tx_bitrev_enable            (0),
		.std_rx_bitrev_enable            (0),
		.std_tx_byterev_enable           (0),
		.std_rx_byterev_enable           (0),
		.std_tx_polinv_enable            (0),
		.std_rx_polinv_enable            (0)
	) arria_v_standalone_gigabit_xcvr_inst (
		.pll_powerdown             (pll_powerdown),                                    //        pll_powerdown.pll_powerdown
		.tx_analogreset            (tx_analogreset),                                   //       tx_analogreset.tx_analogreset
		.tx_digitalreset           (tx_digitalreset),                                  //      tx_digitalreset.tx_digitalreset
		.tx_pll_refclk             (tx_pll_refclk),                                    //        tx_pll_refclk.tx_pll_refclk
		.tx_pma_clkout             (tx_pma_clkout),                                    //        tx_pma_clkout.tx_pma_clkout
		.tx_serial_data            (tx_serial_data),                                   //       tx_serial_data.tx_serial_data
		.tx_pma_parallel_data      (tx_pma_parallel_data),                             // tx_pma_parallel_data.tx_pma_parallel_data
		.pll_locked                (pll_locked),                                       //           pll_locked.pll_locked
		.rx_analogreset            (rx_analogreset),                                   //       rx_analogreset.rx_analogreset
		.rx_digitalreset           (rx_digitalreset),                                  //      rx_digitalreset.rx_digitalreset
		.rx_cdr_refclk             (rx_cdr_refclk),                                    //        rx_cdr_refclk.rx_cdr_refclk
		.rx_pma_clkout             (rx_pma_clkout),                                    //        rx_pma_clkout.rx_pma_clkout
		.rx_serial_data            (rx_serial_data),                                   //       rx_serial_data.rx_serial_data
		.rx_pma_parallel_data      (rx_pma_parallel_data),                             // rx_pma_parallel_data.rx_pma_parallel_data
		.rx_clkslip                (rx_clkslip),                                       //           rx_clkslip.rx_clkslip
		.rx_set_locktodata         (rx_set_locktodata),                                //    rx_set_locktodata.rx_set_locktodata
		.rx_set_locktoref          (rx_set_locktoref),                                 //     rx_set_locktoref.rx_set_locktoref
		.rx_is_lockedtoref         (rx_is_lockedtoref),                                //    rx_is_lockedtoref.rx_is_lockedtoref
		.rx_is_lockedtodata        (rx_is_lockedtodata),                               //   rx_is_lockedtodata.rx_is_lockedtodata
		.rx_seriallpbken           (rx_seriallpbken),                                  //      rx_seriallpbken.rx_seriallpbken
		.tx_cal_busy               (tx_cal_busy),                                      //          tx_cal_busy.tx_cal_busy
		.rx_cal_busy               (rx_cal_busy),                                      //          rx_cal_busy.rx_cal_busy
		.reconfig_to_xcvr          (reconfig_to_xcvr),                                 //     reconfig_to_xcvr.reconfig_to_xcvr
		.reconfig_from_xcvr        (reconfig_from_xcvr),                               //   reconfig_from_xcvr.reconfig_from_xcvr
		.ext_pll_clk               (1'b0),                                             //          (terminated)
		.rx_clklow                 (),                                                 //          (terminated)
		.rx_fref                   (),                                                 //          (terminated)
		.rx_signaldetect           (),                                                 //          (terminated)
		.tx_parallel_data          (44'b00000000000000000000000000000000000000000000), //          (terminated)
		.rx_parallel_data          (),                                                 //          (terminated)
		.tx_std_coreclkin          (1'b0),                                             //          (terminated)
		.rx_std_coreclkin          (1'b0),                                             //          (terminated)
		.tx_std_clkout             (),                                                 //          (terminated)
		.rx_std_clkout             (),                                                 //          (terminated)
		.rx_std_prbs_done          (),                                                 //          (terminated)
		.rx_std_prbs_err           (),                                                 //          (terminated)
		.tx_std_pcfifo_full        (),                                                 //          (terminated)
		.tx_std_pcfifo_empty       (),                                                 //          (terminated)
		.rx_std_pcfifo_full        (),                                                 //          (terminated)
		.rx_std_pcfifo_empty       (),                                                 //          (terminated)
		.rx_std_byteorder_ena      (1'b0),                                             //          (terminated)
		.rx_std_byteorder_flag     (),                                                 //          (terminated)
		.rx_std_rmfifo_full        (),                                                 //          (terminated)
		.rx_std_rmfifo_empty       (),                                                 //          (terminated)
		.rx_std_wa_patternalign    (1'b0),                                             //          (terminated)
		.rx_std_wa_a1a2size        (1'b0),                                             //          (terminated)
		.tx_std_bitslipboundarysel (5'b00000),                                         //          (terminated)
		.rx_std_bitslipboundarysel (),                                                 //          (terminated)
		.rx_std_bitslip            (1'b0),                                             //          (terminated)
		.rx_std_runlength_err      (),                                                 //          (terminated)
		.rx_std_bitrev_ena         (1'b0),                                             //          (terminated)
		.rx_std_byterev_ena        (1'b0),                                             //          (terminated)
		.tx_std_polinv             (1'b0),                                             //          (terminated)
		.rx_std_polinv             (1'b0),                                             //          (terminated)
		.tx_std_elecidle           (1'b0),                                             //          (terminated)
		.rx_std_signaldetect       ()                                                  //          (terminated)
	);

endmodule
// Retrieval info: <?xml version="1.0"?>
//<!--
//	Generated by Altera MegaWizard Launcher Utility version 1.0
//	************************************************************
//	THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//	************************************************************
//	Copyright (C) 1991-2014 Altera Corporation
//	Any megafunction design, and related net list (encrypted or decrypted),
//	support information, device programming or simulation file, and any other
//	associated documentation or information provided by Altera or a partner
//	under Altera's Megafunction Partnership Program may be used only to
//	program PLD devices (but not masked PLD devices) from Altera.  Any other
//	use of such megafunction design, net list, support information, device
//	programming or simulation file, or any other related documentation or
//	information is prohibited for any other purpose, including, but not
//	limited to modification, reverse engineering, de-compiling, or use with
//	any other silicon devices, unless such use is explicitly licensed under
//	a separate agreement with Altera or a megafunction partner.  Title to
//	the intellectual property, including patents, copyrights, trademarks,
//	trade secrets, or maskworks, embodied in any such megafunction design,
//	net list, support information, device programming or simulation file, or
//	any other related documentation or information provided by Altera or a
//	megafunction partner, remains with Altera, the megafunction partner, or
//	their respective licensors.  No other licenses, including any licenses
//	needed under any third party's intellectual property, are provided herein.
//-->
// Retrieval info: <instance entity-name="altera_xcvr_native_av" version="13.1" >
// Retrieval info: 	<generic name="device_family" value="Arria V" />
// Retrieval info: 	<generic name="show_advanced_features" value="0" />
// Retrieval info: 	<generic name="device_speedgrade" value="4_H4" />
// Retrieval info: 	<generic name="message_level" value="error" />
// Retrieval info: 	<generic name="tx_enable" value="1" />
// Retrieval info: 	<generic name="rx_enable" value="1" />
// Retrieval info: 	<generic name="enable_std" value="0" />
// Retrieval info: 	<generic name="set_data_path_select" value="standard" />
// Retrieval info: 	<generic name="channels" value="1" />
// Retrieval info: 	<generic name="bonded_mode" value="non_bonded" />
// Retrieval info: 	<generic name="enable_simple_interface" value="0" />
// Retrieval info: 	<generic name="set_data_rate" value="1250" />
// Retrieval info: 	<generic name="pma_direct_width" value="10" />
// Retrieval info: 	<generic name="tx_pma_clk_div" value="1" />
// Retrieval info: 	<generic name="pll_reconfig_enable" value="0" />
// Retrieval info: 	<generic name="pll_external_enable" value="0" />
// Retrieval info: 	<generic name="plls" value="1" />
// Retrieval info: 	<generic name="pll_select" value="0" />
// Retrieval info: 	<generic name="pll_refclk_cnt" value="1" />
// Retrieval info: 	<generic name="cdr_reconfig_enable" value="1" />
// Retrieval info: 	<generic name="cdr_refclk_cnt" value="1" />
// Retrieval info: 	<generic name="cdr_refclk_select" value="0" />
// Retrieval info: 	<generic name="set_cdr_refclk_freq" value="125.0 MHz" />
// Retrieval info: 	<generic name="rx_ppm_detect_threshold" value="1000" />
// Retrieval info: 	<generic name="enable_port_rx_pma_clkout" value="1" />
// Retrieval info: 	<generic name="enable_port_rx_is_lockedtodata" value="1" />
// Retrieval info: 	<generic name="enable_port_rx_is_lockedtoref" value="1" />
// Retrieval info: 	<generic name="enable_ports_rx_manual_cdr_mode" value="1" />
// Retrieval info: 	<generic name="rx_clkslip_enable" value="1" />
// Retrieval info: 	<generic name="enable_port_rx_signaldetect" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_seriallpbken" value="1" />
// Retrieval info: 	<generic name="std_protocol_hint" value="gige" />
// Retrieval info: 	<generic name="std_pcs_pma_width" value="10" />
// Retrieval info: 	<generic name="std_low_latency_bypass_enable" value="0" />
// Retrieval info: 	<generic name="std_tx_pcfifo_mode" value="low_latency" />
// Retrieval info: 	<generic name="std_rx_pcfifo_mode" value="low_latency" />
// Retrieval info: 	<generic name="enable_port_tx_std_pcfifo_full" value="0" />
// Retrieval info: 	<generic name="enable_port_tx_std_pcfifo_empty" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_pcfifo_full" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_pcfifo_empty" value="0" />
// Retrieval info: 	<generic name="std_rx_byte_order_enable" value="0" />
// Retrieval info: 	<generic name="std_rx_byte_order_mode" value="manual" />
// Retrieval info: 	<generic name="std_rx_byte_order_symbol_count" value="1" />
// Retrieval info: 	<generic name="std_rx_byte_order_pattern" value="0" />
// Retrieval info: 	<generic name="std_rx_byte_order_pad" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_byteorder_ena" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_byteorder_flag" value="0" />
// Retrieval info: 	<generic name="std_tx_byte_ser_enable" value="0" />
// Retrieval info: 	<generic name="std_rx_byte_deser_enable" value="0" />
// Retrieval info: 	<generic name="std_tx_8b10b_enable" value="1" />
// Retrieval info: 	<generic name="std_tx_8b10b_disp_ctrl_enable" value="0" />
// Retrieval info: 	<generic name="std_rx_8b10b_enable" value="1" />
// Retrieval info: 	<generic name="std_rx_rmfifo_enable" value="1" />
// Retrieval info: 	<generic name="std_rx_rmfifo_pattern_p" value="A257C" />
// Retrieval info: 	<generic name="std_rx_rmfifo_pattern_n" value="AB683" />
// Retrieval info: 	<generic name="enable_port_rx_std_rmfifo_full" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_rmfifo_empty" value="0" />
// Retrieval info: 	<generic name="std_tx_bitslip_enable" value="0" />
// Retrieval info: 	<generic name="enable_port_tx_std_bitslipboundarysel" value="0" />
// Retrieval info: 	<generic name="std_rx_word_aligner_mode" value="sync_sm" />
// Retrieval info: 	<generic name="std_rx_word_aligner_pattern_len" value="10" />
// Retrieval info: 	<generic name="std_rx_word_aligner_pattern" value="17C" />
// Retrieval info: 	<generic name="std_rx_word_aligner_rknumber" value="3" />
// Retrieval info: 	<generic name="std_rx_word_aligner_renumber" value="3" />
// Retrieval info: 	<generic name="std_rx_word_aligner_rgnumber" value="3" />
// Retrieval info: 	<generic name="std_rx_run_length_val" value="31" />
// Retrieval info: 	<generic name="enable_port_rx_std_wa_patternalign" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_wa_a1a2size" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_bitslipboundarysel" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_bitslip" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_runlength_err" value="0" />
// Retrieval info: 	<generic name="std_tx_bitrev_enable" value="0" />
// Retrieval info: 	<generic name="std_rx_bitrev_enable" value="0" />
// Retrieval info: 	<generic name="std_tx_byterev_enable" value="0" />
// Retrieval info: 	<generic name="std_rx_byterev_enable" value="0" />
// Retrieval info: 	<generic name="std_tx_polinv_enable" value="0" />
// Retrieval info: 	<generic name="std_rx_polinv_enable" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_bitrev_ena" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_byterev_ena" value="0" />
// Retrieval info: 	<generic name="enable_port_tx_std_polinv" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_polinv" value="0" />
// Retrieval info: 	<generic name="enable_port_tx_std_elecidle" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_signaldetect" value="0" />
// Retrieval info: 	<generic name="enable_port_rx_std_prbs_status" value="0" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll0_pll_type" value="CMU" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll0_data_rate" value="1250 Mbps" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll0_refclk_freq" value="125.0 MHz" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll0_refclk_sel" value="0" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll0_clk_network" value="x1" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll1_pll_type" value="CMU" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll1_data_rate" value="1250 Mbps" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll1_refclk_freq" value="125.0 MHz" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll1_refclk_sel" value="0" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll1_clk_network" value="x1" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll2_pll_type" value="CMU" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll2_data_rate" value="1250 Mbps" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll2_refclk_freq" value="125.0 MHz" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll2_refclk_sel" value="0" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll2_clk_network" value="x1" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll3_pll_type" value="CMU" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll3_data_rate" value="1250 Mbps" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll3_refclk_freq" value="125.0 MHz" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll3_refclk_sel" value="0" />
// Retrieval info: 	<generic name="gui_pll_reconfig_pll3_clk_network" value="x1" />
// Retrieval info: </instance>
// IPFS_FILES : arria_v_standalone_gigabit_xcvr.vo
// RELATED_FILES: arria_v_standalone_gigabit_xcvr.v, altera_xcvr_functions.sv, sv_reconfig_bundle_to_xcvr.sv, sv_reconfig_bundle_to_ip.sv, sv_reconfig_bundle_merger.sv, av_xcvr_h.sv, av_xcvr_avmm_csr.sv, av_tx_pma_ch.sv, av_tx_pma.sv, av_rx_pma.sv, av_pma.sv, av_pcs_ch.sv, av_pcs.sv, av_xcvr_avmm.sv, av_xcvr_native.sv, av_xcvr_plls.sv, av_xcvr_data_adapter.sv, av_reconfig_bundle_to_basic.sv, av_reconfig_bundle_to_xcvr.sv, av_hssi_8g_rx_pcs_rbc.sv, av_hssi_8g_tx_pcs_rbc.sv, av_hssi_common_pcs_pma_interface_rbc.sv, av_hssi_common_pld_pcs_interface_rbc.sv, av_hssi_pipe_gen1_2_rbc.sv, av_hssi_rx_pcs_pma_interface_rbc.sv, av_hssi_rx_pld_pcs_interface_rbc.sv, av_hssi_tx_pcs_pma_interface_rbc.sv, av_hssi_tx_pld_pcs_interface_rbc.sv, alt_reset_ctrl_lego.sv, alt_reset_ctrl_tgx_cdrauto.sv, alt_xcvr_resync.sv, alt_xcvr_csr_common_h.sv, alt_xcvr_csr_common.sv, alt_xcvr_csr_pcs8g_h.sv, alt_xcvr_csr_pcs8g.sv, alt_xcvr_csr_selector.sv, alt_xcvr_mgmt2dec.sv, altera_wait_generate.v, altera_xcvr_native_av_functions_h.sv, altera_xcvr_native_av.sv, altera_xcvr_data_adapter_av.sv
