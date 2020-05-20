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

// Module: Bytes_to_LVDS
//
// Author: Chris Esser
//
// Description: This module serializes and deserializes the streaming
//   interface onto an LVDS medium.

module bytes_to_lvds #(
  parameter P_SLAVE = 1'b0,
  parameter P_PCFIFO = 1'b1,
  parameter P_OOSCNTR = 8,
  parameter P_ALIGNSEQ0 = 11'h00A,
  parameter P_ALIGNSEQ1 = 11'h00A,
  parameter P_DEV_FAMILY = 0)(
  input        rxpll_refclk,
  input        txpll_refclk,
  input        reset,
  input        aligner_ena,
  input        aligner_shift,
  output       lvdspll_locked,
  output [7:0] avst_rxdata,
  input        avst_rxready,
  output       avst_rxvalid,
  input  [7:0] avst_txdata,
  output logic avst_txready,
  input        avst_txvalid,
  input  [1:0] lvds_rxdata,
  output [1:0] lvds_txdata,
  output logic aligner_oos,
  output       rx_outclock,
  output       tx_outclock);

  logic lvdsrxpll_locked;
  logic lvdstxpll_locked;
  logic [1:0][10:0] data_align_q;
  logic [P_OOSCNTR:0] synccntr;
  logic [P_OOSCNTR:0] ooscntr;
  wire pll_fastclk, pll_slowclk, pll_readclk, pll_writeclk;
  wire rx_outclk;
  logic [9:0] parallel_rxdata;
  logic [9:0] parallel_txdata;
  logic [9:0] pcfifo_txdata;
  logic [3:0] pcfifo_rdusedw;
  logic [7:0] fifo_rxdata;
  logic [5:0] fifo_usedw;
  logic fifo_empty;
  logic fifo_ae;
  logic [10:0] aligner_sync;
  logic aligner_ready;
  logic oos_symbol;
  logic pcfifo_full;
  logic pcfifo_ae;

  // The only time you're not ready, is if you're a slave, auto alignment is enabled, and you're OOS with the master
  assign aligner_ready = !(P_SLAVE & aligner_ena & aligner_oos); 

  // Sequential process that creates the pulses to align the LVDS input
  always_ff @(posedge pll_readclk or negedge lvdsrxpll_locked) begin : align_rx
    if (!lvdsrxpll_locked) begin
      data_align_q[1]  <= P_ALIGNSEQ1;
      data_align_q[0]  <= P_ALIGNSEQ0;
      synccntr         <= '0;
      avst_txready     <= 1'b0;
    end
    else begin
      // Serially shift out the bit-slip pulses to the aligner
      data_align_q[1]  <= {1'b0, data_align_q[1][10:1]};
      data_align_q[0]  <= {1'b0, data_align_q[0][10:1]};
      // Send the 10-bit pulse pattern, then freeze the counter
      if (synccntr[P_OOSCNTR] != 1'b1) synccntr++;
      else if (aligner_ena & aligner_oos == 1) begin
          synccntr         <= '0;
          data_align_q[1]  <= aligner_sync;
          data_align_q[0]  <= aligner_sync;
      end
      else begin
          data_align_q[1]  <= {10'b0, aligner_shift};
          data_align_q[0]  <= {10'b0, aligner_shift};
      end
      // Register the received data to the parallel rx clock
      avst_txready     <= parallel_rxdata[9];
    end
  end: align_rx

  // Sequential process that auto-aligns the receiver, based on a 0x200 idle pattern
  always_ff @(posedge pll_readclk or negedge lvdsrxpll_locked) begin : auto_aligner
    // Start in the out-of-sync condition after reset
    if (!lvdsrxpll_locked) begin
      aligner_oos  <= 1'b1;
      oos_symbol   <= '1;
      aligner_sync <= '0;
      ooscntr      <= '1;
    end
    else begin
      // Are we receiving a byte that might be a bit shifted idle pattern, or all zeroes?
      if (oos_symbol == 1'b1) begin
        // If our OOS counter is saturated, don't increment it and declare OOS
        if (ooscntr[P_OOSCNTR] == 1'b1) begin
          ooscntr      <= ooscntr;
          aligner_oos  <= 1'b1;
        end
        // Increment the OOS counter
        else begin
          ooscntr++;
          aligner_oos  <= 1'b0;
        end
      end
      // If we are not receiving a byte that could be a shifted idle pattern or all zeroes, reset
      //   the OOS counter and declare the aligner to be in-sync
      else begin
          ooscntr      <= '0;
          aligner_oos  <= 1'b0;
      end

      // Monitor the incoming bytes to check for a possible out-of-sync condition
      case (parallel_rxdata)
        // This is the idle pattern - if we are receiving it, we are in-sync.
        10'h200: begin
          oos_symbol   <= '0;
          aligner_sync <= '0;
        end
        // Is this possibly a bit-shifted version of the idle pattern?  Mark it as an OOS symbol,
        //   and prepare the bit-slip pattern to re-align the RX LVDS deserializers.
        10'h100: begin
          oos_symbol   <= '1;
          aligner_sync <= 11'h0AA;
        end
        10'h080: begin
          oos_symbol   <= '1;
          aligner_sync <= 11'h02A;
        end
        10'h040: begin
          oos_symbol   <= '1;
          aligner_sync <= 11'h00A;
        end
        10'h020: begin
          oos_symbol   <= '1;
          aligner_sync <= 11'h002;
        end
        10'h000: begin
          oos_symbol   <= '1;
          aligner_sync <= '0;
        end
        default: begin
          oos_symbol   <= oos_symbol;
          aligner_sync <= '0;
        end
      endcase
    end
  end: auto_aligner

  generate
    case (P_DEV_FAMILY)
      // Implement the Max 10 LVDS interface
      "0": begin
        lvds_rx_x2_m10 U_LVDSRX (
          .pll_areset(2'b0),
          .rx_locked(lvdsrxpll_locked),
          .rx_cda_reset({2{!lvdsrxpll_locked}}),
          .rx_channel_data_align({data_align_q[1][0], data_align_q[0][0]}),
          .rx_in(lvds_rxdata),
          .rx_inclock(rxpll_refclk),
          .rx_outclock(pll_readclk),
          .rx_out(parallel_rxdata));

        lvds_tx_x2_m10 U_LVDSTX (
          .pll_areset(2'b0),
          .tx_locked(lvdstxpll_locked),
          .tx_in(parallel_txdata),
          .tx_inclock(txpll_refclk),
          .tx_outclock(tx_outclock),
          .tx_coreclock(pll_writeclk),
          .tx_out(lvds_txdata));
      end

      // Implement the Cyclone V LVDS interface
      "1": begin
        lvds_rx_x2_c5 U_LVDSRX (
          .pll_areset(2'b0),
          .rx_locked(lvdsrxpll_locked),
          .rx_channel_data_align({data_align_q[1][0], data_align_q[0][0]}),
          .rx_in(lvds_rxdata),
          .rx_inclock(rxpll_refclk),
          .rx_outclock(pll_readclk),
          .rx_out(parallel_rxdata));

        lvds_tx_x2_c5 U_LVDSTX (
          .pll_areset(2'b0),
          .tx_locked(lvdstxpll_locked),
          .tx_in(parallel_txdata),
          .tx_inclock(txpll_refclk),
          // If we are targeting the CycloneV to Max10 demo, we need to change how we
          //   provide the output clock (see below).
          `ifndef DEVKIT_DEMO
            .tx_outclock(tx_outclock),
          `endif
          .tx_coreclock(pll_writeclk),
          .tx_out(lvds_txdata));

        `ifdef DEVKIT_DEMO
        // Due to lack of LVDS-capable RX clock on dev kits (purely due to
        //   implementation choices on PCB, and not due to any sort of
        //   silicon limitation), it is not possible to utilize the differential
        //   tx_outclock from the ALTLVDS IP.  Therefore, I'm using a DDR
        //   output to recreate the clock (next best option).  However, it is
        //   not possible to perform meaningful timing analysis, given the large
        //   skew and variation between clock and data for this configuration.
        ddout_x1 U_TXCLK(
          .datain_h (1'b1),
          .datain_l (1'b0),
          .outclock (pll_writeclk),
          .dataout (tx_outclock));
        `endif

      end
    endcase
  endgenerate

  generate
    case (P_PCFIFO)
      // Implement Phase comp FIFO to transfer from RX to TX clock domain.  Note - if both read and write
      //   clocks are present, the FIFO should always be passing through data, even if it's merely idle bytes.
      1'b1: begin
        avst_phasecompfifo U_LVDSTXFIFO (
          .aclr(reset | pcfifo_full),
          .data({aligner_ready & avst_rxready & fifo_ae, avst_txvalid & avst_txready, {8{avst_txvalid & avst_txready}} & avst_txdata}),
          .rdclk(pll_writeclk),
          .wrclk(pll_readclk),
          .rdreq(!pcfifo_ae),
          .wrreq(1'b1),
          .rdusedw(pcfifo_rdusedw),
          .wrfull(pcfifo_full),
          .q(pcfifo_txdata));

      // The FIFO is "almost empty" when there are two or less words in the FIFO.  Mask out the output data if the FIFO is almost empty.
      assign pcfifo_ae = !pcfifo_rdusedw[3] & !pcfifo_rdusedw[2] & !pcfifo_rdusedw[1];
      assign parallel_txdata = {{10{!pcfifo_ae}} & pcfifo_txdata};

      end

      // Bypass the FIFO
      1'b0: begin
        assign parallel_txdata = {aligner_ready & avst_rxready & fifo_ae, avst_txvalid & avst_txready, {8{avst_txvalid & avst_txready}} & avst_txdata};
      end
    endcase
  endgenerate


  // Implement FIFO to store received bytes, to provide buffering in
  //   case of backpressure from AVMM master or AVST bridges
  avst_fifo U_LVDSFIFO (
    .clock(pll_readclk),
    .sclr(reset),
    .data(parallel_rxdata[7:0]),
    .rdreq(avst_rxready & !fifo_empty),
    .wrreq(parallel_rxdata[8]),
    .empty(fifo_empty),
    .full(),
    .q(fifo_rxdata),
    .usedw(fifo_usedw));

  // The FIFO is almost empty, when there are 7 or less bytes stored.
  assign fifo_ae = !(fifo_usedw[5] | fifo_usedw[4] | fifo_usedw[3]);
  // As long as the FIFO isn't empty, the data contained within it is valid.
  assign avst_rxvalid = !fifo_empty;
  assign avst_rxdata  = fifo_rxdata;
  assign rx_outclock = pll_readclk;
  assign lvdspll_locked = lvdstxpll_locked;

endmodule
