//altlvds_tx CBX_SINGLE_OUTPUT_FILE="ON" COMMON_RX_TX_PLL="ON" CORECLOCK_DIVIDE_BY=2 DESERIALIZATION_FACTOR=5 DEVICE_FAMILY="MAX 10" IMPLEMENT_IN_LES="ON" INCLOCK_PERIOD=20000 INCLOCK_PHASE_SHIFT=0 NUMBER_OF_CHANNELS=2 OUTCLOCK_DIVIDE_BY=5 OUTCLOCK_DUTY_CYCLE=50 OUTCLOCK_PHASE_SHIFT=0 OUTCLOCK_RESOURCE="AUTO" OUTPUT_DATA_RATE=500 PLL_SELF_RESET_ON_LOSS_LOCK="ON" REGISTERED_INPUT="OFF" USE_EXTERNAL_PLL="OFF" pll_areset tx_coreclock tx_in tx_inclock tx_locked tx_out tx_outclock
//VERSION_BEGIN 14.1 cbx_altaccumulate 2014:12:03:18:04:04:SJ cbx_altclkbuf 2014:12:03:18:04:04:SJ cbx_altddio_in 2014:12:03:18:04:04:SJ cbx_altddio_out 2014:12:03:18:04:04:SJ cbx_altiobuf_bidir 2014:12:03:18:04:04:SJ cbx_altiobuf_in 2014:12:03:18:04:04:SJ cbx_altiobuf_out 2014:12:03:18:04:04:SJ cbx_altlvds_tx 2014:12:03:18:04:04:SJ cbx_altpll 2014:12:03:18:04:04:SJ cbx_altsyncram 2014:12:03:18:04:04:SJ cbx_arriav 2014:12:03:18:04:03:SJ cbx_cyclone 2014:12:03:18:04:04:SJ cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_lpm_counter 2014:12:03:18:04:04:SJ cbx_lpm_decode 2014:12:03:18:04:04:SJ cbx_lpm_mux 2014:12:03:18:04:04:SJ cbx_lpm_shiftreg 2014:12:03:18:04:04:SJ cbx_maxii 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ cbx_stratixiii 2014:12:03:18:04:04:SJ cbx_stratixv 2014:12:03:18:04:04:SJ cbx_util_mgl 2014:12:03:18:04:04:SJ  VERSION_END
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




//altddio_out CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" WIDTH=2 aclr datain_h datain_l dataout outclock
//VERSION_BEGIN 14.1 cbx_altddio_out 2014:12:03:18:04:04:SJ cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_maxii 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ cbx_stratixiii 2014:12:03:18:04:04:SJ cbx_stratixv 2014:12:03:18:04:04:SJ cbx_util_mgl 2014:12:03:18:04:04:SJ  VERSION_END

//synthesis_resources = IO 2 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"ANALYZE_METASTABILITY=OFF;ADV_NETLIST_OPT_ALLOWED=DEFAULT"} *)
module  lvds_tx_x2_m10_0002_ddio_out_n5a
	( 
	aclr,
	datain_h,
	datain_l,
	dataout,
	outclock) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   [1:0]  datain_h;
	input   [1:0]  datain_l;
	output   [1:0]  dataout;
	input   outclock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [1:0]   wire_ddio_outa_datainhi;
	wire  [1:0]   wire_ddio_outa_datainlo;
	wire  [1:0]   wire_ddio_outa_dataout;

	fiftyfivenm_ddio_out   ddio_outa_0
	( 
	.areset(aclr),
	.clkhi(outclock),
	.clklo(outclock),
	.datainhi(wire_ddio_outa_datainhi[0:0]),
	.datainlo(wire_ddio_outa_datainlo[0:0]),
	.dataout(wire_ddio_outa_dataout[0:0]),
	.muxsel(outclock)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clk(1'b0),
	.ena(1'b1),
	.sreset(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1),
	.dffhi(),
	.dfflo()
	// synopsys translate_on
	);
	defparam
		ddio_outa_0.async_mode = "clear",
		ddio_outa_0.power_up = "low",
		ddio_outa_0.sync_mode = "none",
		ddio_outa_0.use_new_clocking_model = "true",
		ddio_outa_0.lpm_type = "fiftyfivenm_ddio_out";
	fiftyfivenm_ddio_out   ddio_outa_1
	( 
	.areset(aclr),
	.clkhi(outclock),
	.clklo(outclock),
	.datainhi(wire_ddio_outa_datainhi[1:1]),
	.datainlo(wire_ddio_outa_datainlo[1:1]),
	.dataout(wire_ddio_outa_dataout[1:1]),
	.muxsel(outclock)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clk(1'b0),
	.ena(1'b1),
	.sreset(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1),
	.dffhi(),
	.dfflo()
	// synopsys translate_on
	);
	defparam
		ddio_outa_1.async_mode = "clear",
		ddio_outa_1.power_up = "low",
		ddio_outa_1.sync_mode = "none",
		ddio_outa_1.use_new_clocking_model = "true",
		ddio_outa_1.lpm_type = "fiftyfivenm_ddio_out";
	assign
		wire_ddio_outa_datainhi = datain_h,
		wire_ddio_outa_datainlo = datain_l;
	assign
		dataout = wire_ddio_outa_dataout;
endmodule //lvds_tx_x2_m10_0002_ddio_out_n5a


//altddio_out CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" WIDTH=1 aclr datain_h datain_l dataout outclock
//VERSION_BEGIN 14.1 cbx_altddio_out 2014:12:03:18:04:04:SJ cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_maxii 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ cbx_stratixiii 2014:12:03:18:04:04:SJ cbx_stratixv 2014:12:03:18:04:04:SJ cbx_util_mgl 2014:12:03:18:04:04:SJ  VERSION_END

//synthesis_resources = IO 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"ANALYZE_METASTABILITY=OFF;ADV_NETLIST_OPT_ALLOWED=DEFAULT"} *)
module  lvds_tx_x2_m10_0002_ddio_out_m5a
	( 
	aclr,
	datain_h,
	datain_l,
	dataout,
	outclock) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   [0:0]  datain_h;
	input   [0:0]  datain_l;
	output   [0:0]  dataout;
	input   outclock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]   wire_ddio_outa_dataout;

	fiftyfivenm_ddio_out   ddio_outa_0
	( 
	.areset(aclr),
	.clkhi(outclock),
	.clklo(outclock),
	.datainhi(datain_h),
	.datainlo(datain_l),
	.dataout(wire_ddio_outa_dataout[0:0]),
	.muxsel(outclock)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clk(1'b0),
	.ena(1'b1),
	.sreset(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devclrn(1'b1),
	.devpor(1'b1),
	.dffhi(),
	.dfflo()
	// synopsys translate_on
	);
	defparam
		ddio_outa_0.async_mode = "clear",
		ddio_outa_0.power_up = "low",
		ddio_outa_0.sync_mode = "none",
		ddio_outa_0.use_new_clocking_model = "true",
		ddio_outa_0.lpm_type = "fiftyfivenm_ddio_out";
	assign
		dataout = wire_ddio_outa_dataout;
endmodule //lvds_tx_x2_m10_0002_ddio_out_m5a


//lpm_compare CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" LPM_WIDTH=3 aeb dataa datab
//VERSION_BEGIN 14.1 cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ  VERSION_END

//synthesis_resources = 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lvds_tx_x2_m10_0002_cmpr_a68
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
endmodule //lvds_tx_x2_m10_0002_cmpr_a68


//lpm_counter CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" lpm_modulus=5 lpm_width=3 aclr clock q updown
//VERSION_BEGIN 14.1 cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_lpm_counter 2014:12:03:18:04:04:SJ cbx_lpm_decode 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ  VERSION_END


//lpm_compare CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="MAX 10" LPM_WIDTH=3 ONE_INPUT_IS_CONSTANT="YES" aeb dataa datab
//VERSION_BEGIN 14.1 cbx_cycloneii 2014:12:03:18:04:04:SJ cbx_lpm_add_sub 2014:12:03:18:04:04:SJ cbx_lpm_compare 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ cbx_stratix 2014:12:03:18:04:04:SJ cbx_stratixii 2014:12:03:18:04:04:SJ  VERSION_END

//synthesis_resources = 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lvds_tx_x2_m10_0002_cmpr_hsa
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
endmodule //lvds_tx_x2_m10_0002_cmpr_hsa

//synthesis_resources = lut 3 reg 3 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lvds_tx_x2_m10_0002_cntr_3v9
	( 
	aclr,
	clock,
	q,
	updown) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clock;
	output   [2:0]  q;
	input   updown;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
	tri1   updown;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [0:0]   wire_counter_comb_bita_0combout;
	wire  [0:0]   wire_counter_comb_bita_1combout;
	wire  [0:0]   wire_counter_comb_bita_2combout;
	wire  [0:0]   wire_counter_comb_bita_0cout;
	wire  [0:0]   wire_counter_comb_bita_1cout;
	wire  [0:0]   wire_counter_comb_bita_2cout;
	wire	[2:0]	wire_counter_reg_bit_d;
	wire	[2:0]	wire_counter_reg_bit_asdata;
	reg	[2:0]	counter_reg_bit;
	wire	[2:0]	wire_counter_reg_bit_ena;
	wire	[2:0]	wire_counter_reg_bit_sload;
	wire  wire_cmpr27_aeb;
	wire  aclr_actual;
	wire clk_en;
	wire cnt_en;
	wire  compare_result;
	wire  cout_actual;
	wire [2:0]  data;
	wire  external_cin;
	wire  [2:0]  modulus_bus;
	wire  modulus_trigger;
	wire  [2:0]  s_val;
	wire  [2:0]  safe_q;
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
		wire_counter_reg_bit_asdata = ({3{(~ sclr)}} & (({3{sset}} & s_val) | ({3{(~ sset)}} & (({3{sload}} & data) | (({3{(~ sload)}} & modulus_bus) & {3{(~ updown_dir)}}))))),
		wire_counter_reg_bit_d = {wire_counter_comb_bita_2combout[0:0], wire_counter_comb_bita_1combout[0:0], wire_counter_comb_bita_0combout[0:0]};
	assign
		wire_counter_reg_bit_ena = {3{(clk_en & (((sclr | sset) | sload) | cnt_en))}},
		wire_counter_reg_bit_sload = {3{(((sclr | sset) | sload) | modulus_trigger)}};
	lvds_tx_x2_m10_0002_cmpr_hsa   cmpr27
	( 
	.aeb(wire_cmpr27_aeb),
	.dataa(safe_q),
	.datab(modulus_bus));
	assign
		aclr_actual = aclr,
		clk_en = 1'b1,
		cnt_en = 1'b1,
		compare_result = wire_cmpr27_aeb,
		cout_actual = (wire_counter_comb_bita_2cout[0:0] | (time_to_clear & updown_dir)),
		data = {3{1'b0}},
		external_cin = 1'b1,
		modulus_bus = 3'b100,
		modulus_trigger = cout_actual,
		q = safe_q,
		s_val = {3{1'b1}},
		safe_q = counter_reg_bit,
		sclr = 1'b0,
		sload = 1'b0,
		sset = 1'b0,
		time_to_clear = compare_result,
		updown_dir = updown;
endmodule //lvds_tx_x2_m10_0002_cntr_3v9


//lpm_shiftreg CBX_SINGLE_OUTPUT_FILE="ON" LPM_DIRECTION="RIGHT" LPM_WIDTH=5 aclr clock data load shiftin shiftout
//VERSION_BEGIN 14.1 cbx_lpm_shiftreg 2014:12:03:18:04:04:SJ cbx_mgl 2014:12:03:18:06:09:SJ  VERSION_END

//synthesis_resources = reg 5 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lvds_tx_x2_m10_0002_shift_reg_4ia
	( 
	aclr,
	clock,
	data,
	load,
	shiftin,
	shiftout) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clock;
	input   [4:0]  data;
	input   load;
	input   shiftin;
	output   shiftout;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   aclr;
	tri0   [4:0]  data;
	tri0   load;
	tri1   shiftin;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	reg	[4:0]	shift_reg;
	wire  [4:0]  shift_node;

	// synopsys translate_off
	initial
		shift_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge aclr)
		if (aclr == 1'b1) shift_reg <= 5'b0;
		else
			if (load == 1'b1) shift_reg <= data;
			else  shift_reg <= shift_node;
	assign
		shift_node = {shiftin, shift_reg[4:1]},
		shiftout = shift_reg[0];
endmodule //lvds_tx_x2_m10_0002_shift_reg_4ia

//synthesis_resources = fiftyfivenm_pll 1 IO 3 lut 6 reg 107 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"SUPPRESS_DA_RULE_INTERNAL=C104;{-to lvds_tx_pll} AUTO_MERGE_PLLS=ON"} *)
module  lvds_tx_x2_m10_0002
	( 
	pll_areset,
	tx_coreclock,
	tx_in,
	tx_inclock,
	tx_locked,
	tx_out,
	tx_outclock) /* synthesis synthesis_clearbox=1 */;
	input   pll_areset;
	output   tx_coreclock;
	input   [9:0]  tx_in;
	input   tx_inclock;
	output   tx_locked;
	output   [1:0]  tx_out;
	output   tx_outclock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   pll_areset;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  [1:0]   wire_ddio_out_dataout;
	wire  [0:0]   wire_outclock_ddio_dataout;
	reg	dffe11;
	reg	[2:0]	dffe14a;
	reg	[2:0]	dffe15a;
	reg	[2:0]	dffe16a;
	reg	[2:0]	dffe17a;
	reg	[2:0]	dffe18a;
	reg	[2:0]	dffe19a;
	reg	dffe22;
	reg	[2:0]	dffe3a;
	reg	[2:0]	dffe4a;
	reg	[2:0]	dffe5a;
	reg	[2:0]	dffe6a;
	reg	[2:0]	dffe7a;
	reg	[2:0]	dffe8a;
	reg	[9:0]	h_sync_a;
	reg	[9:0]	h_sync_b;
	reg	[9:0]	l_sync_a;
	(* ALTERA_ATTRIBUTE = {"SUPPRESS_DA_RULE_INTERNAL=D103"} *)
	reg	pll_lock_sync;
	reg	sync_dffe12a;
	reg	sync_dffe1a;
	wire  wire_cmpr10_aeb;
	wire  wire_cmpr20_aeb;
	wire  wire_cmpr21_aeb;
	wire  wire_cmpr9_aeb;
	wire  [2:0]   wire_cntr13_q;
	wire  [2:0]   wire_cntr2_q;
	wire  wire_outclk_shift_h_shiftout;
	wire  wire_outclk_shift_l_shiftout;
	wire  wire_shift_reg23_shiftout;
	wire  wire_shift_reg24_shiftout;
	wire  wire_shift_reg25_shiftout;
	wire  wire_shift_reg26_shiftout;
	wire  [4:0]   wire_lvds_tx_pll_clk;
	wire  wire_lvds_tx_pll_fbout;
	wire  wire_lvds_tx_pll_locked;
	wire  fast_clock;
	wire  [1:0]  h_input;
	wire  [1:0]  l_input;
	wire  load_signal;
	wire  out_clock;
	wire  outclk_load_signal;
	wire  slow_clock;
	wire  [19:0]  tx_align_wire;
	wire  [19:0]  tx_in_wire;
	wire  w_reset;

	lvds_tx_x2_m10_0002_ddio_out_n5a   ddio_out
	( 
	.aclr(w_reset),
	.datain_h(l_input),
	.datain_l(h_input),
	.dataout(wire_ddio_out_dataout),
	.outclock(fast_clock));
	lvds_tx_x2_m10_0002_ddio_out_m5a   outclock_ddio
	( 
	.aclr(w_reset),
	.datain_h(wire_outclk_shift_h_shiftout),
	.datain_l(wire_outclk_shift_l_shiftout),
	.dataout(wire_outclock_ddio_dataout),
	.outclock(out_clock));
	// synopsys translate_off
	initial
		dffe11 = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		  dffe11 <= ((wire_cmpr9_aeb & sync_dffe1a) | (wire_cmpr10_aeb & (~ sync_dffe1a)));
	// synopsys translate_off
	initial
		dffe14a = 0;
	// synopsys translate_on
	always @ ( posedge out_clock)
		if (sync_dffe12a == 1'b1)   dffe14a <= wire_cntr13_q;
	// synopsys translate_off
	initial
		dffe15a = 0;
	// synopsys translate_on
	always @ ( posedge out_clock)
		if (sync_dffe12a == 1'b0)   dffe15a <= wire_cntr13_q;
	// synopsys translate_off
	initial
		dffe16a = 0;
	// synopsys translate_on
	always @ ( posedge out_clock)
		if (sync_dffe12a == 1'b1)   dffe16a <= dffe14a;
	// synopsys translate_off
	initial
		dffe17a = 0;
	// synopsys translate_on
	always @ ( posedge out_clock)
		if (sync_dffe12a == 1'b0)   dffe17a <= dffe15a;
	// synopsys translate_off
	initial
		dffe18a = 0;
	// synopsys translate_on
	always @ ( posedge out_clock)
		if (sync_dffe12a == 1'b0)   dffe18a <= dffe16a;
	// synopsys translate_off
	initial
		dffe19a = 0;
	// synopsys translate_on
	always @ ( posedge out_clock)
		if (sync_dffe12a == 1'b1)   dffe19a <= dffe17a;
	// synopsys translate_off
	initial
		dffe22 = 0;
	// synopsys translate_on
	always @ ( posedge out_clock)
		  dffe22 <= ((wire_cmpr20_aeb & sync_dffe12a) | (wire_cmpr21_aeb & (~ sync_dffe12a)));
	// synopsys translate_off
	initial
		dffe3a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		if (sync_dffe1a == 1'b1)   dffe3a <= wire_cntr2_q;
	// synopsys translate_off
	initial
		dffe4a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		if (sync_dffe1a == 1'b0)   dffe4a <= wire_cntr2_q;
	// synopsys translate_off
	initial
		dffe5a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		if (sync_dffe1a == 1'b1)   dffe5a <= dffe3a;
	// synopsys translate_off
	initial
		dffe6a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		if (sync_dffe1a == 1'b0)   dffe6a <= dffe4a;
	// synopsys translate_off
	initial
		dffe7a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		if (sync_dffe1a == 1'b0)   dffe7a <= dffe5a;
	// synopsys translate_off
	initial
		dffe8a = 0;
	// synopsys translate_on
	always @ ( posedge fast_clock)
		if (sync_dffe1a == 1'b1)   dffe8a <= dffe6a;
	// synopsys translate_off
	initial
		h_sync_a = 0;
	// synopsys translate_on
	always @ ( posedge slow_clock or  posedge w_reset)
		if (w_reset == 1'b1) h_sync_a <= 10'b0;
		else  h_sync_a <= tx_in;
	// synopsys translate_off
	initial
		h_sync_b = 0;
	// synopsys translate_on
	always @ ( negedge slow_clock or  posedge w_reset)
		if (w_reset == 1'b1) h_sync_b <= 10'b0;
		else  h_sync_b <= h_sync_a;
	// synopsys translate_off
	initial
		l_sync_a = 0;
	// synopsys translate_on
	always @ ( negedge slow_clock or  posedge w_reset)
		if (w_reset == 1'b1) l_sync_a <= 10'b0;
		else  l_sync_a <= tx_in;
	// synopsys translate_off
	initial
		pll_lock_sync = 0;
	// synopsys translate_on
	always @ ( posedge wire_lvds_tx_pll_locked or  posedge pll_areset)
		if (pll_areset == 1'b1) pll_lock_sync <= 1'b0;
		else  pll_lock_sync <= 1'b1;
	// synopsys translate_off
	initial
		sync_dffe12a = 0;
	// synopsys translate_on
	always @ ( posedge slow_clock or  posedge w_reset)
		if (w_reset == 1'b1) sync_dffe12a <= 1'b0;
		else  sync_dffe12a <= (~ sync_dffe12a);
	// synopsys translate_off
	initial
		sync_dffe1a = 0;
	// synopsys translate_on
	always @ ( posedge slow_clock or  posedge w_reset)
		if (w_reset == 1'b1) sync_dffe1a <= 1'b0;
		else  sync_dffe1a <= (~ sync_dffe1a);
	lvds_tx_x2_m10_0002_cmpr_a68   cmpr10
	( 
	.aeb(wire_cmpr10_aeb),
	.dataa(dffe4a),
	.datab(dffe8a));
	lvds_tx_x2_m10_0002_cmpr_a68   cmpr20
	( 
	.aeb(wire_cmpr20_aeb),
	.dataa(dffe14a),
	.datab(dffe18a));
	lvds_tx_x2_m10_0002_cmpr_a68   cmpr21
	( 
	.aeb(wire_cmpr21_aeb),
	.dataa(dffe15a),
	.datab(dffe19a));
	lvds_tx_x2_m10_0002_cmpr_a68   cmpr9
	( 
	.aeb(wire_cmpr9_aeb),
	.dataa(dffe3a),
	.datab(dffe7a));
	lvds_tx_x2_m10_0002_cntr_3v9   cntr13
	( 
	.aclr(w_reset),
	.clock(out_clock),
	.q(wire_cntr13_q),
	.updown(sync_dffe12a));
	lvds_tx_x2_m10_0002_cntr_3v9   cntr2
	( 
	.aclr(w_reset),
	.clock(fast_clock),
	.q(wire_cntr2_q),
	.updown(sync_dffe1a));
	lvds_tx_x2_m10_0002_shift_reg_4ia   outclk_shift_h
	( 
	.aclr(w_reset),
	.clock(out_clock),
	.data(5'b11000),
	.load(outclk_load_signal),
	.shiftin(1'b0),
	.shiftout(wire_outclk_shift_h_shiftout));
	lvds_tx_x2_m10_0002_shift_reg_4ia   outclk_shift_l
	( 
	.aclr(w_reset),
	.clock(out_clock),
	.data(5'b11100),
	.load(outclk_load_signal),
	.shiftin(1'b0),
	.shiftout(wire_outclk_shift_l_shiftout));
	lvds_tx_x2_m10_0002_shift_reg_4ia   shift_reg23
	( 
	.aclr(w_reset),
	.clock(fast_clock),
	.data({tx_in_wire[1], tx_in_wire[3], tx_in_wire[5], tx_in_wire[7], tx_in_wire[9]}),
	.load(load_signal),
	.shiftin(1'b0),
	.shiftout(wire_shift_reg23_shiftout));
	lvds_tx_x2_m10_0002_shift_reg_4ia   shift_reg24
	( 
	.aclr(w_reset),
	.clock(fast_clock),
	.data({tx_in_wire[0], tx_in_wire[2], tx_in_wire[4], tx_in_wire[6], tx_in_wire[8]}),
	.load(load_signal),
	.shiftin(1'b0),
	.shiftout(wire_shift_reg24_shiftout));
	lvds_tx_x2_m10_0002_shift_reg_4ia   shift_reg25
	( 
	.aclr(w_reset),
	.clock(fast_clock),
	.data({tx_in_wire[11], tx_in_wire[13], tx_in_wire[15], tx_in_wire[17], tx_in_wire[19]}),
	.load(load_signal),
	.shiftin(1'b0),
	.shiftout(wire_shift_reg25_shiftout));
	lvds_tx_x2_m10_0002_shift_reg_4ia   shift_reg26
	( 
	.aclr(w_reset),
	.clock(fast_clock),
	.data({tx_in_wire[10], tx_in_wire[12], tx_in_wire[14], tx_in_wire[16], tx_in_wire[18]}),
	.load(load_signal),
	.shiftin(1'b0),
	.shiftout(wire_shift_reg26_shiftout));
	fiftyfivenm_pll   lvds_tx_pll
	( 
	.activeclock(),
	.areset(pll_areset),
	.clk(wire_lvds_tx_pll_clk),
	.clkbad(),
	.fbin(wire_lvds_tx_pll_fbout),
	.fbout(wire_lvds_tx_pll_fbout),
	.inclk({1'b0, tx_inclock}),
	.locked(wire_lvds_tx_pll_locked),
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
		lvds_tx_pll.clk0_divide_by = 1,
		lvds_tx_pll.clk0_multiply_by = 5,
		lvds_tx_pll.clk0_phase_shift = "-1000",
		lvds_tx_pll.clk1_divide_by = 5,
		lvds_tx_pll.clk1_multiply_by = 5,
		lvds_tx_pll.clk1_phase_shift = "-1000",
		lvds_tx_pll.inclk0_input_frequency = 20000,
		lvds_tx_pll.operation_mode = "normal",
		lvds_tx_pll.self_reset_on_loss_lock = "on",
		lvds_tx_pll.lpm_type = "fiftyfivenm_pll";
	assign
		fast_clock = wire_lvds_tx_pll_clk[0],
		h_input = {wire_shift_reg26_shiftout, wire_shift_reg24_shiftout},
		l_input = {wire_shift_reg25_shiftout, wire_shift_reg23_shiftout},
		load_signal = dffe11,
		out_clock = wire_lvds_tx_pll_clk[0],
		outclk_load_signal = dffe22,
		slow_clock = wire_lvds_tx_pll_clk[1],
		tx_align_wire = {h_sync_b[9:5], l_sync_a[9:5], h_sync_b[4:0], l_sync_a[4:0]},
		tx_coreclock = slow_clock,
		tx_in_wire = tx_align_wire,
		tx_locked = (wire_lvds_tx_pll_locked & pll_lock_sync),
		tx_out = wire_ddio_out_dataout,
		tx_outclock = wire_outclock_ddio_dataout,
		w_reset = pll_areset;
endmodule //lvds_tx_x2_m10_0002
//VALID FILE
