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

// Module: AVS_to_Packets
//
// Author: Chris Esser
//
// Description: This module queues up transactions from an Avalon-MM master,
//   and converts them to packet-based streams.  It receives packet-based
//   responses, and translates them back to Avalon-MM (AVMM) transactions.


`default_nettype none
`timescale 1ns / 1ns
module avs_to_packets #(
    parameter DATA_W = 8,
              ADDR_W = 32,
              BURST_W = 3,
              P_FIFOSIZELOGN = 4
  )
  (
  // Avalon-MM slave interface (avs)
  avmm_if.slave avs,

  // Avalon-ST source interface (avst_out)
  avst_if.source avst_out,

  // Avalon-ST sink interface (avst_in)
  avst_if.sink avst_in

);

  // Enumerate a list of states for the FSM that will translate the
  //   incoming Avalon-MM transaction to the Avalon-ST (AVST) packet.
  typedef enum int unsigned {
    ST_IDLE,
    ST_TRANSACTION_CODE,
    ST_TRANSACTION_RSVD,
    ST_TRANSACTION_SIZE1,
    ST_TRANSACTION_SIZE2,
    ST_TRANSACTION_ADDRESS,
    ST_TRANSACTION_DATA,
    ST_TRANSACTION_LASTDATA
  } t_avmm_txstate;
  t_avmm_txstate avs_txstate, avs_nexttxstate;

  // Enumerate a list of commands that are used to define the packet type
  typedef enum logic [7:0] {
    CMD_WRITE_FIXED = 8'h00,
    CMD_WRITE_INC = 8'h04,
    CMD_READ_FIXED = 8'h10,
    CMD_READ_INC = 8'h14,
    CMD_NOP = 8'h7F
  } t_cmd;

  // Define the local signals that will be used within the module
  logic avs_read_q;
  logic avs_write_q;
  logic [10:0] avs_burstcount_q;
  logic [BURST_W-1:0] avs_burstcount_i;  
  logic [0:3][7:0] avs_addr_q;
  logic [ADDR_W-1:0] avs_addr_i;  
  logic [7:0] avs_writedata_q;
  logic avmm_fifo_read;
  logic avmm_fifo_empty;
  logic avmm_fifo_full;
  logic cmdresp_fifo_rd;
  logic cmdresp_fifo_wr;
  logic cmdresp_fifo_empty;
  logic cmdresp_fifo_full;
  logic cmdresp_read_q;
  logic cmdresp_write_q;
  logic [10:0] cmdresp_brstcount_q;
  int unsigned statecntr;
  logic statecntr_rst;
  logic statecntr_ldb;
  logic statecntr_inc;
  logic statecntr_dec;

  // Store all incoming transactions into a FIFO.  This is required, since the
  //   ready latency of the downstream target for the AVST packet is "0", and
  //   we need to be able to immediately halt transmission, when backpressured.
  avmm_transaction_fifo #(
    .P_FIFOSIZELOGN (P_FIFOSIZELOGN),
    .P_FIFOWIDTH (ADDR_W+BURST_W+DATA_W+2)
  ) U_AVMM_FIFO (
    .clock(avs.clk),
    .sclr(avs.reset),
    .data({avs.read, avs.write, avs.burstcount, avs.address, avs.writedata}),
    .rdreq(avmm_fifo_read),
    .wrreq((avs.read | avs.write) & ! avs.waitrequest),
    .empty(avmm_fifo_empty),
    .full(avmm_fifo_full),
    .q({avs_read_q, avs_write_q, avs_burstcount_i, avs_addr_i, avs_writedata_q}),
    .usedw());

  // Zero out the unused bits in the address and burstcount busses.
  assign avs_addr_q = {'0, avs_addr_i};
  assign avs_burstcount_q = {'0, avs_burstcount_i};

  // Stop accepting AVMM transactions into the FIFO, while it is full.
  assign avs.waitrequest   = avmm_fifo_full;

  // Store all outgoing command types/sizes into a FIFO.  This is so that we
  //   will know how to process the response packet (i.e. write ack, read data,
  //   or bursted read data).  Note - currently not utilizing the burstcount, but
  //   letting Quartus optimize it out for now, as we might utilize at a later point.
  avmm_cmdresp_fifo U_AVMM_RESPFIFO (
    .clock(avs.clk),
    .sclr(avs.reset),
    .data({avs_read_q, avs_write_q, avs_burstcount_q}),
    .rdreq(cmdresp_fifo_rd),
    .wrreq(cmdresp_fifo_wr),
    .empty(cmdresp_fifo_empty),
    .full(cmdresp_fifo_full),
    .q({cmdresp_read_q, cmdresp_write_q, cmdresp_brstcount_q}));

  // Process the response packet interface.  Handle both the command response FIFO
  //   control, as well as readdatavalid signal generation.
  always @* begin : avs_rxfsm_combinatorial
    // Default inactive assignments
    avs.readdata        <= '0;
    avs.readdatavalid   <= 1'b0;
    cmdresp_fifo_rd     <= 1'b0;
    // Pop the transaction off the FIFO as soon as the EOP is received.
    cmdresp_fifo_rd     <= avst_in.eop & avst_in.valid;
    // Has the remote AVMM sent back valid read data?  If so, respond back to
    //   the local master AVMM interface.
    if (cmdresp_read_q & !cmdresp_fifo_empty & avst_in.valid) begin
      avs.readdata      <= avst_in.data;
      avs.readdatavalid <= 1'b1;
    end
  end: avs_rxfsm_combinatorial

  // Sequential process that advances the AVMM state machine
  always_ff @(posedge avs.clk or posedge avs.reset) begin : avs_fsm_sequential
    if (avs.reset) begin
      avs_txstate  <= ST_TRANSACTION_CODE;
      statecntr    <= 0;
    end
    else begin
      // Up/Down counter, used by the state machine to count out bytes for
      //   transmission of the address and bursted data.
      if (statecntr_rst) statecntr <= 0;
      else if (statecntr_ldb) statecntr <= avs_burstcount_q; 
      else if (statecntr_inc) statecntr++;
      else if (statecntr_dec) statecntr--;

      avs_txstate <= avs_nexttxstate;
    end
  end: avs_fsm_sequential

  // State machine that processes the incoming AVMM transactions and generates
  //   the appropriate AVST output packet.
  always @* begin : avs_txfsm_combinatorial
    // Default inactive assignments
    avs_nexttxstate     <= avs_txstate;
    avmm_fifo_read    <= 1'b0;
    avst_out.valid    <= 1'b0;
    avst_out.sop      <= 1'b0;
    avst_out.eop      <= 1'b0;
    avst_out.data     <= 0;
    cmdresp_fifo_wr   <= 1'b0;
    avst_in.ready     <= 1'b1;
    statecntr_rst     <= 1'b0;
    statecntr_ldb     <= 1'b0;
    statecntr_inc     <= 1'b0;
    statecntr_dec     <= 1'b0;

    case (avs_txstate)
      // Idle state
      ST_TRANSACTION_CODE: begin
        statecntr_rst      <= 1'b1;
        // If we have a transaction in the FIFO, transmit the SOP indication,
        //   and the appropriate command type on the AVST packet interface.
        if (!avmm_fifo_empty) begin
          if (avs_burstcount_q == 1) begin
            if (avs_read_q) avst_out.data <= CMD_READ_FIXED;
            else            avst_out.data <= CMD_WRITE_FIXED;
          end
          else begin
            if (avs_read_q) avst_out.data <= CMD_READ_INC;
            else            avst_out.data <= CMD_WRITE_INC;
          end
          avst_out.sop     <= 1'b1;
          avst_out.valid   <= 1'b1;
          cmdresp_fifo_wr  <= avst_out.ready;
          // If the downstream interface is ready, proceed to the next
          //   state; if not, retransmit the data until it is ready.
          if (avst_out.ready) avs_nexttxstate <= ST_TRANSACTION_RSVD;
        end
      end

      // Reserved state - The second byte in the packet is defined as
      //   "reserved".  Transmit zeroes, and move to the next state.
      ST_TRANSACTION_RSVD: begin
        avst_out.valid     <= 1'b1;
        avst_out.data      <= 0;
        // If the downstream interface is ready, proceed to the next
        //   state; if not, retransmit the data until it is ready.
        if (avst_out.ready) avs_nexttxstate <= ST_TRANSACTION_SIZE1;
      end

      // First "Transaction size" state - This state defines the number
      //   of bytes in the burst (between 1 and 2048).  Send the MSB
      //   for the burst size, and move to the next state.
      ST_TRANSACTION_SIZE1: begin
        avst_out.valid     <= 1'b1;
        avst_out.data      <= {'0, avs_burstcount_q[10:8]};
        // If the downstream interface is ready, proceed to the next
        //   state; if not, retransmit the data until it is ready.
        if (avst_out.ready) avs_nexttxstate <= ST_TRANSACTION_SIZE2;
      end

      // Second "Transaction size" state - This state defines the number
      //   of bytes in the burst (between 1 and 2048).  Send the LSB
      //   for the burst size, and move to the next state.
      ST_TRANSACTION_SIZE2: begin
        avst_out.valid     <= 1'b1;
        avst_out.data      <= avs_burstcount_q[7:0];
        // If the downstream interface is ready, proceed to the next
        //   state; if not, retransmit the data until it is ready.
        if (avst_out.ready) avs_nexttxstate <= ST_TRANSACTION_ADDRESS;
      end

      // During this state, the 32-bit address is transmitted, MSB to LSB,
      //   over 4 cycles
      ST_TRANSACTION_ADDRESS: begin
        statecntr_inc      <= avst_out.ready;
        avst_out.valid     <= 1'b1;
        avst_out.data      <= avs_addr_q[statecntr];
        if ((statecntr == 3) && (avs_read_q)) avst_out.eop <= 1'b1;
        // If all four bytes of address data have been transmitted, and the
        //   downstream interface is ready, proceed to the next state; if not,
        //   retransmit the data until it is ready.
        if ((avst_out.ready) && (statecntr == 3)) begin
          statecntr_ldb    <= 1'b1;
          // If we're processing a read, send the EOP and return to the idle state
          if (avs_read_q) begin
            avmm_fifo_read   <= 1'b1;
            avs_nexttxstate <= ST_TRANSACTION_CODE;
            end
          // If we're processing a non-burst write, continue to the state where
          //   we can send the data byte.
          else if (avs_burstcount_q == 1) avs_nexttxstate <= ST_TRANSACTION_LASTDATA;
          // We're processing a bursted write, so continue to the state where we
          //   pull our writedata from the FIFO.
          else                            avs_nexttxstate <= ST_TRANSACTION_DATA;
        end
      end

      // Transmit the burst of data, until there is only one byte left to transfer
      ST_TRANSACTION_DATA: begin
        avst_out.valid     <= 1'b1;
        avst_out.data      <= avs_writedata_q;
        statecntr_dec      <= avst_out.ready;
        // If the downstream interface is ready, proceed to the next
        //   state; if not, retransmit the data until it is ready.
        if (avst_out.ready) begin
          avmm_fifo_read   <= 1'b1;
          if (statecntr == 2) avs_nexttxstate  <= ST_TRANSACTION_LASTDATA;
        end
      end

      // Transmit the last byte of data and send the EOP indicator
      ST_TRANSACTION_LASTDATA: begin
        avst_out.valid     <= 1'b1;
        avst_out.data      <= avs_writedata_q;
        statecntr_dec      <= avst_out.ready;
        avst_out.eop       <= 1'b1;
        // If the downstream interface is ready, proceed to the next
        //   state; if not, retransmit the data until it is ready.
        if (avst_out.ready) begin
          avmm_fifo_read   <= 1'b1;
          avs_nexttxstate  <= ST_TRANSACTION_CODE;
        end
      end
    endcase
  end : avs_txfsm_combinatorial

endmodule : avs_to_packets
