// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`default_nettype none
`timescale 1ns / 1ps

module avmm_to_packets_tb (
  output logic         clk_50m,
  output logic         clk_160m,
  output logic         reset,
  input  wire          avmm_readdatavalid,
  input  wire          avmm_waitrequest,
  input  wire   [ 7:0] avmm_readdata,
  output logic  [ 7:0] avmm_writedata,
  output logic  [23:0] avmm_address,
  output logic  [10:0] avmm_burstcount,
  output logic  [ 0:0] avmm_byteenable,
  output logic         avmm_write,
  output logic         avmm_read
);
  logic clk;

  `include "avmm_sim_package.h"

  initial clk = 0; 
  always #3.125 clk = ~clk; 

  initial clk_50m = 0; 
  always #10 clk_50m = ~clk_50m; 

  assign clk_160m = clk;

  initial
  begin
    reset = 1;
    avmm_read = 0;
    avmm_write = 0;
    avmm_byteenable = '1;
    avmm_burstcount = 1;
    avmm_address = 0;
    avmm_writedata = 0;
    #155;
    reset = 0;
    #2000;
    AVMM_Write(.waddr(24'h000000), .wdata(8'hFA));
    AVMM_Write(.waddr(24'h000044), .wdata(8'hAF));
    AVMM_Read (.raddr(24'h000000), .rdata(8'hFA));
      fork AVMM_CheckRead (.raddr(24'h000000), .rdata(8'hFA)); join_none
    AVMM_Write(.waddr(24'h00004c), .wdata(8'h01));
    AVMM_Write(.waddr(24'h000050), .wdata(8'h02));
//    AVMM_Write(24'h000044, 8'hAF, avm_address, avm_write, avm_writedata, clk, avmm_waitrequest);
//    AVMM_Read(24'h000042, 8'hFA, avm_address, avm_read, clk, avmm_readdata, avmm_readdatavalid);
  end

endmodule : avmm_to_packets_tb
