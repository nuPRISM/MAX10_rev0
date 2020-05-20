/////////////////////////////////////////////////////////////////////
////                                                             ////
//// MCS51 to Wishbone Interface                                 ////
////                                                             ////
//// $Id: wb_mcs51.v,v 1.2 2008-03-10 13:58:10 hharte Exp $          ////
////                                                             ////
//// Copyright (C) 2007 Howard M. Harte                          ////
////                    hharte@opencores.org                     ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
`default_nettype none

module basic_bus_to_wishbone_bridge 
(
int_address, 
int_wr_data, 
int_write,
int_read, 
data_from_slave,

wbm_adr_o, 
wbm_dat_i, 
wbm_dat_o, 
wbm_sel_o, 
wbm_cyc_o,
wbm_stb_o, 
wbm_we_o, 
wbm_ack_i, 
wbm_rty_i, 
wbm_err_i
);

  parameter ADDRESS_WIDTH_IN_BITS = 32 ;
  parameter DATA_WIDTH_IN_BITS = 32;
  parameter SEL_WIDTH_IN_BITS = DATA_WIDTH_IN_BITS/8;

	
  input	[ADDRESS_WIDTH_IN_BITS-1:0]	int_address;	// address bus to register file 
  input	[DATA_WIDTH_IN_BITS-1:0]	int_wr_data;	// write data to register file 
  input			int_write;		// write control to register file 
  input			int_read;		// read control to register file 
  output	[DATA_WIDTH_IN_BITS-1:0]	data_from_slave;	// data read from register file 
	
	
   // WISHBONE master interface
   output [ADDRESS_WIDTH_IN_BITS-1:0]  wbm_adr_o;
   input  [DATA_WIDTH_IN_BITS-1:0]   wbm_dat_i;
   output [DATA_WIDTH_IN_BITS-1:0]   wbm_dat_o;
   output [SEL_WIDTH_IN_BITS-1:0]        wbm_sel_o;
   output         wbm_cyc_o;
   output         wbm_stb_o;
   output         wbm_we_o;
   input          wbm_ack_i;
   input          wbm_rty_i;
   input          wbm_err_i;

   
   assign wbm_adr_o = int_address;
   assign wbm_we_o  = int_write;
   assign wbm_stb_o = int_write | int_read;
   assign wbm_cyc_o = wbm_stb_o;
   assign data_from_slave = wbm_dat_i;

   assign wbm_dat_o = int_wr_data;

   assign wbm_sel_o = (2**SEL_WIDTH_IN_BITS)-1;
   
endmodule
`default_nettype wire
