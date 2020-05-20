// megafunction wizard: %ALTGX_RECONFIG%VBB%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: alt2gxb_reconfig 

// ============================================================
// File Name: four_lane_seriallite_reconfig_dfe.v
// Megafunction Name(s):
// 			alt2gxb_reconfig
//
// Simulation Library Files(s):
// 			altera_mf;lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 14.1.1 Build 190 01/19/2015 SJ Full Version
// ************************************************************

//Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, the Altera Quartus II License Agreement,
//the Altera MegaCore Function License Agreement, or other 
//applicable license agreement, including, without limitation, 
//that your use is for the sole purpose of programming logic 
//devices manufactured by Altera and sold by Altera or its 
//authorized distributors.  Please refer to the applicable 
//agreement for further details.

module four_lane_seriallite_reconfig_dfe (
	ctrl_address,
	ctrl_read,
	ctrl_write,
	ctrl_writedata,
	read,
	reconfig_clk,
	reconfig_fromgxb,
	reconfig_mode_sel,
	reconfig_reset,
	tx_vodctrl,
	write_all,
	busy,
	ctrl_readdata,
	ctrl_waitrequest,
	data_valid,
	error,
	reconfig_togxb,
	tx_vodctrl_out)/* synthesis synthesis_clearbox = 1 */;

	input	[15:0]  ctrl_address;
	input	  ctrl_read;
	input	  ctrl_write;
	input	[15:0]  ctrl_writedata;
	input	  read;
	input	  reconfig_clk;
	input	[16:0]  reconfig_fromgxb;
	input	[3:0]  reconfig_mode_sel;
	input	  reconfig_reset;
	input	[2:0]  tx_vodctrl;
	input	  write_all;
	output	  busy;
	output	[15:0]  ctrl_readdata;
	output	  ctrl_waitrequest;
	output	  data_valid;
	output	  error;
	output	[3:0]  reconfig_togxb;
	output	[2:0]  tx_vodctrl_out;

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: ADCE NUMERIC "0"
// Retrieval info: PRIVATE: CMU_PLL NUMERIC "0"
// Retrieval info: PRIVATE: DATA_RATE NUMERIC "0"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix IV"
// Retrieval info: PRIVATE: PMA NUMERIC "1"
// Retrieval info: PRIVATE: PROTO_SWITCH NUMERIC "0"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: CONSTANT: BASE_PORT_WIDTH NUMERIC "1"
// Retrieval info: CONSTANT: CBX_BLACKBOX_LIST STRING "-lpm_mux"
// Retrieval info: CONSTANT: ENABLE_CHL_ADDR_FOR_ANALOG_CTRL STRING "TRUE"
// Retrieval info: CONSTANT: ENABLE_DFE STRING "ON"
// Retrieval info: CONSTANT: ENABLE_SELF_RECOVERY STRING "TRUE"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Stratix IV"
// Retrieval info: CONSTANT: NUMBER_OF_CHANNELS NUMERIC "1"
// Retrieval info: CONSTANT: NUMBER_OF_RECONFIG_PORTS NUMERIC "1"
// Retrieval info: CONSTANT: READ_BASE_PORT_WIDTH NUMERIC "1"
// Retrieval info: CONSTANT: RECONFIG_MODE_SEL_WIDTH NUMERIC "4"
// Retrieval info: CONSTANT: enable_buf_cal STRING "true"
// Retrieval info: CONSTANT: reconfig_fromgxb_width NUMERIC "17"
// Retrieval info: CONSTANT: reconfig_togxb_width NUMERIC "4"
// Retrieval info: USED_PORT: busy 0 0 0 0 OUTPUT NODEFVAL "busy"
// Retrieval info: USED_PORT: ctrl_address 0 0 16 0 INPUT NODEFVAL "ctrl_address[15..0]"
// Retrieval info: USED_PORT: ctrl_read 0 0 0 0 INPUT NODEFVAL "ctrl_read"
// Retrieval info: USED_PORT: ctrl_readdata 0 0 16 0 OUTPUT NODEFVAL "ctrl_readdata[15..0]"
// Retrieval info: USED_PORT: ctrl_waitrequest 0 0 0 0 OUTPUT NODEFVAL "ctrl_waitrequest"
// Retrieval info: USED_PORT: ctrl_write 0 0 0 0 INPUT NODEFVAL "ctrl_write"
// Retrieval info: USED_PORT: ctrl_writedata 0 0 16 0 INPUT NODEFVAL "ctrl_writedata[15..0]"
// Retrieval info: USED_PORT: data_valid 0 0 0 0 OUTPUT NODEFVAL "data_valid"
// Retrieval info: USED_PORT: error 0 0 0 0 OUTPUT NODEFVAL "error"
// Retrieval info: USED_PORT: read 0 0 0 0 INPUT NODEFVAL "read"
// Retrieval info: USED_PORT: reconfig_clk 0 0 0 0 INPUT NODEFVAL "reconfig_clk"
// Retrieval info: USED_PORT: reconfig_fromgxb 0 0 17 0 INPUT NODEFVAL "reconfig_fromgxb[16..0]"
// Retrieval info: USED_PORT: reconfig_mode_sel 0 0 4 0 INPUT NODEFVAL "reconfig_mode_sel[3..0]"
// Retrieval info: USED_PORT: reconfig_reset 0 0 0 0 INPUT NODEFVAL "reconfig_reset"
// Retrieval info: USED_PORT: reconfig_togxb 0 0 4 0 OUTPUT NODEFVAL "reconfig_togxb[3..0]"
// Retrieval info: USED_PORT: tx_vodctrl 0 0 3 0 INPUT NODEFVAL "tx_vodctrl[2..0]"
// Retrieval info: USED_PORT: tx_vodctrl_out 0 0 3 0 OUTPUT NODEFVAL "tx_vodctrl_out[2..0]"
// Retrieval info: USED_PORT: write_all 0 0 0 0 INPUT NODEFVAL "write_all"
// Retrieval info: CONNECT: @ctrl_address 0 0 16 0 ctrl_address 0 0 16 0
// Retrieval info: CONNECT: @ctrl_read 0 0 0 0 ctrl_read 0 0 0 0
// Retrieval info: CONNECT: @ctrl_write 0 0 0 0 ctrl_write 0 0 0 0
// Retrieval info: CONNECT: @ctrl_writedata 0 0 16 0 ctrl_writedata 0 0 16 0
// Retrieval info: CONNECT: @read 0 0 0 0 read 0 0 0 0
// Retrieval info: CONNECT: @reconfig_clk 0 0 0 0 reconfig_clk 0 0 0 0
// Retrieval info: CONNECT: @reconfig_fromgxb 0 0 17 0 reconfig_fromgxb 0 0 17 0
// Retrieval info: CONNECT: @reconfig_mode_sel 0 0 4 0 reconfig_mode_sel 0 0 4 0
// Retrieval info: CONNECT: @reconfig_reset 0 0 0 0 reconfig_reset 0 0 0 0
// Retrieval info: CONNECT: @tx_vodctrl 0 0 3 0 tx_vodctrl 0 0 3 0
// Retrieval info: CONNECT: @write_all 0 0 0 0 write_all 0 0 0 0
// Retrieval info: CONNECT: busy 0 0 0 0 @busy 0 0 0 0
// Retrieval info: CONNECT: ctrl_readdata 0 0 16 0 @ctrl_readdata 0 0 16 0
// Retrieval info: CONNECT: ctrl_waitrequest 0 0 0 0 @ctrl_waitrequest 0 0 0 0
// Retrieval info: CONNECT: data_valid 0 0 0 0 @data_valid 0 0 0 0
// Retrieval info: CONNECT: error 0 0 0 0 @error 0 0 0 0
// Retrieval info: CONNECT: reconfig_togxb 0 0 4 0 @reconfig_togxb 0 0 4 0
// Retrieval info: CONNECT: tx_vodctrl_out 0 0 3 0 @tx_vodctrl_out 0 0 3 0
// Retrieval info: GEN_FILE: TYPE_NORMAL four_lane_seriallite_reconfig_dfe.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL four_lane_seriallite_reconfig_dfe.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL four_lane_seriallite_reconfig_dfe.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL four_lane_seriallite_reconfig_dfe.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL four_lane_seriallite_reconfig_dfe_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL four_lane_seriallite_reconfig_dfe_bb.v TRUE
// Retrieval info: LIB_FILE: altera_mf
// Retrieval info: LIB_FILE: lpm
