// Describe the interface for a Avalon-MM Interface
interface avmm_if #(parameter ADDR_W = 32, DATA_W = 8, BURST_W=11);
  logic clk;
  logic reset;
  logic read;
  logic write;
  logic [BURST_W - 1: 0] burstcount;
  logic [DATA_W - 1: 0] writedata;
  logic [DATA_W - 1: 0] readdata;
  logic [ADDR_W - 1: 0] address;
  logic [DATA_W/8 - 1: 0] byteenable;
  logic waitrequest;
  logic readdatavalid;

  // Avalon-MM master
  modport master (
    input clk, reset, readdata, waitrequest, readdatavalid,
    output read, write, byteenable, burstcount, address, writedata);

  // Avalon-MM slave
  modport slave (
    input clk, reset, read, write, byteenable, burstcount, address, writedata,
    output readdata, waitrequest, readdatavalid);

  // This is an embedded task for simulating read/write behavior on the AVMM interface
  //   It has been commented out, as it is purely for simulation purposes, and not for
  //   synthesis.
  /*
  task AVMM_Read (input logic [7:0] raddr,
                  input logic [7:0] rdata);
    address = raddr;
    read = 1;
    @(posedge clk);
    wait (readdatavalid == 1);
    read  = 0;
    assert (readdata == rdata) else $error("Memory Read Error at Address 0x%h: expected 0x%h, received 0x%h", raddr, rdata, readdata);
  endtask : AVMM_Read

  task AVMM_Write (input logic [7:0] waddr,
                   input logic [7:0] wdata);
    address = waddr;
    writedata = wdata;
    write = 1;
    @(posedge clk);
    wait (waitrequest == 0);
    write = 0;
  endtask : AVMM_Write
  */

endinterface

// Describe the interface for a Packet-based Avalon-ST Interface
interface avst_if #(parameter DATA_W = 8);
  logic clk;
  logic reset;
  logic sop;
  logic eop;
  logic ready;
  logic valid;
  logic [DATA_W - 1 : 0] data;

  // Avalon-ST source
  modport source (
    input clk, reset, ready,
    output sop, eop, valid, data);

  // Avalon-ST sink
  modport sink (
    input clk, reset, sop, eop, valid, data,
    output ready);

endinterface
