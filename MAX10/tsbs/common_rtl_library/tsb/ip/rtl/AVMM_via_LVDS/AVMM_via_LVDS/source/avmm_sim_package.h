// avmm_sim_package.h

task AVMM_Read (input logic [7:0] raddr,
                input logic [7:0] rdata);
  avmm_address = raddr;
  avmm_read = 1;
  @(posedge clk);
  if (avmm_waitrequest) begin
    wait (!avmm_waitrequest);
    @(posedge clk);
  end
  avmm_read  = 0;
endtask : AVMM_Read

task AVMM_CheckRead (input logic [7:0] raddr,
                     input logic [7:0] rdata);
  if (!avmm_readdatavalid) begin
    wait (avmm_readdatavalid);
    @(posedge clk);
  end
  assert (avmm_readdata == rdata) else $error("Memory Read Error at Address 0x%h: expected 0x%h, received 0x%h", raddr, rdata, avmm_readdata);
endtask : AVMM_CheckRead

task AVMM_Write (input [7:0] waddr,
                 input [7:0] wdata);
  avmm_address = waddr;
  avmm_writedata = wdata;
  avmm_write = 1;
  @(posedge clk);
  if (avmm_waitrequest) begin
    wait (!avmm_waitrequest);
    @(posedge clk);
  end
  avmm_write = 0;
endtask : AVMM_Write
