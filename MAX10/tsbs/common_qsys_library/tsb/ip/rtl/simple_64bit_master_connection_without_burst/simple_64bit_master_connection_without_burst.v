// simple_64bit_master_connection_without_burst.v

// This file was auto-generated as a prototype implementation of a module
// created in component editor.  It ties off all outputs to ground and
// ignores all inputs.  It needs to be edited to make it do something
// useful.
// 
// This file will not be automatically regenerated.  You should check it in
// to your version control system if you want to keep it.

`timescale 1 ps / 1 ps
module simple_64bit_master_connection_without_burst #(
		parameter AUTO_CLOCK_CLOCK_RATE = "-1"
	) (
		input  wire [31:0] avs_s0_address,     //    s0.address
		input  wire        avs_s0_read,        //      .read
		output wire [63:0] avs_s0_readdata,    //      .readdata
		input  wire        avs_s0_write,       //      .write
		input  wire [63:0] avs_s0_writedata,   //      .writedata
		output wire        avs_s0_waitrequest, //      .waitrequest
		output wire        avs_s0_readdatavalid,

		input  wire        clk,                // clock.clk
		input  wire        reset,              // reset.reset
		output wire [31:0] avm_m0_address,     //    m0.address
		output wire        avm_m0_read,        //      .read
		input  wire        avm_m0_waitrequest, //      .waitrequest
		input  wire [63:0] avm_m0_readdata,    //      .readdata
		output wire        avm_m0_write,       //      .write
		output wire [63:0] avm_m0_writedata,    //      .writedata
		input wire         avm_m0_readdatavalid
	);

 assign avm_m0_writedata          = avs_s0_writedata;	
 assign avm_m0_address            = avs_s0_address;	
 assign avm_m0_write              = avs_s0_write;	
 assign avm_m0_read               = avs_s0_read;	
 assign avs_s0_waitrequest        = avm_m0_waitrequest;
 assign avs_s0_readdata           = avm_m0_readdata;
 assign avs_s0_readdatavalid      = avm_m0_readdatavalid;
	

endmodule
