// Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, the Altera Quartus II License Agreement,
// the Altera MegaCore Function License Agreement, or other 
// applicable license agreement, including, without limitation, 
// that your use is for the sole purpose of programming logic 
// devices manufactured by Altera and sold by Altera or its 
// authorized distributors.  Please refer to the applicable 
// agreement for further details.

`timescale 1 ps/ 1 ps

// Unfortunately, SV interfaces are not supported by Qsys, so this wrapper
//   converts the various interfaces to standard I/O ports.
module avs_to_packets_wrapper #(
  parameter P_AWIDTH = 24,
  parameter P_MAXBURSTWIDTH = 3,
  parameter P_FIFOSIZELOGN = 2)(
  input         clk,
  input         reset,
  output        avs_readdatavalid,
  output        avs_waitrequest,
  output [ 7:0] avs_readdata,
  input  [ 7:0] avs_writedata,
  input  [P_AWIDTH-1:0] avs_address,
  input  [P_MAXBURSTWIDTH-1:0] avs_burstcount,
  input         avs_write,
  input         avs_read,
  output [7:0] avst_out_data,
  output        avst_out_sop,
  output        avst_out_eop,
  output        avst_out_valid,
  input         avst_out_ready,
  output        avst_in_ready,
  input  [7:0] avst_in_data,
  input         avst_in_sop,
  input         avst_in_eop,
  input         avst_in_valid
);

  avmm_if #(.ADDR_W(P_AWIDTH),.BURST_W(P_MAXBURSTWIDTH)) wrap_avm ();
  avst_if wrap_avst_in ();
  avst_if wrap_avst_out ();

  assign wrap_avm.clk        = clk;
  assign wrap_avst_in.clk    = clk;
  assign wrap_avst_out.clk   = clk;
  assign wrap_avm.reset      = reset;
  assign wrap_avst_in.reset  = reset;
  assign wrap_avst_out.reset = reset;
  assign avs_readdatavalid   = wrap_avm.readdatavalid;
  assign avs_waitrequest     = wrap_avm.waitrequest;
  assign avs_readdata        = wrap_avm.readdata;
  assign wrap_avm.writedata  = avs_writedata;
  assign wrap_avm.address    = avs_address;
  assign wrap_avm.burstcount = avs_burstcount;
  assign wrap_avm.write      = avs_write;
  assign wrap_avm.read       = avs_read;
  assign avst_out_data       = wrap_avst_out.data;
  assign avst_out_sop        = wrap_avst_out.sop;
  assign avst_out_eop        = wrap_avst_out.eop;
  assign avst_out_valid      = wrap_avst_out.valid;
  assign wrap_avst_out.ready = avst_out_ready;
  assign avst_in_ready       = wrap_avst_in.ready;
  assign wrap_avst_in.data   = avst_in_data;
  assign wrap_avst_in.sop    = avst_in_sop;
  assign wrap_avst_in.eop    = avst_in_eop;
  assign wrap_avst_in.valid  = avst_in_valid;

  avs_to_packets #(
    .DATA_W (8),
    .ADDR_W (P_AWIDTH),
    .BURST_W (P_MAXBURSTWIDTH),
    .P_FIFOSIZELOGN (P_FIFOSIZELOGN)
  )  U_A2P (
    .avs(wrap_avm.slave),
    .avst_out(wrap_avst_out.source),
    .avst_in(wrap_avst_in.sink) 
  );

endmodule
