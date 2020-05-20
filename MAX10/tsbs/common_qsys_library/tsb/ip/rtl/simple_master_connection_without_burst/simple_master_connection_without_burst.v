// simple_master_connection_without_burst.v
`include "keep_defines.v"

`timescale 1 ps / 1 ps

//`define SIMPLE_MASTER_CONNECTION_WITHOUT_BURST_KEEP (* keep = 1, preserve = 1 *)
`ifndef SIMPLE_MASTER_CONNECTION_WITHOUT_BURST_KEEP
`define SIMPLE_MASTER_CONNECTION_WITHOUT_BURST_KEEP 
`endif
module simple_master_connection_without_burst #(
		parameter AUTO_CLOCK_CLOCK_RATE = "-1"
	) (
		input  wire [31:0] avs_s0_address,     //    s0.address
		input  wire        avs_s0_read,        //      .read
		output wire [31:0] avs_s0_readdata,    //      .readdata
		input  wire        avs_s0_write,       //      .write
		input  wire [31:0] avs_s0_writedata,   //      .writedata
		output wire        avs_s0_waitrequest, //      .waitrequest

		input  wire        clk,                // clock.clk
		input  wire        reset,              // reset.reset
		output wire [31:0] avm_m0_address,     //    m0.address
		output wire        avm_m0_read,        //      .read
		input  wire        avm_m0_waitrequest, //      .waitrequest
		input  wire [31:0] avm_m0_readdata,    //      .readdata
		output wire        avm_m0_write,       //      .write
		output wire [31:0] avm_m0_writedata     //      .writedata
	);


`SIMPLE_MASTER_CONNECTION_WITHOUT_BURST_KEEP wire [31:0] intermediary_address;     
`SIMPLE_MASTER_CONNECTION_WITHOUT_BURST_KEEP wire        intermediary_read;     
`SIMPLE_MASTER_CONNECTION_WITHOUT_BURST_KEEP wire        intermediary_waitrequest;
`SIMPLE_MASTER_CONNECTION_WITHOUT_BURST_KEEP wire [31:0] intermediary_readdata; 
`SIMPLE_MASTER_CONNECTION_WITHOUT_BURST_KEEP wire        intermediary_write;    
`SIMPLE_MASTER_CONNECTION_WITHOUT_BURST_KEEP wire [31:0] intermediary_writedata;

assign intermediary_writedata 	 = avs_s0_writedata;	
assign intermediary_address 	 = avs_s0_address;	
assign intermediary_write 	     = avs_s0_write;	
assign intermediary_read 	     = avs_s0_read;	
assign intermediary_waitrequest  = avm_m0_waitrequest;
assign intermediary_readdata     = avm_m0_readdata;
	
assign avm_m0_writedata          = intermediary_writedata 	     ;
assign avm_m0_address            = intermediary_address 	     ;
assign avm_m0_write              = intermediary_write 	         ;
assign avm_m0_read               = intermediary_read 	         ;
assign avs_s0_waitrequest        = intermediary_waitrequest     ;
assign avs_s0_readdata           = intermediary_readdata        ;

endmodule
