// Switch network arbiter
// Wishbone B3 signals compliant 
`include "keep_defines.v"

`ifndef WISHBONE_BRIDGE_MULTIPLE_MASTERS_MULTIPLE_SLAVES_PRESERVE
`define WISHBONE_BRIDGE_MULTIPLE_MASTERS_MULTIPLE_SLAVES_PRESERVE
`endif

`ifdef NUM_MASTERS_6
`undef NUM_MASTERS_6
`endif

`ifdef NUM_MASTERS_5
`undef NUM_MASTERS_5
`endif

`ifdef NUM_MASTERS_4
`undef NUM_MASTERS_4
`endif

`ifdef NUM_MASTERS_3
`undef NUM_MASTERS_3
`endif

`ifdef NUM_MASTERS_2
`undef NUM_MASTERS_2
`endif

`ifdef NUM_MASTERS_1
`undef NUM_MASTERS_1
`endif

`ifdef NUM_SLAVES_7
`undef NUM_SLAVES_7
`endif

`ifdef NUM_SLAVES_6
`undef NUM_SLAVES_6
`endif

`ifdef NUM_SLAVES_5
`undef NUM_SLAVES_5
`endif

`ifdef NUM_SLAVES_4
`undef NUM_SLAVES_4
`endif 

`ifdef NUM_SLAVES_3
`undef NUM_SLAVES_3
`endif

`ifdef NUM_SLAVES_2
`undef NUM_SLAVES_2
`endif

`ifdef NUM_SLAVES_1
`undef NUM_SLAVES_1
`endif

//`define build_suffix_for_wb_multiple_master_and_slave(numslaves,nummasters)  _``nummasters\_masters_``numslaves\_slaves
//
//`define set_masters_define_for_wb_multiple_master_and_slave(nummasters) NUM_MASTERS_``nummasters
//`define set_slaves_define_for_wb_multiple_master_and_slave(numslaves) NUM_SLAVES_``numslaves
//
//`define build_wb_bridge_defines(numslaves,nummasters) \
//            `define NUM_MASTERS_``nummasters  \
//            `define NUM_SLAVES_``numslaves    \
//			`define wb_bridge_name_suffix _``nummasters\_masters_``numslaves\_slaves
//			
//`define unbuild_wb_bridge_defines(numslaves,nummasters) \
//            `undef NUM_MASTERS_``nummasters  \
//            `undef NUM_SLAVES_``numslaves    \
//			`undef wb_bridge_name_suffix

//`define NUM_MASTERS_2
//`define NUM_SLAVES_5
//`define wb_bridge_name_suffix _2_masters_5_slaves
//`define current_wb_bridge_top_module_name            wishbone_bridge_2_masters_5_slaves
//`define current_wb_b3_switch_slave_sel_name          wb_b3_switch_slave_sel_2_masters_5_slaves
//`define current_wb_b3_switch_master_detect_slave_sel wb_b3_switch_master_detect_slave_sel_2_masters_5_slaves
//`define current_wb_b3_switch_slave_out_mux           wb_b3_switch_slave_out_mux_2_masters_5_slaves
//`define current_wb_b3_switch_master_out_mux          wb_b3_switch_master_out_mux_2_masters_5_slaves
//
//`include "generic_define_parametrizeable_master_slave_wb_bridge.v"
//
//`define NUM_MASTERS_2
//`define NUM_SLAVES_5
//`define wb_bridge_name_suffix _2_masters_5_slaves
//`define current_wb_bridge_top_module_name            wishbone_bridge_2_masters_5_slaves
//`define current_wb_b3_switch_slave_sel_name          wb_b3_switch_slave_sel_2_masters_5_slaves
//`define current_wb_b3_switch_master_detect_slave_sel wb_b3_switch_master_detect_slave_sel_2_masters_5_slaves
//`define current_wb_b3_switch_slave_out_mux           wb_b3_switch_slave_out_mux_2_masters_5_slaves
//`define current_wb_b3_switch_master_out_mux          wb_b3_switch_master_out_mux_2_masters_5_slaves
//
//`include "generic_define_parametrizeable_master_slave_wb_bridge.v"

 `include "auto_generated_wb_bridge_invocation.v"
