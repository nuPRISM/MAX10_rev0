//altlvds_rx BUFFER_IMPLEMENTATION="RAM" CBX_SINGLE_OUTPUT_FILE="ON" COMMON_RX_TX_PLL="ON" DATA_ALIGN_ROLLOVER=5 DESERIALIZATION_FACTOR=5 DEVICE_FAMILY="MAX 10" IMPLEMENT_IN_LES="ON" INCLOCK_PERIOD=10000 INCLOCK_PHASE_SHIFT=0 INPUT_DATA_RATE=500 NUMBER_OF_CHANNELS=2 OUTCLOCK_RESOURCE="AUTO" PLL_SELF_RESET_ON_LOSS_LOCK="ON" PORT_RX_CHANNEL_DATA_ALIGN="PORT_USED" PORT_RX_DATA_ALIGN="PORT_UNUSED" REGISTERED_DATA_ALIGN_INPUT="OFF" REGISTERED_OUTPUT="ON" USE_CORECLOCK_INPUT="OFF" USE_EXTERNAL_PLL="OFF" pll_areset rx_cda_reset rx_channel_data_align rx_data_align rx_data_align_reset rx_in rx_inclock rx_locked rx_out rx_outclock ALTERA_INTERNAL_OPTIONS=AUTO_SHIFT_REGISTER_RECOGNITION=OFF
//VERSION_BEGIN 14.1 cbx_altaccumulate 2014:12:03:18:04:04:SJ cbx_altclkbuf 2014:12:03:18:04:04:SJ cbx_altddio_in 2014:12:03:18:04:04:SJ cbx_altddio_out 2014:12:03:18:04:04:SJ cbx_altiobuf_bidir 2014:12:03:18:04:04:SJ cbx_altiobuf_in 2014:12:03:18:04:04:SJ cbx_altiobuf_out 2014:12:03:18:04:04:SJ cbx_altlvds_rx 2014:12:03:18:04:04:SJ cbx_altpll 2014:12:03:18:04:04:SJ cbx_altsyncram 2014:12:03:18:04:04:SJ cbx_arriav 2014:12:03:18:04:03:SJ cbx_cyclone 2014:12:03:18:04:04:SJ cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_lpm_counter 2014:12:03:18:04:04:SJ cbx_lpm_decode 2014:12:03:18:04:04:SJ cbx_lpm_mux 2014:12:03:18:04:04:SJ cbx_lpm_shiftreg 2014:12:03:18:04:04:SJ cbx_maxii 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ cbx_stratixiii 2014:12:03:18:04:04:SJ cbx_stratixv 2014:12:03:18:04:04:SJ cbx_util_mgl 2014:12:03:18:04:04:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, the Altera Quartus II License Agreement,
//  the Altera MegaCore Function License Agreement, or other 
//  applicable license agreement, including, without limitation, 
//  that your use is for the sole purpose of programming logic 
//  devices manufactured by Altera and sold by Altera or its 
//  authorized distributors.  Please refer to the applicable 
//  agreement for further details.




//alt_lvds_ddio_in ADD_LATENCY_REG="TRUE" CBX_SINGLE_OUTPUT_FILE="ON" WIDTH=2 aclr clock datain dataout_h dataout_l
//VERSION_BEGIN 14.1 cbx_altaccumulate 2014:12:03:18:04:04:SJ cbx_altclkbuf 2014:12:03:18:04:04:SJ cbx_altddio_in 2014:12:03:18:04:04:SJ cbx_altddio_out 2014:12:03:18:04:04:SJ cbx_altiobuf_bidir 2014:12:03:18:04:04:SJ cbx_altiobuf_in 2014:12:03:18:04:04:SJ cbx_altiobuf_out 2014:12:03:18:04:04:SJ cbx_altlvds_rx 2014:12:03:18:04:04:SJ cbx_altpll 2014:12:03:18:04:04:SJ cbx_altsyncram 2014:12:03:18:04:04:SJ cbx_arriav 2014:12:03:18:04:03:SJ cbx_cyclone 2014:12:03:18:04:04:SJ cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_lpm_counter 2014:12:03:18:04:04:SJ cbx_lpm_decode 2014:12:03:18:04:04:SJ cbx_lpm_mux 2014:12:03:18:04:04:SJ cbx_lpm_shiftreg 2014:12:03:18:04:04:SJ cbx_maxii 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ cbx_stratixiii 2014:12:03:18:04:04:SJ cbx_stratixv 2014:12:03:18:04:04:SJ cbx_util_mgl 2014:12:03:18:04:04:SJ  VERSION_END

//synthesis_resources = reg 10 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"{-to ddio_h_reg*} PLL_COMPENSATE=ON;ADV_NETLIST_OPT_ALLOWED=\"NEVER_ALLOW\""} *)
module  lvds_rx_x2_m10_0002_lvds_ddio_in_jka
	( 
	aclr,
	clock,
	datain,
	dataout_h,
	dataout_l) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clock;
	input   [1:0]  datain;
	output   [1:0]  dataout_h;
	output   [1:0]  dataout_l;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	reg	[1:0]	dataout_h_reg;
	reg	[1:0]	dataout_l_latch;
	reg	[1:0]	dataout_l_reg;
	(* ALTERA_ATTRIBUTE = {"LVDS_RX_REGISTER=HIGH;PRESERVE_REGISTER=ON;PRESERVE_FANOUT_FREE_NODE=ON"} *)
	reg	[1:0]	ddio_h_reg;
	(* ALTERA_ATTRIBUTE = {"LVDS_RX_REGISTER=LOW;PRESERVE_REGISTER=ON;PRESERVE_FANOUT_FREE_NODE=ON"} *)
	reg	[1:0]	ddio_l_reg;

	// synopsys translate_off
	initial
		dataout_h_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) dataout_h_reg <= 2'b0;
		else  dataout_h_reg <= ddio_h_reg;
	// synopsys translate_off
	initial
		dataout_l_latch = 0;
	// synopsys translate_on
	always @ ( negedge clock or  posedge aclr)
		if (aclr == 1'b1) dataout_l_latch <= 2'b0;
		else  dataout_l_latch <= ddio_l_reg;
	// synopsys translate_off
	initial
		dataout_l_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) dataout_l_reg <= 2'b0;
		else  dataout_l_reg <= dataout_l_latch;
	// synopsys translate_off
	initial
		ddio_h_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) ddio_h_reg <= 2'b0;
		else  ddio_h_reg <= datain;
	// synopsys translate_off
	initial
		ddio_l_reg = 0;
	// synopsys translate_on
	always @ ( negedge clock or  posedge aclr)
		if (aclr == 1'b1) ddio_l_reg <= 2'b0;
		else  ddio_l_reg <= datain;
	assign
		dataout_h = dataout_l_reg,
		dataout_l = dataout_h_reg;
endmodule //lvds_rx_x2_m10_0002_lvds_ddio_in_jka


//altsyncram ADDRESS_REG_B="CLOCK1" CBX_SINGLE_OUTPUT_FILE="ON" CYCLONEII_SAFE_WRITE="RESTRUCTURE" DEVICE_FAMILY="MAX 10" OPERATION_MODE="DUAL_PORT" OUTDATA_REG_B="CLOCK1" WIDTH_A=20 WIDTH_B=10 WIDTHAD_A=4 WIDTHAD_B=5 address_a address_b clock0 clock1 data_a q_b wren_a
//VERSION_BEGIN 14.1 cbx_altsyncram 2014:12:03:18:04:04:SJ cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_lpm_decode 2014:12:03:18:04:04:SJ cbx_lpm_mux 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ cbx_stratixiii 2014:12:03:18:04:04:SJ cbx_stratixv 2014:12:03:18:04:04:SJ cbx_util_mgl 2014:12:03:18:04:04:SJ  VERSION_END

//synthesis_resources = M9K 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"OPTIMIZE_POWER_DURING_SYNTHESIS=NORMAL_COMPILATION"} *)
module  lvds_rx_x2_m10_0002_altsyncram_s9o
	( 
	address_a,
	address_b,
	clock0,
	clock1,
	data_a,
	q_b,
	wren_a) /* synthesis synthesis_clearbox=1 */;
	input   [3:0]  address_a;
	input   [4:0]  address_b;
	input   clock0;
	input   clock1;
	input   [19:0]  data_a;
	output   [9:0]  q_b;
	input   wren_a;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1   [4:0]  address_b;
	tri1   clock0;
	tri1   clock1;
	tri1   [19:0]  data_a;
	tri0   wren_a;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]   wire_ram_block15a_0portbdataout;
	wire  [0:0]   wire_ram_block15a_1portbdataout;
	wire  [0:0]   wire_ram_block15a_2portbdataout;
	wire  [0:0]   wire_ram_block15a_3portbdataout;
	wire  [0:0]   wire_ram_block15a_4portbdataout;
	wire  [0:0]   wire_ram_block15a_5portbdataout;
	wire  [0:0]   wire_ram_block15a_6portbdataout;
	wire  [0:0]   wire_ram_block15a_7portbdataout;
	wire  [0:0]   wire_ram_block15a_8portbdataout;
	wire  [0:0]   wire_ram_block15a_9portbdataout;
	wire  [3:0]  address_a_wire;
	wire  [4:0]  address_b_wire;

	fiftyfivenm_ram_block   ram_block15a_0
	( 
	.clk0(clock0),
	.clk1(clock1),
	.ena0(wren_a),
	.portaaddr({address_a_wire[3:0]}),
	.portadatain({data_a[10], data_a[0]}),
	.portadataout(),
	.portawe(wren_a),
	.portbaddr({address_b_wire[4:0]}),
	.portbdataout(wire_ram_block15a_0portbdataout[0:0]),
	.portbre(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clr0(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.ena2(1'b1),
	.ena3(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portare(1'b1),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbwe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block15a_0.clk0_core_clock_enable = "ena0",
		ram_block15a_0.clk0_input_clock_enable = "none",
		ram_block15a_0.clk1_core_clock_enable = "none",
		ram_block15a_0.clk1_input_clock_enable = "none",
		ram_block15a_0.clk1_output_clock_enable = "none",
		ram_block15a_0.connectivity_checking = "OFF",
		ram_block15a_0.data_interleave_offset_in_bits = 10,
		ram_block15a_0.data_interleave_width_in_bits = 1,
		ram_block15a_0.logical_ram_name = "ALTSYNCRAM",
		ram_block15a_0.mixed_port_feed_through_mode = "dont_care",
		ram_block15a_0.operation_mode = "dual_port",
		ram_block15a_0.port_a_address_width = 4,
		ram_block15a_0.port_a_data_width = 2,
		ram_block15a_0.port_a_first_address = 0,
		ram_block15a_0.port_a_first_bit_number = 0,
		ram_block15a_0.port_a_last_address = 15,
		ram_block15a_0.port_a_logical_ram_depth = 16,
		ram_block15a_0.port_a_logical_ram_width = 20,
		ram_block15a_0.port_b_address_clear = "none",
		ram_block15a_0.port_b_address_clock = "clock1",
		ram_block15a_0.port_b_address_width = 5,
		ram_block15a_0.port_b_data_out_clear = "none",
		ram_block15a_0.port_b_data_out_clock = "clock1",
		ram_block15a_0.port_b_data_width = 1,
		ram_block15a_0.port_b_first_address = 0,
		ram_block15a_0.port_b_first_bit_number = 0,
		ram_block15a_0.port_b_last_address = 31,
		ram_block15a_0.port_b_logical_ram_depth = 32,
		ram_block15a_0.port_b_logical_ram_width = 10,
		ram_block15a_0.port_b_read_enable_clock = "clock1",
		ram_block15a_0.ram_block_type = "AUTO",
		ram_block15a_0.lpm_type = "fiftyfivenm_ram_block";
	fiftyfivenm_ram_block   ram_block15a_1
	( 
	.clk0(clock0),
	.clk1(clock1),
	.ena0(wren_a),
	.portaaddr({address_a_wire[3:0]}),
	.portadatain({data_a[11], data_a[1]}),
	.portadataout(),
	.portawe(wren_a),
	.portbaddr({address_b_wire[4:0]}),
	.portbdataout(wire_ram_block15a_1portbdataout[0:0]),
	.portbre(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clr0(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.ena2(1'b1),
	.ena3(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portare(1'b1),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbwe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block15a_1.clk0_core_clock_enable = "ena0",
		ram_block15a_1.clk0_input_clock_enable = "none",
		ram_block15a_1.clk1_core_clock_enable = "none",
		ram_block15a_1.clk1_input_clock_enable = "none",
		ram_block15a_1.clk1_output_clock_enable = "none",
		ram_block15a_1.connectivity_checking = "OFF",
		ram_block15a_1.data_interleave_offset_in_bits = 10,
		ram_block15a_1.data_interleave_width_in_bits = 1,
		ram_block15a_1.logical_ram_name = "ALTSYNCRAM",
		ram_block15a_1.mixed_port_feed_through_mode = "dont_care",
		ram_block15a_1.operation_mode = "dual_port",
		ram_block15a_1.port_a_address_width = 4,
		ram_block15a_1.port_a_data_width = 2,
		ram_block15a_1.port_a_first_address = 0,
		ram_block15a_1.port_a_first_bit_number = 1,
		ram_block15a_1.port_a_last_address = 15,
		ram_block15a_1.port_a_logical_ram_depth = 16,
		ram_block15a_1.port_a_logical_ram_width = 20,
		ram_block15a_1.port_b_address_clear = "none",
		ram_block15a_1.port_b_address_clock = "clock1",
		ram_block15a_1.port_b_address_width = 5,
		ram_block15a_1.port_b_data_out_clear = "none",
		ram_block15a_1.port_b_data_out_clock = "clock1",
		ram_block15a_1.port_b_data_width = 1,
		ram_block15a_1.port_b_first_address = 0,
		ram_block15a_1.port_b_first_bit_number = 1,
		ram_block15a_1.port_b_last_address = 31,
		ram_block15a_1.port_b_logical_ram_depth = 32,
		ram_block15a_1.port_b_logical_ram_width = 10,
		ram_block15a_1.port_b_read_enable_clock = "clock1",
		ram_block15a_1.ram_block_type = "AUTO",
		ram_block15a_1.lpm_type = "fiftyfivenm_ram_block";
	fiftyfivenm_ram_block   ram_block15a_2
	( 
	.clk0(clock0),
	.clk1(clock1),
	.ena0(wren_a),
	.portaaddr({address_a_wire[3:0]}),
	.portadatain({data_a[12], data_a[2]}),
	.portadataout(),
	.portawe(wren_a),
	.portbaddr({address_b_wire[4:0]}),
	.portbdataout(wire_ram_block15a_2portbdataout[0:0]),
	.portbre(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clr0(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.ena2(1'b1),
	.ena3(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portare(1'b1),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbwe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block15a_2.clk0_core_clock_enable = "ena0",
		ram_block15a_2.clk0_input_clock_enable = "none",
		ram_block15a_2.clk1_core_clock_enable = "none",
		ram_block15a_2.clk1_input_clock_enable = "none",
		ram_block15a_2.clk1_output_clock_enable = "none",
		ram_block15a_2.connectivity_checking = "OFF",
		ram_block15a_2.data_interleave_offset_in_bits = 10,
		ram_block15a_2.data_interleave_width_in_bits = 1,
		ram_block15a_2.logical_ram_name = "ALTSYNCRAM",
		ram_block15a_2.mixed_port_feed_through_mode = "dont_care",
		ram_block15a_2.operation_mode = "dual_port",
		ram_block15a_2.port_a_address_width = 4,
		ram_block15a_2.port_a_data_width = 2,
		ram_block15a_2.port_a_first_address = 0,
		ram_block15a_2.port_a_first_bit_number = 2,
		ram_block15a_2.port_a_last_address = 15,
		ram_block15a_2.port_a_logical_ram_depth = 16,
		ram_block15a_2.port_a_logical_ram_width = 20,
		ram_block15a_2.port_b_address_clear = "none",
		ram_block15a_2.port_b_address_clock = "clock1",
		ram_block15a_2.port_b_address_width = 5,
		ram_block15a_2.port_b_data_out_clear = "none",
		ram_block15a_2.port_b_data_out_clock = "clock1",
		ram_block15a_2.port_b_data_width = 1,
		ram_block15a_2.port_b_first_address = 0,
		ram_block15a_2.port_b_first_bit_number = 2,
		ram_block15a_2.port_b_last_address = 31,
		ram_block15a_2.port_b_logical_ram_depth = 32,
		ram_block15a_2.port_b_logical_ram_width = 10,
		ram_block15a_2.port_b_read_enable_clock = "clock1",
		ram_block15a_2.ram_block_type = "AUTO",
		ram_block15a_2.lpm_type = "fiftyfivenm_ram_block";
	fiftyfivenm_ram_block   ram_block15a_3
	( 
	.clk0(clock0),
	.clk1(clock1),
	.ena0(wren_a),
	.portaaddr({address_a_wire[3:0]}),
	.portadatain({data_a[13], data_a[3]}),
	.portadataout(),
	.portawe(wren_a),
	.portbaddr({address_b_wire[4:0]}),
	.portbdataout(wire_ram_block15a_3portbdataout[0:0]),
	.portbre(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clr0(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.ena2(1'b1),
	.ena3(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portare(1'b1),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbwe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block15a_3.clk0_core_clock_enable = "ena0",
		ram_block15a_3.clk0_input_clock_enable = "none",
		ram_block15a_3.clk1_core_clock_enable = "none",
		ram_block15a_3.clk1_input_clock_enable = "none",
		ram_block15a_3.clk1_output_clock_enable = "none",
		ram_block15a_3.connectivity_checking = "OFF",
		ram_block15a_3.data_interleave_offset_in_bits = 10,
		ram_block15a_3.data_interleave_width_in_bits = 1,
		ram_block15a_3.logical_ram_name = "ALTSYNCRAM",
		ram_block15a_3.mixed_port_feed_through_mode = "dont_care",
		ram_block15a_3.operation_mode = "dual_port",
		ram_block15a_3.port_a_address_width = 4,
		ram_block15a_3.port_a_data_width = 2,
		ram_block15a_3.port_a_first_address = 0,
		ram_block15a_3.port_a_first_bit_number = 3,
		ram_block15a_3.port_a_last_address = 15,
		ram_block15a_3.port_a_logical_ram_depth = 16,
		ram_block15a_3.port_a_logical_ram_width = 20,
		ram_block15a_3.port_b_address_clear = "none",
		ram_block15a_3.port_b_address_clock = "clock1",
		ram_block15a_3.port_b_address_width = 5,
		ram_block15a_3.port_b_data_out_clear = "none",
		ram_block15a_3.port_b_data_out_clock = "clock1",
		ram_block15a_3.port_b_data_width = 1,
		ram_block15a_3.port_b_first_address = 0,
		ram_block15a_3.port_b_first_bit_number = 3,
		ram_block15a_3.port_b_last_address = 31,
		ram_block15a_3.port_b_logical_ram_depth = 32,
		ram_block15a_3.port_b_logical_ram_width = 10,
		ram_block15a_3.port_b_read_enable_clock = "clock1",
		ram_block15a_3.ram_block_type = "AUTO",
		ram_block15a_3.lpm_type = "fiftyfivenm_ram_block";
	fiftyfivenm_ram_block   ram_block15a_4
	( 
	.clk0(clock0),
	.clk1(clock1),
	.ena0(wren_a),
	.portaaddr({address_a_wire[3:0]}),
	.portadatain({data_a[14], data_a[4]}),
	.portadataout(),
	.portawe(wren_a),
	.portbaddr({address_b_wire[4:0]}),
	.portbdataout(wire_ram_block15a_4portbdataout[0:0]),
	.portbre(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clr0(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.ena2(1'b1),
	.ena3(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portare(1'b1),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbwe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block15a_4.clk0_core_clock_enable = "ena0",
		ram_block15a_4.clk0_input_clock_enable = "none",
		ram_block15a_4.clk1_core_clock_enable = "none",
		ram_block15a_4.clk1_input_clock_enable = "none",
		ram_block15a_4.clk1_output_clock_enable = "none",
		ram_block15a_4.connectivity_checking = "OFF",
		ram_block15a_4.data_interleave_offset_in_bits = 10,
		ram_block15a_4.data_interleave_width_in_bits = 1,
		ram_block15a_4.logical_ram_name = "ALTSYNCRAM",
		ram_block15a_4.mixed_port_feed_through_mode = "dont_care",
		ram_block15a_4.operation_mode = "dual_port",
		ram_block15a_4.port_a_address_width = 4,
		ram_block15a_4.port_a_data_width = 2,
		ram_block15a_4.port_a_first_address = 0,
		ram_block15a_4.port_a_first_bit_number = 4,
		ram_block15a_4.port_a_last_address = 15,
		ram_block15a_4.port_a_logical_ram_depth = 16,
		ram_block15a_4.port_a_logical_ram_width = 20,
		ram_block15a_4.port_b_address_clear = "none",
		ram_block15a_4.port_b_address_clock = "clock1",
		ram_block15a_4.port_b_address_width = 5,
		ram_block15a_4.port_b_data_out_clear = "none",
		ram_block15a_4.port_b_data_out_clock = "clock1",
		ram_block15a_4.port_b_data_width = 1,
		ram_block15a_4.port_b_first_address = 0,
		ram_block15a_4.port_b_first_bit_number = 4,
		ram_block15a_4.port_b_last_address = 31,
		ram_block15a_4.port_b_logical_ram_depth = 32,
		ram_block15a_4.port_b_logical_ram_width = 10,
		ram_block15a_4.port_b_read_enable_clock = "clock1",
		ram_block15a_4.ram_block_type = "AUTO",
		ram_block15a_4.lpm_type = "fiftyfivenm_ram_block";
	fiftyfivenm_ram_block   ram_block15a_5
	( 
	.clk0(clock0),
	.clk1(clock1),
	.ena0(wren_a),
	.portaaddr({address_a_wire[3:0]}),
	.portadatain({data_a[15], data_a[5]}),
	.portadataout(),
	.portawe(wren_a),
	.portbaddr({address_b_wire[4:0]}),
	.portbdataout(wire_ram_block15a_5portbdataout[0:0]),
	.portbre(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clr0(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.ena2(1'b1),
	.ena3(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portare(1'b1),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbwe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block15a_5.clk0_core_clock_enable = "ena0",
		ram_block15a_5.clk0_input_clock_enable = "none",
		ram_block15a_5.clk1_core_clock_enable = "none",
		ram_block15a_5.clk1_input_clock_enable = "none",
		ram_block15a_5.clk1_output_clock_enable = "none",
		ram_block15a_5.connectivity_checking = "OFF",
		ram_block15a_5.data_interleave_offset_in_bits = 10,
		ram_block15a_5.data_interleave_width_in_bits = 1,
		ram_block15a_5.logical_ram_name = "ALTSYNCRAM",
		ram_block15a_5.mixed_port_feed_through_mode = "dont_care",
		ram_block15a_5.operation_mode = "dual_port",
		ram_block15a_5.port_a_address_width = 4,
		ram_block15a_5.port_a_data_width = 2,
		ram_block15a_5.port_a_first_address = 0,
		ram_block15a_5.port_a_first_bit_number = 5,
		ram_block15a_5.port_a_last_address = 15,
		ram_block15a_5.port_a_logical_ram_depth = 16,
		ram_block15a_5.port_a_logical_ram_width = 20,
		ram_block15a_5.port_b_address_clear = "none",
		ram_block15a_5.port_b_address_clock = "clock1",
		ram_block15a_5.port_b_address_width = 5,
		ram_block15a_5.port_b_data_out_clear = "none",
		ram_block15a_5.port_b_data_out_clock = "clock1",
		ram_block15a_5.port_b_data_width = 1,
		ram_block15a_5.port_b_first_address = 0,
		ram_block15a_5.port_b_first_bit_number = 5,
		ram_block15a_5.port_b_last_address = 31,
		ram_block15a_5.port_b_logical_ram_depth = 32,
		ram_block15a_5.port_b_logical_ram_width = 10,
		ram_block15a_5.port_b_read_enable_clock = "clock1",
		ram_block15a_5.ram_block_type = "AUTO",
		ram_block15a_5.lpm_type = "fiftyfivenm_ram_block";
	fiftyfivenm_ram_block   ram_block15a_6
	( 
	.clk0(clock0),
	.clk1(clock1),
	.ena0(wren_a),
	.portaaddr({address_a_wire[3:0]}),
	.portadatain({data_a[16], data_a[6]}),
	.portadataout(),
	.portawe(wren_a),
	.portbaddr({address_b_wire[4:0]}),
	.portbdataout(wire_ram_block15a_6portbdataout[0:0]),
	.portbre(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clr0(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.ena2(1'b1),
	.ena3(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portare(1'b1),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbwe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block15a_6.clk0_core_clock_enable = "ena0",
		ram_block15a_6.clk0_input_clock_enable = "none",
		ram_block15a_6.clk1_core_clock_enable = "none",
		ram_block15a_6.clk1_input_clock_enable = "none",
		ram_block15a_6.clk1_output_clock_enable = "none",
		ram_block15a_6.connectivity_checking = "OFF",
		ram_block15a_6.data_interleave_offset_in_bits = 10,
		ram_block15a_6.data_interleave_width_in_bits = 1,
		ram_block15a_6.logical_ram_name = "ALTSYNCRAM",
		ram_block15a_6.mixed_port_feed_through_mode = "dont_care",
		ram_block15a_6.operation_mode = "dual_port",
		ram_block15a_6.port_a_address_width = 4,
		ram_block15a_6.port_a_data_width = 2,
		ram_block15a_6.port_a_first_address = 0,
		ram_block15a_6.port_a_first_bit_number = 6,
		ram_block15a_6.port_a_last_address = 15,
		ram_block15a_6.port_a_logical_ram_depth = 16,
		ram_block15a_6.port_a_logical_ram_width = 20,
		ram_block15a_6.port_b_address_clear = "none",
		ram_block15a_6.port_b_address_clock = "clock1",
		ram_block15a_6.port_b_address_width = 5,
		ram_block15a_6.port_b_data_out_clear = "none",
		ram_block15a_6.port_b_data_out_clock = "clock1",
		ram_block15a_6.port_b_data_width = 1,
		ram_block15a_6.port_b_first_address = 0,
		ram_block15a_6.port_b_first_bit_number = 6,
		ram_block15a_6.port_b_last_address = 31,
		ram_block15a_6.port_b_logical_ram_depth = 32,
		ram_block15a_6.port_b_logical_ram_width = 10,
		ram_block15a_6.port_b_read_enable_clock = "clock1",
		ram_block15a_6.ram_block_type = "AUTO",
		ram_block15a_6.lpm_type = "fiftyfivenm_ram_block";
	fiftyfivenm_ram_block   ram_block15a_7
	( 
	.clk0(clock0),
	.clk1(clock1),
	.ena0(wren_a),
	.portaaddr({address_a_wire[3:0]}),
	.portadatain({data_a[17], data_a[7]}),
	.portadataout(),
	.portawe(wren_a),
	.portbaddr({address_b_wire[4:0]}),
	.portbdataout(wire_ram_block15a_7portbdataout[0:0]),
	.portbre(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clr0(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.ena2(1'b1),
	.ena3(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portare(1'b1),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbwe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block15a_7.clk0_core_clock_enable = "ena0",
		ram_block15a_7.clk0_input_clock_enable = "none",
		ram_block15a_7.clk1_core_clock_enable = "none",
		ram_block15a_7.clk1_input_clock_enable = "none",
		ram_block15a_7.clk1_output_clock_enable = "none",
		ram_block15a_7.connectivity_checking = "OFF",
		ram_block15a_7.data_interleave_offset_in_bits = 10,
		ram_block15a_7.data_interleave_width_in_bits = 1,
		ram_block15a_7.logical_ram_name = "ALTSYNCRAM",
		ram_block15a_7.mixed_port_feed_through_mode = "dont_care",
		ram_block15a_7.operation_mode = "dual_port",
		ram_block15a_7.port_a_address_width = 4,
		ram_block15a_7.port_a_data_width = 2,
		ram_block15a_7.port_a_first_address = 0,
		ram_block15a_7.port_a_first_bit_number = 7,
		ram_block15a_7.port_a_last_address = 15,
		ram_block15a_7.port_a_logical_ram_depth = 16,
		ram_block15a_7.port_a_logical_ram_width = 20,
		ram_block15a_7.port_b_address_clear = "none",
		ram_block15a_7.port_b_address_clock = "clock1",
		ram_block15a_7.port_b_address_width = 5,
		ram_block15a_7.port_b_data_out_clear = "none",
		ram_block15a_7.port_b_data_out_clock = "clock1",
		ram_block15a_7.port_b_data_width = 1,
		ram_block15a_7.port_b_first_address = 0,
		ram_block15a_7.port_b_first_bit_number = 7,
		ram_block15a_7.port_b_last_address = 31,
		ram_block15a_7.port_b_logical_ram_depth = 32,
		ram_block15a_7.port_b_logical_ram_width = 10,
		ram_block15a_7.port_b_read_enable_clock = "clock1",
		ram_block15a_7.ram_block_type = "AUTO",
		ram_block15a_7.lpm_type = "fiftyfivenm_ram_block";
	fiftyfivenm_ram_block   ram_block15a_8
	( 
	.clk0(clock0),
	.clk1(clock1),
	.ena0(wren_a),
	.portaaddr({address_a_wire[3:0]}),
	.portadatain({data_a[18], data_a[8]}),
	.portadataout(),
	.portawe(wren_a),
	.portbaddr({address_b_wire[4:0]}),
	.portbdataout(wire_ram_block15a_8portbdataout[0:0]),
	.portbre(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clr0(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.ena2(1'b1),
	.ena3(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portare(1'b1),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbwe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block15a_8.clk0_core_clock_enable = "ena0",
		ram_block15a_8.clk0_input_clock_enable = "none",
		ram_block15a_8.clk1_core_clock_enable = "none",
		ram_block15a_8.clk1_input_clock_enable = "none",
		ram_block15a_8.clk1_output_clock_enable = "none",
		ram_block15a_8.connectivity_checking = "OFF",
		ram_block15a_8.data_interleave_offset_in_bits = 10,
		ram_block15a_8.data_interleave_width_in_bits = 1,
		ram_block15a_8.logical_ram_name = "ALTSYNCRAM",
		ram_block15a_8.mixed_port_feed_through_mode = "dont_care",
		ram_block15a_8.operation_mode = "dual_port",
		ram_block15a_8.port_a_address_width = 4,
		ram_block15a_8.port_a_data_width = 2,
		ram_block15a_8.port_a_first_address = 0,
		ram_block15a_8.port_a_first_bit_number = 8,
		ram_block15a_8.port_a_last_address = 15,
		ram_block15a_8.port_a_logical_ram_depth = 16,
		ram_block15a_8.port_a_logical_ram_width = 20,
		ram_block15a_8.port_b_address_clear = "none",
		ram_block15a_8.port_b_address_clock = "clock1",
		ram_block15a_8.port_b_address_width = 5,
		ram_block15a_8.port_b_data_out_clear = "none",
		ram_block15a_8.port_b_data_out_clock = "clock1",
		ram_block15a_8.port_b_data_width = 1,
		ram_block15a_8.port_b_first_address = 0,
		ram_block15a_8.port_b_first_bit_number = 8,
		ram_block15a_8.port_b_last_address = 31,
		ram_block15a_8.port_b_logical_ram_depth = 32,
		ram_block15a_8.port_b_logical_ram_width = 10,
		ram_block15a_8.port_b_read_enable_clock = "clock1",
		ram_block15a_8.ram_block_type = "AUTO",
		ram_block15a_8.lpm_type = "fiftyfivenm_ram_block";
	fiftyfivenm_ram_block   ram_block15a_9
	( 
	.clk0(clock0),
	.clk1(clock1),
	.ena0(wren_a),
	.portaaddr({address_a_wire[3:0]}),
	.portadatain({data_a[19], data_a[9]}),
	.portadataout(),
	.portawe(wren_a),
	.portbaddr({address_b_wire[4:0]}),
	.portbdataout(wire_ram_block15a_9portbdataout[0:0]),
	.portbre(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clr0(1'b0),
	.clr1(1'b0),
	.ena1(1'b1),
	.ena2(1'b1),
	.ena3(1'b1),
	.portaaddrstall(1'b0),
	.portabyteenamasks({1{1'b1}}),
	.portare(1'b1),
	.portbaddrstall(1'b0),
	.portbbyteenamasks({1{1'b1}}),
	.portbdatain({1{1'b0}}),
	.portbwe(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1)
	// synopsys translate_on
	);
	defparam
		ram_block15a_9.clk0_core_clock_enable = "ena0",
		ram_block15a_9.clk0_input_clock_enable = "none",
		ram_block15a_9.clk1_core_clock_enable = "none",
		ram_block15a_9.clk1_input_clock_enable = "none",
		ram_block15a_9.clk1_output_clock_enable = "none",
		ram_block15a_9.connectivity_checking = "OFF",
		ram_block15a_9.data_interleave_offset_in_bits = 10,
		ram_block15a_9.data_interleave_width_in_bits = 1,
		ram_block15a_9.logical_ram_name = "ALTSYNCRAM",
		ram_block15a_9.mixed_port_feed_through_mode = "dont_care",
		ram_block15a_9.operation_mode = "dual_port",
		ram_block15a_9.port_a_address_width = 4,
		ram_block15a_9.port_a_data_width = 2,
		ram_block15a_9.port_a_first_address = 0,
		ram_block15a_9.port_a_first_bit_number = 9,
		ram_block15a_9.port_a_last_address = 15,
		ram_block15a_9.port_a_logical_ram_depth = 16,
		ram_block15a_9.port_a_logical_ram_width = 20,
		ram_block15a_9.port_b_address_clear = "none",
		ram_block15a_9.port_b_address_clock = "clock1",
		ram_block15a_9.port_b_address_width = 5,
		ram_block15a_9.port_b_data_out_clear = "none",
		ram_block15a_9.port_b_data_out_clock = "clock1",
		ram_block15a_9.port_b_data_width = 1,
		ram_block15a_9.port_b_first_address = 0,
		ram_block15a_9.port_b_first_bit_number = 9,
		ram_block15a_9.port_b_last_address = 31,
		ram_block15a_9.port_b_logical_ram_depth = 32,
		ram_block15a_9.port_b_logical_ram_width = 10,
		ram_block15a_9.port_b_read_enable_clock = "clock1",
		ram_block15a_9.ram_block_type = "AUTO",
		ram_block15a_9.lpm_type = "fiftyfivenm_ram_block";
	assign
		address_a_wire = address_a,
		address_b_wire = address_b,
		q_b = {wire_ram_block15a_9portbdataout[0], wire_ram_block15a_8portbdataout[0], wire_ram_block15a_7portbdataout[0], wire_ram_block15a_6portbdataout[0], wire_ram_block15a_5portbdataout[0], wire_ram_block15a_4portbdataout[0], wire_ram_block15a_3portbdataout[0], wire_ram_block15a_2portbdataout[0], wire_ram_block15a_1portbdataout[0], wire_ram_block15a_0portbdataout[0]};
endmodule //lvds_rx_x2_m10_0002_altsyncram_s9o


//lpm_counter CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" lpm_modulus=5 lpm_port_updown="PORT_UNUSED" lpm_width=3 aclr clock cnt_en q
//VERSION_BEGIN 14.1 cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_lpm_counter 2014:12:03:18:04:04:SJ cbx_lpm_decode 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ  VERSION_END


//lpm_add_sub CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" LPM_DIRECTION="ADD" LPM_REPRESENTATION="UNSIGNED" LPM_WIDTH=3 ONE_INPUT_IS_CONSTANT="YES" USE_WYS="OPERATORS" cout dataa datab result
//VERSION_BEGIN 14.1 cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ  VERSION_END


//lpm_compare CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" LPM_WIDTH=3 ONE_INPUT_IS_CONSTANT="YES" aeb dataa datab
//VERSION_BEGIN 14.1 cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ  VERSION_END

//synthesis_resources = 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lvds_rx_x2_m10_0002_cmpr_hsa
	( 
	aeb,
	dataa,
	datab) /* synthesis synthesis_clearbox=1 */;
	output   aeb;
	input   [2:0]  dataa;
	input   [2:0]  datab;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [2:0]  dataa;
	tri0   [2:0]  datab;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]  aeb_result_wire;
	wire  [0:0]  aneb_result_wire;
	wire  [7:0]  data_wire;
	wire  eq_wire;

	assign
		aeb = eq_wire,
		aeb_result_wire = (~ aneb_result_wire),
		aneb_result_wire = (data_wire[0] | data_wire[1]),
		data_wire = {datab[2], dataa[2], datab[1], dataa[1], datab[0], dataa[0], (data_wire[6] ^ data_wire[7]), ((data_wire[2] ^ data_wire[3]) | (data_wire[4] ^ data_wire[5]))},
		eq_wire = aeb_result_wire;
endmodule //lvds_rx_x2_m10_0002_cmpr_hsa

//synthesis_resources = lut 3 reg 3 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lvds_rx_x2_m10_0002_cntr_vrc
	( 
	aclr,
	clock,
	cnt_en,
	q) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clock;
	input   cnt_en;
	output   [2:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
	tri1   cnt_en;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	reg	[2:0]	counter_reg_bit;
	wire	[2:0]	wire_counter_reg_bit_ena;
	wire	[3:0]	wire_add_sub16_result_int;
	wire	wire_add_sub16_cout;
	wire	[2:0]	wire_add_sub16_dataa;
	wire	[2:0]	wire_add_sub16_datab;
	wire	[2:0]	wire_add_sub16_result;
	wire  wire_cmpr17_aeb;
	wire  aclr_actual;
	wire  [2:0]  add_sub_one_w;
	wire  [2:0]  add_value_w;
	wire clk_en;
	wire  compare_result;
	wire  cout_actual;
	wire  [2:0]  current_reg_q_w;
	wire  custom_cout_w;
	wire  [2:0]  modulus_bus;
	wire  modulus_trigger;
	wire  [2:0]  modulus_trigger_value_w;
	wire  [2:0]  safe_q;
	wire  time_to_clear;
	wire  [2:0]  trigger_mux_w;
	wire  updown_dir;

	// synopsys translate_off
	initial
		counter_reg_bit[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[0:0] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[0:0] == 1'b1)   counter_reg_bit[0:0] <= trigger_mux_w[0:0];
	// synopsys translate_off
	initial
		counter_reg_bit[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[1:1] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[1:1] == 1'b1)   counter_reg_bit[1:1] <= trigger_mux_w[1:1];
	// synopsys translate_off
	initial
		counter_reg_bit[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[2:2] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[2:2] == 1'b1)   counter_reg_bit[2:2] <= trigger_mux_w[2:2];
	assign
		wire_counter_reg_bit_ena = {3{(clk_en & cnt_en)}};
	assign
		wire_add_sub16_result_int = wire_add_sub16_dataa + wire_add_sub16_datab;
	assign
		wire_add_sub16_result = wire_add_sub16_result_int[2:0],
		wire_add_sub16_cout = wire_add_sub16_result_int[3:3];
	assign
		wire_add_sub16_dataa = current_reg_q_w,
		wire_add_sub16_datab = add_value_w;
	lvds_rx_x2_m10_0002_cmpr_hsa   cmpr17
	( 
	.aeb(wire_cmpr17_aeb),
	.dataa(safe_q),
	.datab(modulus_bus));
	assign
		aclr_actual = aclr,
		add_sub_one_w = wire_add_sub16_result,
		add_value_w = 3'b001,
		clk_en = 1'b1,
		compare_result = wire_cmpr17_aeb,
		cout_actual = (custom_cout_w | (time_to_clear & updown_dir)),
		current_reg_q_w = counter_reg_bit,
		custom_cout_w = (wire_add_sub16_cout & add_value_w[0]),
		modulus_bus = 3'b100,
		modulus_trigger = cout_actual,
		modulus_trigger_value_w = ({3{(~ updown_dir)}} & modulus_bus),
		q = safe_q,
		safe_q = counter_reg_bit,
		time_to_clear = compare_result,
		trigger_mux_w = (({3{(~ modulus_trigger)}} & add_sub_one_w) | ({3{modulus_trigger}} & modulus_trigger_value_w)),
		updown_dir = 1'b1;
endmodule //lvds_rx_x2_m10_0002_cntr_vrc


//lpm_counter CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" lpm_port_updown="PORT_UNUSED" lpm_width=5 aclr clock q
//VERSION_BEGIN 14.1 cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_lpm_counter 2014:12:03:18:04:04:SJ cbx_lpm_decode 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ  VERSION_END

//synthesis_resources = lut 5 reg 5 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lvds_rx_x2_m10_0002_cntr_7ta
	( 
	aclr,
	clock,
	q) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clock;
	output   [4:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]   wire_counter_comb_bita_0combout;
	wire  [0:0]   wire_counter_comb_bita_1combout;
	wire  [0:0]   wire_counter_comb_bita_2combout;
	wire  [0:0]   wire_counter_comb_bita_3combout;
	wire  [0:0]   wire_counter_comb_bita_4combout;
	wire  [0:0]   wire_counter_comb_bita_0cout;
	wire  [0:0]   wire_counter_comb_bita_1cout;
	wire  [0:0]   wire_counter_comb_bita_2cout;
	wire  [0:0]   wire_counter_comb_bita_3cout;
	wire	[4:0]	wire_counter_reg_bit_d;
	wire	[4:0]	wire_counter_reg_bit_asdata;
	reg	[4:0]	counter_reg_bit;
	wire	[4:0]	wire_counter_reg_bit_ena;
	wire	[4:0]	wire_counter_reg_bit_sload;
	wire  aclr_actual;
	wire clk_en;
	wire cnt_en;
	wire [4:0]  data;
	wire  external_cin;
	wire  [4:0]  s_val;
	wire  [4:0]  safe_q;
	wire sclr;
	wire sload;
	wire sset;
	wire  updown_dir;

	fiftyfivenm_lcell_comb   counter_comb_bita_0
	( 
	.cin(external_cin),
	.combout(wire_counter_comb_bita_0combout[0:0]),
	.cout(wire_counter_comb_bita_0cout[0:0]),
	.dataa(counter_reg_bit[0]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_0.lut_mask = 16'h5A90,
		counter_comb_bita_0.sum_lutc_input = "cin",
		counter_comb_bita_0.lpm_type = "fiftyfivenm_lcell_comb";
	fiftyfivenm_lcell_comb   counter_comb_bita_1
	( 
	.cin(wire_counter_comb_bita_0cout[0:0]),
	.combout(wire_counter_comb_bita_1combout[0:0]),
	.cout(wire_counter_comb_bita_1cout[0:0]),
	.dataa(counter_reg_bit[1]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_1.lut_mask = 16'h5A90,
		counter_comb_bita_1.sum_lutc_input = "cin",
		counter_comb_bita_1.lpm_type = "fiftyfivenm_lcell_comb";
	fiftyfivenm_lcell_comb   counter_comb_bita_2
	( 
	.cin(wire_counter_comb_bita_1cout[0:0]),
	.combout(wire_counter_comb_bita_2combout[0:0]),
	.cout(wire_counter_comb_bita_2cout[0:0]),
	.dataa(counter_reg_bit[2]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_2.lut_mask = 16'h5A90,
		counter_comb_bita_2.sum_lutc_input = "cin",
		counter_comb_bita_2.lpm_type = "fiftyfivenm_lcell_comb";
	fiftyfivenm_lcell_comb   counter_comb_bita_3
	( 
	.cin(wire_counter_comb_bita_2cout[0:0]),
	.combout(wire_counter_comb_bita_3combout[0:0]),
	.cout(wire_counter_comb_bita_3cout[0:0]),
	.dataa(counter_reg_bit[3]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_3.lut_mask = 16'h5A90,
		counter_comb_bita_3.sum_lutc_input = "cin",
		counter_comb_bita_3.lpm_type = "fiftyfivenm_lcell_comb";
	fiftyfivenm_lcell_comb   counter_comb_bita_4
	( 
	.cin(wire_counter_comb_bita_3cout[0:0]),
	.combout(wire_counter_comb_bita_4combout[0:0]),
	.cout(),
	.dataa(counter_reg_bit[4]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_4.lut_mask = 16'h5A90,
		counter_comb_bita_4.sum_lutc_input = "cin",
		counter_comb_bita_4.lpm_type = "fiftyfivenm_lcell_comb";
	// synopsys translate_off
	initial
		counter_reg_bit[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[0:0] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[0:0] == 1'b1) 
			if (wire_counter_reg_bit_sload[0:0] == 1'b1) counter_reg_bit[0:0] <= wire_counter_reg_bit_asdata[0:0];
			else  counter_reg_bit[0:0] <= wire_counter_reg_bit_d[0:0];
	// synopsys translate_off
	initial
		counter_reg_bit[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[1:1] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[1:1] == 1'b1) 
			if (wire_counter_reg_bit_sload[1:1] == 1'b1) counter_reg_bit[1:1] <= wire_counter_reg_bit_asdata[1:1];
			else  counter_reg_bit[1:1] <= wire_counter_reg_bit_d[1:1];
	// synopsys translate_off
	initial
		counter_reg_bit[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[2:2] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[2:2] == 1'b1) 
			if (wire_counter_reg_bit_sload[2:2] == 1'b1) counter_reg_bit[2:2] <= wire_counter_reg_bit_asdata[2:2];
			else  counter_reg_bit[2:2] <= wire_counter_reg_bit_d[2:2];
	// synopsys translate_off
	initial
		counter_reg_bit[3:3] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[3:3] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[3:3] == 1'b1) 
			if (wire_counter_reg_bit_sload[3:3] == 1'b1) counter_reg_bit[3:3] <= wire_counter_reg_bit_asdata[3:3];
			else  counter_reg_bit[3:3] <= wire_counter_reg_bit_d[3:3];
	// synopsys translate_off
	initial
		counter_reg_bit[4:4] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[4:4] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[4:4] == 1'b1) 
			if (wire_counter_reg_bit_sload[4:4] == 1'b1) counter_reg_bit[4:4] <= wire_counter_reg_bit_asdata[4:4];
			else  counter_reg_bit[4:4] <= wire_counter_reg_bit_d[4:4];
	assign
		wire_counter_reg_bit_asdata = ({5{(~ sclr)}} & (({5{sset}} & s_val) | ({5{(~ sset)}} & data))),
		wire_counter_reg_bit_d = {wire_counter_comb_bita_4combout[0:0], wire_counter_comb_bita_3combout[0:0], wire_counter_comb_bita_2combout[0:0], wire_counter_comb_bita_1combout[0:0], wire_counter_comb_bita_0combout[0:0]};
	assign
		wire_counter_reg_bit_ena = {5{(clk_en & (((sclr | sset) | sload) | cnt_en))}},
		wire_counter_reg_bit_sload = {5{((sclr | sset) | sload)}};
	assign
		aclr_actual = aclr,
		clk_en = 1'b1,
		cnt_en = 1'b1,
		data = {5{1'b0}},
		external_cin = 1'b1,
		q = safe_q,
		s_val = {5{1'b1}},
		safe_q = counter_reg_bit,
		sclr = 1'b0,
		sload = 1'b0,
		sset = 1'b0,
		updown_dir = 1'b1;
endmodule //lvds_rx_x2_m10_0002_cntr_7ta


//lpm_counter CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" lpm_port_updown="PORT_UNUSED" lpm_width=3 aclr cin clock q
//VERSION_BEGIN 14.1 cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_lpm_counter 2014:12:03:18:04:04:SJ cbx_lpm_decode 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ  VERSION_END

//synthesis_resources = lut 3 reg 3 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lvds_rx_x2_m10_0002_cntr_v7b
	( 
	aclr,
	cin,
	clock,
	q) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   cin;
	input   clock;
	output   [2:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
	tri1   cin;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]   wire_counter_comb_bita_0combout;
	wire  [0:0]   wire_counter_comb_bita_1combout;
	wire  [0:0]   wire_counter_comb_bita_2combout;
	wire  [0:0]   wire_counter_comb_bita_0cout;
	wire  [0:0]   wire_counter_comb_bita_1cout;
	wire	[2:0]	wire_counter_reg_bit_d;
	wire	[2:0]	wire_counter_reg_bit_asdata;
	reg	[2:0]	counter_reg_bit;
	wire	[2:0]	wire_counter_reg_bit_ena;
	wire	[2:0]	wire_counter_reg_bit_sload;
	wire  aclr_actual;
	wire clk_en;
	wire cnt_en;
	wire [2:0]  data;
	wire  external_cin;
	wire  [2:0]  s_val;
	wire  [2:0]  safe_q;
	wire sclr;
	wire sload;
	wire sset;
	wire  updown_dir;

	fiftyfivenm_lcell_comb   counter_comb_bita_0
	( 
	.cin(external_cin),
	.combout(wire_counter_comb_bita_0combout[0:0]),
	.cout(wire_counter_comb_bita_0cout[0:0]),
	.dataa(counter_reg_bit[0]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_0.lut_mask = 16'h5A90,
		counter_comb_bita_0.sum_lutc_input = "cin",
		counter_comb_bita_0.lpm_type = "fiftyfivenm_lcell_comb";
	fiftyfivenm_lcell_comb   counter_comb_bita_1
	( 
	.cin(wire_counter_comb_bita_0cout[0:0]),
	.combout(wire_counter_comb_bita_1combout[0:0]),
	.cout(wire_counter_comb_bita_1cout[0:0]),
	.dataa(counter_reg_bit[1]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_1.lut_mask = 16'h5A90,
		counter_comb_bita_1.sum_lutc_input = "cin",
		counter_comb_bita_1.lpm_type = "fiftyfivenm_lcell_comb";
	fiftyfivenm_lcell_comb   counter_comb_bita_2
	( 
	.cin(wire_counter_comb_bita_1cout[0:0]),
	.combout(wire_counter_comb_bita_2combout[0:0]),
	.cout(),
	.dataa(counter_reg_bit[2]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_2.lut_mask = 16'h5A90,
		counter_comb_bita_2.sum_lutc_input = "cin",
		counter_comb_bita_2.lpm_type = "fiftyfivenm_lcell_comb";
	// synopsys translate_off
	initial
		counter_reg_bit[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[0:0] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[0:0] == 1'b1) 
			if (wire_counter_reg_bit_sload[0:0] == 1'b1) counter_reg_bit[0:0] <= wire_counter_reg_bit_asdata[0:0];
			else  counter_reg_bit[0:0] <= wire_counter_reg_bit_d[0:0];
	// synopsys translate_off
	initial
		counter_reg_bit[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[1:1] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[1:1] == 1'b1) 
			if (wire_counter_reg_bit_sload[1:1] == 1'b1) counter_reg_bit[1:1] <= wire_counter_reg_bit_asdata[1:1];
			else  counter_reg_bit[1:1] <= wire_counter_reg_bit_d[1:1];
	// synopsys translate_off
	initial
		counter_reg_bit[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit[2:2] <= 1'b0;
		else if  (wire_counter_reg_bit_ena[2:2] == 1'b1) 
			if (wire_counter_reg_bit_sload[2:2] == 1'b1) counter_reg_bit[2:2] <= wire_counter_reg_bit_asdata[2:2];
			else  counter_reg_bit[2:2] <= wire_counter_reg_bit_d[2:2];
	assign
		wire_counter_reg_bit_asdata = ({3{(~ sclr)}} & (({3{sset}} & s_val) | ({3{(~ sset)}} & data))),
		wire_counter_reg_bit_d = {wire_counter_comb_bita_2combout[0:0], wire_counter_comb_bita_1combout[0:0], wire_counter_comb_bita_0combout[0:0]};
	assign
		wire_counter_reg_bit_ena = {3{(clk_en & (((sclr | sset) | sload) | cnt_en))}},
		wire_counter_reg_bit_sload = {3{((sclr | sset) | sload)}};
	assign
		aclr_actual = aclr,
		clk_en = 1'b1,
		cnt_en = 1'b1,
		data = {3{1'b0}},
		external_cin = cin,
		q = safe_q,
		s_val = {3{1'b1}},
		safe_q = counter_reg_bit,
		sclr = 1'b0,
		sload = 1'b0,
		sset = 1'b0,
		updown_dir = 1'b1;
endmodule //lvds_rx_x2_m10_0002_cntr_v7b


//lpm_counter CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" lpm_port_updown="PORT_UNUSED" lpm_width=1 aclr clock cout q
//VERSION_BEGIN 14.1 cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_lpm_counter 2014:12:03:18:04:04:SJ cbx_lpm_decode 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ  VERSION_END

//synthesis_resources = lut 1 reg 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lvds_rx_x2_m10_0002_cntr_ubb
	( 
	aclr,
	clock,
	cout,
	q) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clock;
	output   cout;
	output   [0:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]   wire_counter_comb_bita_0combout;
	wire  [0:0]   wire_counter_comb_bita_0cout;
	reg	[0:0]	counter_reg_bit;
	wire	wire_counter_reg_bit_ena;
	wire	wire_counter_reg_bit_sload;
	wire  aclr_actual;
	wire clk_en;
	wire cnt_en;
	wire  cout_actual;
	wire [0:0]  data;
	wire  external_cin;
	wire  [0:0]  s_val;
	wire  [0:0]  safe_q;
	wire sclr;
	wire sload;
	wire sset;
	wire  time_to_clear;
	wire  updown_dir;

	fiftyfivenm_lcell_comb   counter_comb_bita_0
	( 
	.cin(external_cin),
	.combout(wire_counter_comb_bita_0combout[0:0]),
	.cout(wire_counter_comb_bita_0cout[0:0]),
	.dataa(counter_reg_bit[0]),
	.datab(updown_dir),
	.datad(1'b1),
	.datac(1'b0)
	);
	defparam
		counter_comb_bita_0.lut_mask = 16'h5A90,
		counter_comb_bita_0.sum_lutc_input = "cin",
		counter_comb_bita_0.lpm_type = "fiftyfivenm_lcell_comb";
	// synopsys translate_off
	initial
		counter_reg_bit = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr_actual)
		if (aclr_actual == 1'b1) counter_reg_bit <= 1'b0;
		else if  (wire_counter_reg_bit_ena == 1'b1) 
			if (wire_counter_reg_bit_sload == 1'b1) counter_reg_bit <= ((~ sclr) & ((sset & s_val) | ((~ sset) & data)));
			else  counter_reg_bit <= {wire_counter_comb_bita_0combout};
	assign
		wire_counter_reg_bit_ena = (clk_en & (((sclr | sset) | sload) | cnt_en)),
		wire_counter_reg_bit_sload = ((sclr | sset) | sload);
	assign
		aclr_actual = aclr,
		clk_en = 1'b1,
		cnt_en = 1'b1,
		cout = cout_actual,
		cout_actual = (wire_counter_comb_bita_0cout | (time_to_clear & updown_dir)),
		data = 1'b0,
		external_cin = 1'b1,
		q = safe_q,
		s_val = 1'b1,
		safe_q = counter_reg_bit,
		sclr = 1'b0,
		sload = 1'b0,
		sset = 1'b0,
		time_to_clear = 1'b0,
		updown_dir = 1'b1;
endmodule //lvds_rx_x2_m10_0002_cntr_ubb


//lpm_mux CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" LPM_SIZE=5 LPM_WIDTH=1 LPM_WIDTHS=3 data result sel
//VERSION_BEGIN 14.1 cbx_lpm_mux 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ  VERSION_END

//synthesis_resources = lut 3 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lvds_rx_x2_m10_0002_mux_p2a
	( 
	data,
	result,
	sel) /* synthesis synthesis_clearbox=1 */;
	input   [4:0]  data;
	output   [0:0]  result;
	input   [2:0]  sel;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [4:0]  data;
	tri0   [2:0]  sel;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [4:0]  muxlut_data0w;
	wire  muxlut_result0w;
	wire  [2:0]  muxlut_select0w;
	wire  [0:0]  result_node;
	wire  [2:0]  sel_ffs_wire;
	wire  [2:0]  sel_node;
	wire  [3:0]  w380w;
	wire  [1:0]  w382w;
	wire  [0:0]  w405w;
	wire  [1:0]  w_mux_outputs378w;

	assign
		muxlut_data0w = {data[4:0]},
		muxlut_result0w = ((w_mux_outputs378w[0] & (~ w405w[0])) | (w_mux_outputs378w[1] & w405w[0])),
		muxlut_select0w = sel_node,
		result = result_node,
		result_node = {muxlut_result0w},
		sel_ffs_wire = {sel[2:0]},
		sel_node = {sel_ffs_wire[2], sel[1:0]},
		w380w = muxlut_data0w[3:0],
		w382w = muxlut_select0w[1:0],
		w405w = muxlut_select0w[2],
		w_mux_outputs378w = {muxlut_data0w[4], ((((~ w382w[1]) | (w382w[0] & w380w[3])) | ((~ w382w[0]) & w380w[2])) & ((w382w[1] | (w382w[0] & w380w[1])) | ((~ w382w[0]) & w380w[0])))};
endmodule //lvds_rx_x2_m10_0002_mux_p2a

//synthesis_resources = fiftyfivenm_pll 1 lut 27 M9K 1 reg 86 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"AUTO_SHIFT_REGISTER_RECOGNITION=OFF;SUPPRESS_DA_RULE_INTERNAL=C104;{-to lvds_rx_pll} AUTO_MERGE_PLLS=ON"} *)
module  lvds_rx_x2_m10_0002
	( 
	pll_areset,
	rx_cda_reset,
	rx_channel_data_align,
	rx_data_align,
	rx_data_align_reset,
	rx_in,
	rx_inclock,
	rx_locked,
	rx_out,
	rx_outclock) /* synthesis synthesis_clearbox=1 */;
	input   pll_areset;
	input   [1:0]  rx_cda_reset;
	input   [1:0]  rx_channel_data_align;
	input   rx_data_align;
	input   rx_data_align_reset;
	input   [1:0]  rx_in;
	input   rx_inclock;
	output   rx_locked;
	output   [9:0]  rx_out;
	output   rx_outclock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   pll_areset;
	tri0   [1:0]  rx_cda_reset;
	tri0   [1:0]  rx_channel_data_align;
	tri0   rx_data_align;
	tri0   rx_data_align_reset;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [1:0]   wire_ddio_in_dataout_h;
	wire  [1:0]   wire_ddio_in_dataout_l;
	wire  [9:0]   wire_ram_buffer_q_b;
	reg	[1:0]	cda_h_shiftreg11a;
	reg	[1:0]	cda_h_shiftreg5a;
	reg	[1:0]	cda_l_shiftreg12a;
	reg	[1:0]	cda_l_shiftreg6a;
	reg	[4:0]	h_shiftreg10a;
	reg	[4:0]	h_shiftreg4a;
	reg	[1:0]	int_bitslip_reg;
	reg	[4:0]	l_shiftreg3a;
	reg	[4:0]	l_shiftreg9a;
	(* ALTERA_ATTRIBUTE = {"SUPPRESS_DA_RULE_INTERNAL=D103"} *)
	reg	pll_lock_sync;
	reg	[9:0]	rx_reg;
	reg	[19:0]	sync_reg;
	wire  [2:0]   wire_cntr1_q;
	wire  [2:0]   wire_cntr2_q;
	wire  [4:0]   wire_rd_cntr_q;
	wire  [2:0]   wire_wr_cntr_q;
	wire  wire_wrcnt_bit0_cout;
	wire  [0:0]   wire_wrcnt_bit0_q;
	wire  [0:0]   wire_h_mux13a_result;
	wire  [0:0]   wire_h_mux7a_result;
	wire  [0:0]   wire_l_mux14a_result;
	wire  [0:0]   wire_l_mux8a_result;
	wire  [4:0]   wire_lvds_rx_pll_clk;
	wire  wire_lvds_rx_pll_fbout;
	wire  wire_lvds_rx_pll_locked;
	wire  [1:0]  bitslip;
	wire  [5:0]  bitslip_en;
	wire  [1:0]  ddio_dataout_h;
	wire  [1:0]  ddio_dataout_h_int;
	wire  [1:0]  ddio_dataout_l;
	wire  [1:0]  ddio_dataout_l_int;
	wire  fast_clock;
	wire  [1:0]  int_bitslip;
	wire  read_clock;
	wire  [19:0]  rx_out_wire;
	wire  slow_clock;
	wire  w_reset;
	wire  [3:0]  wrcnt;

	lvds_rx_x2_m10_0002_lvds_ddio_in_jka   ddio_in
	( 
	.aclr(w_reset),
	.clock(fast_clock),
	.datain(rx_in),
	.dataout_h(wire_ddio_in_dataout_h),
	.dataout_l(wire_ddio_in_dataout_l));
	lvds_rx_x2_m10_0002_altsyncram_s9o   ram_buffer
	( 
	.address_a(wrcnt),
	.address_b(wire_rd_cntr_q),
	.clock0(slow_clock),
	.clock1(read_clock),
	.data_a({sync_reg[19:15], sync_reg[9:5], sync_reg[14:10], sync_reg[4:0]}),
	.q_b(wire_ram_buffer_q_b),
	.wren_a(1'b1));
	// synopsys translate_off
	initial
		cda_h_shiftreg11a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) cda_h_shiftreg11a <= 2'b0;
		else  cda_h_shiftreg11a <= {cda_h_shiftreg11a[0], ddio_dataout_h[1]};
	// synopsys translate_off
	initial
		cda_h_shiftreg5a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) cda_h_shiftreg5a <= 2'b0;
		else  cda_h_shiftreg5a <= {cda_h_shiftreg5a[0], ddio_dataout_h[0]};
	// synopsys translate_off
	initial
		cda_l_shiftreg12a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) cda_l_shiftreg12a <= 2'b0;
		else  cda_l_shiftreg12a <= {cda_l_shiftreg12a[0], ddio_dataout_l[1]};
	// synopsys translate_off
	initial
		cda_l_shiftreg6a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) cda_l_shiftreg6a <= 2'b0;
		else  cda_l_shiftreg6a <= {cda_l_shiftreg6a[0], ddio_dataout_l[0]};
	// synopsys translate_off
	initial
		h_shiftreg10a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) h_shiftreg10a <= 5'b0;
		else  h_shiftreg10a <= {h_shiftreg10a[3:0], wire_l_mux14a_result};
	// synopsys translate_off
	initial
		h_shiftreg4a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) h_shiftreg4a <= 5'b0;
		else  h_shiftreg4a <= {h_shiftreg4a[3:0], wire_l_mux8a_result};
	// synopsys translate_off
	initial
		int_bitslip_reg = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		  int_bitslip_reg <= int_bitslip;
	// synopsys translate_off
	initial
		l_shiftreg3a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) l_shiftreg3a <= 5'b0;
		else  l_shiftreg3a <= {l_shiftreg3a[3:0], wire_h_mux7a_result};
	// synopsys translate_off
	initial
		l_shiftreg9a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock or  posedge w_reset)
		if (w_reset == 1'b1) l_shiftreg9a <= 5'b0;
		else  l_shiftreg9a <= {l_shiftreg9a[3:0], wire_h_mux13a_result};
	// synopsys translate_off
	initial
		pll_lock_sync = 0;
	// synopsys translate_on
	always @ ( posedge wire_lvds_rx_pll_locked or  posedge pll_areset)
		if (pll_areset == 1'b1) pll_lock_sync <= 1'b0;
		else  pll_lock_sync <= 1'b1;
	// synopsys translate_off
	initial
		rx_reg = 0;
	// synopsys translate_on
	always @ ( posedge read_clock or  posedge w_reset)
		if (w_reset == 1'b1) rx_reg <= 10'b0;
		else  rx_reg <= wire_ram_buffer_q_b;
	// synopsys translate_off
	initial
		sync_reg = 0;
	// synopsys translate_on
	always @ ( posedge read_clock or  posedge w_reset)
		if (w_reset == 1'b1) sync_reg <= 20'b0;
		else  sync_reg <= {rx_out_wire[14:10], rx_out_wire[19:15], rx_out_wire[4:0], rx_out_wire[9:5]};
	lvds_rx_x2_m10_0002_cntr_vrc   cntr1
	( 
	.aclr(rx_cda_reset[0]),
	.clock(fast_clock),
	.cnt_en(bitslip[0]),
	.q(wire_cntr1_q));
	lvds_rx_x2_m10_0002_cntr_vrc   cntr2
	( 
	.aclr(rx_cda_reset[1]),
	.clock(fast_clock),
	.cnt_en(bitslip[1]),
	.q(wire_cntr2_q));
	lvds_rx_x2_m10_0002_cntr_7ta   rd_cntr
	( 
	.aclr(w_reset),
	.clock(read_clock),
	.q(wire_rd_cntr_q));
	lvds_rx_x2_m10_0002_cntr_v7b   wr_cntr
	( 
	.aclr(w_reset),
	.cin((~ wire_wrcnt_bit0_cout)),
	.clock(slow_clock),
	.q(wire_wr_cntr_q));
	lvds_rx_x2_m10_0002_cntr_ubb   wrcnt_bit0
	( 
	.aclr(w_reset),
	.clock(slow_clock),
	.cout(wire_wrcnt_bit0_cout),
	.q(wire_wrcnt_bit0_q));
	lvds_rx_x2_m10_0002_mux_p2a   h_mux13a
	( 
	.data({cda_h_shiftreg11a[1], cda_l_shiftreg12a[1], cda_h_shiftreg11a[0], cda_l_shiftreg12a[0], ddio_dataout_h[1]}),
	.result(wire_h_mux13a_result),
	.sel(bitslip_en[5:3]));
	lvds_rx_x2_m10_0002_mux_p2a   h_mux7a
	( 
	.data({cda_h_shiftreg5a[1], cda_l_shiftreg6a[1], cda_h_shiftreg5a[0], cda_l_shiftreg6a[0], ddio_dataout_h[0]}),
	.result(wire_h_mux7a_result),
	.sel(bitslip_en[2:0]));
	lvds_rx_x2_m10_0002_mux_p2a   l_mux14a
	( 
	.data({cda_l_shiftreg12a[1], cda_h_shiftreg11a[0], cda_l_shiftreg12a[0], ddio_dataout_h[1], ddio_dataout_l[1]}),
	.result(wire_l_mux14a_result),
	.sel(bitslip_en[5:3]));
	lvds_rx_x2_m10_0002_mux_p2a   l_mux8a
	( 
	.data({cda_l_shiftreg6a[1], cda_h_shiftreg5a[0], cda_l_shiftreg6a[0], ddio_dataout_h[0], ddio_dataout_l[0]}),
	.result(wire_l_mux8a_result),
	.sel(bitslip_en[2:0]));
	fiftyfivenm_pll   lvds_rx_pll
	( 
	.activeclock(),
	.areset(pll_areset),
	.clk(wire_lvds_rx_pll_clk),
	.clkbad(),
	.fbin(wire_lvds_rx_pll_fbout),
	.fbout(wire_lvds_rx_pll_fbout),
	.inclk({1'b0, rx_inclock}),
	.locked(wire_lvds_rx_pll_locked),
	.phasedone(),
	.scandataout(),
	.scandone(),
	.vcooverrange(),
	.vcounderrange()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clkswitch(1'b0),
	.configupdate(1'b0),
	.pfdena(1'b1),
	.phasecounterselect({3{1'b0}}),
	.phasestep(1'b0),
	.phaseupdown(1'b0),
	.scanclk(1'b0),
	.scanclkena(1'b1),
	.scandata(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		lvds_rx_pll.clk0_divide_by = 2,
		lvds_rx_pll.clk0_multiply_by = 5,
		lvds_rx_pll.clk0_phase_shift = "-1000",
		lvds_rx_pll.clk1_divide_by = 10,
		lvds_rx_pll.clk1_multiply_by = 5,
		lvds_rx_pll.clk1_phase_shift = "-1000",
		lvds_rx_pll.clk2_divide_by = 10,
		lvds_rx_pll.clk2_multiply_by = 10,
		lvds_rx_pll.clk2_phase_shift = "-1000",
		lvds_rx_pll.inclk0_input_frequency = 10000,
		lvds_rx_pll.operation_mode = "source_synchronous",
		lvds_rx_pll.self_reset_on_loss_lock = "on",
		lvds_rx_pll.lpm_type = "fiftyfivenm_pll";
	assign
		bitslip = ((~ int_bitslip_reg) & int_bitslip),
		bitslip_en = {wire_cntr2_q, wire_cntr1_q},
		ddio_dataout_h = ddio_dataout_h_int,
		ddio_dataout_h_int = wire_ddio_in_dataout_h,
		ddio_dataout_l = ddio_dataout_l_int,
		ddio_dataout_l_int = wire_ddio_in_dataout_l,
		fast_clock = wire_lvds_rx_pll_clk[0],
		int_bitslip = rx_channel_data_align,
		read_clock = wire_lvds_rx_pll_clk[2],
		rx_locked = (wire_lvds_rx_pll_locked & pll_lock_sync),
		rx_out = rx_reg,
		rx_out_wire = {l_shiftreg9a[4], h_shiftreg10a[4], l_shiftreg9a[3], h_shiftreg10a[3], l_shiftreg9a[2], h_shiftreg10a[2], l_shiftreg9a[1], h_shiftreg10a[1], l_shiftreg9a[0], h_shiftreg10a[0], l_shiftreg3a[4], h_shiftreg4a[4], l_shiftreg3a[3], h_shiftreg4a[3], l_shiftreg3a[2], h_shiftreg4a[2], l_shiftreg3a[1], h_shiftreg4a[1], l_shiftreg3a[0], h_shiftreg4a[0]},
		rx_outclock = read_clock,
		slow_clock = wire_lvds_rx_pll_clk[1],
		w_reset = pll_areset,
		wrcnt = {wire_wr_cntr_q, (~ wire_wrcnt_bit0_q)};
endmodule //lvds_rx_x2_m10_0002
//VALID FILE
