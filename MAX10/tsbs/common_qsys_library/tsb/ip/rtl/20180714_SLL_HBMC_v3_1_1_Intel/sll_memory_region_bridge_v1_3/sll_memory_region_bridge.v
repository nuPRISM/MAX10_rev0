// ************************************************************************
// * 
// * SYNAPTIC LABORATORIES CONFIDENTIAL
// * ----------------------------------
// * 
// *  (c) 2017 Synaptic Laboratories Limited
// *  All Rights Reserved.
// * 
// * NOTICE:  All information contained herein is, and remains
// * the property of Synaptic Laboratories Limited and its suppliers,
// * if any.  The intellectual and technical concepts contained
// * herein are proprietary to Synaptic Laboratories Limited 
// * and its suppliers and may be covered by U.S. and Foreign Patents,
// * patents in process, and are protected by trade secret or copyright law.
// * Dissemination of this information or reproduction of this material
// * is strictly forbidden unless prior written permission is obtained
// * from Synaptic Laboratories Limited
// *
// * Modification of this file is strictly forbidden unless prior written 
// * permission is obtained from Synaptic Laboratories Limited
//
//###########################################################################

`timescale 1 ns / 1 ns

module sll_memory_region_bridge
    #(                                              //
        parameter g_iavs0_data_width       = 32,    // Avalon data width 
        parameter g_iavs0_av_numsymbols    = 4,     // Avalon bye width
        parameter g_iavs0_addr_width       = 16,    // Avalon slave address width (in 32-bit words)
        parameter g_iavs0_burstcount_width = 1,     // Avalon burstcount width
        parameter g_iavs0_address_offset   = 32'h0, // Master address offset value
        parameter g_eavm0_addr_width       = 32,    // Avalon master address width (in 32-bit words)
        parameter g_eavm_address_shift     = 2      // Address shift  
    )(
		input  wire                                      clk,                  // clock.clk
		input  wire                                      reset,                // reset.reset

    //
    //Ingress avalon slave        
    //
		input  wire  [(g_iavs0_addr_width-1 ) : 0 ]      avs_s0_address,       //    s0.address
		input  wire                                      avs_s0_read,          //      .read
		output wire  [(g_iavs0_data_width-1 ) : 0 ]      avs_s0_readdata,      //      .readdata
		input  wire                                      avs_s0_write,         //      .write
		input  wire  [(g_iavs0_data_width-1 ) : 0 ]      avs_s0_writedata,     //      .writedata
		output wire                                      avs_s0_readdatavalid, //      .readdatavalid
		output wire                                      avs_s0_waitrequest,   //      .waitrequest
		input  wire  [(g_iavs0_av_numsymbols-1  ) : 0 ]  avs_s0_byteenable,    //      .byteenable
		input  wire  [(g_iavs0_burstcount_width-1) : 0 ] avs_s0_burstcount,    //      .burstcount
		
    //
    //Egress avalon master
    //
    output wire [( g_eavm0_addr_width - 1 ) : 0 ]    avm_m0_address,       //    m0.address
		output wire                                      avm_m0_read,          //      .read
		input  wire                                      avm_m0_waitrequest,   //      .waitrequest
		input  wire [( g_iavs0_data_width - 1 ) : 0 ]    avm_m0_readdata,      //      .readdata
		output wire                                      avm_m0_write,         //      .write
		output wire [( g_iavs0_data_width - 1 ) : 0 ]    avm_m0_writedata,     //      .writedata
		input  wire                                      avm_m0_readdatavalid, //      .readdatavalid
		output wire [( g_iavs0_av_numsymbols - 1 ) : 0 ] avm_m0_byteenable,    //      .byteenable
		output wire [( g_iavs0_burstcount_width-1) : 0 ] avm_m0_burstcount    //      .burstcount
 );


  //
  // signals pass straight thru form the slave to the master
  //
	assign avs_s0_waitrequest   = avm_m0_waitrequest;
	assign avs_s0_readdata      = avm_m0_readdata;
	assign avs_s0_readdatavalid = avm_m0_readdatavalid;

	assign avm_m0_burstcount    = avs_s0_burstcount;
	assign avm_m0_writedata     = avs_s0_writedata;
	assign avm_m0_write         = avs_s0_write;
	assign avm_m0_read          = avs_s0_read;
	assign avm_m0_byteenable    = avs_s0_byteenable;

  //
  //address offset added to address
  //
	assign avm_m0_address       = avs_s0_address | (g_iavs0_address_offset >> g_eavm_address_shift);

endmodule
