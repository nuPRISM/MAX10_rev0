// (C) 2001-2015 Altera Corporation. All rights reserved.
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

// Module: aligner_tbstub
//
// Author: Chris Esser
//
// Description: This module serializes and deserializes the streaming
//   interface onto an LVDS medium.

module aligner_tbstub (
  output aligner1_ena,
  output aligner1_shift,
  input  aligner1_oos,
  output aligner2_ena,
  output aligner2_shift,
  input  aligner2_oos);

  // Tie off the aligner inputs, enabling the auto-aligner and deasserting the manual bit-slip
  assign aligner1_ena   = 1'b1;
  assign aligner1_shift = 1'b0;
  assign aligner2_ena   = 1'b1;
  assign aligner2_shift = 1'b0;

endmodule
