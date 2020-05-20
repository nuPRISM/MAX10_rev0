/* ================================================================================
-- (c) 2009 Altera Corporation. All rights reserved.
-- Altera products are protected under numerous U.S. and foreign patents, maskwork
-- rights, copyrights and other intellectual property laws.
-- 
-- This reference design file, and your use thereof, is subject to and governed
-- by the terms and conditions of the applicable Altera Reference Design License
-- Agreement (either as signed by you, agreed by you upon download or as a
-- "click-through" agreement upon installation andor found at www.altera.com).
-- By using this reference design file, you indicate your acceptance of such terms
-- and conditions between you and Altera Corporation.  In the event that you do
-- not agree with such terms and conditions, you may not use the reference design
-- file and please promptly destroy any copies you have made.
-- 
-- This reference design file is being provided on an "as-is" basis and as an
-- accommodation and therefore all warranties, representations or guarantees of
-- any kind (whether express, implied or statutory) including, without limitation,
-- warranties of merchantability, non-infringement, or fitness for a particular
-- purpose, are specifically disclaimed.  By making this reference design file
-- available, Altera expressly does not recommend, suggest or require that this
-- reference design file be used in combination with any other product not
-- provided by Altera.
-- ================================================================================ */

// JESDCON Top Level
// This edition supports L=1,M=2,F=4 (2*M/L) only.


module jesd_top_qsys #(
   parameter             SAMPLES_PER_CLK= 1,
   parameter             gControllerType = "ADC",
   parameter             device = "SV",
   parameter             SYSREF_DIR = "TO_FPGA",
   parameter             F   = 4,    // 2*M/L
   parameter             K   = 16,
   parameter             M   = 2,
   parameter             L   = 1,
   parameter             N   = 12,
   parameter             CS  = 2,
   parameter             S   = 1,
   parameter             DID = 0,
   parameter             BID = 0
) (
  	//clock reset signals
	input    wire                           jesd_device_clk,        //Device clock
	input    wire                           rstn,       //Input reset, active low
	input    wire                           jesd_sysref_in,    //sysref 
	
	output    wire                          jesd_tx_sysref_out,    //sysref 
	output    wire                          jesd_rx_sysref_out,    //sysref 
	
	//jesd interface
	output   wire [L-1:0]                   jesd_tx_data_out,  //jesd serial link data 
	input    wire                           jesd_tx_syncn,       //syncn, active low

	//AV-ST sink Interface
	input    wire[(M*SAMPLES_PER_CLK*S*16-1):0]             avst_tx_data_in, //Data from the AV ST interface 
	input    wire                           avst_tx_data_valid,
	output   wire                            avst_tx_data_rdy,
    

	//AV-MM Slave Interface (control)
    input    wire [15:0]                     avmm_tx_addr,
	input    wire                           avmm_tx_read,
	input    wire                           avmm_tx_write,
	input    wire[31:0]                      avmm_tx_wr_data,
	output   wire[31:0]                      avmm_tx_rd_data,
	output   wire                           avmm_tx_rd_valid,
	output   wire                           avmm_tx_waitreq,

	//jesd interface
    output   wire                           jesd_rx_syncn,       //syncn, active low
	input    wire [L-1:0]                   jesd_rx_data_in,  //jesd serial link data

	//AV-ST source Interface
	output    reg [(M*SAMPLES_PER_CLK*S*16-1):0]            avst_rx_data_out, //data out from transport layer 
	output    reg                           avst_rx_data_valid,
	input     wire                          avst_rx_data_rdy, //Assumed - always asserted
    

	//AV-MM Slave Interface (control)
    input    wire [15:0]                     avmm_rx_addr,
	input    wire                           avmm_rx_read,
	input    wire                           avmm_rx_write,
	input    wire[31:0]                      avmm_rx_wr_data,
	output   wire[31:0]                      avmm_rx_rd_data,
	output   wire                           avmm_rx_rd_valid,
	output   wire                           avmm_rx_waitreq,

	//AV-MM Slave Interface (reconfig control)
    input    wire [7:0]                     avmm_reconfig_addr,
	input    wire                           avmm_reconfig_read,
	input    wire                           avmm_reconfig_write,
	input    wire[31:0]                      avmm_reconfig_wr_data,
	output   wire[31:0]                      avmm_reconfig_rd_data,
	output   wire                           avmm_reconfig_rd_valid,
	output   wire                           avmm_reconfig_waitreq,

	// interface 'reconfig_to_pll'
	input wire [63:0] reconfig_to_pll,

	// interface 'reconfig_from_pll'
	output wire [63:0] reconfig_from_pll,
	
		//reconfig mif interface	
	output wire [31:0] reconfig_mif_address,   
  output wire        reconfig_mif_read,
  input wire         reconfig_mif_waitrequest, 
  input wire [15:0]  reconfig_mif_readdata,
	
	//clock and reset 
	output   wire                           jesd_tx_frame_clk,
	output   wire                           jesd_tx_frame_clk_div2,
	output   wire                           jesd_tx_frame_rstn,
	output   wire                           jesd_rx_frame_clk,
	output   wire                           jesd_rx_frame_clk_div2,
	output   wire                           jesd_rx_frame_rstn,
    input   wire                           jesd_reconfig_clk, //100-125Mhz clk
    input   wire                           jesd_reconfig_rst, //Active high
    output   wire	                        jesd_clkout, //clkout used in the test bench
    output   wire                           jesd_clkout_rstn,
	

		output wire [31:0] mgmt_readdata,     // mgmt_avalon_slave.readdata
		output wire        mgmt_waitrequest,  //                  .waitrequest
		input  wire        mgmt_read,         //                  .read
		input  wire        mgmt_write,        //                  .write
		input  wire [8:0]  mgmt_address,      //                  .address
		input  wire [31:0] mgmt_writedata,
	

	output	reg										tx_ready,
	
	output	 wire										syncn_tx,
	 output	 wire										syncn_rx,
	 output   wire										lmfc_pulse_rx,
	 
	 //pattern_out
	output    wire [39:0]            check_data_out, 
	output    wire                   check_data_valid,
	input     wire                   check_data_rdy,

	//pattern_in
	input    wire [39:0]            gen_data_in, 
	input    wire                   gen_data_valid,
	output     wire                  gen_data_rdy,
	
	input    wire   [1119:0] ch8_23_to_xcvr,
   output     wire [735:0] ch8_23_from_xcvr,
   input     wire   [559:0]ch0_7_to_xcvr,
   output     wire  [367:0]ch0_7_from_xcvr,
	
	output		reg 	[1:0]				jesd_rx_M,
	output		reg 	[1:0]				jesd_tx_M
);

reg [M-1:0][SAMPLES_PER_CLK-1:0][S-1:0][15:0] enc_data;
reg [M-1:0] enc_data_rdy;
reg [M-1:0] enc_data_valid;

wire [M-1:0][SAMPLES_PER_CLK-1:0][S-1:0][15:0] dec_data;
reg [M-1:0] dec_data_rdy;
wire [M-1:0] dec_data_valid;

wire [31:0]  cntrl_rx_data_out;
wire [31:0]  cntrl_tx_data_out;

wire [63:0] reconfig_to_pll_eb;
wire [63:0] reconfig_from_pll_eb;

wire [31:0] reconfig_mif_address_eb;

assign reconfig_mif_address = reconfig_mif_address_eb[31:1];
//assign avmm_rx_rd_data = {24'd0,cntrl_rx_data_out};
//assign avmm_tx_rd_data = {24'd0,cntrl_tx_data_out};


//pack the data into multi dimensional array

integer i,j,k;
integer x,y,z;
integer cnt_enc ;
integer cnt_dec ;
always @(*)
begin
     cnt_dec = 0;
     for(i=0;i<M;i=i+1)
     begin
	    for(k=0;k<SAMPLES_PER_CLK;k=k+1)
        begin
        	for(j=0;j<S;j=j+1)
        	begin
        	    //avst_rx_data_out[(((k+i+j+1)*16)-1) -:16] = dec_data[i][k][j][15:0]; //verilog 2001 for the data range
        	    avst_rx_data_out[((cnt_dec+1)*16-1) -:16] = dec_data[i][k][j][15:0]; //verilog 2001 for the data range
                cnt_dec = cnt_dec +1;
        	end
         end 
    end
	avst_rx_data_valid = |dec_data_valid; //changed from unary AND to unary OR
	dec_data_rdy = {M{avst_rx_data_rdy}};

end

always @ (*)
begin
   cnt_enc = 0;
   for(z=0;z<M;z=z+1)
   begin
       for(y=0;y<SAMPLES_PER_CLK;y=y+1)
       begin
	       for(x=0;x<S;x=x+1)
	       begin
	       	   //enc_data[z][y][x][15:0] = avst_tx_data_in[(((z+y+x+1)*16)-1) -:16]; //verilog 2001 for the data range
	       	   enc_data[z][y][x][15:0] = avst_tx_data_in[((cnt_enc+1)*16-1) -:16]; //verilog 2001 for the data range
               cnt_enc = cnt_enc +1;
	       end
       end
	end
    tx_ready = |enc_data_rdy;
	enc_data_valid = {M{avst_tx_data_valid}};
end


always @ (posedge jesd_reconfig_clk or posedge jesd_reconfig_rst)
begin
if (jesd_reconfig_rst)
begin
jesd_rx_M = 0;
jesd_tx_M = 0;
end
else
begin
if (avmm_rx_write && avmm_rx_addr=='h18)
jesd_rx_M = avmm_rx_wr_data[1:0];

if (avmm_tx_write && avmm_tx_addr=='h18)
jesd_tx_M = avmm_tx_wr_data[1:0];
end
end

jesd_top #(
    .SAMPLES_PER_CLK (SAMPLES_PER_CLK),
    .gControllerType (gControllerType),
    .device  (device),
    .SYSREF_DIR (SYSREF_DIR),
	.L (L),
	.M (M),
	.F (F),
	.K (K),
	.N (N),
	.S (S),
	.CS (CS),
	.BID (BID),
	.DID (DID)
) u_jesd_top_inst (
    // common clk/reset
    .jesd_device_clk                (jesd_device_clk),
    .jesd_rstn                      (rstn),
    .jesd_sysref_in                 (jesd_sysref_in),
    .jesd_tx_sysref_out             (jesd_tx_sysref_out),
    .jesd_rx_sysref_out             (jesd_rx_sysref_out),
    // JESD Tx Link
    .jesd_tx_syncn                  (jesd_tx_syncn),
    .jesd_tx_data_out               (jesd_tx_data_out),    //serial data
	//AV-ST
    .jesd_tx_data_in                (enc_data[M-1:0]), //16 bits data 
    .jesd_tx_data_valid             (enc_data_valid[M-1:0]),
	 .sample_valid_tx						(avst_tx_data_rdy),
    .jesd_tx_data_rdy               (enc_data_rdy[M-1:0]),
	 
    //control interface                                               
    .jesd_cntrl_tx_addr             (avmm_tx_addr),
    .jesd_cntrl_tx_read             (avmm_tx_read),
    .jesd_cntrl_tx_write            (avmm_tx_write),
    .jesd_cntrl_tx_wr_data          (avmm_tx_wr_data),
    .jesd_cntrl_tx_rd_data          (avmm_tx_rd_data),
    .jesd_cntrl_tx_rd_valid         (avmm_tx_rd_valid),
    .jesd_cntrl_tx_waitreq          (avmm_tx_waitreq),
	 	 
   //reconfig
	.jesd_cntrl_reconfig_addr             (avmm_reconfig_addr),
    .jesd_cntrl_reconfig_read             (avmm_reconfig_read),
    .jesd_cntrl_reconfig_write            (avmm_reconfig_write),
    .jesd_cntrl_reconfig_wr_data          (avmm_reconfig_wr_data[31:0]),
    .jesd_cntrl_reconfig_rd_data          (avmm_reconfig_rd_data),
    .jesd_cntrl_reconfig_rd_valid         (avmm_reconfig_rd_valid),
    .jesd_cntrl_reconfig_waitreq          (avmm_reconfig_waitreq),
	
	.reconfig_to_pll								(reconfig_to_pll),
	.reconfig_from_pll								(reconfig_from_pll),
	 // JESD Rx Link
    .jesd_rx_syncn                  (jesd_rx_syncn),    
	.jesd_rx_data_in                (jesd_rx_data_in),
    //AV-ST	
	.jesd_rx_data_out               (dec_data[M-1:0]),  
	.jesd_rx_data_valid             (dec_data_valid),
	.jesd_rx_data_rdy               (dec_data_rdy), 
	//control interface not connected
    .jesd_cntrl_rx_addr              (avmm_rx_addr),
	.jesd_cntrl_rx_read              (avmm_rx_read),
	.jesd_cntrl_rx_write             (avmm_rx_write),
	.jesd_cntrl_rx_wr_data           (avmm_rx_wr_data),
	.jesd_cntrl_rx_rd_data           (avmm_rx_rd_data),
	.jesd_cntrl_rx_rd_valid          (avmm_rx_rd_valid),
	.jesd_cntrl_rx_waitreq           (avmm_rx_waitreq),
	//reconfig mif interface
	.reconfig_mif_address							(reconfig_mif_address_eb),   
     .reconfig_mif_read								(reconfig_mif_read),
     .reconfig_mif_waitrequest					(reconfig_mif_waitrequest), 
     .reconfig_mif_readdata						(reconfig_mif_readdata),
	
// debug signals
    .jesd_tx_frame_clk	             (jesd_tx_frame_clk),
	 .jesd_tx_frame_clk_div2	       (jesd_tx_frame_clk_div2),	 
    .jesd_tx_frame_rstn              (jesd_tx_frame_rstn),
    .jesd_rx_frame_clk               (jesd_rx_frame_clk),
	 .jesd_rx_frame_clk_div2	       (jesd_rx_frame_clk_div2),	 
    .jesd_rx_frame_rstn              (jesd_rx_frame_rstn),
    .jesd_reconfig_clk               (jesd_reconfig_clk), 
    .jesd_reconfig_rst               (jesd_reconfig_rst),
    .jesd_clkout                     (jesd_clkout),
    .jesd_clkout_rstn                (jesd_clkout_rstn),
	 .syncn_tx								 (syncn_tx),
	 .syncn_rx									(syncn_rx),
	 .lmfc_pulse_rx							(lmfc_pulse_rx),
	 
	 
	  //pattern_out
	  .check_data_out 						(check_data_out),
	  .check_data_valid						(check_data_valid),
	  .check_data_rdy							(check_data_rdy),

	//pattern_in
	.gen_data_in 								(gen_data_in),
	.gen_data_valid							(gen_data_valid),
	.gen_data_rdy								(gen_data_rdy),
	
	 .ch8_23_to_xcvr							(ch8_23_to_xcvr),
    .ch8_23_from_xcvr							(ch8_23_from_xcvr),
   .ch0_7_to_xcvr							(ch0_7_to_xcvr),
   .ch0_7_from_xcvr							(ch0_7_from_xcvr),
	
	//phy_mgmt_interface
	 .phy_mgmt_address								(mgmt_address),   
    .phy_mgmt_write     						(mgmt_write),
    .phy_mgmt_writedata 						(mgmt_writedata),
    .phy_mgmt_read      						(mgmt_read),
    .phy_mgmt_readdata						(mgmt_readdata),  
    .phy_mgmt_waitrequest					(mgmt_waitrequest)

);

endmodule
